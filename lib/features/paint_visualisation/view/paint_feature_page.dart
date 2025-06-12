import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'paint_dialog.dart'; // NEW custom paint dialog

class PaintPage extends StatefulWidget {
  const PaintPage({super.key});

  @override
  State<PaintPage> createState() => _PaintPageState();
}

class _PaintPageState extends State<PaintPage> {
  final exampleImages = [
    'assets/create/pv1.jpeg',
    'assets/create/pv2.jpeg',
    'assets/create/pv3.jpeg',
    'assets/create/pv4.jpeg',
  ];

  Color _selectedColor = Colors.white;

  void _showColorPicker() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select a color'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: _selectedColor,
                onColorChanged:
                    (color) => setState(() => _selectedColor = color),
                enableAlpha: false,
                displayThumbColor: true,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      _openPaintDialog(imageFile);
    }
  }

  Future<void> _selectExampleImage(String assetPath) async {
    final byteData = await DefaultAssetBundle.of(context).load(assetPath);
    final tempFile = File(
      '${(await getTemporaryDirectory()).path}/${assetPath.split('/').last}',
    );
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    _openPaintDialog(tempFile);
  }

  void _openPaintDialog(File imageFile) {
    showDialog(
      context: context,
      builder:
          (_) =>
              PaintDialog(imageFile: imageFile, selectedColor: _selectedColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top bar
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
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Paint',
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

            /// Hero
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/home_page/paint_visualisation.png',
                          fit: BoxFit.cover,
                        ),
                        Container(color: Colors.black.withOpacity(0.4)),
                      ],
                    ),
                  ),
                  const Positioned(
                    bottom: 72,
                    child: Text(
                      'Mark, recolor, and transform your\nspace effortlessly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _pickImageFromGallery,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Upload',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Pick Your Paint Color',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            /// Color Picker Display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: _showColorPicker,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Tap to pick a color',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Example Photos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            /// Example Images
            SizedBox(
              height: 110,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: exampleImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _selectExampleImage(exampleImages[index]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        exampleImages[index],
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
}
