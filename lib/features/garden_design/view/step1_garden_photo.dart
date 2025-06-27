import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interior_designer_jasper/features/garden_design/view_model/garden_design_notifier.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class Step1GardenPhoto extends ConsumerStatefulWidget {
  final Function(File imageFile) onImageSelected;
  final void Function(String assetPath) onAssetSelected;

  const Step1GardenPhoto({
    super.key,
    required this.onImageSelected,
    required this.onAssetSelected,
  });

  @override
  ConsumerState<Step1GardenPhoto> createState() => _Step1GardenPhotoState();
}

class _Step1GardenPhotoState extends ConsumerState<Step1GardenPhoto> {
  File? _selectedImage;
  String? _selectedAssetPath;

  final picker = ImagePicker();

  final exampleImages = [
    'assets/create/gr1.jpeg',
    // 'assets/create/gr2.jpeg',
    'assets/create/gr3.jpeg',
    'assets/create/gr4.jpeg',
    'assets/create/gr5.jpeg',
  ];

  void _showImageSourceActionSheet() {
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
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      final file = File(picked.path);
      setState(() {
        _selectedImage = file;
        _selectedAssetPath = null;
      });
    }
  }

  void _selectExampleAsset(String assetPath) {
    setState(() {
      _selectedAssetPath = assetPath;
      _selectedImage = null;
    });
  }

  double _getAspectRatio() {
    if (_selectedAssetPath != null) return 1;
    if (_selectedImage != null) return 9 / 16;
    return 9 / 16;
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedImage != null || _selectedAssetPath != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.5;

    return SingleChildScrollView(
      child: Column(
        children: [
          // ✅ Header with centered step title, no PRO button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Row(
              children: [
                const Spacer(),
                const Text(
                  'Step 1 / 3',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.goNamed(RouterConstants.home),
                ),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: index == 0 ? Colors.black : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Add a Photo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Start Redesigning\nRedesign and beautify your garden',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: SizedBox(
              width: boxWidth,
              child: AspectRatio(
                aspectRatio: _getAspectRatio(),
                child: GestureDetector(
                  onTap: _showImageSourceActionSheet,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[200],
                    ),
                    child:
                        _selectedImage != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                            : _selectedAssetPath != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                _selectedAssetPath!,
                                fit: BoxFit.cover,
                                width: double.infinity,
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                  hasSelection
                      ? () {
                        final notifier = ref.read(
                          gardenDesignProvider.notifier,
                        );
                        if (_selectedImage != null) {
                          widget.onImageSelected(_selectedImage!);
                          notifier.setImage(_selectedImage!);
                        } else if (_selectedAssetPath != null) {
                          widget.onAssetSelected(_selectedAssetPath!);
                          notifier.setAsset(_selectedAssetPath!);
                        }
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
