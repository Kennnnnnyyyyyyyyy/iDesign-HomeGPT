import 'package:flutter/material.dart';

class Step4ExteriorPalette extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const Step4ExteriorPalette({
    super.key,
    required this.onBack,
    required this.onSubmit,
    required void Function() onClose,
  });

  @override
  Widget build(BuildContext context) {
    final palettes = [
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
        // Header Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            children: [
              IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
              const Spacer(),
              const Text(
                'Step 4 / 4',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // Progress Bar
        Padding(
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
        ),

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

        // Palette Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: palettes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemBuilder: (context, index) {
                final palette = palettes[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Row(
                          children:
                              (palette['colors'] as List<Color>).map((color) {
                                return Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                          (palette['colors']
                                                      as List<Color>)[0] ==
                                                  color
                                              ? 16
                                              : 0,
                                        ),
                                        topRight: Radius.circular(
                                          (palette['colors'] as List<Color>)
                                                      .last ==
                                                  color
                                              ? 16
                                              : 0,
                                        ),
                                      ),
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
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
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
            onPressed: onSubmit,
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
}
