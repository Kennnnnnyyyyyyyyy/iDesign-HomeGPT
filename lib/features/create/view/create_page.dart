import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interior_designer_jasper/features/create/viewmodel/create_form_notifier.dart';
import 'package:interior_designer_jasper/features/create/view/widgets/step1_photo_input.dart';
import 'package:interior_designer_jasper/features/create/view/widgets/step2_room_selection.dart';
import 'package:interior_designer_jasper/features/create/view/widgets/step3_style_selection.dart';
import 'package:interior_designer_jasper/features/create/view/widgets/step4_palette_selection.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class CreatePage extends ConsumerStatefulWidget {
  const CreatePage({super.key});

  @override
  ConsumerState<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends ConsumerState<CreatePage> {
  int _currentStep = 0;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ref.read(createFormProvider.notifier).setImage(File(image.path));
    }
  }

  void _selectExampleImage(String assetPath) {
    ref.read(createFormProvider.notifier).setImage(assetPath);
  }

  void _nextStep() {
    final form = ref.read(createFormProvider);

    // Step 1: Validate photo selection
    if (_currentStep == 0 && form.image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo to continue.')),
      );
      return;
    }

    // Step 2: Validate room selection
    if (_currentStep == 1 && form.room.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a room to continue.')),
      );
      return;
    }

    // Step 3: Validate style selection
    if (_currentStep == 2 && form.style.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a style to continue.')),
      );
      return;
    }

    // Step 4: Validate palette selection
    if (_currentStep == 3 && form.palette.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a palette to continue.')),
      );
      return;
    }

    // Proceed or generate
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _generateDesign();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _generateDesign() async {
    final notifier = ref.read(createFormProvider.notifier);
    final form = ref.read(createFormProvider);

    if (form.image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a photo from gallery.')),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Uploading image...')));

    final imageUrl = await notifier.uploadImageToSupabase();
    if (imageUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image upload failed.')));
      return;
    }

    final prompt = notifier.getPrompt();

    print('--- READY TO CALL AI API ---');
    print('Prompt: $prompt');
    print('Image URL: $imageUrl');
    print('-----------------------------');
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(createFormProvider);

    final steps = [
      Step1PhotoInput(
        onPickPhoto: _pickImage,
        onExamplePhotoSelected: _selectExampleImage,
        selectedImageSource: form.image,
      ),
      Step2RoomSelection(
        selectedRoom: form.room,
        onRoomSelected:
            (room) => ref.read(createFormProvider.notifier).setRoom(room),
      ),
      Step3StyleSelection(
        selectedStyle: form.style,
        onStyleSelected:
            (style) => ref.read(createFormProvider.notifier).setStyle(style),
      ),
      Step4PaletteSelection(
        selectedPalette: form.palette,
        onPaletteSelected:
            (palette) =>
                ref.read(createFormProvider.notifier).setPalette(palette),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// Step Header AppBar-style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back button (only if not on step 0)
                  if (_currentStep > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _prevStep,
                    )
                  else
                    const SizedBox(width: 48), // To align with close button
                  // Step indicator
                  Expanded(
                    child: Center(
                      child: Text(
                        'Step ${_currentStep + 1} of ${steps.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.goNamed(RouterConstants.home),
                  ),
                ],
              ),
            ),

            /// Main Step Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: steps[_currentStep],
              ),
            ),

            /// Continue / Generate Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  _currentStep < steps.length - 1
                      ? 'Continue'
                      : 'Generate Design',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
