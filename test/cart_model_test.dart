import 'package:flutter_test/flutter_test.dart';
import 'package:ar_furniture/models/cart_model.dart';
import 'package:ar_furniture/models/furniture_model.dart';

FurnitureItem _item(String id, {double price = 100.0}) => FurnitureItem(
      id: id,
      name: 'Item $id',
      description: 'desc',
      price: price,
      category: 'Chairs',
      imageUrl: 'assets/images/chair.png',
      modelUrl: 'assets/models/chair.glb',
      colors: const ['Default'],
      dimensions: const {'width': 1, 'depth': 1, 'height': 1},
      material: 'Wood',
    );

void main() {
  group('CartModel', () {
    late CartModel cart;

    setUp(() => cart = CartModel());

    test('starts empty', () {
      expect(cart.items, isEmpty);
      expect(cart.itemCount, 0);
      expect(cart.totalPrice, 0.0);
    });

    test('addItem adds a new item with quantity 1', () {
      cart.addItem(_item('1'));
      expect(cart.items.length, 1);
      expect(cart.getQuantity('1'), 1);
      expect(cart.isInCart('1'), isTrue);
    });

    test('addItem merges duplicates by id and increments quantity', () {
      cart.addItem(_item('1'));
      cart.addItem(_item('1'));
      cart.addItem(_item('1'));
      expect(cart.items.length, 1);
      expect(cart.getQuantity('1'), 3);
      expect(cart.itemCount, 3);
    });

    test('itemCount sums quantities across distinct items', () {
      cart.addItem(_item('1'));
      cart.addItem(_item('2'));
      cart.addItem(_item('2'));
      expect(cart.items.length, 2);
      expect(cart.itemCount, 3);
    });

    test('totalPrice is sum of price * quantity', () {
      cart.addItem(_item('1', price: 100));
      cart.addItem(_item('1', price: 100)); // qty 2 -> 200
      cart.addItem(_item('2', price: 50)); // 50
      expect(cart.totalPrice, 250.0);
    });

    test('updateQuantity sets an explicit quantity', () {
      cart.addItem(_item('1'));
      cart.updateQuantity('1', 5);
      expect(cart.getQuantity('1'), 5);
    });

    test('updateQuantity to zero or below removes the item', () {
      cart.addItem(_item('1'));
      cart.updateQuantity('1', 0);
      expect(cart.isInCart('1'), isFalse);
      cart.addItem(_item('2'));
      cart.updateQuantity('2', -3);
      expect(cart.isInCart('2'), isFalse);
    });

    test('removeItem removes only the matching item', () {
      cart.addItem(_item('1'));
      cart.addItem(_item('2'));
      cart.removeItem('1');
      expect(cart.isInCart('1'), isFalse);
      expect(cart.isInCart('2'), isTrue);
    });

    test('clear empties the cart', () {
      cart.addItem(_item('1'));
      cart.addItem(_item('2'));
      cart.clear();
      expect(cart.items, isEmpty);
      expect(cart.itemCount, 0);
    });

    test('items getter is unmodifiable', () {
      cart.addItem(_item('1'));
      expect(() => cart.items.add(CartItem(furniture: _item('2'))),
          throwsUnsupportedError);
    });

    test('CartItem.totalPrice reflects quantity', () {
      final ci = CartItem(furniture: _item('1', price: 30), quantity: 4);
      expect(ci.totalPrice, 120.0);
    });
  });
}
