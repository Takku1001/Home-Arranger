import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ar_furniture/models/furniture_model.dart';
import 'package:ar_furniture/providers/cart_provider.dart';

void main() {
  testWidgets('CartProvider exposes the notifier and rebuilds on change',
      (tester) async {
    final notifier = CartNotifier();

    final furniture = FurnitureItem(
      id: '1',
      name: 'Test Chair',
      description: 'desc',
      price: 100,
      category: 'Chairs',
      imageUrl: 'assets/images/chair.png',
      modelUrl: 'assets/models/chair.glb',
      colors: const ['Default'],
      dimensions: const {'width': 1, 'depth': 1, 'height': 1},
      material: 'Wood',
    );

    await tester.pumpWidget(
      CartProvider(
        cartNotifier: notifier,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              final cart = CartProvider.of(context)!.cart;
              return Scaffold(
                body: Text('Items: ${cart.itemCount}'),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Items: 0'), findsOneWidget);

    notifier.addItem(furniture);
    await tester.pump();

    expect(find.text('Items: 1'), findsOneWidget);
  });
}
