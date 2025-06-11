import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interior_designer_jasper/features/exterior_design/providers/exterior_providers.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class Step1ExteriorPhoto extends ConsumerStatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback? onClose;

  const Step1ExteriorPhoto({super.key, required this.onContinue, this.onClose});

  @override
  ConsumerState<Step1ExteriorPhoto> createState() => _Step1ExteriorPhotoState();
}

class _Step1ExteriorPhotoState extends ConsumerState<Step1ExteriorPhoto> {
  File? _selectedImage;
  final picker = ImagePicker();

  final exampleImages = [
    'assets/create/ext1.jpeg',
    'assets/create/ext2.jpeg',
    'assets/create/ext3.jpeg',
    'assets/create/ext4.jpeg',
  ];

  Future<void> _pickFromGallery() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      setState(() => _selectedImage = file);
      ref.read(selectedExteriorImageProvider.notifier).state = file;
    }
  }

  Future<void> _selectExample(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${assetPath.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    setState(() => _selectedImage = file);
    ref.read(selectedExteriorImageProvider.notifier).state = file;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            children: [
              const Spacer(),
              const Text(
                'Step 1 / 4',
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

        // Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
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

        // Title
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
            'Start Redesigning\nRedesign and beautify your home',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 20),

        // Upload Preview Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: _pickFromGallery,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child:
                    _selectedImage != null
                        ? Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                        : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Start Redesigning',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Redesign and beautify your home',
                                style: TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _pickFromGallery,
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

        // Example Photos
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
              return GestureDetector(
                onTap: () => _selectExample(exampleImages[index]),
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

        const Spacer(),

        // Continue Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selectedImage != null ? widget.onContinue : null,
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
