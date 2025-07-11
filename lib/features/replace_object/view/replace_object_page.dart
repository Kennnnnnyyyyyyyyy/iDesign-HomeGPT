import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';
import 'package:interior_designer_jasper/features/replace_object/view/paint_dialog_content.dart';

class ReplaceObjectPage extends StatelessWidget {
  const ReplaceObjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final exampleImages = [
      'assets/create/ro1.jpeg',
      'assets/create/ro2.jpeg',
      'assets/create/ro3.jpeg',
      'assets/create/ro4.jpeg',
      'assets/create/ro5.jpeg',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            _buildHeroSection(context),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Example Photos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            _buildExampleImages(context, exampleImages),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        const Spacer(),
        const Text(
          'Replace Objects',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.goNamed(RouterConstants.home),
        ),
      ],
    ),
  );

  Widget _buildHeroSection(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
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
                'assets/home_page/replace_object.png',
                fit: BoxFit.cover,
              ),
              Container(color: Colors.black.withOpacity(0.4)),
            ],
          ),
        ),
        Positioned(
          top: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              '✨ Put a cabinet instead of a tree!',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const Positioned(
          bottom: 72,
          child: Column(
            children: [
              Text(
                'Retouch',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Mark, retouch, and reimagine your space with AI.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () => _showImageSourceActionSheet(context),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Upload', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    ),
  );

  Widget _buildExampleImages(BuildContext context, List<String> images) =>
      SizedBox(
        height: 110,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder:
              (context, index) => GestureDetector(
                onTap: () async {
                  final byteData = await DefaultAssetBundle.of(
                    context,
                  ).load(images[index]);
                  final bytes = byteData.buffer.asUint8List();
                  final tempDir = await Directory.systemTemp.createTemp();
                  final tempFile = File('${tempDir.path}/example_$index.jpg');
                  await tempFile.writeAsBytes(bytes);
                  await _showTutorial(context, tempFile);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    images[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
        ),
      );

  void _showImageSourceActionSheet(BuildContext context) {
    final parentContext = context;
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
                    await _pickImage(parentContext, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _pickImage(parentContext, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      final imageFile = File(picked.path);
      await _showTutorial(context, imageFile);
    }
  }

  Future<void> _showTutorial(BuildContext context, File imageFile) async {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("How to Use Retouch"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text("1️⃣ Mark objects you want to replace."),
                SizedBox(height: 8),
                Text("2️⃣ Use brush & eraser tools."),
                SizedBox(height: 8),
                Text("3️⃣ Generate your retouched room."),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openPaintDialog(context, imageFile);
                },
                child: const Text("Got it!"),
              ),
            ],
          ),
    );
  }

  void _openPaintDialog(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            insetPadding: const EdgeInsets.all(8),
            backgroundColor: Colors.black,
            child: PaintDialogContent(imageFile: imageFile),
          ),
    );
  }
}
