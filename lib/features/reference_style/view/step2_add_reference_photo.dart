import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interior_designer_jasper/features/reference_style/view_model/reference_style_notifier.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class Step2AddReferencePhoto extends ConsumerStatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const Step2AddReferencePhoto({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  ConsumerState<Step2AddReferencePhoto> createState() =>
      _Step2AddReferencePhotoState();
}

class _Step2AddReferencePhotoState
    extends ConsumerState<Step2AddReferencePhoto> {
  File? _selectedImageFile;
  String? _selectedAssetPath;
  bool _isUploading = false;
  bool _hasNavigated = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
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
        fileName = 'style_${DateTime.now().millisecondsSinceEpoch}.jpg';
      } else {
        final byteData = await rootBundle.load(_selectedAssetPath!);
        final tempDir = Directory.systemTemp;
        fileToUpload = File(
          '${tempDir.path}/style_example_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await fileToUpload.writeAsBytes(byteData.buffer.asUint8List());
        fileName = 'style_example_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
          .setStylePhotoUrl(publicUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Reference photo uploaded')),
      );
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
    final state = ref.watch(referenceStyleNotifierProvider);
    final hasSelection =
        _selectedImageFile != null || _selectedAssetPath != null;
    final exampleImages = [
      'assets/create/cj1.jpeg',
      'assets/create/cj2.jpeg',
      'assets/create/cj3.jpeg',
      'assets/create/cj4.jpeg',
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.5;

    ref.listen<AsyncValue<String?>>(referenceStyleNotifierProvider, (
      prev,
      next,
    ) {
      next.whenOrNull(
        data: (url) {
          if (!_hasNavigated && url != null && mounted) {
            _hasNavigated = true;
            context.goNamed(RouterConstants.aiResult, extra: url);
          }
        },
      );
    });

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: widget.onBack,
                    ),
                    const Spacer(),
                    const Text(
                      'Reference Style (2 / 2)',
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
                  'Add a Reference Photo',
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
                      onTap: _pickImage,
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
                                      onPressed: _pickImage,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Add Reference',
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
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset(assetPath, fit: BoxFit.cover),
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
        ),

        if (state is AsyncLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
