import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<IconData> icons;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    const double fabSize = 56.0; // Size of the floating action button
    const double extraSpacing = fabSize; // Extra spacing required

    return BottomAppBar(
      height: 60,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(icons[0], 0),
          _buildNavItem(icons[1], 1),
          const SizedBox(width: extraSpacing), // Space for the FAB
          _buildNavItem(icons[2], 2),
          _buildNavItem(icons[3], 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        decoration: isSelected
            ? BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(30.0),
              )
            : null,
        child: Transform.scale(
          scale: isSelected ? 1.5 : 1.0,
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFF55CDF3) : Colors.grey,
          ),
        ),
      ),
    );
  }
}
