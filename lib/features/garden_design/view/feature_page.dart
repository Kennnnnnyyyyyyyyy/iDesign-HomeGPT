import 'dart:io';
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
  File? _selectedImage;
  String? _selectedAssetPath;

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _onImageSelected(File imageFile) {
    setState(() {
      _selectedImage = imageFile;
      _selectedAssetPath = null;
      _currentStep++;
    });
  }

  void _onAssetSelected(String assetPath) {
    setState(() {
      _selectedAssetPath = assetPath;
      _selectedImage = null;
      _currentStep++;
    });
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      Step1GardenPhoto(
        onImageSelected: _onImageSelected,
        onAssetSelected: _onAssetSelected,
      ),
      Step2GardenStyle(onBack: _prevStep, onContinue: _nextStep),
      Step3GardenPalette(onBack: _prevStep),
    ];

    return Scaffold(body: SafeArea(child: steps[_currentStep]));
  }
}
