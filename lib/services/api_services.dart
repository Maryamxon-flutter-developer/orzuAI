import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API'dan 401 yoki 403 xatolik kelganda tashlanadigan maxsus xatolik.
class ApiAuthException implements Exception {
  final String message;
  ApiAuthException(this.message);
}

class ApiService {
  // Ilova murojaat qiladigan yagona va to'g'ri server manzili.
  // Bu manzil internetda joylashgani uchun ham emulyatorda, ham haqiqiy telefonda ishlaydi.
  static const String _baseUrl = 'https://beautyaiapp.duckdns.org';

  // Barcha so'rovlar uchun markazlashtirilgan javobni qayta ishlash funksiyasi
  static Future<Map<String, dynamic>> _handleResponse(
      http.Response response) async {
    // Serverdan kelgan javobni UTF-8 formatida o'qish
    final String responseBody = utf8.decode(response.bodyBytes);

    // Muvaffaqiyatli javob (status kodi 200-299 oralig'ida)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        // Agar javob bo'sh bo'lsa, muvaffaqiyat belgisi bilan bo'sh Map qaytaramiz
        if (responseBody.isEmpty) return {'success': true};
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } on FormatException {
        // Agar javob JSON formatida bo'lmasa, bu ham xatolik
        throw Exception(
            'Serverdan kutilmagan javob qaytdi (JSON emas). Status: ${response.statusCode}');
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Token yaroqsiz yoki mavjud emas. Maxsus xatolik tashlaymiz.
      // Bu AuthProvider'da tokenni yangilash mantig'ini ishga tushirishga yordam beradi.
      throw ApiAuthException(responseBody);
    } else {
      // Xatolik bilan kelgan javob (status kodi 4xx, 5xx)
      try {
        // Xato matnini JSON formatida o'qishga harakat qilamiz
        final errorBody = jsonDecode(responseBody);
        // Xatoni qayta JSONga o'girish shart emas, bu AuthProvider'da parse qilishni qiyinlashtiradi.
        // To'g'ridan-to'g'ri serverdan kelgan xato matnini uzatamiz.
        throw Exception(responseBody);
      } on FormatException {
        // Agar xato javobi ham JSON bo'lmasa (masalan, HTML xato sahifasi)
        final shortBody = responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody;
        throw Exception(
            'Server xatoligi (Status: ${response.statusCode}). Javob JSON emas: $shortBody');
      }
    }
  }

  // 1. Ro'yxatdan o'tish
  static Future<Map<String, dynamic>> register(
      String fullName, String email, String phone, String password, String password2) async { 
    final url = Uri.parse('$_baseUrl/users/register/customer/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone_number': phone, // Backend talabiga moslandi
        'password': password,
        'password2': password2,
      }),
    );
    return _handleResponse(response);
  }

  // 2. Emailni tasdiqlash
  static Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    final url = Uri.parse('$_baseUrl/users/verify-email/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'email': email, 
        'code': code,
      }),
    );
    return _handleResponse(response);
  }

  // 3. Tizimga kirish
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final body = {
      'email': email,
      'password': password,
    };
    // DEBUG: Serverga yuborilayotgan ma'lumotni konsolga chiqarish uchun `developer.log` dan foydalanamiz
    developer.log('Login request body: ${jsonEncode(body)}', name: 'ApiService.login');

    final url = Uri.parse('$_baseUrl/users/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );

    final setCookieHeader = response.headers['set-cookie'];
    if (setCookieHeader != null) {
      // Misol: 'csrftoken=...; expires=...; Max-Age=...; Path=/'
      final csrfCookie = setCookieHeader.split(';').firstWhere(
            (cookie) => cookie.trim().startsWith('csrftoken='),
        orElse: () => '',
      );
      if (csrfCookie.isNotEmpty) {
        final csrfToken = csrfCookie.split('=').last;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('csrftoken', csrfToken);
        developer.log('CSRF Token saqlandi: $csrfToken', name: 'ApiService');
      }
    }

    return _handleResponse(response);
  }

  // 4. Tasdiqlash kodini qayta yuborish
  static Future<Map<String, dynamic>> resendVerificationCode(String email) async {
    // MUHIM: /users/resend-otp/ manzili 404 xato berayotgan edi.
    // Quyidagi manzil - bu taxmin. Iltimos, to'g'ri manzilni backend dasturchingizdan aniqlang.
    final url = Uri.parse('$_baseUrl/users/resend-verification-code/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email}),
    );
    return _handleResponse(response);
  }

  // 5. Foydalanuvchi ma'lumotlarini olish
  static Future<Map<String, dynamic>> getMe(String token) async {
    // MUHIM: Bu manzil ham taxmin. To'g'ri manzilni backend dasturchidan aniqlang.
    final url = Uri.parse('$_baseUrl/users/user/profile/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    return _handleResponse(response);
  }

  // 6. Profil ma'lumotlarini yangilash (ism, telefon va hokazo)
  static Future<Map<String, dynamic>> updateProfile(String token,
      {String? fullName, String? phone}) async {
    final url = Uri.parse('$_baseUrl/users/user/profile/');
    final Map<String, dynamic> body = {};
    if (fullName != null) {
      body['full_name'] = fullName;
    }
    if (phone != null) {
      body['phone_number'] = phone;
    }

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  // 7. Profil rasmini yangilash
  static Future<Map<String, dynamic>> updateProfilePicture(
      String token, String imagePath) async {
    final url = Uri.parse('$_baseUrl/users/user/profile/');
    // TUZATISH: Server `PUT` metodini qabul qilmayotgan ko'rinadi.
    // Fayl yuklash uchun standart bo'lgan `PATCH` metodiga qaytamiz.
    var request = http.MultipartRequest('PATCH', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(
      'profile_picture', // Backenddagi field nomi
      imagePath,
    ));

    final streamedResponse = await request.send();
    return _handleResponse(await http.Response.fromStream(streamedResponse));
  }

  // 8. Tokenni yangilash
  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final url = Uri.parse('$_baseUrl/users/token/refresh/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'refresh': refreshToken}),
    );
    // Bu yerda _handleResponse xatolikni to'g'ri ushlaydi (masalan, 401 Unauthorized)
    return _handleResponse(response);
  }
}
