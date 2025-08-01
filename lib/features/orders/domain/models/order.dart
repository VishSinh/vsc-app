import 'order_item.dart';

/// Pure business entity representing an order
class Order {
  final String id;
  final String customerId;
  final DateTime deliveryDate;
  final List<OrderItem> orderItems;
  final OrderStatus status;
  final double totalAmount;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customerId,
    required this.deliveryDate,
    required this.orderItems,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  /// Create a copy with updated values
  Order copyWith({
    String? id,
    String? customerId,
    DateTime? deliveryDate,
    List<OrderItem>? orderItems,
    OrderStatus? status,
    double? totalAmount,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      orderItems: orderItems ?? this.orderItems,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Order status enum
enum OrderStatus { pending, confirmed, inProgress, completed, cancelled }
