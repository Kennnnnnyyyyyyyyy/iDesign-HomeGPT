import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/core/constants/palettes.dart';
import 'package:interior_designer_jasper/core/widgets/palette_card.dart';
import 'package:interior_designer_jasper/features/garden_design/providers/garden_providers.dart';
import 'package:interior_designer_jasper/features/garden_design/view_model/garden_design_notifier.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class Step3GardenPalette extends ConsumerWidget {
  final VoidCallback onBack;

  const Step3GardenPalette({super.key, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPalette = ref.watch(selectedGardenPaletteProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                final name = palette['name'] as String;
                final colors = palette['colors'] as List<Color>;
                final isSelected = selectedPalette == name;

                return PaletteTile(
                  name: name,
                  colors: colors,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(selectedGardenPaletteProvider.notifier).state =
                        name;
                  },
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed:
                selectedPalette != null
                    ? () async {
                      final notifier = ref.read(gardenDesignProvider.notifier);
                      notifier.setPalette(selectedPalette);

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );

                      final outputUrl = await notifier.generateDesign();

                      if (context.mounted) Navigator.pop(context);

                      if (outputUrl != null && context.mounted) {
                        context.pushNamed(
                          RouterConstants.aiResult,
                          extra: outputUrl,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to generate design.'),
                          ),
                        );
                      }
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
