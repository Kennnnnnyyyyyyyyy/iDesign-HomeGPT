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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() {
      _selectedImageFile = File(picked.path);
      _selectedAssetPath = null; // Clear asset selection if a file is picked
    });
  }

  void _selectExampleAsset(String assetPath) {
    setState(() {
      _selectedImageFile = null;
      _selectedAssetPath = assetPath;
    });
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
        // Load asset as bytes, write to temp file
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

      // Set in ViewModel
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
      'assets/create/br1.jpeg',
      'assets/create/br2.jpeg',
      'assets/create/br3.jpeg',
      'assets/create/br4.jpeg',
    ];

    final hasSelection =
        _selectedImageFile != null || _selectedAssetPath != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
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

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Builder(
              builder: (_) {
                if (_selectedImageFile != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _selectedImageFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                } else if (_selectedAssetPath != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      _selectedAssetPath!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                } else {
                  return ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickImage,
                    icon: const Icon(Icons.add),
                    label: const Text('Add a Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  );
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 24),

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
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: exampleImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final assetPath = exampleImages[index];
              return GestureDetector(
                onTap: () => _selectExampleAsset(assetPath),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    assetPath,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        const Spacer(),

        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed:
                hasSelection && !_isUploading
                    ? _uploadSelectedImageAndContinue
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child:
                _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Continue', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }
}
