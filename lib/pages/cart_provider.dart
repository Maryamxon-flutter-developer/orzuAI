// lib/cart_provider.dart

import 'package:flutter/material.dart';
import 'package:orzulab/models/style_item.dart';

// Savatdagi har bir mahsulotning holatini saqlash uchun yordamchi class
// Bu yerda mahsulotning o'zi va uning soni (quantity) saqlanadi
class CartItem {
  final StyleItem product;
  int quantity;
  final String size;
  final Color color;

  CartItem({
    required this.product,
    required this.quantity,
    required this.size,
    required this.color,
  });
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => [..._items];

  /// Savatdagi umumiy mahsulotlar sonini qaytaradi (har birining quantity'sini hisobga olgan holda)
  int get totalItemsCount {
    int count = 0;
    for (var item in _items) {
      count += item.quantity;
    }
    return count;
  }

  /// Savatdagi noyob mahsulot turlari soni
  int get uniqueItemCount {
    return _items.length;
  }

  /// Savatdagi barcha mahsulotlarning umumiy narxini hisoblaydi.
  double get totalAmount {
    var total = 0.0;
    for (var cartItem in _items) {
      total += cartItem.product.price * cartItem.quantity;
    }
    return total;
  }

  /// Mahsulotni savatga qo'shish
  void addToCart(StyleItem product, int quantity, String size, Color color) {
    // Agar savatda xuddi shu mahsulot va o'lcham mavjud bo'lsa, sonini oshiramiz
    final existingIndex = _items.indexWhere(
        (item) => item.product.id == product.id && item.size == size);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      // Aks holda, yangi mahsulot sifatida qo'shamiz
      _items.add(CartItem(
          product: product, quantity: quantity, size: size, color: color));
    }
    // O'zgarishlar haqida widget'larni xabardor qilamiz
    notifyListeners();
  }

  /// Mahsulot sonini bittaga oshiradi
  void increaseQuantity(CartItem cartItem) {
    cartItem.quantity++;
    notifyListeners();
  }

  /// Mahsulot sonini bittaga kamaytiradi
  void decreaseQuantity(CartItem cartItem) {
    // Faqatgina miqdor 1 dan katta bo'lsa kamaytiramiz
    if (cartItem.quantity > 1) {
      cartItem.quantity--;
      notifyListeners();
    }
  }

  /// Mahsulotni savatdan o'chirib tashlaydi
  void removeItem(CartItem cartItem) {
    _items.remove(cartItem);
    notifyListeners();
  }

  /// Savatni butunlay tozalash
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
