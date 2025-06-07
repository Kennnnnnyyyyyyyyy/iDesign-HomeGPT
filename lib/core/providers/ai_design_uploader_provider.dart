import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiDesignUploader {
  final SupabaseClient _supabase;
  final FirebaseAuth _auth;

  AiDesignUploader(this._supabase, this._auth);

  Future<void> upload({
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
        'firebase_uid': uid,
      });

      print('✅ Design uploaded to Supabase.');
    } catch (e) {
      print('❌ Failed to upload design to Supabase: $e');
    }
  }
}

final aiDesignUploaderProvider = Provider<AiDesignUploader>((ref) {
  final supabase = Supabase.instance.client;
  final auth = FirebaseAuth.instance;
  return AiDesignUploader(supabase, auth);
});
