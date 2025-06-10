import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_painter/image_painter.dart';
import 'package:interior_designer_jasper/features/paint_visualisation/view_model.dart/ai_paint_generator.dart';
import 'package:interior_designer_jasper/features/replace_object/view_model/replace_object_viewmodel.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class PaintDialog extends ConsumerStatefulWidget {
  final File imageFile;
  final Color selectedColor;

  const PaintDialog({
    super.key,
    required this.imageFile,
    required this.selectedColor,
  });

  @override
  ConsumerState<PaintDialog> createState() => _PaintDialogState();
}

class _PaintDialogState extends ConsumerState<PaintDialog> {
  late ImagePainterController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = ImagePainterController(
      strokeWidth: 30,
      color: widget.selectedColor.withValues(),
      mode: PaintMode.freeStyle,
    );
  }

  Future<void> _onDone() async {
    setState(() => _isLoading = true);

    try {
      // 1. Export user-painted mask as image bytes
      final bytes = await _controller.exportImage();
      if (bytes == null) throw Exception('Failed to export mask image');

      final decodedMask = img.decodeImage(bytes);
      if (decodedMask == null) throw Exception('Failed to decode mask image');

      final originalBytes = await widget.imageFile.readAsBytes();
      final originalImage = img.decodeImage(originalBytes);
      if (originalImage == null)
        throw Exception('Failed to decode original image');

      // 2. Resize mask to original image size
      final resizedMask = img.copyResize(
        decodedMask,
        width: originalImage.width,
        height: originalImage.height,
      );

      final rgbMask = img.Image.fromBytes(
        width: resizedMask.width,
        height: resizedMask.height,
        bytes: resizedMask.getBytes(order: img.ChannelOrder.rgb).buffer,
      );

      final encodedPng = img.encodePng(rgbMask);
      final dir = await getTemporaryDirectory();
      final maskFile = File('${dir.path}/paint_mask.png')
        ..writeAsBytesSync(encodedPng);

      // 3. Use AI Paint Generator
      final aiPaint = ref.read(aiPaintGeneratorProvider(context));
      final resultUrl = await aiPaint.repaintFromMask(
        maskImage: maskFile,
        originalImage: widget.imageFile,
      );

      // 4. Navigate to result page if success
      if (resultUrl != null && mounted) {
        if (context.mounted) {
          context.goNamed(RouterConstants.aiResult, extra: resultUrl);
        }
      }
    } catch (e) {
      print('❌ PaintDialog Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text("Paint on Image"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: _isLoading ? null : _onDone,
                  ),
                ],
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
