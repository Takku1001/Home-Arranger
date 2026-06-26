import 'package:flutter/material.dart';
import '../models/furniture_model.dart';

class FurnitureCard extends StatelessWidget {
  final FurnitureItem item;
  final VoidCallback onTap;

  const FurnitureCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final iconSize = screenWidth * 0.15; // 15% of screen width
    final nameFontSize = screenWidth * 0.038; // 3.8% of screen width
    final categoryFontSize = screenWidth * 0.028; // 2.8% of screen width
    final priceFontSize = screenWidth * 0.042; // 4.2% of screen width
    final buttonIconSize = screenWidth * 0.035; // 3.5% of screen width

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFF5F5F5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: item.imagePath != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.asset(
                            item.imagePath!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                _getCategoryIcon(item.category),
                                size: iconSize,
                                color: const Color(0xFF0058A3).withOpacity(0.4),
                              );
                            },
                          ),
                        )
                      : Icon(
                          _getCategoryIcon(item.category),
                          size: iconSize,
                          color: const Color(0xFF0058A3).withOpacity(0.4),
                        ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1a1a1a),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.category,
                    style: TextStyle(
                      fontSize: categoryFontSize,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Rs ${item.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: priceFontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0058A3),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBD914),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: buttonIconSize,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Chairs':
        return Icons.chair;
      case 'Tables':
        return Icons.table_restaurant;
      case 'Sofas':
        return Icons.weekend;
      case 'Beds':
        return Icons.bed;
      case 'Storage':
        return Icons.shelves;
      default:
        return Icons.home;
    }
  }
}
