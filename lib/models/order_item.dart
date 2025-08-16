
import 'package:orzulab/models/style_item.dart';

class OrderItem {
  final String id;
  final List<StyleItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final String paymentMethod;

  OrderItem({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.paymentMethod,
  });
}