import 'package:flutter/material.dart';
import '../models/cart_model.dart';

class CartProvider extends InheritedNotifier<CartNotifier> {
  const CartProvider({
    super.key,
    required CartNotifier cartNotifier,
    required super.child,
  }) : super(notifier: cartNotifier);

  static CartNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CartProvider>()?.notifier;
  }
}

class CartNotifier extends ChangeNotifier {
  final CartModel _cart = CartModel();

  CartModel get cart => _cart;

  void addItem(dynamic furniture) {
    _cart.addItem(furniture);
    notifyListeners();
  }

  void removeItem(String furnitureId) {
    _cart.removeItem(furnitureId);
    notifyListeners();
  }

  void updateQuantity(String furnitureId, int quantity) {
    _cart.updateQuantity(furnitureId, quantity);
    notifyListeners();
  }

  void clear() {
    _cart.clear();
    notifyListeners();
  }
}
