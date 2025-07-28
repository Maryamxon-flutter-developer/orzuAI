import 'package:flutter/material.dart';
import 'package:orzulab/pages/home_page.dart'; // StyleItem klassi shu yerda deb taxmin qilindi

/// Savatdagi bitta mahsulotni ifodalovchi klass
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

/// Savat holatini boshqaruvchi Provider
class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => [..._items];

  int get itemCount {
    return _items.length;
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
}