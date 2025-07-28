// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:orzulab/services/api_services.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Holatni aniqroq boshqarish uchun
enum AuthStatus { unknown, authenticating, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  // Private o'zgaruvchilar (faqat shu class ichida ishlatiladi)
  String? _token;                    // JWT token saqlash
  Map<String, dynamic>? _user;       // Foydalanuvchi ma'lumotlari
  bool _isLoading = false;           // Loading holati
  String? _error;                    // Xato xabarlari
  AuthStatus _status = AuthStatus.unknown; // Boshlang'ich holat
  
  // Register jarayoni uchun
  String? _pendingEmail;             // Tasdiqlash kutilayotgan email
  bool _isEmailSent = false;         // Email yuborilganmi?
  
  // Public getters (boshqa joylardan o'qish uchun)
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null;        // Token bor = login qilgan
  String? get pendingEmail => _pendingEmail;
  bool get isEmailSent => _isEmailSent;
  AuthStatus get status => _status;
  
  // Loading holatini o'zgartirish
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // UI ni yangilash uchun
  }
  
  // Xato xabarini o'rnatish
  void _setError(String? error) {
    _error = error;
    // Debug uchun xatolikni har doim konsolga chiqarish
    if (error != null) {
      print('[AUTH_PROVIDER_ERROR]: $error');
    }
    notifyListeners();
  }

  // Serverdan kelgan xato (Map) ni o'qiladigan String'ga o'tkazish
  String _parseError(dynamic error) {
    // Agar ApiService xatoni allaqachon Map ko'rinishida qaytargan bo'lsa
    if (error is Map<String, dynamic>) {
      return _extractErrorMessage(error);
    }

    // Xato obyekti String ko'rinishida kelishi mumkin (masalan, Exception.toString())
    final String errorString = error.toString();

    // Tarmoq xatolarini aniqlash (masalan, "Connection refused")
    if (errorString.contains('SocketException') || errorString.contains('ClientException')) {
        return 'Serverga ulanib bo‘lmadi. Internet aloqasini tekshiring yoki keyinroq qayta urinib ko‘ring.';
    }

    try {
      // Xato matnining ichidan JSON qismini ajratib olish
      int jsonStartIndex = errorString.indexOf('{');
      if (jsonStartIndex != -1) {
        String jsonPart = errorString.substring(jsonStartIndex);
        final decoded = jsonDecode(jsonPart);
        if (decoded is Map<String, dynamic>) {
          return _extractErrorMessage(decoded);
        }
      }
    } catch (e) {
      // JSON tahlilida xatolik bo'lsa, texnik qismlarni olib tashlash
      if (errorString.startsWith('Exception: ')) {
        return errorString.substring('Exception: '.length);
      }
    }

    // Eng oxirgi chora sifatida xatoning o'zini qaytaramiz
    return errorString;
  }

  String _extractErrorMessage(Map<String, dynamic> decoded) {
    // Django REST Framework'ning umumiy xatolari uchun ("non_field_errors")
    if (decoded.containsKey('non_field_errors') && decoded['non_field_errors'] is List) {
      return (decoded['non_field_errors'] as List).join(' ');
    }
    // Eng ko'p uchraydigan xato formatlarini tekshirish
    if (decoded.containsKey('detail') && decoded['detail'] is String) return decoded['detail'];
    if (decoded.containsKey('message') && decoded['message'] is String) return decoded['message'];
    if (decoded.containsKey('error') && decoded['error'] is String) return decoded['error'];

    // Agar xato maydonlar bo'yicha bo'lsa (masalan, "email": ["..."])
    var messages = <String>[];
    decoded.forEach((key, value) {
      if (value is List) {
        messages.add('$key: ${value.join(', ')}');
      } else {
        messages.add('$key: $value');
      }
    });

    if (messages.isNotEmpty) {
      return messages.join('\n');
    }

    return 'Noma’lum xatolik yuz berdi.';
  }
  
  // 1-BOSQICH: Register qilish funksiyasi
  Future<bool> register(
    String fullName,    // To'liq ism
    String email,       // Email
    String phone,       // Telefon
    String password,    // Parol
    String password2    // Parolni takrorlash
  ) async {
    _setLoading(true);  // Loading boshlash
    _status = AuthStatus.authenticating;
    _setError(null);    // Oldingi xatolarni tozalash
    
    try {
      // API Service orqali serverga so'rov yuborish.
      // Agar xatolik bo'lsa (status 400, 500), ApiService o'zi Exception tashlaydi
      // va kod to'g'ridan-to'g'ri 'catch' blokiga o'tadi.
      final response = await ApiService.register(fullName, email, phone, password, password2);
      
      print('Provider Register Response: $response');
      
      // Agar kod shu yerga yetib kelgan bo'lsa, demak ro'yxatdan o'tish muvaffaqiyatli bo'ldi.
      _pendingEmail = email;    // Email ni eslab qolish
      _isEmailSent = true;      // Email yuborilgan deb belgilash
      
      _setLoading(false);       // Loading tugatish
      notifyListeners();
      return true;              // Muvaffaqiyat
    } catch (e) {
      // Network yoki boshqa xatoliklar
      _setError(_parseError(e));
      _setLoading(false);
      _status = AuthStatus.unauthenticated;
      return false;
    }
  }
  
  // 2-BOSQICH: Email tasdiqlash funksiyasi
  Future<bool> verifyEmail(String code) async {
    // Agar pending email bo'lmasa xato
    if (_pendingEmail == null) {
      _status = AuthStatus.unauthenticated;
      _setError('No pending email verification');
      _setLoading(false); // Loading holatini to'g'rilash
      return false;
    }
    
    _status = AuthStatus.authenticating;
    _setLoading(true);
    _setError(null);
    
    try {
      // API Service orqali kod yuborish
      final response = await ApiService.verifyEmail(_pendingEmail!, code);
      
      print('Provider Verify Email Response: $response');
      
      // Agar verification muvaffaqiyatli bo'lsa va token kelsa
      if (response.containsKey('access') || response.containsKey('token')) {
        _token = response['access'] ?? response['token'];  // Token olish
        _user = response['user'] ?? response;             // User ma'lumotlari
        
        // Token ni telefonda saqlash (keyingi safar avtomatik kirish uchun)
        if (_token != null) {
          await _saveToken(_token!);
        }
        
        // Holalni tozalash
        _pendingEmail = null;
        _isEmailSent = false;
        
        _status = AuthStatus.authenticated;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? response['error'] ?? 'Email verification failed');
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(_parseError(e));
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }
  
  // LOGIN: Mavjud foydalanuvchilar uchun
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _status = AuthStatus.authenticating;
    _setError(null);
    
    try {
      final response = await ApiService.login(email, password);
      
      print('Provider Login Response: $response');
      
      // Serverdan kelgan javobni tekshirish. Login javobi 'tokens' ichida kelmoqda.
      final tokens = response['tokens'];
      if (tokens is Map && tokens.containsKey('access')) {
        _token = tokens['access'];
        
        if (_token == null) {
          throw Exception('Access token not found in response');
        }
        await _saveToken(_token!);
        _status = AuthStatus.authenticated;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        // Agar 'tokens' yoki 'access' kalitlari topilmasa, xatolik beramiz.
        // Serverdan kelgan xato xabarini ishlatishga harakat qilamiz.
        _setError(_parseError(response));
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(_parseError(e));
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }
  
  // Kodni qayta yuborish
  Future<bool> resendVerificationCode() async {
    if (_pendingEmail == null) {
      _setError('No pending email verification');
      return false;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await ApiService.resendVerificationCode(_pendingEmail!);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_parseError(e));
      _setLoading(false);
      return false;
    }
  }
  
  // LOGOUT: Tizimdan chiqish
  Future<void> logout() async {
    _token = null;
    _user = null;
    _error = null;
    _pendingEmail = null;
    _isEmailSent = false;
    
    _status = AuthStatus.unauthenticated;
    await _removeToken();  // Saqlangan tokenni o'chirish
    notifyListeners();
  }
  
  // Token ni telefon xotirasida saqlash (SharedPreferences)
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  // Saqlangan tokenni yuklash (app ochilganda)
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    
    if (_token != null) {
      // Token bor bo'lsa, foydalanuvchi tizimga kirgan hisoblanadi.
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    
    notifyListeners();
  }
  
  // Saqlangan tokenni o'chirish
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  // Xato xabarini tozalash
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Register jarayonini bekor qilish
  void cancelRegistration() {
    _pendingEmail = null;
    _isEmailSent = false;
    _error = null;
    notifyListeners();
  }
}