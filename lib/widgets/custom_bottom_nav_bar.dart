import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.article_rounded,
                label: 'News',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.grid_view_rounded,
                label: 'Categories',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.play_circle_rounded,
                label: 'Videos',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    
    // Different colors for each tab when selected
    Color getColor() {
      if (!isSelected) return const Color.fromARGB(255, 53, 52, 52);
      
      switch (index) {
        case 0:
          return const Color(0xFFFFA722);
        case 1:
          return const Color(0xFFFFA722);
        case 2:
          return const Color(0xFFFFA722);
        case 3:
          return const Color(0xFFFFA722);
        default:
          return const Color(0xFFFFA722);
      }
    }

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: getColor(),
              size: isSelected ? 28 : 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: getColor(),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}