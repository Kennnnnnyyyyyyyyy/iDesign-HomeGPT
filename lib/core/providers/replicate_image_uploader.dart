import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// AsyncNotifier that uploads a Replicate image URL to Supabase
class ReplicateImageUploader extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    // No initial logic
    return null;
  }

  /// Call Supabase Edge Function to store Replicate image in ai-output bucket
  Future<String?> upload(String imageUrl) async {
    state = const AsyncLoading();

    const String functionUrl =
        'https://gmhaifyuoshptyxodvfm.supabase.co/functions/v1/store-replicate-image';

    try {
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imageUrl': imageUrl}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final publicUrl = data['publicUrl'];
        print('✅ Upload successful: $publicUrl');
        state = AsyncData(publicUrl);
        return publicUrl;
      } else {
        print('❌ Upload failed: ${response.statusCode} ${response.body}');
        state = AsyncError(Exception('Upload failed'), StackTrace.current);
        return null;
      }
    } catch (e, st) {
      print('❌ Error calling store-replicate-image: $e');
      state = AsyncError(e, st);
      return null;
    }
  }
}

/// Riverpod provider
final replicateImageUploaderProvider =
    AsyncNotifierProvider<ReplicateImageUploader, String?>(
      ReplicateImageUploader.new,
    );
