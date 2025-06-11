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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
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

  @override
  Widget build(BuildContext context) {
    final exampleImages = [
      'assets/create/gr1.jpeg',
      'assets/create/gr2.jpeg',
      'assets/create/gr3.jpeg',
      'assets/create/gr4.jpeg',
      'assets/create/gr5.jpeg',
    ];

    final hasSelection = _selectedImage != null || _selectedAssetPath != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            children: [
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
          ),
        ),
        const SizedBox(height: 16),

        // Upload area or selected example
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: _pickImage,
            child:
                _selectedImage != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    )
                    : _selectedAssetPath != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        _selectedAssetPath!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    )
                    : Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, size: 30, color: Colors.black),
                          SizedBox(height: 8),
                          Text(
                            'Add a Photo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        ),

        const SizedBox(height: 24),

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
                  child: Image.asset(
                    asset,
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
                hasSelection
                    ? () {
                      final notifier = ref.read(gardenDesignProvider.notifier);

                      if (_selectedImage != null) {
                        widget.onImageSelected(_selectedImage!);
                        notifier.setImage(
                          _selectedImage!,
                        ); // ✅ store to provider
                      } else if (_selectedAssetPath != null) {
                        widget.onAssetSelected(_selectedAssetPath!);
                        notifier.setAsset(
                          _selectedAssetPath!,
                        ); // ✅ store to provider
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
            child: const Text('Continue', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
