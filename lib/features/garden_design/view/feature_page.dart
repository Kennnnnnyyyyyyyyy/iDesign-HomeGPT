import 'package:flutter/material.dart';
import 'step1_garden_photo.dart';
import 'step2_garden_style.dart';
import 'step3_garden_palette.dart';

class GardenDesignPage extends StatefulWidget {
  const GardenDesignPage({super.key});

  @override
  State<GardenDesignPage> createState() => _GardenDesignPageState();
}

class _GardenDesignPageState extends State<GardenDesignPage> {
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 2) {
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
      Step1GardenPhoto(onContinue: _nextStep),
      Step2GardenStyle(onBack: _prevStep, onContinue: _nextStep),
      Step3GardenPalette(
        onBack: _prevStep,
        onContinue: () {
          // Handle final submission or next action
        },
      ),
    ];

    return Scaffold(body: SafeArea(child: steps[_currentStep]));
  }
}
