import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
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

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final croppedFile = await _cropImage(File(image.path));
      if (croppedFile != null) {
        ref.read(createFormProvider.notifier).setImage(croppedFile);
      }
    }
  }

  Future<File?> _cropImage(File file) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16),
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          lockAspectRatio: true,
          hideBottomControls: true,
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
        ),
        IOSUiSettings(aspectRatioLockEnabled: true, title: 'Crop Image'),
      ],
    );
    return croppedFile != null ? File(croppedFile.path) : null;
  }

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
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
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
        onPickPhoto: _showImageSourceActionSheet,
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight;
            final maxWidth = constraints.maxWidth;
            final portraitWidth = (maxHeight * 9 / 16).clamp(0, maxWidth);
            final portraitHeight = portraitWidth * 16 / 9;

            return Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: portraitWidth.toDouble(),
                    height: portraitHeight,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap:
                                    () => context.goNamed(
                                      RouterConstants.paywall,
                                    ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Text(
                                    'PRO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.black,
                                ),
                                onPressed:
                                    () => context.goNamed(RouterConstants.home),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: steps[_currentStep],
                          ),
                        ),
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
                ),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
