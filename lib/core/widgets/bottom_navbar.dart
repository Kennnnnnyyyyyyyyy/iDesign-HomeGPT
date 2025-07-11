import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_designer_jasper/routes/router_constants.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _getCurrentIndex(context),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            context.goNamed(RouterConstants.home); // Tools
            break;
          case 1:
            context.goNamed(RouterConstants.profile); // Profile
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.style), label: 'Tools'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Profile'),
      ],
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;

    if (routeName == RouterConstants.profile) return 1;
    if (routeName == RouterConstants.home) return 0;

    return 0; // Default to Tools
  }
}
