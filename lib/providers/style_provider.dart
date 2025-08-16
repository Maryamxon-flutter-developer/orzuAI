// providers/style_provider.dart

import 'package:flutter/material.dart';
import 'package:orzulab/services/product_service.dart';
import 'package:orzulab/models/style_item.dart';
import 'package:orzulab/providers/auth_provider.dart';
import 'dart:developer' as developer;

class StyleProvider extends ChangeNotifier {
  final ProductService _productService;

  StyleProvider(this._productService);

  List<StyleItem> _originalItems = [];
  List<StyleItem> _filteredItems = [];
  bool _isLoading = false;
  String? _error;

  List<StyleItem> get displayedItems => _filteredItems;
  List<StyleItem> get allItems => _originalItems;
  List<StyleItem> get favoriteItems => _originalItems.where((item) => item.isFavorite).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

Future<void> loadInitialData(AuthProvider authProvider) async {
  // Agar ma'lumotlar allaqachon yuklanayotgan bo'lsa, qayta so'rov yubormaslik
  if (_isLoading) return;

  _error = null;
  _isLoading = true;
  notifyListeners();

  try {
    // Test ma'lumotlari o'rniga ProductService orqali serverdan ma'lumotlarni olamiz
    final items = await _productService.fetchProducts(authProvider);
    _originalItems = items;
    _filteredItems = List.from(_originalItems);
    _error = null;
  } catch (e) {
    developer.log('Mahsulotlarni yuklashda xatolik', name: 'StyleProvider', error: e);
    _error = e.toString();
    _originalItems = []; // Xatolik yuz berganda ro'yxatni bo'shatamiz
    _filteredItems = [];
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
  void searchItems(String query) {
    if (query.isEmpty) {
      _filteredItems = List.from(_originalItems);
    } else {
      _filteredItems = _originalItems
          .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final originalIndex = _originalItems.indexWhere((item) => item.id == id);
    if (originalIndex != -1) {
      _originalItems[originalIndex] = _originalItems[originalIndex].copyWith(isFavorite: !_originalItems[originalIndex].isFavorite);
      final filteredIndex = _filteredItems.indexWhere((item) => item.id == id);
      if (filteredIndex != -1) {
        _filteredItems[filteredIndex] = _originalItems[originalIndex];
      }
      notifyListeners();
    }
  }

  StyleItem? getItemById(String id) {
    try {
      return _originalItems.firstWhere((item) => item.id == id);
    } on StateError {
      return null;
    }
  }
}