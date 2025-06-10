import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/core/providers/ai_image_generator.dart';
import 'package:interior_designer_jasper/core/providers/replicate_image_uploader.dart';
import 'package:interior_designer_jasper/core/providers/replicate_output_parser.dart';
import 'package:interior_designer_jasper/core/providers/supabase_design_uploader.dart';
import 'package:interior_designer_jasper/core/utils/supabase_image_uploader.dart';

class AiPaintGenerator {
  final Ref ref;
  final BuildContext context;

  AiPaintGenerator(this.ref, this.context);

  Future<String?> repaintFromMask({
    required File maskImage,
    required File originalImage,
  }) async {
    try {
      // Step 1: Upload mask
      _showSnackBar('🎨 Uploading painted mask...');
      final uploadResult = await SupabaseImageUploader.upload(image: maskImage);
      if (uploadResult == null) {
        _showSnackBar('❌ Failed to upload mask.');
        return null;
      }

      final maskUrl = uploadResult['publicUrl']!;
      final filePath = uploadResult['filePath']!;

      // Step 2: Smart prompt
      const smartPrompt =
          "Repaint the object painted by the user using the exact same color. ";

      // Step 3: Send to AI
      _showSnackBar('🧠 Sending to AI for recolor...');
      final response = await ref
          .read(aiPromptSenderProvider.notifier)
          .send(filePath: filePath, imageUrl: maskUrl, prompt: smartPrompt);

      if (response == null) {
        _showSnackBar('❌ AI did not respond.');
        return null;
      }

      final replicateUrl = ref.read(replicateOutputParserProvider)(
        response.body,
      );
      if (replicateUrl == null) {
        _showSnackBar('❌ No image returned by AI.');
        return null;
      }

      print('🎨 Repainted image: $replicateUrl');

      // Step 4: Upload final image to Supabase
      _showSnackBar('☁️ Uploading final image...');
      final uploader = ref.read(replicateImageUploaderProvider.notifier);
      final finalUrl = await uploader.upload(replicateUrl);

      if (finalUrl == null) {
        _showSnackBar('❌ Upload to Supabase failed.');
        return null;
      }

      // Step 5: Save to DB (optional)
      final dbUploader = ref.read(aiDesignDbUploaderProvider);
      await dbUploader.insertDesign(
        prompt: smartPrompt,
        imageUrl: maskUrl,
        outputUrl: finalUrl,
      );

      _showSnackBar('✅ Recolor complete!');
      return finalUrl;
    } catch (e) {
      _showSnackBar('❌ Unexpected error: $e');
      return null;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

final aiPaintGeneratorProvider =
    Provider.family<AiPaintGenerator, BuildContext>((ref, context) {
      return AiPaintGenerator(ref, context);
    });
