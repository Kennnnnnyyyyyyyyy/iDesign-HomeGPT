import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class Step3GardenPalette extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const Step3GardenPalette({
    super.key,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final palettes = [
      {
        'name': 'Surprise Me',
        'colors': [
          Colors.red,
          Colors.orange,
          Colors.yellow,
          Colors.green,
          Colors.blue,
        ],
      },
      {
        'name': 'Millennial Gray',
        'colors': [
          Colors.grey[100]!,
          Colors.grey[300]!,
          Colors.grey[500]!,
          Colors.grey[700]!,
        ],
      },
      {
        'name': 'Terracotta Mirage',
        'colors': [
          Color(0xFFFFE5D9),
          Color(0xFFFEB89F),
          Color(0xFFFF8552),
          Color(0xFFD94F2A),
        ],
      },
      {
        'name': 'Neon Sunset',
        'colors': [Colors.pink, Colors.purpleAccent, Colors.yellow],
      },
      {
        'name': 'Forest Hues',
        'colors': [
          Colors.green[900]!,
          Colors.green[600]!,
          Colors.green[300]!,
          Colors.green[100]!,
        ],
      },
      {
        'name': 'Peach Orchard',
        'colors': [
          Color(0xFFFFF3EC),
          Color(0xFFFFDFD3),
          Color(0xFFFFC4B2),
          Color(0xFFFFA78C),
        ],
      },
      {
        'name': 'Fuschia Blossom',
        'colors': [Colors.pink[100]!, Colors.pink[300]!, Colors.pink[600]!],
      },
      {
        'name': 'Emerald Gem',
        'colors': [
          Colors.green[800]!,
          Colors.green[600]!,
          Colors.green[400]!,
          Colors.green[200]!,
        ],
      },
      {
        'name': 'Pastel Breeze',
        'colors': [
          Colors.teal[50]!,
          Colors.purple[50]!,
          Colors.yellow[50]!,
          Colors.blue[50]!,
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
              const Spacer(),
              const Text(
                'Step 3 / 3',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.goNamed(RouterConstants.home),
              ),
            ],
          ),
        ),

        // Progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 24),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Select Palette',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'Choose a color palette to bring your vision to life!\nSelect from curated shades to transform your space.',
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
        const SizedBox(height: 16),

        // Palette Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: palettes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                final palette = palettes[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children:
                              (palette['colors'] as List<Color>).map((color) {
                                return Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          palette['name'] as String,
                          style: const TextStyle(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Continue', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
