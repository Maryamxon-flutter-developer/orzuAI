// lib/cart_provider.dart

import 'package:flutter/foundation.dart';
import 'package:orzulab/pages/home_page.dart'; // StyleItem klassini import qilish


// Savatdagi har bir mahsulotning holatini saqlash uchun yordamchi class
// Bu yerda mahsulotning o'zi va uning soni (quantity) saqlanadi
class CartItem {
  final StyleItem product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  // Savatdagi mahsulotlarni saqlash uchun Map.
  // Mahsulot ID'si (key) orqali ishlash qulay va tez.
  final Map<String, CartItem> _items = {};

  // Tashqaridan _items'ga to'g'ridan-to'g'ri o'zgartirish kiritishni cheklash uchun
  // uning nusxasini (copy) qaytaramiz.
  Map<String, CartItem> get items {
    return {..._items};
  }

  // Savatdagi noyob mahsulotlar sonini qaytaradi.
  int get itemCount {
    return _items.length;
  }

  // Savatdagi barcha mahsulotlarning umumiy narxini hisoblaydi.
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  // Savatga mahsulot qo'shish metodi
  void addItem(StyleItem product) {
    if (_items.containsKey(product.id)) {
      // Agar mahsulot savatda mavjud bo'lsa, uning sonini bittaga oshiramiz.
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // Agar mahsulot yangi bo'lsa, uni savatga qo'shamiz.
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product),
      );
    }
    // O'zgarishlar haqida UI'ni xabardor qilish. Bu eng muhim qator!
    notifyListeners();
  }

  // Mahsulotni savatdan butunlay olib tashlash
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Mahsulot sonini bittaga kamaytirish
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return; // Agar bunday mahsulot bo'lmasa, hech narsa qilmaymiz
    }
    if (_items[productId]!.quantity > 1) {
      // Agar mahsulot soni 1 dan ko'p bo'lsa, sonini kamaytiramiz
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      // Agar soni 1 ta bo'lsa, ro'yxatdan butunlay o'chiramiz
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Savatni butunlay tozalash
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
