import 'package:flutter/material.dart';
import 'package:orzulab/pages/home_page.dart'; // StyleItem, User, DataService shu faylda

class StyleProvider with ChangeNotifier {
  List<StyleItem> _allStyles = []; // Barcha elementlar (o'zgarmas nusxa)
  List<StyleItem> _filteredStyles = []; // Faqat qidiruv natijalari
  bool _isLoading = true;
  User? _user;

  // Getter'lar
  List<StyleItem> get allItems => _filteredStyles;
  List<StyleItem> get favoriteItems =>
      _filteredStyles.where((item) => item.isFavorite).toList();
  bool get isLoading => _isLoading;
  User? get user => _user;

  // Konstruktor: dastlabki ma'lumotlarni yuklaydi
  StyleProvider() {
    loadInitialData();
  }

  /// Ma'lumotlarni yuklash
  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        DataService.getCurrentUser(),
        DataService.getAllStyles(),
      ]);
      _user = results[0] as User;
      _allStyles = results[1] as List<StyleItem>;
      _filteredStyles = _allStyles; // Avval barcha elementlar ko‘rsatiladi
    } catch (e) {
      print("Ma'lumotlarni yuklashda xatolik: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sevimlilarni almashtirish
  Future<void> toggleFavorite(String itemId) async {
    final index = _filteredStyles.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final current = _filteredStyles[index];
      final updated = current.copyWith(isFavorite: !current.isFavorite);
      _filteredStyles[index] = updated;

      // Barcha ro'yxatda ham yangilash kerak
      final allIndex = _allStyles.indexWhere((item) => item.id == itemId);
      if (allIndex != -1) {
        _allStyles[allIndex] = updated;
      }

      notifyListeners();
      await DataService.updateFavoriteStatus(itemId, updated.isFavorite);
    }
  }

  /// Qidiruvni amalga oshirish
  void searchItems(String query) {
    if (query.isEmpty) {
      _filteredStyles = _allStyles;
    } else {
      _filteredStyles = _allStyles.where((item) =>
          item.title.toLowerCase().contains(query.toLowerCase()) ||
          item.category.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }
}
