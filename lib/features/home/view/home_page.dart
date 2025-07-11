import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.chair,
        'title': 'Interior Design',
        'subtitle': 'Transform your interior space',
        'route': RouterConstants.create,
        'image': 'assets/home_page/interior_design.png',
        'gradient': [Colors.purple, Colors.deepPurpleAccent],
      },
      {
        'icon': Icons.house,
        'title': 'Exterior Design',
        'subtitle': 'Beautify your home\'s exterior',
        'route': RouterConstants.exteriorDesign,
        'image': 'assets/home_page/exterior_design.png',
        'gradient': [Colors.teal, Colors.greenAccent],
      },
      {
        'icon': Icons.swap_horiz,
        'title': 'Replace',
        'subtitle': 'Swap out objects in your space',
        'route': RouterConstants.replace,
        'image': 'assets/home_page/replace_object.png',
        'gradient': [Colors.orange, Colors.deepOrangeAccent],
      },
      {
        'icon': Icons.style,
        'title': 'Style Transfer',
        'subtitle': 'Apply a new style to your room',
        'route': RouterConstants.referenceStyle,
        'image': 'assets/home_page/reference_style.png',
        'gradient': [Colors.blue, Colors.lightBlueAccent],
      },
      {
        'icon': Icons.format_paint,
        'title': 'New Walls',
        'subtitle': 'Change paint or wallpaper',
        'route': RouterConstants.paintVisualisation,
        'image': 'assets/home_page/paint_visualisation.png',
        'gradient': [Colors.pink, Colors.redAccent],
      },
      {
        'icon': Icons.park,
        'title': 'Garden Design',
        'subtitle': 'Redesign your garden',
        'route': RouterConstants.gardenDesign,
        'image': 'assets/home_page/garden_design.png',
        'gradient': [Colors.green, Colors.lightGreenAccent],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'iDesign',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22,
            letterSpacing: 1.1,
          ),
        ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.redAccent, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Explore Features',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final feature = features[index];
              return GestureDetector(
                onTap: () => context.goNamed(feature['route'] as String),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: feature['gradient'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (feature['gradient'] as List<Color>).last
                            .withOpacity(0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          feature['image'] as String,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        left: 14,
                        top: 14,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.85),
                          child: Icon(
                            feature['icon'] as IconData,
                            color: (feature['gradient'] as List<Color>).first,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 44,
                        right: 14,
                        child: Text(
                          feature['title'] as String,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black26),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 22,
                        right: 14,
                        child: Text(
                          feature['subtitle'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black26),
                            ],
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 10,
                        right: 14,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
