import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/features/exterior_design/providers/exterior_providers.dart'; // Adjust path as needed

class Step3ExteriorStyle extends ConsumerStatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final VoidCallback onClose;

  const Step3ExteriorStyle({
    super.key,
    required this.onContinue,
    required this.onBack,
    required this.onClose,
  });

  @override
  ConsumerState<Step3ExteriorStyle> createState() => _Step3ExteriorStyleState();
}

class _Step3ExteriorStyleState extends ConsumerState<Step3ExteriorStyle> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(selectedExteriorStyleProvider);
  }

  void _handleSelect(String name) {
    setState(() => _selected = name);
    ref.read(selectedExteriorStyleProvider.notifier).state = name;
  }

  @override
  Widget build(BuildContext context) {
    final styles = [
      {'name': 'Custom', 'icon': Icons.auto_awesome},
      {'name': 'Art Deco', 'icon': Icons.architecture},
      {'name': 'Brutalist', 'icon': Icons.account_balance},
      {'name': 'Chinese', 'icon': Icons.temple_buddhist},
      {'name': 'Cottage', 'icon': Icons.cottage},
      {'name': 'Farm House', 'icon': Icons.agriculture},
      {'name': 'French', 'icon': Icons.wine_bar},
      {'name': 'Gothic', 'icon': Icons.castle},
      {'name': 'Italianate', 'icon': Icons.villa},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              const Spacer(),
              const Text(
                'Step 3 / 4',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
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
                    color: index <= 2 ? Colors.black : Colors.grey[300],
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
            'Select your desired design style to start creating your ideal exterior',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 16),

        // Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: styles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final style = styles[index];
                final isSelected = _selected == style['name'];
                return GestureDetector(
                  onTap: () => _handleSelect(style['name'] as String),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.redAccent.withOpacity(0.1)
                              : const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.redAccent
                                : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          style['icon'] as IconData,
                          size: 36,
                          color: isSelected ? Colors.redAccent : Colors.black54,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          style['name'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
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
            onPressed: _selected != null ? widget.onContinue : null,
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
