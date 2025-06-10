import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiDesignUploader {
  final SupabaseClient _supabase;
  final FirebaseAuth _auth;

  AiDesignUploader(this._supabase, this._auth);

  Future<void> saveDesign({
    // 🔁 Renamed from upload
    required String prompt,
    required String imageUrl,
    required String outputUrl,
  }) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      print('❌ Cannot upload: User not signed in.');
      return;
    }

    try {
      await _supabase.from('ai_designs').insert({
        'prompt': prompt,
        'image_url': imageUrl,
        'output_url': outputUrl,
        'supabase_uid': uid,
        'created_at': DateTime.now().toIso8601String(), // Optional: timestamp
      });

      print('✅ Design saved to Supabase.');
    } catch (e) {
      print('❌ Failed to save design: $e');
    }
  }

  Future<Map<String, String>?> uploadImageToSupabase(File image) async {
    try {
      final supabase = Supabase.instance.client;
      final bytes = await image.readAsBytes();
      final fileName = 'exterior_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'uploads/exterior/$fileName';

      print('📤 Uploading $filePath to Supabase...');

      final response = await supabase.storage
          .from('temp-image') // 🔁 Replace with your actual bucket name
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final publicUrl = supabase.storage
          .from('temp-image') // same bucket name
          .getPublicUrl(filePath);

      print('✅ Upload successful: $publicUrl');

      return {'publicUrl': publicUrl, 'filePath': filePath};
    } catch (e) {
      print('❌ Upload failed: $e');
      return null;
    }
  }
}

final aiDesignUploaderProvider = Provider<AiDesignUploader>((ref) {
  final supabase = Supabase.instance.client;
  final auth = FirebaseAuth.instance;
  return AiDesignUploader(supabase, auth);
});
