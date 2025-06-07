import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(FirebaseAuth.instance);
    });

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._auth) : super(const AsyncData(null));

  final FirebaseAuth _auth;

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    try {
      print("[Auth] Signing up with email: $email");
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("[Auth] Sign-up successful: ${credential.user?.uid}");
      await _syncUserToSupabase(credential.user!);
      state = const AsyncData(null);
    } catch (e, st) {
      print("[Auth] Signup failed: $e");
      state = AsyncError(e, st);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      print("[Auth] Signing in with email: $email");
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("[Auth] Sign-in successful: ${credential.user?.uid}");
      await _syncUserToSupabase(credential.user!);
      state = const AsyncData(null);
    } catch (e, st) {
      print("[Auth] Sign-in failed: $e");
      state = AsyncError(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      print("[Google] Initiating Google Sign-In...");
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw Exception("Google sign-in aborted.");

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      print("[Google] Sign-in successful: ${result.user?.uid}");
      await _syncUserToSupabase(result.user!);
      state = const AsyncData(null);
    } catch (e, st) {
      print("[Google] Sign-in failed: $e");
      state = AsyncError(e, st);
    }
  }

  Future<void> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      print("[Apple] Apple Sign-In not supported on this platform.");
      return;
    }

    state = const AsyncLoading();
    try {
      print("[Apple] Starting Apple Sign-In...");
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final result = await _auth.signInWithCredential(oauthCredential);
      print("[Apple] Sign-in successful: ${result.user?.uid}");
      await _syncUserToSupabase(result.user!);
      state = const AsyncData(null);
    } catch (e, st) {
      print("[Apple] Sign-in failed: $e");
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    print("[Auth] Signing out user: ${_auth.currentUser?.uid}");
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  User? get currentUser => _auth.currentUser;

  Future<void> _syncUserToSupabase(User user) async {
    final metadata = user.metadata;
    final providerId =
        user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'password';

    final supabaseClient = supabase.Supabase.instance.client;

    final data = {
      'uid': user.uid,
      'email': user.email,
      'email_verified': user.emailVerified,
      'sign_in_provider': providerId,
      'first_sign_in': metadata.creationTime?.toUtc().toIso8601String(),
      'last_sign_in': metadata.lastSignInTime?.toUtc().toIso8601String(),
      'display_name': user.displayName,
      'photo_url': user.photoURL,
      'phone_number': user.phoneNumber,
      'metadata': {
        'createdAt': metadata.creationTime?.toIso8601String(),
        'lastLogin': metadata.lastSignInTime?.toIso8601String(),
      },
      'provider_data':
          user.providerData
              .map(
                (e) => {
                  'uid': e.uid,
                  'providerId': e.providerId,
                  'email': e.email,
                  'displayName': e.displayName,
                  'photoURL': e.photoURL,
                  'phoneNumber': e.phoneNumber,
                },
              )
              .toList(),
    };

    final response = await supabaseClient.from('firebase_users').upsert(data);
    print('[Supabase] Sync response: $response');
  }

  Future<void> syncAnonymousUserToSupabase() async {
    final supabaseClient = supabase.Supabase.instance.client;
    final user = supabaseClient.auth.currentUser;

    if (user == null) {
      print('[Anon Sync] No current user found');
      return;
    }

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

    final response = await supabaseClient.from('firebase_users').upsert(data);
    print('[Anon Supabase Sync] Response: $response');
  }
}
