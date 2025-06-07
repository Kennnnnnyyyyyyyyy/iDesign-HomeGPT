import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // no-op for now
  }

  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    try {
      final supabase = Supabase.instance.client;
      final result = await supabase.auth.signInAnonymously();
      final user = result.user;

      if (user == null) {
        throw Exception('Anonymous user creation failed');
      }

      await _syncAnonymousUserToSupabase(user);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> _syncAnonymousUserToSupabase(User user) async {
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

    await Supabase.instance.client.from('firebase_users').upsert(data);
    print('[AuthNotifier] Anonymous user synced to Supabase.');
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(
  AuthNotifier.new,
);
