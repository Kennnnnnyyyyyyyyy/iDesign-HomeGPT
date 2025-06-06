import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/core/widgets/bottom_navbar.dart';
import 'package:interior_designer_jasper/core/widgets/feature_card.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'image': 'assets/home_page/interior_design.png',
        'title': 'Interior Design',
        'subtitle': 'Upload a pic, choose a style, let AI design the room!',
        'route': RouterConstants.create,
      },
      {
        'image': 'assets/home_page/replace_object.png',
        'title': 'Replace Objects',
        'subtitle': 'Choose any object you wanna change, see it transform!',
        'route': RouterConstants.replace,
      },
      {
        'image': 'assets/home_page/reference_style.png',
        'title': 'Reference Style',
        'subtitle':
            'Show AI what you like, let it apply that vibe to your room.',
        'route': RouterConstants.referenceStyle,
      },
      {
        'image': 'assets/home_page/paint_visualisation.png',
        'title': 'Paint Visualisation',
        'subtitle':
            'Pick any door you love and transform your space with a touch.',
        'route': RouterConstants.paintVisualisation,
      },
      {
        'image': 'assets/home_page/garden_design.png',
        'title': 'Garden Design',
        'subtitle': 'Choose a style you adore and give your garden a new vibe.',
        'route': RouterConstants.gardenDesign,
      },
      {
        'image': 'assets/home_page/exterior_design.png',
        'title': 'Exterior Design',
        'subtitle': 'Snap your home, pick a vibe, let AI craft the face.',
        'route': RouterConstants.exteriorDesign,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'HomeGPT - Interior Design',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () => context.goNamed(RouterConstants.settings),
          ),
        ],
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => context.goNamed(RouterConstants.paywall),
            child: Center(
              child: Container(
                width: 50,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: features.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = features[index];
          return FeatureCard(
            imagePath: item['image']!,
            title: item['title']!,
            subtitle: item['subtitle']!,
            onPressed: () => context.goNamed(item['route']!),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
