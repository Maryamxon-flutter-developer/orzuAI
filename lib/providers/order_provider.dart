import 'package:flutter/material.dart';
import 'package:orzulab/models/order_item.dart';
import 'package:orzulab/models/style_item.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderItem> _orders = [];

  List<OrderItem> get orders => [..._orders];

  void addOrder(List<StyleItem> cartProducts, double total, String paymentMethod) {
    // Yangi buyurtmani ro'yxat boshiga qo'shamiz
    _orders.insert(
      0,
      OrderItem(
        id: DateTime.now().toString(),
        items: cartProducts,
        totalAmount: total,
        orderDate: DateTime.now(),
        paymentMethod: paymentMethod,
      ),
    );
    notifyListeners();
  }
}