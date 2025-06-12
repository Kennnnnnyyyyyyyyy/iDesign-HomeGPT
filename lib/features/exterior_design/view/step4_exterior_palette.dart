import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/core/widgets/palette_card.dart';
import 'package:interior_designer_jasper/features/exterior_design/providers/exterior_providers.dart';

class Step4ExteriorPalette extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final VoidCallback onClose;

  const Step4ExteriorPalette({
    super.key,
    required this.onBack,
    required this.onSubmit,
    required this.onClose,
  });

  @override
  ConsumerState<Step4ExteriorPalette> createState() =>
      _Step4ExteriorPaletteState();
}

class _Step4ExteriorPaletteState extends ConsumerState<Step4ExteriorPalette> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(selectedPaletteProvider);
  }

  void _handleSelect(String name) {
    setState(() => _selected = name);
    ref.read(selectedPaletteProvider.notifier).state = name;
  }

  @override
  Widget build(BuildContext context) {
    // Local palettes for exterior design
    final exteriorPalettes = [
      {
        'name': 'Terracotta Warmth',
        'colors': [Color(0xFFCC7351), Color(0xFFF4A896), Color(0xFFFFE5D9)],
      },
      {
        'name': 'Modern Grey',
        'colors': [Colors.grey[800]!, Colors.grey[500]!, Colors.grey[300]!],
      },
      {
        'name': 'Bold Contrast',
        'colors': [Colors.black, Colors.white, Colors.redAccent],
      },
      {
        'name': 'Earthy Greens',
        'colors': [Colors.green[900]!, Colors.green[600]!, Colors.green[300]!],
      },
      {
        'name': 'Pastel Pop',
        'colors': [Colors.pink[100]!, Colors.teal[100]!, Colors.yellow[100]!],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildProgressBar(),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Choose a Palette',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Pick a color palette that matches your home\'s personality.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: exteriorPalettes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemBuilder: (context, index) {
                final palette = exteriorPalettes[index];
                final name = palette['name'] as String;
                final colors = palette['colors'] as List<Color>;
                final isSelected = _selected == name;

                return PaletteTile(
                  name: name,
                  colors: colors,
                  isSelected: isSelected,
                  onTap: () => _handleSelect(name),
                );
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selected != null ? widget.onSubmit : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Generate Design',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const Spacer(),
          const Text(
            'Step 4 / 4',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close), onPressed: widget.onClose),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}
