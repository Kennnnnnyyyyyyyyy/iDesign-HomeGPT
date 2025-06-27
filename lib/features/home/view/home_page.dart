import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/core/widgets/feature_card.dart';
import 'package:interior_designer_jasper/core/widgets/bottom_navbar.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';
import 'package:interior_designer_jasper/core/models/feature_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FeatureItem> features = [
      FeatureItem(
        image: 'assets/home_page/interior_design.png',
        title: 'Interior Design',
        subtitle: 'Transform your interior space',
        route: RouterConstants.create,
        isBig: true,
      ),
      FeatureItem(
        image: 'assets/home_page/exterior_design.png',
        title: 'Exterior Design',
        subtitle: 'Transform your exterior space',
        route: RouterConstants.exteriorDesign,
        isBig: false,
      ),
      FeatureItem(
        image: 'assets/home_page/replace_object.png',
        title: 'Replace',
        subtitle: 'Replace any part of your space',
        route: RouterConstants.replace,
        isBig: false,
      ),
      FeatureItem(
        image: 'assets/home_page/reference_style.png',
        title: 'Style Transfer',
        subtitle: 'Apply style from reference image',
        route: RouterConstants.referenceStyle,
        isBig: true,
      ),
      FeatureItem(
        image: 'assets/home_page/paint_visualisation.png',
        title: 'New Walls',
        subtitle: 'Change paint, wallpaper, and more',
        route: RouterConstants.paintVisualisation,
        isBig: false,
      ),
      FeatureItem(
        image: 'assets/home_page/garden_design.png',
        title: 'Garden Design',
        subtitle: 'Redesign your garden space',
        route: RouterConstants.gardenDesign,
        isBig: false,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'HomeGPT',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () => context.goNamed(RouterConstants.settings),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomScrollView(
          slivers: [
            // First Big Tile
            SliverToBoxAdapter(
              child: FeatureCard(
                imagePath: features[0].image,
                title: features[0].title,
                subtitle: features[0].subtitle,
                onPressed: () => context.goNamed(features[0].route),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // First Grid (2 tiles)
            SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = features[index + 1];
                return FeatureCard(
                  imagePath: item.image,
                  title: item.title,
                  subtitle: item.subtitle,
                  onPressed: () => context.goNamed(item.route),
                );
              }, childCount: 2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Second Big Tile
            SliverToBoxAdapter(
              child: FeatureCard(
                imagePath: features[3].image,
                title: features[3].title,
                subtitle: features[3].subtitle,
                onPressed: () => context.goNamed(features[3].route),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Second Grid (last 2 tiles)
            SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = features[index + 4];
                return FeatureCard(
                  imagePath: item.image,
                  title: item.title,
                  subtitle: item.subtitle,
                  onPressed: () => context.goNamed(item.route),
                );
              }, childCount: 2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
