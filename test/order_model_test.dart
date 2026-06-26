import 'package:flutter_test/flutter_test.dart';
import 'package:ar_furniture/models/order_model.dart';

void main() {
  group('OrderModel', () {
    test('fromMap reads fields and a String createdAt', () {
      final order = OrderModel.fromMap('order1', {
        'userId': 'u1',
        'userEmail': 'a@b.com',
        'createdAt': '2026-01-01',
        'status': OrderStatus.completed,
        'total': 1500,
      });

      expect(order.id, 'order1');
      expect(order.userId, 'u1');
      expect(order.userEmail, 'a@b.com');
      expect(order.createdAt, '2026-01-01');
      expect(order.status, OrderStatus.completed);
      expect(order.total, 1500.0);
    });

    test('fromMap applies defaults for missing fields', () {
      final order = OrderModel.fromMap('order2', {});
      expect(order.userId, '');
      expect(order.userEmail, '');
      expect(order.status, OrderStatus.pending);
      expect(order.total, 0.0);
    });

    test('coerces integer totals to double', () {
      final order = OrderModel.fromMap('order3', {'total': 99});
      expect(order.total, isA<double>());
      expect(order.total, 99.0);
    });

    test('toMap round-trips the core fields', () {
      final order = OrderModel(
        id: 'x',
        userId: 'u',
        userEmail: 'e@e.com',
        createdAt: '2026-06-27',
        status: OrderStatus.pending,
        total: 42.0,
      );
      final map = order.toMap();
      expect(map['userId'], 'u');
      expect(map['userEmail'], 'e@e.com');
      expect(map['status'], OrderStatus.pending);
      expect(map['total'], 42.0);
    });
  });
}
