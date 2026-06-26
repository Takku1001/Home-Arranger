import 'furniture_model.dart';

class CartItem {
  final FurnitureItem furniture;
  int quantity;

  CartItem({
    required this.furniture,
    this.quantity = 1,
  });

  double get totalPrice => furniture.price * quantity;
}

class CartModel {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addItem(FurnitureItem furniture) {
    final existingIndex = _items.indexWhere(
      (item) => item.furniture.id == furniture.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(furniture: furniture));
    }
  }

  void removeItem(String furnitureId) {
    _items.removeWhere((item) => item.furniture.id == furnitureId);
  }

  void updateQuantity(String furnitureId, int quantity) {
    if (quantity <= 0) {
      removeItem(furnitureId);
      return;
    }

    final index = _items.indexWhere(
      (item) => item.furniture.id == furnitureId,
    );

    if (index >= 0) {
      _items[index].quantity = quantity;
    }
  }

  void clear() {
    _items.clear();
  }

  bool isInCart(String furnitureId) {
    return _items.any((item) => item.furniture.id == furnitureId);
  }

  int getQuantity(String furnitureId) {
    final index = _items.indexWhere(
      (item) => item.furniture.id == furnitureId,
    );
    return index >= 0 ? _items[index].quantity : 0;
  }
}
