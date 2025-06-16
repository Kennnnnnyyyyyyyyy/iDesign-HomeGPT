import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    await signInAnonymously();
  }

  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    try {
      print('[AuthNotifier] Starting anonymous sign-in');
      final supabase = Supabase.instance.client;
      final result = await supabase.auth.signInAnonymously();
      final user = result.user;

      print('[AuthNotifier] Supabase response: $result');
      print('[AuthNotifier] Retrieved user: ${user?.id}');

      if (user == null) {
        throw Exception('Anonymous user creation failed');
      }

      await _syncAnonymousUserToSupabase(user);
      state = const AsyncData(null);
    } catch (e, st) {
      print('[AuthNotifier] Error during signInAnonymously: $e');
      state = AsyncError(e, st);
    }
  }

  Future<void> _syncAnonymousUserToSupabase(User user) async {
    print('[AuthNotifier] Syncing anonymous user to firebase_users table');
    final now = DateTime.now().toUtc().toIso8601String();

    final data = {
      'uid': user.id,
      'email': user.email,
      'email_verified': false,
      'sign_in_provider': 'anonymous',
      'first_sign_in': now,
      'last_sign_in': now,
      'display_name': null,
      'photo_url': null,
      'phone_number': null,
      'metadata': {'createdAt': now, 'lastLogin': now},
      'provider_data': [],
    };

    try {
      await Supabase.instance.client.from('firebase_users').upsert(data);
      print('[AuthNotifier] Anonymous user synced to Supabase successfully.');
    } catch (e) {
      print('[AuthNotifier] Error syncing user to firebase_users: $e');
      rethrow;
    }
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(
  AuthNotifier.new,
);
