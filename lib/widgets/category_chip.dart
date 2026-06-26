import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.038; // 3.8% of screen width
    final horizontalPadding = screenWidth * 0.06; // 6% of screen width
    final verticalPadding = screenWidth * 0.03; // 3% of screen width

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0058A3)
              : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF0F0F0)),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0058A3).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white : const Color(0xFF0058A3)),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
