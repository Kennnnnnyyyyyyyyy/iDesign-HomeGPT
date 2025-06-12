import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

class Step1PhotoInput extends StatelessWidget {
  final VoidCallback onPickPhoto;
  final void Function(String assetPath) onExamplePhotoSelected;
  final Object? selectedImageSource;

  const Step1PhotoInput({
    super.key,
    required this.onPickPhoto,
    required this.onExamplePhotoSelected,
    required this.selectedImageSource,
  });

  @override
  Widget build(BuildContext context) {
    final exampleImages = [
      'assets/create/cj2.jpeg',
      'assets/create/cj1.jpeg',
      'assets/create/cj4.jpeg',
      'assets/create/cj3.jpeg',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add a Photo',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        if (selectedImageSource != null)
          GestureDetector(
            onTap: onPickPhoto, // tap to change image
            child: Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.hardEdge,
              child:
                  selectedImageSource is File
                      ? Image.file(
                        selectedImageSource as File,
                        fit: BoxFit.cover,
                      )
                      : Image.asset(
                        selectedImageSource as String,
                        fit: BoxFit.cover,
                      ),
            ),
          ),

        if (selectedImageSource == null)
          DottedBorder(
            options: const RectDottedBorderOptions(
              dashPattern: [6, 3],
              strokeWidth: 1,
              padding: EdgeInsets.all(0),
            ),
            child: Container(
              height: 180,
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Start Redesigning',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Redesign and beautify your home',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onPickPhoto,
                    icon: const Icon(Icons.add),
                    label: const Text('Add a Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 24),
        const Text(
          'Example Photos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: exampleImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final path = exampleImages[index];
              return GestureDetector(
                onTap: () => onExamplePhotoSelected(path),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    path,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
