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
            context.goNamed(
              RouterConstants.create,
            ); // ✅ Navigate to Create page
            break;
          case 2:
            context.goNamed(RouterConstants.profile); // Profile
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.style), label: 'Tools'),
        BottomNavigationBarItem(icon: Icon(Icons.layers), label: 'Create'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Profile'),
      ],
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;

    if (routeName == RouterConstants.profile) return 2;
    if (routeName == RouterConstants.home) return 0;
    if (routeName == RouterConstants.create)
      return 1; // ✅ highlight Create tab when active

    return 1; // Default to Create
  }
}
