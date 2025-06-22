import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/features/auth/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    return ''; // no-op, do not use .future in Splash
  }

  Future<String> signInAnonymously() async {
    final client = Supabase.instance.client;

    // 1. Check current session
    final existingSession = client.auth.currentSession;
    final user = existingSession?.user;

    if (user != null) {
      await _syncToFirebaseUsers(user);
      return user.id;
    }

    // 2. Perform anonymous sign-in
    final result = await client.auth.signInAnonymously();
    final newUser = result.user;

    if (newUser == null) {
      throw Exception('Anonymous sign-in failed');
    }

    await _syncToFirebaseUsers(newUser);
    return newUser.id;
  }

  Future<void> _syncToFirebaseUsers(User user) async {
    final client = Supabase.instance.client;

    final existing =
        await client
            .from('firebase_users')
            .select()
            .eq('uid', user.id)
            .maybeSingle();

    if (existing == null) {
      await client.from('firebase_users').insert({
        'uid': user.id,
        'email': user.email ?? 'anonymous@homegpt.app',
        'sign_in_provider': user.appMetadata['provider'] ?? 'anonymous',
        'first_sign_in': DateTime.now().toUtc().toIso8601String(),
        'last_sign_in': DateTime.now().toUtc().toIso8601String(),
        'metadata': user.userMetadata,
        'provider_data': user.appMetadata,
      });
    }
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, String>(
  () => AuthNotifier(),
);
