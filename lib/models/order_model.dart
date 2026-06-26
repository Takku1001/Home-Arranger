import 'package:cloud_firestore/cloud_firestore.dart';

class OrderStatus {
  static const String pending = 'pending';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
}

class OrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final String createdAt;
  final String status;
  final double total;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.createdAt,
    required this.status,
    required this.total,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    // Handle Firestore Timestamp conversion
    String createdAtStr = '';
    final createdAtField = data['createdAt'];
    if (createdAtField is Timestamp) {
      createdAtStr = createdAtField.toDate().toString();
    } else if (createdAtField is String) {
      createdAtStr = createdAtField;
    }

    return OrderModel(
      id: id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      createdAt: createdAtStr,
      status: data['status'] ?? OrderStatus.pending,
      total: (data['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'createdAt': createdAt,
      'status': status,
      'total': total,
    };
  }
}
