import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/features/create/view/widgets/step1_photo_input.dart';
import 'package:interior_designer_jasper/features/create/view/widgets/step2_room_selection.dart';
import 'package:interior_designer_jasper/features/create/view/widgets/step3_style_selection.dart';
import 'package:interior_designer_jasper/features/create/view/widgets/step4_palette_selection.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  int _currentStep = 0;

  final List<Widget> _steps = [
    Step1PhotoInput(
      onPickPhoto: () {
        print("Photo picking...");
      },
    ),
    Step2RoomSelection(
      selectedRoom: '',
      onRoomSelected: (room) => print('Room selected: $room'),
    ),
    Step3StyleSelection(
      selectedStyle: '',
      onStyleSelected: (style) {
        print('Selected style: $style');
      },
    ),
    Step4PaletteSelection(
      selectedPalette: '',
      onPaletteSelected: (palette) {
        print('Selected palette: $palette');
      },
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _prevStep,
                    ),
                  const Spacer(),
                  Text(
                    'Step ${_currentStep + 1} / 4',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.goNamed(RouterConstants.home),
                  ),
                ],
              ),
            ),
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        color:
                            index <= _currentStep
                                ? Colors.black
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(child: _steps[_currentStep]),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _currentStep < _steps.length - 1 ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
