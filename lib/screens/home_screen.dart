import 'package:flutter/material.dart';
import '../main.dart';
import '../models/furniture_model.dart';
import '../widgets/furniture_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/profile_sidebar.dart';
import '../providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<FurnitureItem> _furnitureItems =
      FurnitureItem.getSampleFurniture();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Chairs',
    'Tables',
    'Sofas',
    'Beds',
    'Storage',
  ];

  List<FurnitureItem> get _filteredItems {
    var items = _furnitureItems;

    // Filter by category
    if (_selectedCategory != 'All') {
      items =
          items.where((item) => item.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      items = items
          .where((item) =>
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return items;
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: FurnitureSearchDelegate(_furnitureItems),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeController.of(context);
    final isDark = themeController?.themeMode == ThemeMode.dark;
    final cartNotifier = CartProvider.of(context);
    final cartCount = cartNotifier?.cart.itemCount ?? 0;

    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = screenWidth * 0.065; // 6.5% of screen width
    final crossAxisCount = screenWidth > 600 ? 3 : 2; // 3 columns for tablets
    final childAspectRatio = screenWidth > 600 ? 0.75 : 0.7;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Store',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              ProfileSidebar.show(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      cartCount > 99 ? '99+' : '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF1E1E1E) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Categories
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return CategoryChip(
                    label: category,
                    isSelected: _selectedCategory == category,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Furniture Grid
            Expanded(
              child: _filteredItems.isEmpty
                  ? const Center(
                      child: Text('No items in this category'),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        return FurnitureCard(
                          item: _filteredItems[index],
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/product',
                              arguments: _filteredItems[index],
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class FurnitureSearchDelegate extends SearchDelegate<FurnitureItem?> {
  final List<FurnitureItem> furnitureItems;

  FurnitureSearchDelegate(this.furnitureItems);

  @override
  String get searchFieldLabel => 'Search furniture...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = furnitureItems.where((item) {
      final nameLower = item.name.toLowerCase();
      final categoryLower = item.category.toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower) ||
          categoryLower.contains(searchLower);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No furniture found',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return FurnitureCard(
          item: results[index],
          onTap: () {
            close(context, results[index]);
            Navigator.pushNamed(
              context,
              '/product',
              arguments: results[index],
            );
          },
        );
      },
    );
  }
}
