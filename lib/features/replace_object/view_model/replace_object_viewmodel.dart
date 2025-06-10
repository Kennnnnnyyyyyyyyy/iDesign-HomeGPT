import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/core/utils/supabase_image_uploader.dart';

class ReplaceObjectNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No-op
  }

  Future<void> uploadMaskOnly({
    required dynamic maskImage,
    required String prompt,
  }) async {
    state = const AsyncLoading();

    try {
      final mask = await SupabaseImageUploader.upload(image: maskImage);

      if (mask != null) {
        print('✅ Mask Image: ${mask['publicUrl']}');
        print('🧠 Prompt: $prompt');

        // 🔁 Send to AI pipeline or Edge Function here
        // await callReplaceFunction(mask['publicUrl'], prompt);

        state = const AsyncData(null);
      } else {
        throw Exception('Mask upload failed.');
      }
    } catch (e, st) {
      print('❌ ReplaceObjectNotifier error: $e');
      state = AsyncError(e, st);
    }
  }
}

final replaceObjectNotifierProvider =
    AsyncNotifierProvider<ReplaceObjectNotifier, void>(
      ReplaceObjectNotifier.new,
    );
