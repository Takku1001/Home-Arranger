class FurnitureItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final String modelUrl;
  final String? imagePath; // PNG icon path
  final List<String> colors;
  final Map<String, double> dimensions;
  final String material;

  FurnitureItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.modelUrl,
    this.imagePath,
    required this.colors,
    required this.dimensions,
    required this.material,
  });

  static List<FurnitureItem> getSampleFurniture() {
    // Helper function to determine category from name
    String getCategory(String name) {
      final lowerName = name.toLowerCase();
      if (lowerName.contains('chair') ||
          lowerName.contains('stool') ||
          lowerName.contains('throne')) return 'Chairs';
      if (lowerName.contains('table') || lowerName.contains('desk'))
        return 'Tables';
      if (lowerName.contains('bed') || lowerName.contains('mattress'))
        return 'Beds';
      if (lowerName.contains('sofa') || lowerName.contains('couch'))
        return 'Sofas';
      // Lighting must be checked before Storage: "Standing lamp" contains the
      // "stand" substring used by the Storage rule and would otherwise match it.
      if (lowerName.contains('lamp')) return 'Lighting';
      if (lowerName.contains('shelf') ||
          lowerName.contains('bookcase') ||
          lowerName.contains('cabinet') ||
          lowerName.contains('drawer') ||
          lowerName.contains('closet') ||
          lowerName.contains('dresser') ||
          lowerName.contains('stand')) return 'Storage';
      if (lowerName.contains('kitchen') || lowerName.contains('dining'))
        return 'Dining';
      return 'Other';
    }

    // All furniture models
    final models = [
      'Baby Bed',
      'Baby Bed1',
      'Bakery Shelf',
      'Bed Double',
      'Bed Single',
      'Bed With Cabinet',
      'bed',
      'Big Couch',
      'Black Bed',
      'Blue Office Chair',
      'Book Shelf',
      'Bookcase Closed',
      'Bookshelf',
      'Bookshelf1',
      'Bunk Bed',
      'Bunk Bed1',
      'Cabinet Television Doo',
      'Cage',
      'Camp Bed',
      'Cart',
      'Chair Cushion',
      'Chair Round',
      'chair',
      'Chair2',
      'ChairB',
      'ChairC',
      'Closet',
      'Coffee Table',
      'Cool Bed',
      'Couch Large',
      'Couch Medium',
      'Couch Small',
      'Couch Small1',
      'Desk Chair',
      'Desk1',
      'Desk2',
      'Dining Set Brown',
      'Dining Set Red',
      'Dock Shelf',
      'Door mat',
      'Double Bed',
      'Double Couch',
      'Double Door Drawer',
      'Drafting Table',
      'Drawer',
      'Drawer1',
      'Drawers Base Cabinet',
      'Dresser',
      'Executive Chair',
      'Executive Desk',
      'Kitchen',
      'L Shaped Sofa',
      'Lava lamp',
      'Living Room Full',
      'Lounge Chair Red',
      'Lounge Chair',
      'Lounge Sofa',
      'Low Wide',
      'Majestic Bed',
      'Market Stand',
      'Mattress Bed',
      'Mattress',
      'Medistation',
      'Medium Cabinet',
      'Minimalist Modern Chair',
      'Modern Chair',
      'Night Stand',
      'Office Chair',
      'Office Chair1',
      'Office Setup',
      'Old Chair',
      'Picnic Bed',
      'Pool Table',
      'Pretty Stool',
      'Red Couchie',
      'Sack Bed',
      'Shelf Large',
      'Shelf Small',
      'Shelf Tall',
      'Shelf',
      'Short Closet',
      'Side Table',
      'Side Table1',
      'Single Bed',
      'Sofa1',
      'Sofa2',
      'Sofa3',
      'Standing lamp',
      'Stereo Furniture',
      'Stool',
      'Stool1',
      'Table angle - L',
      'Table Large Circular',
      'Table Round Small',
      'table',
      'Table2',
      'That Expensive Chair',
      'The Stabby Throne',
      'tv',
      'Velvet Sofa',
      'White Couch',
      'Wine Table',
      'Wood Chair',
      'Wood Floor',
      'Wooden Arm Chair',
      'Wooden Bed',
      'Wooden Office Chair',
    ];

    return models.asMap().entries.map((entry) {
      final index = entry.key;
      final name = entry.value;
      final category = getCategory(name);
      final hasPng = !['Bed2', 'Cerdenza Drawer', 'Red Sofa'].contains(name);

      // Realistic PKR pricing based on category
      double getPriceInPKR(String category) {
        switch (category) {
          case 'Chairs':
            return 8000.0 + (index * 500.0); // 8,000 - 60,000 PKR
          case 'Tables':
            return 15000.0 + (index * 800.0); // 15,000 - 100,000 PKR
          case 'Beds':
            return 35000.0 + (index * 1500.0); // 35,000 - 200,000 PKR
          case 'Sofas':
            return 45000.0 + (index * 2000.0); // 45,000 - 250,000 PKR
          case 'Storage':
            return 12000.0 + (index * 700.0); // 12,000 - 80,000 PKR
          case 'Lighting':
            return 3500.0 + (index * 300.0); // 3,500 - 35,000 PKR
          case 'Dining':
            return 25000.0 + (index * 1200.0); // 25,000 - 150,000 PKR
          default:
            return 10000.0 + (index * 600.0); // 10,000 - 70,000 PKR
        }
      }

      return FurnitureItem(
        id: '${index + 1}',
        name: name,
        description: 'High-quality $name for your home',
        price: getPriceInPKR(category),
        category: category,
        imageUrl:
            hasPng ? 'assets/images/$name.png' : 'assets/images/chair.png',
        modelUrl: 'assets/models/$name.glb',
        imagePath: hasPng ? 'assets/images/$name.png' : null,
        colors: ['Default'],
        dimensions: {'width': 60.0, 'depth': 60.0, 'height': 80.0},
        material: 'Premium Materials',
      );
    }).toList();
  }
}
