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

    print('🔍 Supabase current user UID: $uid');

    if (uid == null) {
      print('❌ No Supabase user signed in.');
      return;
    }

    final data = {
      'prompt': prompt,
      'output_url': outputUrl,
      'image_url': imageUrl,
      'supabase_uid': uid,
      'created_at': DateTime.now().toIso8601String(),
    };

    print('📦 Prepared data for insertion: $data');

    try {
      final response = await supabase.from('ai_designs').insert(data);
      print('✅ Design inserted successfully. Supabase response: $response');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.message}');
      print('🔧 Details: code=${e.code}, hint=${e.hint}, details=${e.details}');
    } catch (e) {
      print('❌ Unexpected error during design insertion: $e');
    }
  }
}

final aiDesignDbUploaderProvider = Provider<AiDesignDatabaseUploader>((ref) {
  final supabase = Supabase.instance.client;
  return AiDesignDatabaseUploader(supabase);
});
