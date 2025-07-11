import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/features/auth/providers/auth_provider.dart';
import 'package:interior_designer_jasper/routes/router_config.dart';
import 'package:qonversion_flutter/qonversion_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config =
      QonversionConfigBuilder(
            'kDuejpRZMwJPkDZcr8t3k6sahysiYbNq',
            QLaunchMode.subscriptionManagement,
          )
          .setEnvironment(QEnvironment.sandbox) // For testing only
          .build();
  Qonversion.initialize(config);

  await dotenv.load();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: HomeAIApp()));
}

class HomeAIApp extends StatelessWidget {
  const HomeAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HomeAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
          brightness: Brightness.light,
        ),
      ),
      routerConfig: router,
    );
  }
}
