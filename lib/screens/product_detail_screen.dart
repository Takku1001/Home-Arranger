import 'package:flutter/material.dart';
import '../models/furniture_model.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final item = ModalRoute.of(context)!.settings.arguments as FurnitureItem;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final appBarHeight = screenHeight * 0.50; // 50% of screen height
    final iconSizeInAppBar = screenWidth * 0.50; // 50% of screen width
    final nameFontSize = screenWidth * 0.07; // 7% of screen width
    final descFontSize = screenWidth * 0.04; // 4% of screen width
    final priceFontSize = screenWidth * 0.06; // 6% of screen width
    final sectionTitleSize = screenWidth * 0.045; // 4.5% of screen width
    final bodyTextSize = screenWidth * 0.038; // 3.8% of screen width

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: appBarHeight,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                child: Center(
                  child: item.imagePath != null
                      ? Image.asset(
                          item.imagePath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.chair_outlined,
                              size: iconSizeInAppBar,
                              color: Colors.grey,
                            );
                          },
                        )
                      : Icon(
                          Icons.chair_outlined,
                          size: iconSizeInAppBar,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: nameFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: descFontSize,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rs ${item.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: priceFontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0058A3),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Dimensions
                  Text(
                    'Measurements',
                    style: TextStyle(
                      fontSize: sectionTitleSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildDimensionCard(
                        'Width',
                        '${item.dimensions['width']} cm',
                        Icons.straighten,
                      ),
                      const SizedBox(width: 12),
                      _buildDimensionCard(
                        'Depth',
                        '${item.dimensions['depth']} cm',
                        Icons.straighten,
                      ),
                      const SizedBox(width: 12),
                      _buildDimensionCard(
                        'Height',
                        '${item.dimensions['height']} cm',
                        Icons.height,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Material
                  Text(
                    'Materials',
                    style: TextStyle(
                      fontSize: sectionTitleSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          color: Color(0xFF0058A3),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.material,
                            style: TextStyle(
                              fontSize: bodyTextSize,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Features
                  Text(
                    'Product features',
                    style: TextStyle(
                      fontSize: sectionTitleSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem('Easy to assemble'),
                  _buildFeatureItem('Timeless design'),
                  _buildFeatureItem('High-quality materials'),
                  _buildFeatureItem('Sustainable production'),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/ar',
                      arguments: item,
                    );
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: Text('View in AR',
                      style: TextStyle(fontSize: bodyTextSize)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0058A3),
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final cartNotifier = CartProvider.of(context);
                    cartNotifier?.addItem(item);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.name} added to cart'),
                        duration: const Duration(milliseconds: 1000),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: Text('Add to Cart',
                      style: TextStyle(fontSize: bodyTextSize)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBD914),
                    foregroundColor: Colors.black,
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionCard(String label, String value, IconData icon) {
    return Expanded(
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final screenWidth = MediaQuery.of(context).size.width;
          final labelFontSize = screenWidth * 0.03; // 3% of screen width
          final valueFontSize = screenWidth * 0.035; // 3.5% of screen width

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(icon, color: const Color(0xFF0058A3)),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final iconSize = screenWidth * 0.05; // 5% of screen width
        final textSize = screenWidth * 0.038; // 3.8% of screen width

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: const Color(0xFF0058A3),
                size: iconSize,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: textSize),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
