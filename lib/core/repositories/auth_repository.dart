import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  static const _uidKey = 'anonymous_uid';

  final SupabaseClient supabase;

  AuthRepository(this.supabase);

  Future<String> getOrCreateAnonymousUser() async {
    final prefs = await SharedPreferences.getInstance();

    // Try to recover session first
    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      await prefs.setString(
        _uidKey,
        currentUser.id,
      ); // sync storage just in case
      return currentUser.id;
    }

    // Check SharedPreferences for UID
    final cachedUid = prefs.getString(_uidKey);
    if (cachedUid != null) {
      // You can use cachedUid for identifying the user even if session expired
      // Optionally: re-authenticate silently if Supabase allows
      return cachedUid;
    }

    // No UID found: create new anonymous user
    final result = await supabase.auth.signInAnonymously();
    final user = result.user;

    if (user == null) {
      throw Exception('Anonymous sign-in failed');
    }

    await prefs.setString(_uidKey, user.id);
    return user.id;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = Supabase.instance.client;
  return AuthRepository(supabase);
});
