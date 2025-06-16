import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/features/exterior_design/providers/exterior_providers.dart';

class Step2ExteriorBuildingType extends ConsumerStatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final VoidCallback onClose;

  const Step2ExteriorBuildingType({
    super.key,
    required this.onContinue,
    required this.onBack,
    required this.onClose,
  });

  @override
  ConsumerState<Step2ExteriorBuildingType> createState() =>
      _Step2ExteriorBuildingTypeState();
}

class _Step2ExteriorBuildingTypeState
    extends ConsumerState<Step2ExteriorBuildingType> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(selectedBuildingTypeProvider);
  }

  void _handleSelect(String name) {
    setState(() => _selected = name);
    ref.read(selectedBuildingTypeProvider.notifier).state = name;
  }

  @override
  Widget build(BuildContext context) {
    final buildings = [
      {'name': 'Apartment', 'image': 'assets/create/apartment.jpeg'},
      {'name': 'House', 'image': 'assets/create/house.jpeg'},
      {'name': 'Office', 'image': 'assets/create/office.jpeg'},
      {'name': 'Residential', 'image': 'assets/create/residential.jpeg'},
      {'name': 'School', 'image': 'assets/create/school.jpeg'},
      {'name': 'Villa', 'image': 'assets/create/villa.jpeg'},
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
                'Step 2 / 4',
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
            'Choose Building Type',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Select the building type to redesign and see it in your chosen style',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 16),

        // Grid of building types using images
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: buildings.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final building = buildings[index];
                final isSelected = _selected == building['name'];

                return GestureDetector(
                  onTap: () => _handleSelect(building['name'] as String),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.redAccent.withOpacity(0.1)
                              : const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.redAccent
                                : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            building['image'] as String,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          building['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
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
              textStyle: TextStyle(color: Colors.white),
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
