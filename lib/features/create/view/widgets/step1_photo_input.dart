import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/features/create/viewmodel/create_form_notifier.dart';

class Step1PhotoInput extends ConsumerWidget {
  final VoidCallback onPickPhoto;
  final Function(String assetPath) onExamplePhotoSelected;
  final dynamic selectedImageSource;

  const Step1PhotoInput({
    super.key,
    required this.onPickPhoto,
    required this.onExamplePhotoSelected,
    required this.selectedImageSource,
  });

  double _getAspectRatio() {
    if (selectedImageSource is String &&
        selectedImageSource.startsWith('assets/')) {
      return 1;
    } else if (selectedImageSource is File) {
      return 9 / 16;
    }
    return 9 / 16;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exampleImages = [
      'assets/create/ro1.jpeg',
      'assets/create/ro2.jpeg',
      'assets/create/ro3.jpeg',
    ];

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: AspectRatio(
                aspectRatio: _getAspectRatio(),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: onPickPhoto,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildImageView(),
                      ),
                    ),
                    if (selectedImageSource != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () {
                            ref.read(createFormProvider.notifier).reset();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ✅ Always show example photos below
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Example Photos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: exampleImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final assetPath = exampleImages[index];
                  return GestureDetector(
                    onTap: () => onExamplePhotoSelected(assetPath),
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
          ],
        ),
      ),
    );
  }

  Widget _buildImageView() {
    if (selectedImageSource == null) {
      return const Center(
        child: Icon(Icons.add_a_photo, size: 40, color: Colors.black54),
      );
    } else if (selectedImageSource is File) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          selectedImageSource,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else if (selectedImageSource is String &&
        selectedImageSource.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          selectedImageSource,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
