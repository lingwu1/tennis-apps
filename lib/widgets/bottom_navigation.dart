import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                index: 0,
                isSelected: selectedIndex == 0,
              ),
              _buildNavItem(
                icon: Icons.sports_tennis,
                label: 'Training',
                index: 1,
                isSelected: selectedIndex == 1,
                isCustomIcon: true,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                label: 'Me',
                index: 2,
                isSelected: selectedIndex == 2,
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
    required bool isSelected,
    bool isCustomIcon = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCustomIcon && isSelected)
              // Custom tennis ball icon for selected state
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports_tennis,
                  color: Colors.white,
                  size: 16,
                ),
              )
            else if (isCustomIcon && !isSelected)
              // Custom tennis ball icon for unselected state
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports_tennis,
                  color: Color(0xFF999999),
                  size: 16,
                ),
              )
            else
              Icon(
                icon,
                color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF999999),
                size: 24,
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
