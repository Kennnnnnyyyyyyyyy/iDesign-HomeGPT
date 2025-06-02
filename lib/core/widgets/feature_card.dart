import 'package:flutter/material.dart';

class FeatureCardListView extends StatefulWidget {
  const FeatureCardListView({super.key});

  @override
  State<FeatureCardListView> createState() => _FeatureCardListViewState();
}

class _FeatureCardListViewState extends State<FeatureCardListView> {
  final List<Map<String, String>> features = [
    {
      'image': 'assets/interior.jpg',
      'title': 'Interior Design',
      'subtitle': 'Upload a pic, choose a style, let AI design the room!',
    },
    {
      'image': 'assets/replace.jpg',
      'title': 'Replace Objects',
      'subtitle': 'Choose any object you wanna change, see it transform!',
    },
    {
      'image': 'assets/garden.jpg',
      'title': 'Garden Upgrade',
      'subtitle': 'AI makeover for your backyard or balcony.',
    },
    {
      'image': 'assets/floorplan.jpg',
      'title': '2D Floor Plan to 3D',
      'subtitle': 'Convert blueprints into 3D visuals in one tap!',
    },
    {
      'image': 'assets/exterior.jpg',
      'title': 'Exterior Facade',
      'subtitle': 'See how your house could look from the outside.',
    },
    {
      'image': 'assets/stylesample.jpg',
      'title': 'Sample My Style',
      'subtitle': 'Pick a style reference and apply it to your space.',
    },
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      itemExtent: 320,
      perspective: 0.003,
      diameterRatio: 2.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) {
        setState(() {
          selectedIndex = index;
        });
      },
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: features.length,
        builder: (context, index) {
          final feature = features[index];
          final isSelected = index == selectedIndex;
          return AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: isSelected ? 1.0 : 0.9, // squeeze effect
            child: FeatureCard(
              imagePath: feature['image']!,
              title: feature['title']!,
              subtitle: feature['subtitle']!,
              onPressed: () {
                debugPrint('Tapped on ${feature['title']}');
              },
            ),
          );
        },
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const FeatureCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -10), // subtle lift
      child: Container(
        height: 280,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(imagePath, fit: BoxFit.cover),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black54],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text("Try It!"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
