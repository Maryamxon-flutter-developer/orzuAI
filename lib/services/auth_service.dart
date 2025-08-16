// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

/// `AuthService` klassi autentifikatsiya tokenini boshqarish uchun
/// markazlashtirilgan yechimni taqdim etadi.
/// U tokenni qurilma xotirasida (`SharedPreferences`) saqlash, o'qish va o'chirish
/// uchun statik metodlarni o'z ichiga oladi.
class AuthService {
  // Tokenni saqlash uchun ishlatiladigan kalit so'z.
  // Bu kalit `AuthProvider`'da ishlatilgan kalit bilan bir xil bo'lishi muhim.
  static const String _tokenKey = 'access_token';

  /// Saqlangan JWT tokenni `SharedPreferences`'dan asinxron ravishda oladi.
  ///
  /// Agar token topilsa, uni `String` sifatida qaytaradi.
  /// Aks holda `null` qaytaradi.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Berilgan JWT tokenni `SharedPreferences`'ga saqlaydi.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Saqlangan JWT tokenni `SharedPreferences`'dan o'chiradi.
  /// Bu odatda "logout" (tizimdan chiqish) jarayonida ishlatiladi.
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
