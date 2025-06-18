import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient supabase;
  final FlutterSecureStorage storage;

  AuthRepository(this.supabase, this.storage);

  static const String _storageKey = 'anonymous_uid';

  Future<String> getOrCreateAnonymousUser() async {
    final savedUid = await storage.read(key: _storageKey);

    if (savedUid != null) {
      await _upsertFirebaseUser(savedUid); // update last_sign_in
      return savedUid;
    }

    final result = await supabase.auth.signInAnonymously();
    final uid = result.user?.id;

    if (uid != null) {
      await storage.write(key: _storageKey, value: uid);
      await _upsertFirebaseUser(uid); // insert new user
      return uid;
    } else {
      throw Exception("Anonymous sign-in failed");
    }
  }

  Future<void> _upsertFirebaseUser(String uid) async {
    try {
      final existingUser =
          await supabase
              .from('firebase_users')
              .select('uid')
              .eq('uid', uid)
              .maybeSingle();

      if (existingUser != null) {
        // update last_sign_in
        await supabase
            .from('firebase_users')
            .update({'last_sign_in': DateTime.now().toIso8601String()})
            .eq('uid', uid);
        print('🔁 Updated last_sign_in for existing user');
      } else {
        // insert new user
        await supabase.from('firebase_users').insert({
          'uid': uid,
          'email': '',
          'sign_in_provider': 'anonymous',
          'first_sign_in': DateTime.now().toIso8601String(),
          'last_sign_in': DateTime.now().toIso8601String(),
        });
        print('🆕 Inserted new anonymous user into firebase_users');
      }
    } catch (e) {
      print('❌ Error syncing firebase_users: $e');
    }
  }
}
