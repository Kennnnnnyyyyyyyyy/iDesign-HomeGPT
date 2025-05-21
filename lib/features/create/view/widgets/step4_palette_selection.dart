import 'package:flutter/material.dart';

class Step4PaletteSelection extends StatelessWidget {
  final String selectedPalette;
  final Function(String) onPaletteSelected;

  const Step4PaletteSelection({
    super.key,
    required this.selectedPalette,
    required this.onPaletteSelected,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Palette',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a color palette to bring your vision to life!\nSelect from curated shades to transform your space.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: palettes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final palette = palettes[index];
              final isSelected = palette['name'] == selectedPalette;

              return GestureDetector(
                onTap: () => onPaletteSelected(palette['name'] as String),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.redAccent : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                              (palette['colors'] as List<Color>).map((color) {
                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1.5,
                                    ),
                                    color: color,
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          palette['name'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.redAccent : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
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
