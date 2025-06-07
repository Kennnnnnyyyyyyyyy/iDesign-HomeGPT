import 'package:flutter/material.dart';

class Step3StyleSelection extends StatefulWidget {
  final String selectedStyle;
  final ValueChanged<String> onStyleSelected;

  const Step3StyleSelection({
    super.key,
    required this.selectedStyle,
    required this.onStyleSelected,
  });

  @override
  State<Step3StyleSelection> createState() => _Step3StyleSelectionState();
}

class _Step3StyleSelectionState extends State<Step3StyleSelection> {
  final List<Map<String, dynamic>> styles = [
    {'name': 'Custom', 'icon': Icons.auto_awesome},
    {'name': 'Modern', 'icon': Icons.chair_alt},
    {'name': 'Tropical', 'icon': Icons.park},
    {'name': 'Minimalistic', 'icon': Icons.blur_on},
    {'name': 'Bohemian', 'icon': Icons.palette},
    {'name': 'Rustic', 'icon': Icons.cabin},
    {'name': 'Vintage', 'icon': Icons.library_books},
    {'name': 'Baroque', 'icon': Icons.account_balance},
    {'name': 'Mediterranean', 'icon': Icons.beach_access},
  ];

  Future<void> _showCustomStyleDialog() async {
    String input = '';
    final customStyle = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Custom Style'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => input = value,
            decoration: const InputDecoration(hintText: 'e.g. Futuristic Zen'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, input),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (customStyle != null && customStyle.trim().isNotEmpty) {
      widget.onStyleSelected(customStyle.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Style',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select your desired design style to start creating your ideal interior',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            itemCount: styles.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final style = styles[index];
              final isCustom = style['name'] == 'Custom';

              // selectedStyle might be a custom input (not in styles list)
              final isSelected =
                  isCustom
                      ? !styles.any(
                        (s) =>
                            s['name'] != 'Custom' &&
                            s['name'].toString().toLowerCase() ==
                                widget.selectedStyle.toLowerCase(),
                      )
                      : widget.selectedStyle == style['name'];

              return GestureDetector(
                onTap: () {
                  if (isCustom) {
                    _showCustomStyleDialog();
                  } else {
                    widget.onStyleSelected(style['name']);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.redAccent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(style['icon'], size: 36),
                      const SizedBox(height: 10),
                      Text(
                        style['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: isSelected ? Colors.redAccent : Colors.black87,
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
      ],
    );
  }
}
