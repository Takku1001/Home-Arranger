import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/cart_provider.dart';
import '../models/order_model.dart';
import '../widgets/profile_sidebar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartNotifier = CartProvider.of(context);
    final cart = cartNotifier?.cart;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final iconSize = screenWidth * 0.30; // 30% of screen width
    final titleFontSize = screenWidth * 0.06; // 6% of screen width
    final subtitleFontSize = screenWidth * 0.04; // 4% of screen width
    final buttonPaddingH = screenWidth * 0.08; // 8% of screen width
    final buttonPaddingV = screenHeight * 0.02; // 2% of screen height

    if (cart == null || cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'Profile',
              onPressed: () {
                ProfileSidebar.show(context);
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: iconSize,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add items to get started',
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/store');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: buttonPaddingH,
                    vertical: buttonPaddingV,
                  ),
                ),
                child: const Text('Browse Furniture'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart (${cart.itemCount} items)'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              ProfileSidebar.show(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear cart',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Cart'),
                  content: const Text('Remove all items from cart?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        cartNotifier?.clear();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final cartItem = cart.items[index];
                final furniture = cartItem.furniture;

                final imageSize = screenWidth * 0.20; // 20% of screen width
                final iconSizeInCard =
                    screenWidth * 0.10; // 10% of screen width
                final nameFontSize = screenWidth * 0.04; // 4% of screen width
                final categoryFontSize =
                    screenWidth * 0.035; // 3.5% of screen width
                final priceFontSize =
                    screenWidth * 0.045; // 4.5% of screen width
                final quantityFontSize =
                    screenWidth * 0.04; // 4% of screen width

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Furniture Image
                        Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: furniture.imagePath != null
                                ? Image.asset(
                                    furniture.imagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.chair_outlined,
                                        size: iconSizeInCard,
                                        color: Colors.grey[600],
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.chair_outlined,
                                    size: iconSizeInCard,
                                    color: Colors.grey[600],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Furniture Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                furniture.name,
                                style: TextStyle(
                                  fontSize: nameFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                furniture.category,
                                style: TextStyle(
                                  fontSize: categoryFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rs ${cartItem.totalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: priceFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0058A3),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Quantity Controls
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    if (cartItem.quantity > 1) {
                                      cartNotifier?.updateQuantity(
                                        furniture.id,
                                        cartItem.quantity - 1,
                                      );
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    '${cartItem.quantity}',
                                    style: TextStyle(
                                      fontSize: quantityFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    cartNotifier?.updateQuantity(
                                      furniture.id,
                                      cartItem.quantity + 1,
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                cartNotifier?.removeItem(furniture.id);
                              },
                              icon: const Icon(Icons.delete, size: 16),
                              label: const Text('Remove'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Summary
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(fontSize: subtitleFontSize),
                      ),
                      Text(
                        'Rs ${cart.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shipping',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'FREE',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rs ${cart.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize:
                              titleFontSize * 1.2, // Slightly larger than title
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0058A3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please log in to checkout')),
                          );
                          return;
                        }

                        try {
                          // Create order in Firestore
                          await FirebaseFirestore.instance
                              .collection('orders')
                              .add({
                            'userId': user.uid,
                            'userEmail': user.email ?? '',
                            'createdAt': FieldValue.serverTimestamp(),
                            'status': OrderStatus.pending,
                            'total': cart.totalPrice,
                          });

                          // Clear cart
                          cartNotifier?.clear();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order placed successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0058A3),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: buttonPaddingV),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
