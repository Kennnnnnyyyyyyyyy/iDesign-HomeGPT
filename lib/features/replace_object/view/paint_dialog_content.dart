import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_painter/image_painter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:interior_designer_jasper/utils/replace_object_utils.dart';
import 'package:image/image.dart' as img;

class PaintDialogContent extends ConsumerStatefulWidget {
  final File imageFile;
  const PaintDialogContent({super.key, required this.imageFile});

  @override
  ConsumerState<PaintDialogContent> createState() => _PaintDialogContentState();
}

class _PaintDialogContentState extends ConsumerState<PaintDialogContent> {
  late ImagePainterController _controller;
  final TextEditingController _promptController = TextEditingController();
  bool _isPromptFilled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = ImagePainterController(
      strokeWidth: 70,
      mode: PaintMode.freeStyle,
      fill: false,
    );

    // Force a fixed translucent color (e.g. red with 40% opacity)
    _controller.setColor(const Color.fromRGBO(255, 0, 0, 0.4));

    _promptController.addListener(() {
      setState(() {
        _isPromptFilled = _promptController.text.trim().isNotEmpty;
      });
    });
  }

  Future<String> _saveMask() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      throw Exception('Prompt cannot be empty');
    }

    setState(() => _isLoading = true);
    try {
      final exportedBytes = await _controller.exportImage();
      if (exportedBytes == null) {
        throw Exception('❌ Failed to export painted mask');
      }

      final decodedMask = img.decodeImage(exportedBytes);
      if (decodedMask == null) {
        throw Exception('❌ Failed to decode exported mask');
      }

      final originalBytes = await widget.imageFile.readAsBytes();
      final originalImage = img.decodeImage(originalBytes);
      if (originalImage == null) {
        throw Exception('❌ Failed to decode original image');
      }

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
      final maskFile = File('${dir.path}/mask.png')
        ..writeAsBytesSync(encodedPng);

      final generatedImageUrl = await processRetouchImage(
        originalImage: widget.imageFile,
        maskImage: maskFile,
        prompt: prompt,
        context: context,
        ref: ref,
      );

      return generatedImageUrl;
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Failed: $e')));
      rethrow;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text("Paint Over Object"),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color:
                        _isPromptFilled && !_isLoading
                            ? Colors.green
                            : Colors.green.withAlpha(102),
                  ),
                  onPressed: _isPromptFilled && !_isLoading ? _saveMask : null,
                  tooltip:
                      _isPromptFilled ? 'Submit' : 'Enter prompt to enable',
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _promptController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Replace object with...',
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.edit, color: Colors.white70),
                  border: InputBorder.none,
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: ImagePainter.file(
                widget.imageFile,
                controller: _controller,
                scalable: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.cancel, color: Colors.redAccent),
                label: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ],
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withAlpha(153),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }
}
