import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/core/providers/ai_design_uploader_provider.dart';
import 'package:interior_designer_jasper/core/providers/ai_image_generator.dart';
import 'package:interior_designer_jasper/core/providers/replicate_output_parser.dart';
import 'package:interior_designer_jasper/features/create/viewmodel/create_form_notifier.dart';

class AiDesignGenerator {
  final Ref ref;
  final BuildContext context;

  AiDesignGenerator(this.ref, this.context);

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
