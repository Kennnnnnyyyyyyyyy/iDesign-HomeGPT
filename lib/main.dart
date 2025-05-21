import 'package:flutter/material.dart';
import 'package:interior_designer_jasper/routes/router_config.dart';

void main() {
  runApp(const HomeAIApp());
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
        fontFamily: 'SFPro', // Optional: match app branding
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
          brightness: Brightness.light,
        ),
      ),
      routerConfig: router,
    );
  }
}
