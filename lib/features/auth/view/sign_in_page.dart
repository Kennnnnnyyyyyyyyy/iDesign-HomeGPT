import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/auth_controller.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    ref.listen(authControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (_) => context.go('/home'),
        error: (err, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Login failed: $err')));
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            /// LOGO
            Image.asset('assets/logo/home_gpt_logo.png', height: 120),
            const SizedBox(height: 32),

            /// EMAIL FIELD
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            /// PASSWORD FIELD
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            /// SIGN IN BUTTON OR LOADING
            authState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: () {
                    ref
                        .read(authControllerProvider.notifier)
                        .signIn(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                  },
                  child: const Text("Sign In"),
                ),

            const SizedBox(height: 24),

            /// Divider
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("OR"),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),

            /// GOOGLE SIGN IN BUTTON
            ElevatedButton.icon(
              icon: Image.asset('assets/logo/google.png', height: 24),
              label: const Text(
                "Continue with Google",
                style: TextStyle(color: Colors.black87),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Colors.black12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                ref.read(authControllerProvider.notifier).signInWithGoogle();
              },
            ),

            const SizedBox(height: 12),

            /// APPLE SIGN IN BUTTON (iOS only)
            if (Platform.isIOS)
              ElevatedButton.icon(
                icon: Image.asset('assets/logo/apple.png', height: 24),
                label: const Text(
                  "Continue with Apple",
                  style: TextStyle(color: Colors.black87),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Colors.black12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // You may leave this unimplemented if not using Apple
                  ref.read(authControllerProvider.notifier).signInWithApple();
                },
              ),

            const SizedBox(height: 16),

            /// NAV TO SIGNUP
            TextButton(
              onPressed: () => context.push('/signup'),
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
