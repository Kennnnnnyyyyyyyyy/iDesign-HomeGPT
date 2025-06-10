import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/core/providers/ai_design_uploader_provider.dart';
import 'package:interior_designer_jasper/core/providers/ai_image_generator.dart';
import 'package:interior_designer_jasper/core/providers/replicate_image_uploader.dart';
import 'package:interior_designer_jasper/core/providers/replicate_output_parser.dart';
import 'package:interior_designer_jasper/core/providers/supabase_design_uploader.dart';
import 'package:interior_designer_jasper/core/utils/supabase_image_uploader.dart';
import 'package:interior_designer_jasper/features/create/viewmodel/create_form_notifier.dart';
import 'package:interior_designer_jasper/features/exterior_design/providers/exterior_providers.dart';

class AiDesignGenerator {
  final Ref ref;
  final BuildContext context;

  AiDesignGenerator(this.ref, this.context);

  Future<String?> generateFromMask({
    required File maskImage,
    required String prompt,
  }) async {
    try {
      // Step 1: Upload mask to Supabase
      _showSnackBar('Uploading mask image...');
      final uploadResult = await SupabaseImageUploader.upload(image: maskImage);

      if (uploadResult == null) {
        _showSnackBar('Mask image upload failed.');
        return null;
      }

      final imageUrl = uploadResult['publicUrl']!;
      final filePath = uploadResult['filePath']!;
      final smartPrompt =
          "In the masked area, replace the object with $prompt.";

      // Step 2: Send to AI
      _showSnackBar('Generating AI replacement...');
      final response = await ref
          .read(aiPromptSenderProvider.notifier)
          .send(filePath: filePath, imageUrl: imageUrl, prompt: smartPrompt);

      if (response == null) {
        _showSnackBar('AI failed to respond.');
        return null;
      }

      final replicateUrl = ref.read(replicateOutputParserProvider)(
        response.body,
      );
      if (replicateUrl == null) {
        _showSnackBar('AI responded but returned no image.');
        return null;
      }

      print('🎨 Replicate Output URL: $replicateUrl');

      // Step 3: Upload replicate image to Supabase via Edge Function
      _showSnackBar('Re-uploading output to Supabase...');
      final uploader = ref.read(replicateImageUploaderProvider.notifier);
      final finalUrl = await uploader.upload(replicateUrl);

      if (finalUrl == null) {
        _showSnackBar('❌ Upload to Supabase failed.');
        return null;
      }

      // Step 4: Save to DB
      final dbUploader = ref.read(aiDesignDbUploaderProvider);
      await dbUploader.insertDesign(
        prompt: prompt,
        imageUrl: imageUrl,
        outputUrl: finalUrl,
      );

      _showSnackBar('✅ AI design saved.');
      return finalUrl;
    } catch (e) {
      _showSnackBar('Unexpected error: $e');
      return null;
    }
  }

  Future<String?> generateFromExteriorForm() async {
    final image = ref.read(selectedExteriorImageProvider);
    final style = ref.read(selectedExteriorStyleProvider);
    final palette = ref.read(selectedPaletteProvider);

    if (image == null) {
      _showSnackBar('❌ Please select an image.');
      return null;
    }
    if (style == null || palette == null) {
      _showSnackBar('❌ Please complete all selections.');
      return null;
    }

    final prompt =
        "Design a modern exterior in '$style' style with a '$palette' color palette.";
    print('🧠 Prompt: $prompt');

    // Step 1: Upload original image to Supabase
    final uploader = ref.read(aiDesignUploaderProvider);
    _showSnackBar('📤 Uploading image...');
    final uploadResult = await uploader.uploadImageToSupabase(image);
    if (uploadResult == null) {
      _showSnackBar('❌ Upload failed.');
      return null;
    }

    final imageUrl = uploadResult['publicUrl']!;
    final filePath = uploadResult['filePath']!;
    print('✅ Image URL: $imageUrl');

    // Step 2: Generate design via Replicate
    _showSnackBar('🤖 Generating AI design...');
    final response = await ref
        .read(aiPromptSenderProvider.notifier)
        .send(filePath: filePath, imageUrl: imageUrl, prompt: prompt);

    if (response == null) {
      _showSnackBar('❌ AI failed to respond.');
      return null;
    }

    final replicateUrl = ref.read(replicateOutputParserProvider)(response.body);
    if (replicateUrl == null) {
      _showSnackBar('❌ AI returned no image.');
      return null;
    }
    print('🖼️ Replicate URL: $replicateUrl');

    // Step 3: Re-upload to your Supabase bucket via Edge Function
    _showSnackBar('🔁 Uploading result to Supabase...');
    final finalUrl = await ref
        .read(replicateImageUploaderProvider.notifier)
        .upload(replicateUrl);

    if (finalUrl == null) {
      _showSnackBar('❌ Failed to upload AI result.');
      return null;
    }
    print('📦 Final Supabase URL: $finalUrl');

    // Step 4: Save to DB
    _showSnackBar('💾 Saving design to database...');
    await ref
        .read(aiDesignDbUploaderProvider)
        .insertDesign(prompt: prompt, imageUrl: imageUrl, outputUrl: finalUrl);

    _showSnackBar('🎉 Design saved successfully!');
    return finalUrl;
  }

  /// ✅ Now returns the final output image URL from Replicate
  Future<String?> generate() async {
    final notifier = ref.read(createFormProvider.notifier);
    final form = ref.read(createFormProvider);
    final parser = ref.read(replicateOutputParserProvider);
    final uploader = ref.read(aiDesignUploaderProvider);

    if (form.image == null) {
      _showSnackBar('Please choose a photo.');
      return null;
    }

    _showSnackBar('Uploading image...');
    final uploadResult = await notifier.uploadImageToSupabase();
    if (uploadResult == null) {
      _showSnackBar('Image upload failed.');
      return null;
    }

    final imageUrl = uploadResult['publicUrl']!;
    final filePath = uploadResult['filePath']!;
    final prompt = notifier.getPrompt();

    _showSnackBar('Generating design...');
    final response = await ref
        .read(aiPromptSenderProvider.notifier)
        .send(filePath: filePath, imageUrl: imageUrl, prompt: prompt);

    if (response == null) {
      _showSnackBar('AI failed to respond.');
      return null;
    }

    final outputUrl = parser(response.body);
    if (outputUrl == null) {
      _showSnackBar('AI response received, but no image.');
      return null;
    }

    print('🎨 Output Image URL: $outputUrl');

    // await uploader.saveDesign(
    //   prompt: prompt,
    //   imageUrl: imageUrl,
    //   outputUrl: outputUrl,
    // );

    // _showSnackBar('✅ Design saved to Supabase.');

    return outputUrl;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Provider that can be used across the app
final aiDesignGeneratorProvider =
    Provider.family<AiDesignGenerator, BuildContext>(
      (ref, context) => AiDesignGenerator(ref, context),
    );
