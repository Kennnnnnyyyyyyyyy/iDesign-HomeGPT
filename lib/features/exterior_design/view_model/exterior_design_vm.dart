import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/core/providers/ai_design_uploader_provider.dart';
import 'package:interior_designer_jasper/core/providers/ai_image_generator.dart';
import 'package:interior_designer_jasper/core/providers/replicate_output_parser.dart';
import 'package:interior_designer_jasper/features/create/viewmodel/create_form_notifier.dart';
import 'package:interior_designer_jasper/features/exterior_design/providers/exterior_providers.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ExteriorDesignViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> generate(BuildContext context) async {
    final image = ref.read(selectedExteriorImageProvider);
    final style = ref.read(selectedExteriorStyleProvider);
    final palette = ref.read(selectedPaletteProvider);
    final parser = ref.read(replicateOutputParserProvider);
    final uploader = ref.read(aiDesignUploaderProvider);

    print('🚀 generate() called');
    print('📸 Image: $image');
    print('🎨 Style: $style');
    print('🌈 Palette: $palette');

    if (image == null) {
      print('❌ No image selected');
      _showSnackBar(context, 'Please choose a photo.');
      return null;
    }

    if (style == null || palette == null) {
      print('❌ Missing style or palette');
      _showSnackBar(context, 'Please complete all selections.');
      return null;
    }

    final prompt =
        "Design a modern exterior in '$style' style with a '$palette' color palette.";
    print('🧠 Generated Prompt: $prompt');

    _showSnackBar(context, 'Uploading image...');
    print('⏫ Uploading image to Supabase...');
    final uploadResult = await uploader.uploadImageToSupabase(image);

    if (uploadResult == null) {
      print('❌ Image upload failed');
      _showSnackBar(context, 'Image upload failed.');
      return null;
    }

    final imageUrl = uploadResult['publicUrl']!;
    final filePath = uploadResult['filePath']!;
    print('✅ Image uploaded: $imageUrl');
    print('📁 File path: $filePath');

    _showSnackBar(context, 'Generating design...');
    print('🤖 Sending prompt to AI...');
    final response = await ref
        .read(aiPromptSenderProvider.notifier)
        .send(filePath: filePath, imageUrl: imageUrl, prompt: prompt);

    if (response == null) {
      print('❌ AI did not respond');
      _showSnackBar(context, 'AI failed to respond.');
      return null;
    }

    final outputUrl = parser(response.body);
    print('🖼️ Parsed output URL: $outputUrl');

    if (outputUrl == null) {
      print('❌ No image in AI response');
      _showSnackBar(context, 'AI response received, but no image.');
      return null;
    }

    print('🎯 Final Output Image URL: $outputUrl');

    print('💾 Saving design to Supabase...');
    await uploader.saveDesign(
      prompt: prompt,
      imageUrl: imageUrl,
      outputUrl: outputUrl,
    );

    print('✅ Design saved successfully.');
    _showSnackBar(context, '✅ Design saved to Supabase.');

    return outputUrl;
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<File> _convertToTempImage(File originalFile) async {
    final bytes = await originalFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    final resized = img.copyResize(decoded!, width: 1024); // Optional resize

    final tempDir = await getTemporaryDirectory();
    final tempPath =
        '${tempDir.path}/exterior_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(tempPath);
    return await file.writeAsBytes(img.encodeJpg(resized));
  }
}

final exteriorDesignViewModelProvider =
    AsyncNotifierProvider<ExteriorDesignViewModel, void>(
      ExteriorDesignViewModel.new,
    );
