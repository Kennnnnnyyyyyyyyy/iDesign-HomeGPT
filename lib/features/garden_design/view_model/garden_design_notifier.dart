import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart'; // for rootBundle
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/core/providers/ai_image_generator.dart';
import 'package:interior_designer_jasper/core/providers/replicate_image_uploader.dart';
import 'package:interior_designer_jasper/core/providers/replicate_output_parser.dart';
import 'package:interior_designer_jasper/core/providers/supabase_design_uploader.dart';
import 'package:interior_designer_jasper/core/utils/supabase_image_uploader.dart';
import 'package:path_provider/path_provider.dart';
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

    try {
      // ✅ Upload to Supabase if image file exists
      if (state.imageFile != null) {
        final uploadResult = await SupabaseImageUploader.upload(
          image: state.imageFile!,
        );
        if (uploadResult == null) throw Exception("Image upload failed");
        imageUrl = uploadResult['publicUrl'];
      }
      // ✅ Upload assetPath to Supabase
      else if (state.assetPath != null) {
        final assetFile = await _loadAssetAsFile(state.assetPath!);
        final uploadResult = await SupabaseImageUploader.upload(
          image: assetFile,
        );
        if (uploadResult == null) throw Exception("Asset upload failed");
        imageUrl = uploadResult['publicUrl'];
      }

      // ✅ Compose AI prompt
      final prompt =
          "Style: ${state.style}, Palette: ${state.palette}, no text";

      // ✅ Send AI call with correct public URL
      final rawResponse = await ref
          .read(aiPromptSenderProvider.notifier)
          .send(
            filePath: imageUrl!, // Now always public URL
            imageUrl: imageUrl,
            prompt: prompt,
          );

      if (rawResponse == null) throw Exception("AI call failed");

      // ✅ Parse replicateOutputUrl
      final outputUrl = ref.read(replicateOutputParserProvider)(
        rawResponse.body,
      );
      if (outputUrl == null) throw Exception("Replicate returned no output");

      print('🌐 Replicate Output URL: $outputUrl');

      // ✅ Upload Replicate output back to Supabase
      final publicUrl = await ref
          .read(replicateImageUploaderProvider.notifier)
          .upload(outputUrl);
      if (publicUrl == null) throw Exception("Replicate image upload failed");

      print('✅ Final Public Image URL: $publicUrl');

      // ✅ Store final result into DB
      await ref
          .read(aiDesignDbUploaderProvider)
          .insertDesign(
            prompt: prompt,
            imageUrl: imageUrl,
            outputUrl: publicUrl,
          );

      state = state.copyWith(isLoading: false, outputUrl: publicUrl);
      return publicUrl;
    } catch (e) {
      print("❌ Error: $e");
      state = state.copyWith(isLoading: false);
      return null;
    }
  }

  /// 🔧 Helper: load assetPath into File for Supabase upload
  Future<File> _loadAssetAsFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final buffer = byteData.buffer;
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${assetPath.split('/').last}');
    await file.writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );
    return file;
  }
}

final gardenDesignProvider =
    StateNotifierProvider<GardenDesignNotifier, GardenDesignState>(
      (ref) => GardenDesignNotifier(ref),
    );
