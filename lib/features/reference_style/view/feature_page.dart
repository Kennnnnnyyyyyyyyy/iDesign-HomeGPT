import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/features/reference_style/view_model/reference_style_notifier.dart';
import 'step1_add_room_photo.dart';
import 'step2_add_reference_photo.dart';

class ReferenceStylePage extends ConsumerStatefulWidget {
  const ReferenceStylePage({super.key});

  @override
  ConsumerState<ReferenceStylePage> createState() => _ReferenceStylePageState();
}

class _ReferenceStylePageState extends ConsumerState<ReferenceStylePage> {
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

  Future<void> _submitStyleTransfer() async {
    final notifier = ref.read(referenceStyleNotifierProvider.notifier);
    await notifier.submitReferenceStyle();

    final result = ref.read(referenceStyleNotifierProvider);
    result.whenOrNull(
      error:
          (e, _) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      Step1AddRoomPhoto(onContinue: _nextStep),
      Step2AddReferencePhoto(
        onBack: _prevStep,
        onContinue: _submitStyleTransfer,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
