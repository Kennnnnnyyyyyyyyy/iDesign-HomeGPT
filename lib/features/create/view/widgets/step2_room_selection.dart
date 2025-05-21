import 'package:flutter/material.dart';

class Step2RoomSelection extends StatelessWidget {
  final String selectedRoom;
  final Function(String) onRoomSelected;

  const Step2RoomSelection({
    super.key,
    required this.selectedRoom,
    required this.onRoomSelected,
  });

  @override
  Widget build(BuildContext context) {
    final rooms = [
      {'name': 'Kitchen', 'icon': Icons.kitchen},
      {'name': 'Living Room', 'icon': Icons.weekend},
      {'name': 'Home Office', 'icon': Icons.apartment},
      {'name': 'Bedroom', 'icon': Icons.bed},
      {'name': 'Bathroom', 'icon': Icons.bathtub},
      {'name': 'Dining Room', 'icon': Icons.restaurant},
      {'name': 'Coffee Shop', 'icon': Icons.coffee},
      {'name': 'Study Room', 'icon': Icons.edit},
      {'name': 'Restaurant', 'icon': Icons.room_service},
      {'name': 'Gaming Room', 'icon': Icons.sports_esports},
      {'name': 'Office', 'icon': Icons.chair},
      {'name': 'Attic', 'icon': Icons.card_giftcard},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Room',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select a room to design and see it transformed in your chosen style',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: rooms.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.8,
            ),
            itemBuilder: (context, index) {
              final room = rooms[index];
              final isSelected = room['name'] == selectedRoom;

              return GestureDetector(
                onTap: () => onRoomSelected(room['name'] as String),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                    border:
                        isSelected
                            ? Border.all(color: Colors.redAccent, width: 2)
                            : null,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        room['icon'] as IconData,
                        color: isSelected ? Colors.redAccent : Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          room['name']! as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.redAccent : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
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
