import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interior_designer_jasper/core/providers/ai_pipeline_executor.dart';
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
  bool _isLoading = false;
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

  Future<void> _nextStep() async {
    final form = ref.read(createFormProvider);

    if (_currentStep == 0 && form.image == null) {
      _showError('Please select a photo to continue.');
      return;
    }
    if (_currentStep == 1 && form.room.trim().isEmpty) {
      _showError('Please select a room to continue.');
      return;
    }
    if (_currentStep == 2 && form.style.trim().isEmpty) {
      _showError('Please select a style to continue.');
      return;
    }
    if (_currentStep == 3 && form.palette.trim().isEmpty) {
      _showError('Please select a palette to continue.');
      return;
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      setState(() => _isLoading = true);
      final finalUrl = await ref.read(aiPipelineProvider(context)).execute();
      setState(() => _isLoading = false);

      if (finalUrl != null && mounted) {
        context.goNamed(RouterConstants.aiResult, extra: finalUrl);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
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
      body: Stack(
        children: [
          SafeArea(
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
                      if (_currentStep > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _prevStep,
                        )
                      else
                        const SizedBox(width: 48),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Step ${_currentStep + 1} of ${steps.length}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => context.goNamed(RouterConstants.home),
                      ),
                    ],
                  ),
                ),

                // Main Step Widget
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: steps[_currentStep],
                  ),
                ),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextStep,
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

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
