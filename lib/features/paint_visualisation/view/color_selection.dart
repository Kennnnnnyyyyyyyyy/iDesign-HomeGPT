import 'dart:io';
import 'package:flutter/material.dart';
import 'package:interior_designer_jasper/features/paint_visualisation/view/paint_dialog.dart';

class ColorSelectionPage extends StatefulWidget {
  final File imageFile;

  const ColorSelectionPage({super.key, required this.imageFile});

  @override
  State<ColorSelectionPage> createState() => _ColorSelectionPageState();
}

class _ColorSelectionPageState extends State<ColorSelectionPage> {
  double _hue = 0;
  double _saturation = 1;
  double _lightness = 0.5;

  Color get selectedColor =>
      HSLColor.fromAHSL(1.0, _hue, _saturation, _lightness).toColor();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Wall Color"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Color Preview
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: selectedColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 3),
            ),
          ),
          const SizedBox(height: 24),

          // Hue slider
          const Text("Hue", style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _hue,
            min: 0,
            max: 360,
            onChanged: (value) => setState(() => _hue = value),
            activeColor: Colors.redAccent,
          ),

          // Saturation slider
          const Text(
            "Saturation",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _saturation,
            min: 0,
            max: 1,
            onChanged: (value) => setState(() => _saturation = value),
            activeColor: Colors.redAccent,
          ),

          // Lightness slider
          const Text(
            "Lightness",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _lightness,
            min: 0,
            max: 1,
            onChanged: (value) => setState(() => _lightness = value),
            activeColor: Colors.redAccent,
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => PaintDialogContent(imageFile: widget.imageFile),
                );
              },
              child: const Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }
}
