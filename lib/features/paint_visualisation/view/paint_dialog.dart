import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_painter/image_painter.dart';
import 'package:interior_designer_jasper/features/paint_visualisation/view_model.dart/ai_paint_generator.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';
import 'package:path_provider/path_provider.dart';

class PaintDialogContent extends ConsumerStatefulWidget {
  final File imageFile;
  const PaintDialogContent({super.key, required this.imageFile});

  @override
  ConsumerState<PaintDialogContent> createState() => _PaintDialogState();
}

class _PaintDialogState extends ConsumerState<PaintDialogContent> {
  late ImagePainterController _controller;
  Color selectedColor = Colors.redAccent;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = ImagePainterController(
      strokeWidth: 50,
      color: selectedColor.withOpacity(0.4),
      mode: PaintMode.freeStyle,
    );
  }

  void _openColorPicker() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Choose Mask Color'),
            content: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                  _controller.setColor(color.withOpacity(0.4));
                });
              },
              enableAlpha: false,
              displayThumbColor: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  Future<void> _onSubmit() async {
    setState(() => _isProcessing = true);
    try {
      // Export mask from painter
      final exportedBytes = await _controller.exportImage();
      if (exportedBytes == null) throw Exception('Mask export failed');

      final decodedMask = img.decodeImage(exportedBytes);
      if (decodedMask == null) throw Exception('Failed to decode mask image');

      // Resize original image for consistency
      final originalBytes = await widget.imageFile.readAsBytes();
      final originalImage = img.decodeImage(originalBytes);
      if (originalImage == null)
        throw Exception('Failed to decode original image');

      // Resize both to 1024 width to avoid payload size issue
      const targetWidth = 1024;
      final resizedMask = img.copyResize(decodedMask, width: targetWidth);
      final resizedOriginal = img.copyResize(originalImage, width: targetWidth);

      final rgbMask = img.Image.fromBytes(
        width: resizedMask.width,
        height: resizedMask.height,
        bytes: resizedMask.getBytes(order: img.ChannelOrder.rgb).buffer,
      );

      // Save resized mask file
      final encodedPng = img.encodePng(rgbMask);
      final dir = await getTemporaryDirectory();
      final maskFile = File('${dir.path}/mask_resized.png')
        ..writeAsBytesSync(encodedPng);

      // Save resized original as well (for better AI stability)
      final originalJpg = img.encodeJpg(resizedOriginal, quality: 90);
      final resizedOriginalFile = File('${dir.path}/original_resized.jpg')
        ..writeAsBytesSync(originalJpg);

      // 🔥 Call AI Pipeline
      final aiPaint = ref.read(aiPaintGeneratorProvider(context));
      final resultUrl = await aiPaint.repaintFromMask(
        maskImage: maskFile,
        originalImage: resizedOriginalFile,
      );

      if (resultUrl != null && mounted) {
        // Navigate to AI Result Page
        context.pushNamed(RouterConstants.aiResult, extra: resultUrl);
      }
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.black,
                title: const Text("Paint Area"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.color_lens),
                    onPressed: _openColorPicker,
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: _onSubmit,
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                color: Colors.orange.shade100,
                child: const Text(
                  "🖌️ Mark area to recolor.\n🎯 Use color picker for mask color.",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ImagePainter.file(
                  widget.imageFile,
                  controller: _controller,
                ),
              ),
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
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }
}
