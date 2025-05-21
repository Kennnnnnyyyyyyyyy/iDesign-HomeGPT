import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/features/create/view/create_page.dart';
import 'package:interior_designer_jasper/features/home/view/home_page.dart';
import 'package:interior_designer_jasper/features/profile/view/profile_page.dart';
import 'package:interior_designer_jasper/features/reference_style/view/feature_page.dart';
import 'package:interior_designer_jasper/features/replace_object/view/feature_page.dart';
import 'package:interior_designer_jasper/features/settings/view/settings_page.dart';
import 'package:interior_designer_jasper/features/splash/view/splash_screen.dart';

import 'router_constants.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: RouterConstants.splash,
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: RouterConstants.home,
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/editor',
      name: RouterConstants.editor,
      builder: (context, state) => const PlaceholderScreen(title: 'Editor'),
    ),
    GoRoute(
      path: '/processing',
      name: RouterConstants.processing,
      builder: (context, state) => const PlaceholderScreen(title: 'Processing'),
    ),
    GoRoute(
      path: '/profile',
      name: RouterConstants.profile,
      builder: (context, state) => ProfilePage(),
    ),
    GoRoute(
      path: '/settings',
      name: RouterConstants.settings,
      builder: (context, state) => SettingsPage(),
    ),
    GoRoute(
      path: '/privacy-policy',
      name: RouterConstants.privacyPolicy,
      builder:
          (context, state) => const PlaceholderScreen(title: 'Privacy Policy'),
    ),
    GoRoute(
      path: '/terms-of-service',
      name: RouterConstants.termsOfService,
      builder:
          (context, state) =>
              const PlaceholderScreen(title: 'Terms of Service'),
    ),
    GoRoute(
      path: '/your-board',
      name: RouterConstants.yourBoard,
      builder: (context, state) => const PlaceholderScreen(title: 'Your Board'),
    ),
    GoRoute(
      path: '/create',
      name: RouterConstants.create,
      builder: (context, state) => const CreatePage(),
    ),
    GoRoute(
      name: RouterConstants.replace,
      path: '/replace',
      builder: (context, state) => const ReplaceObjectPage(),
    ),
    GoRoute(
      path: '/reference',
      name: RouterConstants.referenceStyle,
      builder: (context, state) => const ReferenceStylePage(),
    ),
  ],
);

GoRouter get router => _router;

/// Simple placeholder widget for routes
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title Page', style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
