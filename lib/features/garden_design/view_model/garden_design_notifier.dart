import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/core/providers/ai_image_generator.dart';
import 'package:interior_designer_jasper/core/providers/replicate_image_uploader.dart';
import 'package:interior_designer_jasper/core/providers/replicate_output_parser.dart';
import 'package:interior_designer_jasper/core/providers/supabase_design_uploader.dart';
import 'package:interior_designer_jasper/core/utils/supabase_image_uploader.dart';
import '../model/garden_design_state.dart';

class GardenDesignNotifier extends StateNotifier<GardenDesignState> {
  final Ref ref;

  GardenDesignNotifier(this.ref) : super(GardenDesignState());

  void setImage(File image) {
    state = state.copyWith(imageFile: image, assetPath: null);
  }

  void setAsset(String assetPath) {
    state = state.copyWith(assetPath: assetPath, imageFile: null);
  }

  void setStyle(String style) {
    state = state.copyWith(style: style);
  }

  void setPalette(String palette) {
    state = state.copyWith(palette: palette);
  }

  Future<String?> generateDesign() async {
    if (state.imageFile == null && state.assetPath == null) return null;
    if (state.style == null || state.palette == null) return null;

    state = state.copyWith(isLoading: true);

    String? imageUrl;

    // Upload user image if provided
    if (state.imageFile != null) {
      final uploadResult = await SupabaseImageUploader.upload(
        image: state.imageFile!,
      );
      if (uploadResult == null) {
        state = state.copyWith(isLoading: false);
        return null;
      }
      imageUrl = uploadResult['publicUrl'];
    } else if (state.assetPath != null) {
      imageUrl = state.assetPath;
    }

    final prompt = "Style: ${state.style}, Palette: ${state.palette}, no text";

    // 🔁 Step 1: Call AI via Supabase Edge Function
    final rawResponse = await ref
        .read(aiPromptSenderProvider.notifier)
        .send(
          filePath: state.imageFile?.path ?? state.assetPath!,
          imageUrl: imageUrl!,
          prompt: prompt,
        );

    if (rawResponse == null) {
      state = state.copyWith(isLoading: false);
      return null;
    }

    // 🔁 Step 2: Extract replicateOutputUrl
    final outputUrl = ref.read(replicateOutputParserProvider)(rawResponse.body);

    if (outputUrl == null) {
      print('❌ No replicateOutputUrl found');
      state = state.copyWith(isLoading: false);
      return null;
    }

    print('🌐 Replicate Output URL: $outputUrl');

    // 🔁 Step 3: Upload Replicate image to Supabase (ai-output bucket)
    final publicUrl = await ref
        .read(replicateImageUploaderProvider.notifier)
        .upload(outputUrl);

    if (publicUrl == null) {
      state = state.copyWith(isLoading: false);
      return null;
    }

    print('✅ Final Public Image URL: $publicUrl');

    // 🔁 Step 4: Store result in ai_designs table
    await ref
        .read(aiDesignDbUploaderProvider)
        .insertDesign(prompt: prompt, imageUrl: imageUrl, outputUrl: publicUrl);

    // 🔁 Step 5: Update state and return
    state = state.copyWith(isLoading: false, outputUrl: publicUrl);
    return publicUrl;
  }

  Future<String?> _callSupabaseAI(
    String filePath,
    String imageUrl,
    String prompt,
  ) async {
    final response = await ref
        .read(aiPromptSenderProvider.notifier)
        .send(filePath: filePath, imageUrl: imageUrl, prompt: prompt);

    if (response == null) return null;

    try {
      final json = jsonDecode(response.body);
      return json['outputUrl'] as String?;
    } catch (e) {
      print('❌ Failed to parse response JSON: $e');
      return null;
    }
  }
}

final gardenDesignProvider =
    StateNotifierProvider<GardenDesignNotifier, GardenDesignState>(
      (ref) => GardenDesignNotifier(ref),
    );
