import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'step1_add_room_photo.dart';
import 'step2_add_reference_photo.dart';

class ReferenceStylePage extends StatefulWidget {
  const ReferenceStylePage({super.key});

  @override
  State<ReferenceStylePage> createState() => _ReferenceStylePageState();
}

class _ReferenceStylePageState extends State<ReferenceStylePage> {
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      Step1AddRoomPhoto(onContinue: _nextStep),
      Step2AddReferencePhoto(
        onBack: _prevStep,
        onContinue: () {
          // TODO: Handle final submission / generation
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _prevStep,
                    )
                  else
                    const SizedBox(width: 48), // Reserve space

                  const Spacer(),
                  Text(
                    'Reference Style (${_currentStep + 1} / 2)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      context.goNamed('home'); // ⬅️ Adjust if named differently
                    },
                  ),
                ],
              ),
            ),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Row(
                children: List.generate(2, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 1 ? 8 : 0),
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

            Expanded(child: steps[_currentStep]),
          ],
        ),
      ),
    );
  }
}
