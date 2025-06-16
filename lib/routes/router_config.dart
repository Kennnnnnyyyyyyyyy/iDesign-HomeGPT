import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/features/ai_results/ai_results_view.dart';
import 'package:interior_designer_jasper/features/auth/view/sign_in_page.dart';
import 'package:interior_designer_jasper/features/auth/view/sign_up_page.dart';
import 'package:interior_designer_jasper/features/create/view/create_page.dart';
import 'package:interior_designer_jasper/features/exterior_design/view/feature_page.dart';
import 'package:interior_designer_jasper/features/faqs/faq_view.dart';
import 'package:interior_designer_jasper/features/garden_design/view/feature_page.dart';
import 'package:interior_designer_jasper/features/home/view/home_page.dart';
import 'package:interior_designer_jasper/features/paint_visualisation/view/paint_feature_page.dart';
import 'package:interior_designer_jasper/features/paywall/view/paywall.dart';
import 'package:interior_designer_jasper/features/privacy_policy/privacy_policy.dart';
import 'package:interior_designer_jasper/features/profile/view/profile_page.dart';
import 'package:interior_designer_jasper/features/reference_style/view/feature_page.dart';
import 'package:interior_designer_jasper/features/replace_object/view/replace_object_page.dart';
import 'package:interior_designer_jasper/features/settings/view/settings_page.dart';
import 'package:interior_designer_jasper/features/splash/view/splash_screen.dart';
import 'package:interior_designer_jasper/features/tos/tos_view.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isOnAuthRoute = [
      '/signin',
      '/signup',
    ].contains(state.matchedLocation);

    if (session == null && !isOnAuthRoute && state.matchedLocation != '/') {
      // Anonymous session failed — usually shouldn't happen, but fallback to splash
      return '/';
    }

    if (session != null && isOnAuthRoute) {
      // Already logged in anonymously — block auth pages
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: RouterConstants.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: RouterConstants.home,
      builder: (context, state) => const HomePage(),
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
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/settings',
      name: RouterConstants.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/privacy-policy',
      name: RouterConstants.privacyPolicy,
      builder: (context, state) => const PrivacyPolicyPage(),
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
      path: '/replace',
      name: RouterConstants.replace,
      builder: (context, state) => const ReplaceObjectPage(),
    ),
    GoRoute(
      path: '/reference',
      name: RouterConstants.referenceStyle,
      builder: (context, state) => const ReferenceStylePage(),
    ),
    GoRoute(
      path: '/paint',
      name: RouterConstants.paintVisualisation,
      builder: (context, state) => const PaintPage(),
    ),
    GoRoute(
      path: '/garden-design',
      name: RouterConstants.gardenDesign,
      builder: (context, state) => const GardenDesignPage(),
    ),
    GoRoute(
      path: '/exterior-design',
      name: RouterConstants.exteriorDesign,
      builder: (context, state) => const ExteriorDesignPage(),
    ),
    GoRoute(
      path: '/faqs',
      name: RouterConstants.faqs,
      builder: (context, state) => const FAQPage(),
    ),
    GoRoute(
      path: '/tos',
      name: RouterConstants.tos,
      builder: (context, state) => const TermsOfServicePage(),
    ),
    GoRoute(
      path: '/signin',
      name: RouterConstants.signIn,
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: '/signup',
      name: RouterConstants.signUp,
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: '/paywall',
      name: RouterConstants.paywall,
      builder: (context, state) => const PaywallPage(),
    ),
    GoRoute(
      path: '/ai-result',
      name: RouterConstants.aiResult,
      builder: (context, state) {
        final imageUrl = state.extra as String;
        return AiResultPage(imageUrl: imageUrl);
      },
    ),
  ],
);

GoRouter get router => _router;

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
