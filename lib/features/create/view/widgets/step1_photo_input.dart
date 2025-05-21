import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart'; // 👈 Import this

class Step1PhotoInput extends StatelessWidget {
  final VoidCallback onPickPhoto;

  const Step1PhotoInput({super.key, required this.onPickPhoto});

  @override
  Widget build(BuildContext context) {
    final exampleImages = [
      'assets/create/br1.jpeg',
      'assets/create/br2.jpeg',
      'assets/create/br3.jpeg',
      'assets/create/br4.jpeg',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add a Photo',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // ⬇️ REPLACED THIS BLOCK
        DottedBorder(
          options: const RectDottedBorderOptions(
            dashPattern: [6, 3],
            strokeWidth: 1,
            padding: EdgeInsets.all(0),
          ),
          child: Container(
            height: 220,
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
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  exampleImages[index],
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
