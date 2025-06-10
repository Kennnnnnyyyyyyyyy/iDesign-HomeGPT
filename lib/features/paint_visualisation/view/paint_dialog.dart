import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';

class PaintDialog extends StatefulWidget {
  final File imageFile;
  final Color selectedColor;

  const PaintDialog({
    super.key,
    required this.imageFile,
    required this.selectedColor,
  });

  @override
  State<PaintDialog> createState() => _PaintDialogState();
}

class _PaintDialogState extends State<PaintDialog> {
  late ImagePainterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ImagePainterController(
      strokeWidth: 20,
      color: widget.selectedColor.withValues(),
      mode: PaintMode.freeStyle,
    );
  }

  Future<void> _onDone() async {
    final imageBytes = await _controller.exportImage();
    if (imageBytes != null) {
      Navigator.pop(context); // Close dialog
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to export painted image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(8),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("Paint on Image"),
            actions: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: _onDone,
              ),
            ],
          ),
          Expanded(
            child: ImagePainter.file(widget.imageFile, controller: _controller),
          ),

          // ✅ Bottom Close Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.cancel, color: Colors.redAccent),
              label: const Text(
                'Close',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
