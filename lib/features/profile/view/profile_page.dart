import 'package:flutter/material.dart';
import 'package:interior_designer_jasper/core/widgets/bottom_navbar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // hides back button
        centerTitle: true, // 👈 Center the title
        title: const Text(
          'Your Board',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBoardCard(
            imagePath: 'assets/generated/gn1.jpeg',
            style: 'Mediterranean',
            room: 'Living Room',
          ),
          const SizedBox(height: 16),
          _buildBoardCard(
            imagePath: 'assets/generated/gn2.jpeg',
            style: 'Modern',
            room: 'Home Office',
          ),
          const SizedBox(height: 16),
          _buildBoardCard(
            imagePath: 'assets/generated/gn3.jpeg',
            style: 'Minimalist',
            room: 'Kitchen',
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(), // 👈 Include bottom nav
    );
  }

  Widget _buildBoardCard({
    required String imagePath,
    required String style,
    required String room,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Image.asset(imagePath, fit: BoxFit.cover),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  room,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
