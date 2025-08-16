import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orzulab/models/user_profile.dart';
import 'package:orzulab/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Foydalanuvchi autentifikatsiya holatini ifodalovchi enum
enum AuthStatus {
  unknown,          // Boshlang'ich holat, foydalanuvchi tizimga kirganmi yoki yo'qmi, noma'lum
  unauthenticated,  // Foydalanuvchi tizimga kirmagan
  authenticating,   // Tizimga kirish yoki ro'yxatdan o'tish jarayonida
  authenticated,    // Foydalanuvchi muvaffaqiyatli tizimga kirgan
}

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  String? _token;
  String? _refreshToken;
  UserProfile? _userProfile;
  String? _error;
  bool _isLoading = false;
  String? _pendingEmail; // Emailni tasdiqlash jarayoni uchun

  // UI (interfeys) holatni o'qishi uchun getter'lar
  AuthStatus get status => _status;
  String? get token => _token;
  String? get refreshTokenValue => _refreshToken; // Tashqaridan refresh token olish uchun
  UserProfile? get userProfile => _userProfile;
  String? get error => _error;
  bool get isLoading => _isLoading;
  String? get pendingEmail => _pendingEmail;

  AuthProvider() {
    _tryAutoLogin();
  }

  // Agar qurilma xotirasida token saqlangan bo'lsa, avtomatik tizimga kirishga harakat qiladi
  // YAXSHILANGAN VERSIYA: Endi tokenning yaroqliligini tekshiradi va kerak bo'lsa yangilaydi.
  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token') || !prefs.containsKey('refresh_token')) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _token = prefs.getString('token');
    _refreshToken = prefs.getString('refresh_token');

    _status = AuthStatus.authenticating; // Vaqtinchalik holat
    notifyListeners();

    // YAXSHILANGAN MANTIQ: `fetchUserProfile` endi o'zida token yangilash mantig'iga ega.
    try {
      await fetchUserProfile();
      _status = AuthStatus.authenticated;
      developer.log("Auto-login: Muvaffaqiyatli tizimga kirildi (token yangilangan bo'lishi mumkin).", name: "AuthProvider");
    } catch (e) {
      // Agar `fetchUserProfile` (va undan keyin token yangilash) muvaffaqiyatsiz bo'lsa,
      // u `AuthException` tashlaydi va `logout()`ni chaqirgan bo'ladi.
      // Bu yerda faqat holatni to'g'ri o'rnatish qoladi.
      developer.log("Auto-login muvaffaqiyatsiz tugadi.", name: "AuthProvider", error: e);
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  // Tokenni yangilash uchun metod
  Future<bool> refreshToken() async {
    if (_refreshToken == null) {
      developer.log("Refresh token mavjud emas, yangilab bo'lmadi.", name: "AuthProvider.refreshToken");
      return false;
    }

    try {
      // Muhim: ApiService'da refresh token yordamida yangi access token olish uchun
      // metod bo'lishi kerak. Masalan: ApiService.refreshToken(_refreshToken!)
      final response = await ApiService.refreshToken(_refreshToken!);

      final newAccessToken = _findTokenInMap(response); // 'access' yoki 'token' kalitini qidiradi

      if (newAccessToken != null) {
        _token = newAccessToken;

        // Ba'zi API'lar refresh token'ni yangilagandan keyin yangi refresh token ham berishi mumkin.
        // Agar shunday bo'lsa, uni ham saqlash kerak.
        final newRefreshToken = _findRefreshTokenInMap(response);
        if (newRefreshToken != null) {
          _refreshToken = newRefreshToken;
        }

        // Yangilangan tokenlarni xotiraga saqlaymiz
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('refresh_token', _refreshToken!); // Refresh token'ni ham yangilaymiz

        developer.log("Token muvaffaqiyatli yangilandi.", name: "AuthProvider.refreshToken");
        return true;
      } else {
        developer.log("Token yangilashdan keyin javobda access token topilmadi.", name: "AuthProvider.refreshToken", error: response);
        return false;
      }
    } catch (e) {
      developer.log("Tokenni yangilashda xatolik yuz berdi.", name: "AuthProvider.refreshToken", error: e);
      // Xatolik yuz berganda, bu refresh token yaroqsiz ekanligini anglatishi mumkin.
      return false;
    }
  }

  // Foydalanuvchi ma'lumotlarini serverdan olib, holatni yangilaydi
  // YAXSHILANGAN VERSIYA: Endi xatolik bo'lsa darhol logout qilmaydi, xatoni yuqoriga uzatadi.
  Future<void> fetchUserProfile() async {
    // Barcha autentifikatsiyalangan so'rovlar uchun yagona markazdan foydalanamiz.
    // Bu token eskirganda avtomatik yangilanishini ta'minlaydi.
    final userData = await _callAuthenticatedApi((token) => ApiService.getMe(token));
    var profile = UserProfile.fromJson(userData);

    // Mahalliy saqlangan rasm manzilini tekshiramiz
    final prefs = await SharedPreferences.getInstance();
    final localImagePath = prefs.getString('profile_picture_path');
    // Agar mahalliy rasm mavjud bo'lsa, serverdan kelgan rasm o'rniga shuni ishlatamiz
    if (localImagePath != null && await File(localImagePath).exists()) {
      profile = profile.copyWith(profilePicture: localImagePath);
    }
    _userProfile = profile;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _startLoading();
    try {
      final response = await ApiService.login(email, password);
      final receivedToken = _findTokenInMap(response);
      final receivedRefreshToken = _findRefreshTokenInMap(response);

      if (receivedToken != null && receivedRefreshToken != null) {
        _token = receivedToken;
        _refreshToken = receivedRefreshToken;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('refresh_token', _refreshToken!);
        _status = AuthStatus.authenticated;
        await fetchUserProfile(); // Tizimga kirgandan so'ng profilni yuklash
        _finishLoading();
        return true;
      } else {
        developer.log('Serverdan tokersiz javob keldi: $response', name: 'AuthProvider.login');
        _setError('Tizimga kirish muvaffaqiyatli, lekin token kelmadi.');
        return false;
      }
    } catch (e) {
      final errorMessage = _parseErrorMessage(e);
      _setError(errorMessage);
      // Agar xatolik emailni tasdiqlash kerakligi haqida bo'lsa,
      // foydalanuvchini tasdiqlash sahifasiga yo'naltirish uchun holatni o'zgartiramiz.
      final lowerCaseMessage = errorMessage.toLowerCase();
      if (lowerCaseMessage.contains('email') && (lowerCaseMessage.contains('verify') || lowerCaseMessage.contains('tasdiqla'))) {
          _pendingEmail = email; // Tasdiqlash sahifasi uchun emailni saqlab qo'yamiz
          notifyListeners(); // _pendingEmail o'zgarganini UI'ga bildirish uchun
      }
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String phone, String password, String password2) async {
    _startLoading();
    try {
      await ApiService.register(fullName, email, phone, password, password2);
      _pendingEmail = email; // Keyingi qadam (tasdiqlash) uchun emailni saqlab qolamiz
      _finishLoading();
      return true;
    } catch (e) {
      _setError(_parseErrorMessage(e));
      return false;
    }
  }

  Future<bool> verifyEmail(String code) async {
    if (_pendingEmail == null) {
      _setError('Tasdiqlash uchun email topilmadi.');
      return false;
    }
    _startLoading();
    try {
      final response = await ApiService.verifyEmail(_pendingEmail!, code);
      final receivedToken = _findTokenInMap(response);
      final receivedRefreshToken = _findRefreshTokenInMap(response);
      
      if (receivedToken != null && receivedRefreshToken != null) {
        _token = receivedToken;
        _refreshToken = receivedRefreshToken;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('refresh_token', _refreshToken!);
        _status = AuthStatus.authenticated;
        await fetchUserProfile(); // Email tasdiqlangandan so'ng profilni yuklash
        _pendingEmail = null; // Tasdiqlangan emailni tozalaymiz
        _finishLoading();
        return true;
      } else {
        developer.log('Serverdan tokersiz javob keldi (verifyEmail): $response', name: 'AuthProvider.verifyEmail');
        _setError('Tasdiqlash muvaffaqiyatli, lekin avtorizatsiya tokeni kelmadi.');
        return false;
      }
    } catch (e) {
      _setError(_parseErrorMessage(e));
      return false;
    }
  }

  Future<bool> resendVerificationCode() async {
    if (_pendingEmail == null) {
      _setError('Kod yuborish uchun email topilmadi.');
      return false;
    }
    _startLoading();
    try {
      await ApiService.resendVerificationCode(_pendingEmail!);
      _finishLoading(notify: false); // Holat o'zgarmadi, shuning uchun UI'ni yangilash shart emas
      return true;
    } catch (e) {
      _setError(_parseErrorMessage(e));
      return false;
    }
  }

  void cancelRegistration() {
    _pendingEmail = null;
  }

  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _userProfile = null; // Tizimdan chiqqanda profil ma'lumotlarini tozalash
    _status = AuthStatus.unauthenticated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refresh_token');
    await prefs.remove('csrftoken');

    // Tizimdan chiqqanda mahalliy saqlangan rasmni va uning manzilini o'chiramiz
    final localImagePath = prefs.getString('profile_picture_path');
    if (localImagePath != null) {
      try {
        final file = File(localImagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        developer.log("Mahalliy rasmni o'chirishda xatolik: $e", name: "AuthProvider.logout");
      }
      await prefs.remove('profile_picture_path');
    }

    notifyListeners();
  }

  // Profil ma'lumotlarini (ism, telefon) yangilash
  Future<void> updateProfile({String? fullName, String? phone}) async {
    if (_token == null || _userProfile == null) {
      throw Exception("Foydalanuvchi tizimga kirmagan.");
    }
    try {
      // UI o'zining yuklanish holatini boshqargani uchun bu yerda _startLoading chaqirilmaydi
      final updatedData = await ApiService.updateProfile(
        _token!,
        fullName: fullName,
        phone: phone,
      );
      // Serverdan kelgan ma'lumotlarni yangilaymiz, lekin mahalliy saqlangan
      // profil rasmini saqlab qolamiz, agar u mavjud bo'lsa.
      var newProfile = UserProfile.fromJson(updatedData);
      final prefs = await SharedPreferences.getInstance();
      final localImagePath = prefs.getString('profile_picture_path');
      if (localImagePath != null && await File(localImagePath).exists()) {
        newProfile = newProfile.copyWith(profilePicture: localImagePath);
      }
      _userProfile = newProfile;
      notifyListeners();
    } catch (e) {
      // Xatolikni UI'ga yetkazish uchun qayta tashlaymiz
      throw Exception(_parseErrorMessage(e));
    }
  }

  // Profil rasmini yangilash (mahalliy saqlash)
  // TUZATISH: Rasm endi vaqtinchalik xotiradan ilovaning doimiy xotirasiga ko'chiriladi.
  // Bu ilovadan chiqib ketilganda ham rasm saqlanib qolishini ta'minlaydi.
  Future<void> updateProfilePicture(XFile image) async {
    if (_userProfile == null) {
      throw Exception("Profil yuklanmagan.");
    }
    try {
      // Rasmni doimiy xotiraga ko'chirish
      final directory = await getApplicationDocumentsDirectory();
      final permanentPath = p.join(directory.path, 'profile_picture.jpg');
      final imageFile = File(permanentPath);

      // Yangi rasmni saqlashdan OLDIN eski rasmni keshdan o'chiramiz.
      // Bu FileImage'ga fayl o'zgarganini "bildiradi" va uni qayta yuklashga majbur qiladi.
      // Agar bu qilinmasa, Flutter eski keshlangan rasmni ko'rsatishda davom etishi mumkin.
      if (await imageFile.exists()) {
        // `FileImage.evict()` - rasmni keshdan tozalashning rasmiy usuli.
        await FileImage(imageFile).evict();
      }

      // XFile'ni doimiy faylga saqlaymiz.
      await image.saveTo(permanentPath);

      // Doimiy manzilni saqlash
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_picture_path', permanentPath);
      _userProfile = _userProfile!.copyWith(profilePicture: permanentPath);
      notifyListeners();
    } catch (e) {
      throw Exception("Profil rasmini saqlashda xatolik: $e");
    }
  }

  // --- API so'rovlari uchun yordamchi metod ---

  /// Barcha autentifikatsiyalangan API so'rovlari uchun markaziy funksiya.
  ///
  /// Bu metod token eskirgan bo'lsa, uni avtomatik yangilaydi va so'rovni qayta urinadi.
  /// Bu kod takrorlanishining oldini oladi va xatoliklarni boshqarishni markazlashtiradi.
  /// [apiCall] - bu joriy `token`ni qabul qiluvchi va API so'rovini bajaruvchi funksiya.
  Future<T> _callAuthenticatedApi<T>(Future<T> Function(String token) apiCall) async {
    if (_token == null) {
      developer.log("Autentifikatsiya tokeni yo'q. Logout qilinmoqda.", name: "AuthProvider._callAuthenticatedApi");
      // Token yo'q bo'lsa, bu mantiqan tizimga kirmagan degani.
      // `logout` chaqirish barcha holatni tozalaydi.
      await logout();
      throw Exception('Foydalanuvchi tizimga kirmagan.');
    }

    try {
      // Birinchi urinish: joriy token bilan so'rovni yuborish
      return await apiCall(_token!);
    } catch (e) {
      // Xatolikni tekshiramiz, agar u "token eskirgan" (odatda 401 Unauthorized) bo'lsa.
      // Bu tekshiruv ApiService'dan keladigan xatolik matniga bog'liq.
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('401') || (errorString.contains('token') && (errorString.contains('expired') || errorString.contains('invalid') || errorString.contains('not valid')))) {
        developer.log("Token eskirgan yoki yaroqsiz. Yangilanmoqda...", name: "AuthProvider._callAuthenticatedApi");

        // Tokenni yangilashga harakat qilamiz
        final refreshed = await refreshToken();

        if (refreshed && _token != null) {
          developer.log("Token yangilandi. So'rov qayta yuborilmoqda.", name: "AuthProvider._callAuthenticatedApi");
          // Ikkinchi urinish: yangilangan token bilan so'rovni qayta yuborish
          return await apiCall(_token!);
        } else {
          // Agar token yangilash muvaffaqiyatsiz bo'lsa, bu refresh token ham yaroqsiz
          // degan ma'noni anglatadi. Foydalanuvchini tizimdan chiqaramiz.
          developer.log("Tokenni yangilab bo'lmadi. Logout qilinmoqda.", name: "AuthProvider._callAuthenticatedApi");
          await logout();
          throw Exception('Sessiya muddati tugadi. Iltimos, qayta tizimga kiring.');
        }
      } else {
        // Agar xatolik token bilan bog'liq bo'lmasa, uni o'zgarishsiz yuqoriga uzatamiz.
        rethrow;
      }
    }
  }

  // --- Holatni boshqarish uchun yordamchi metodlar ---

  void _startLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void _finishLoading({bool notify = true}) {
    _isLoading = false;
    if (notify) {
      notifyListeners();
    }
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    _isLoading = false;
    _status = AuthStatus.unauthenticated; // Xatolik bo'lganda, foydalanuvchi tizimga kirmagan holatga o'tadi
    notifyListeners();
  }

  // --- Ma'lumotlarni tahlil qilish uchun yordamchi metodlar ---

  // Serverdan kelgan javob (Map) ichidan tokenni rekursiv qidirish.
  // Bu usul server javobining tuzilishi o'zgarganda ham token topishga yordam beradi.
  String? _findTokenInMap(Map<String, dynamic> data) {
    const possibleTokenKeys = ['access', 'token'];
    for (final key in possibleTokenKeys) {
      if (data.containsKey(key) && data[key] is String) {
        return data[key] as String;
      }
    }

    // Ichki Map'larda (nested objects) qidirish
    for (final value in data.values) {
      if (value is Map<String, dynamic>) {
        final token = _findTokenInMap(value);
        if (token != null) {
          return token;
        }
      }
    }
    return null;
  }

  // Serverdan kelgan javob (Map) ichidan refresh tokenni rekursiv qidirish.
  String? _findRefreshTokenInMap(Map<String, dynamic> data) {
    const possibleTokenKeys = ['refresh', 'refresh_token'];
    for (final key in possibleTokenKeys) {
      if (data.containsKey(key) && data[key] is String) {
        return data[key] as String;
      }
    }

    // Ichki Map'larda (nested objects) qidirish
    for (final value in data.values) {
      if (value is Map<String, dynamic>) {
        final token = _findRefreshTokenInMap(value);
        if (token != null) {
          return token;
        }
      }
    }
    return null;
  }

  String _parseErrorMessage(Object e) {
    // ApiService'dan kelgan xatolik "Exception: { ...json... }" ko'rinishida bo'ladi
    final errorString = e.toString().replaceFirst('Exception: ', '').trim();
    try {
      // JSON formatiga o'girishga harakat qilamiz
      final errorJson = jsonDecode(errorString);
      if (errorJson is Map<String, dynamic>) {
        // Keng tarqalgan xatolik kalitlarini qidiramiz
        if (errorJson.containsKey('detail')) return errorJson['detail'];
        if (errorJson.containsKey('error')) return errorJson['error'];
        // Agar aniq kalit bo'lmasa, barcha qiymatlarni birlashtiramiz
        return errorJson.values.map((v) => v is List ? v.join(' ') : v.toString()).join(' ');
      }
      return errorString; // JSON, lekin Map emas
    } catch (_) {
      // Agar JSON bo'lmasa, xatolik matnini o'zini qaytaramiz
      return errorString;
    }
  }
}