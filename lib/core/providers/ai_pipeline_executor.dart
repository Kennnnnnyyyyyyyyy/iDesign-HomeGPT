import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/core/providers/ai_design_generator_provider.dart';
import 'package:interior_designer_jasper/core/providers/replicate_image_uploader.dart';
import 'package:interior_designer_jasper/core/providers/supabase_design_uploader.dart';
import 'package:interior_designer_jasper/features/create/viewmodel/create_form_notifier.dart';

class AiPipelineExecutor {
  final Ref ref;
  final BuildContext context;

  AiPipelineExecutor(this.ref, this.context);

  /// Executes full AI image generation and upload pipeline.
  Future<String?> execute() async {
    final outputUrl =
        await ref.read(aiDesignGeneratorProvider(context)).generate();

    if (outputUrl != null) {
      final replicateUploader = ref.read(
        replicateImageUploaderProvider.notifier,
      );
      final finalUrl = await replicateUploader.upload(outputUrl);

      if (finalUrl != null) {
        print('✅ Final stored image: $finalUrl');
        ref.read(createFormProvider.notifier).setImageUrl(finalUrl);

        // Insert into ai_designs table
        final dbUploader = ref.read(aiDesignDbUploaderProvider);
        final formNotifier = ref.read(createFormProvider.notifier);
        final prompt = formNotifier.getPrompt();
        final form = ref.read(createFormProvider);

        if (form.imageUrl != null) {
          await dbUploader.insertDesign(
            prompt: prompt,
            imageUrl: form.imageUrl!,
            outputUrl: finalUrl,
          );
        } else {
          print('⚠️ imageUrl in state is null, skipping DB insert.');
        }

        // ✅ This is the fix — return finalUrl!
        return finalUrl;
      } else {
        print('❌ Failed to store image in ai-output bucket.');
      }
    } else {
      print('❌ AI generation failed or returned null.');
    }

    return null;
  }
}

final aiPipelineProvider = Provider.family<AiPipelineExecutor, BuildContext>(
  (ref, context) => AiPipelineExecutor(ref, context),
);
