import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/core/providers/ai_design_generator_provider.dart';
import 'package:interior_designer_jasper/features/exterior_design/view/step1_exterior_photo.dart';
import 'package:interior_designer_jasper/features/exterior_design/view/step2_exterior_photo.dart';
import 'package:interior_designer_jasper/features/exterior_design/view/step3_exterior_photo.dart';
import 'package:interior_designer_jasper/features/exterior_design/view/step4_exterior_palette.dart';
import 'package:interior_designer_jasper/features/exterior_design/view_model/exterior_design_vm.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class ExteriorDesignPage extends ConsumerStatefulWidget {
  const ExteriorDesignPage({super.key});

  @override
  ConsumerState<ExteriorDesignPage> createState() => _ExteriorDesignPageState();
}

class _ExteriorDesignPageState extends ConsumerState<ExteriorDesignPage> {
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
      Step1ExteriorPhoto(onContinue: _nextStep, onClose: _exitFlow),
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
        onSubmit: () async {
          print('🛠️ onSubmit called — starting exterior design generation...');

          final generator = ref.read(aiDesignGeneratorProvider(context));
          print('✅ AiDesignGenerator initialized.');

          final outputUrl = await generator.generateFromExteriorForm();

          if (outputUrl != null && context.mounted) {
            context.goNamed(RouterConstants.aiResult, extra: outputUrl);
          } else {
            print('❌ Design generation failed or returned null.');
          }
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: steps[_currentStep]),
    );
  }
}
