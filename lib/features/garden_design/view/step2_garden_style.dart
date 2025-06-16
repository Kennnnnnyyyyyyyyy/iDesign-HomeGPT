import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/features/garden_design/providers/garden_providers.dart';
import 'package:interior_designer_jasper/features/garden_design/view_model/garden_design_notifier.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class Step2GardenStyle extends ConsumerWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const Step2GardenStyle({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStyle = ref.watch(selectedGardenStyleProvider);
    final styles = [
      {'name': 'Modern', 'icon': Icons.chair_alt},
      {'name': 'Tropical', 'icon': Icons.park},
      {'name': 'Zen', 'icon': Icons.self_improvement},
      {'name': 'Cottage', 'icon': Icons.home},
      {'name': 'Minimalist', 'icon': Icons.blur_on},
      {'name': 'Botanical', 'icon': Icons.local_florist},
      {'name': 'Scandinavian', 'icon': Icons.ac_unit},
      {'name': 'Industrial', 'icon': Icons.factory},
      {'name': 'Bohemian', 'icon': Icons.palette},
      {'name': 'Rustic', 'icon': Icons.cabin},
      {'name': 'Vintage', 'icon': Icons.library_books},
      {'name': 'Farmhouse', 'icon': Icons.agriculture},
      {'name': 'Art Deco', 'icon': Icons.auto_fix_high},
      {'name': 'Mid-Century', 'icon': Icons.timelapse},
      {'name': 'Eclectic', 'icon': Icons.scatter_plot},
      {'name': 'Luxury', 'icon': Icons.diamond},
      {'name': 'Mediterranean', 'icon': Icons.beach_access},
      {'name': 'Moroccan', 'icon': Icons.light_mode},
      {'name': 'Oriental', 'icon': Icons.yard},
      {'name': 'French Country', 'icon': Icons.wine_bar},
      {'name': 'Hollywood Glam', 'icon': Icons.star},
      {'name': 'Southwestern', 'icon': Icons.landscape},
      {'name': 'Urban', 'icon': Icons.location_city},
      {'name': 'Traditional', 'icon': Icons.temple_buddhist},
      {'name': 'Japanese', 'icon': Icons.temple_hindu},
      {'name': 'Color Pop', 'icon': Icons.color_lens},
      {'name': 'Contemporary', 'icon': Icons.style},
      {'name': 'Beach House', 'icon': Icons.waves},
      {'name': 'Futuristic', 'icon': Icons.memory},
      {'name': 'Coastal', 'icon': Icons.sailing},
      {'name': 'Baroque', 'icon': Icons.account_balance},
      {'name': 'Regency', 'icon': Icons.crop},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
              const Spacer(),
              const Text(
                'Step 2 / 3',
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

        // Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: index <= 1 ? Colors.black : Colors.grey[300],
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
            'Select Style',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Select your desired garden style to match your outdoor vision.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 16),

        // Style Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: styles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final style = styles[index];
                final isSelected = style['name'] == selectedStyle;

                return GestureDetector(
                  onTap: () {
                    final styleName = style['name'] as String;
                    ref.read(selectedGardenStyleProvider.notifier).state =
                        styleName;
                    ref
                        .read(gardenDesignProvider.notifier)
                        .setStyle(styleName); // ✅ global state update
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.redAccent.withOpacity(0.15)
                              : const Color(0xFFF5F6FA),
                      border: Border.all(
                        color:
                            isSelected ? Colors.redAccent : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          style['icon'] as IconData,
                          size: 40,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          style['name'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.redAccent : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: selectedStyle != null ? onContinue : null,
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
