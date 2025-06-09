import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:interior_designer_jasper/core/providers/ai_design_generator_provider.dart';
import 'package:interior_designer_jasper/core/utils/supabase_image_uploader.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

/// Processes the retouch image workflow by uploading the original image,
/// mask image, and prompt to an AI backend (e.g., Supabase Edge Function or Replicate API).
///
/// You can customize this to work with your API structure.

Future<String> processRetouchImage({
  required File originalImage,
  required File maskImage,
  required String prompt,
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final generator = ref.read(aiDesignGeneratorProvider(context));
  final resultUrl = await generator.generateFromMask(
    maskImage: maskImage,
    prompt: prompt,
  );

  if (resultUrl != null && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("✅ AI design generated")));

    // Push to results page
    context.goNamed(
      RouterConstants.aiResult, // 👈 use your route name or path
      extra: resultUrl, // or pass as param depending on your routing setup
    );
    return resultUrl;
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("❌ AI generation failed")));
    throw Exception('AI generation failed: resultUrl is null');
  }
}
