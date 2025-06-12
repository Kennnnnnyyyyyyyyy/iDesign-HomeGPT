import 'package:flutter/material.dart';

class PaletteTile extends StatelessWidget {
  final String name;
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

  const PaletteTile({
    super.key,
    required this.name,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.redAccent : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Row(
                  children:
                      colors.map((color) {
                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(color: color),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.redAccent : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
