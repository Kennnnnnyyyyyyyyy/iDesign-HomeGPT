import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

final referenceStyleNotifierProvider =
    AsyncNotifierProvider<ReferenceStyleNotifier, String?>(
      ReferenceStyleNotifier.new,
    );

class ReferenceStyleNotifier extends AsyncNotifier<String?> {
  String? roomPhotoUrl;
  String? stylePhotoUrl;

  @override
  Future<String?> build() async => null;

  void setRoomPhotoUrl(String url) {
    roomPhotoUrl = url;
  }

  void setStylePhotoUrl(String url) {
    stylePhotoUrl = url;
  }

  Future<String?> upload(String imageUrl) async {
    const functionUrl =
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
        return publicUrl;
      } else {
        print('❌ Upload failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error in upload: $e');
      return null;
    }
  }

  Future<String> uploadImage(File file, String fileName) async {
    final storage = Supabase.instance.client.storage;
    final bucket = storage.from('temp-image');
    final path = 'uploads/$fileName';

    await bucket.upload(
      path,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    return bucket.getPublicUrl(path);
  }

  Future<void> submitReferenceStyle() async {
    if (roomPhotoUrl == null || stylePhotoUrl == null) {
      state = AsyncError('Both images must be uploaded', StackTrace.current);
      return;
    }

    state = const AsyncLoading();

    try {
      // Step 1: Generate AI Output via Supabase Edge Function
      final aiResponse = await http.post(
        Uri.parse(
          'https://gmhaifyuoshptyxodvfm.supabase.co/functions/v1/transform-room',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'structure_image': roomPhotoUrl,
          'style_image': stylePhotoUrl,
        }),
      );

      final result = jsonDecode(aiResponse.body);
      final output = result['output'];

      if (output is! List || output.isEmpty) {
        throw Exception('No output received from AI generation');
      }

      final replicateImageUrl = output[0];

      // Step 2: Upload final image to ai-designs bucket
      final supabaseHostedUrl = await upload(replicateImageUrl);
      if (supabaseHostedUrl == null) {
        throw Exception('Failed to upload AI image to Supabase bucket');
      }

      // Step 3: Save entry in ai_designs table
      final supabase = Supabase.instance.client;
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) {
        throw Exception('No authenticated Supabase user');
      }

      await supabase.from('ai_designs').insert({
        'prompt': 'Reference style design',
        'image_url': roomPhotoUrl, // 📸 Original room image uploaded by user
        'output_url':
            supabaseHostedUrl, // 🧠 AI-generated + Supabase-hosted image
        'supabase_uid': uid,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      print('✅ Design inserted into ai_designs table');

      // Step 4: Done – return the final URL
      state = AsyncData(supabaseHostedUrl);
    } catch (e, st) {
      print('❌ Error in submitReferenceStyle: $e');
      state = AsyncError(e, st);
    }
  }
}
