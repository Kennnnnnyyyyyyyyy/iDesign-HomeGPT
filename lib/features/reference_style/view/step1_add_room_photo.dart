import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interior_designer_jasper/features/reference_style/view_model/reference_style_notifier.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class Step1AddRoomPhoto extends ConsumerStatefulWidget {
  final VoidCallback onContinue;

  const Step1AddRoomPhoto({super.key, required this.onContinue});

  @override
  ConsumerState<Step1AddRoomPhoto> createState() => _Step1AddRoomPhotoState();
}

class _Step1AddRoomPhotoState extends ConsumerState<Step1AddRoomPhoto> {
  File? _selectedImageFile;
  String? _selectedAssetPath;
  bool _isUploading = false;

  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked == null) return;

    setState(() {
      _selectedImageFile = File(picked.path);
      _selectedAssetPath = null;
    });
  }

  void _selectExampleAsset(String assetPath) {
    setState(() {
      _selectedImageFile = null;
      _selectedAssetPath = assetPath;
    });
  }

  double _getAspectRatio() {
    if (_selectedAssetPath != null) return 1;
    if (_selectedImageFile != null) return 9 / 16;
    return 9 / 16;
  }

  Future<void> _uploadSelectedImageAndContinue() async {
    if (_selectedImageFile == null && _selectedAssetPath == null) return;

    setState(() => _isUploading = true);

    try {
      final supabase = Supabase.instance.client;
      final storageRef = supabase.storage.from('temp-image');

      late File fileToUpload;
      late String fileName;

      if (_selectedImageFile != null) {
        fileToUpload = _selectedImageFile!;
        fileName = 'room_${DateTime.now().millisecondsSinceEpoch}.jpg';
      } else {
        final byteData = await rootBundle.load(_selectedAssetPath!);
        final tempDir = Directory.systemTemp;
        fileToUpload = File(
          '${tempDir.path}/room_example_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await fileToUpload.writeAsBytes(byteData.buffer.asUint8List());
        fileName = 'room_example_${DateTime.now().millisecondsSinceEpoch}.jpg';
      }

      final filePath = 'uploads/$fileName';
      await storageRef.upload(
        filePath,
        fileToUpload,
        fileOptions: const FileOptions(upsert: true),
      );
      final publicUrl = storageRef.getPublicUrl(filePath);

      ref
          .read(referenceStyleNotifierProvider.notifier)
          .setRoomPhotoUrl(publicUrl);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Room photo uploaded')));
      widget.onContinue();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Upload failed: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exampleImages = [
      'assets/create/ro1.jpeg',
      'assets/create/ro2.jpeg',
      'assets/create/ro3.jpeg',
      'assets/create/ro4.jpeg',
    ];

    final hasSelection =
        _selectedImageFile != null || _selectedAssetPath != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.5;

    return SingleChildScrollView(
      child: Column(
        children: [
          // ✅ Header without PRO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Spacer(),
                const Text(
                  'Reference Style (1 / 2)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.goNamed(RouterConstants.home),
                ),
              ],
            ),
          ),
          const Divider(thickness: 2),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Add a Photo of Your Room',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),

          // Upload Box
          Center(
            child: SizedBox(
              width: boxWidth,
              child: AspectRatio(
                aspectRatio: _getAspectRatio(),
                child: GestureDetector(
                  onTap: _showImageSourceActionSheet,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child:
                        _selectedImageFile != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                            : _selectedAssetPath != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                _selectedAssetPath!,
                                fit: BoxFit.cover,
                              ),
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.black54,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _showImageSourceActionSheet,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Add a Photo',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Example Photos',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 100,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: exampleImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final asset = exampleImages[index];
                return GestureDetector(
                  onTap: () => _selectExampleAsset(asset),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(asset, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed:
                  hasSelection && !_isUploading
                      ? _uploadSelectedImageAndContinue
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child:
                  _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Continue',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
