import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AiResultPage extends StatelessWidget {
  final String imageUrl;

  const AiResultPage({super.key, required this.imageUrl});

  Future<void> _downloadImage(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/downloaded_ai_design.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(response.bodyBytes);

      // Save to gallery
      await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.bodyBytes),
        quality: 100,
        name: "ai_design_${DateTime.now().millisecondsSinceEpoch}",
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Image saved to gallery')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Failed to download image: $e')));
    }
  }

  Future<void> _shareImage() async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/share_ai_design.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(response.bodyBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(imageFile.path)],
          text: 'Check out my AI generated room design!',
        ),
      );
    } catch (e) {
      print('❌ Share failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your AI Design"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: "Close",
          onPressed: () {
            context.goNamed(RouterConstants.home);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Download",
            onPressed: () => _downloadImage(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: "Share",
            onPressed: _shareImage,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator();
            },
            errorBuilder:
                (context, error, stackTrace) =>
                    const Text("❌ Failed to load image."),
          ),
        ),
      ),
    );
  }
}
