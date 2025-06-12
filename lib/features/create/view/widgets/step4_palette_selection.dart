import 'package:flutter/material.dart';
import 'package:interior_designer_jasper/core/constants/palettes.dart';
import 'package:interior_designer_jasper/core/widgets/palette_card.dart';

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
              final name = palette['name'] as String;
              final colors = palette['colors'] as List<Color>;
              final isSelected = name == selectedPalette;

              return PaletteTile(
                name: name,
                colors: colors,
                isSelected: isSelected,
                onTap: () => onPaletteSelected(name),
              );
            },
          ),
        ],
      ),
    );
  }
}
