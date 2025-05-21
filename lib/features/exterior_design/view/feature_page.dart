import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/features/exterior_design/view/step1_exterior_photo.dart';

import 'package:interior_designer_jasper/features/exterior_design/view/step2_exterior_photo.dart';
import 'package:interior_designer_jasper/features/exterior_design/view/step3_exterior_photo.dart';
import 'package:interior_designer_jasper/features/exterior_design/view/step4_exterior_palette.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class ExteriorDesignPage extends StatefulWidget {
  const ExteriorDesignPage({super.key});

  @override
  State<ExteriorDesignPage> createState() => _ExteriorDesignPageState();
}

class _ExteriorDesignPageState extends State<ExteriorDesignPage> {
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _exitFlow() {
    context.goNamed(RouterConstants.home);
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      Step1ExteriorPhoto(onContinue: _nextStep, onClose: () => _exitFlow),
      Step2ExteriorBuildingType(
        onContinue: _nextStep,
        onBack: _prevStep,
        onClose: _exitFlow,
      ),
      Step3ExteriorStyle(
        onContinue: _nextStep,
        onBack: _prevStep,
        onClose: _exitFlow,
      ),
      Step4ExteriorPalette(
        onBack: _prevStep,
        onClose: _exitFlow,
        onSubmit: () {
          // Submit final data or trigger API call here
          Navigator.pop(context);
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: steps[_currentStep]),
    );
  }
}
