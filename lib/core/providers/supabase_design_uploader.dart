import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiDesignDatabaseUploader {
  final SupabaseClient supabase;

  AiDesignDatabaseUploader(this.supabase);

  Future<void> insertDesign({
    required String prompt,
    required String imageUrl,
    required String outputUrl,
  }) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      print('❌ No Supabase user signed in.');
      return;
    }

    try {
      await supabase.from('ai_designs').insert({
        'prompt': prompt,
        'output_url': outputUrl,
        'firebase_uid': uid,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Design inserted into ai_designs table.');
    } catch (e) {
      print('❌ Error inserting design: $e');
    }
  }
}

final aiDesignDbUploaderProvider = Provider<AiDesignDatabaseUploader>((ref) {
  final supabase = Supabase.instance.client;
  return AiDesignDatabaseUploader(supabase);
});
