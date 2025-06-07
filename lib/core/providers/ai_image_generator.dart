import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// A StateNotifier that manages sending prompt + image to Supabase Edge Function.
class AiPromptSender extends StateNotifier<AsyncValue<void>> {
  AiPromptSender() : super(const AsyncData(null));

  Future<http.Response?> send({
    required String filePath,
    required String imageUrl,
    required String prompt,
  }) async {
    state = const AsyncLoading();

    final url = Uri.parse(
      'https://gmhaifyuoshptyxodvfm.supabase.co/functions/v1/process-image',
    );

    final body = jsonEncode({
      'filePath': filePath,
      'imageUrl': imageUrl,
      'prompt': prompt,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('✅ Supabase AI response: ${response.body}');
        state = const AsyncData(null);
        return response;
      } else {
        print('❌ AI call failed: ${response.statusCode}');
        state = AsyncError(response.body, StackTrace.current);
        return null;
      }
    } catch (e, st) {
      print('❌ Exception during AI call: $e');
      state = AsyncError(e, st);
      return null;
    }
  }
}

/// Riverpod provider for the AI prompt sender
final aiPromptSenderProvider =
    StateNotifierProvider<AiPromptSender, AsyncValue<void>>(
      (ref) => AiPromptSender(),
    );
