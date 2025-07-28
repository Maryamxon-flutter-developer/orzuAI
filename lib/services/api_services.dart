// lib/services/api_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Sizning backend serveringizning asosiy manzili

  static const String baseUrl = 'http://13.60.62.242:8080';

  
  // 1-BOSQICH: Yangi foydalanuvchi ro'yxatdan o'tish
  // Bu funksiya foydalanuvchi ma'lumotlarini serverga yuboradi
  // Server email ga 6 xonali tasdiqlash kodini yuboradi
  static Future<Map<String, dynamic>> register(
    String fullName,    // To'liq ism
    String email,       // Email manzil
    String phone,       // Telefon raqam
    String password,    // Parol
    String password2    // Parolni takrorlash
  ) async {
    try {
      // HTTP POST so'rov yuborish
      final response = await http.post(
        Uri.parse('$baseUrl/users/register/customer/'), // API endpoint
        headers: {'Content-Type': 'application/json'},   // JSON formatda ma'lumot yuboramiz
        body: jsonEncode({  // Ma'lumotlarni JSON formatga o'tkazish
          'email': email,
          'full_name': fullName,
          'phone': phone,
          'password': password,
          'password2': password2,
        }),
      );
      
      // Debug uchun - consoleda ko'rish
      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');
      
      // Agar server muvaffaqiyatli javob bersa (2xx kodlar)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // JSON javobni Dart Map ga o'tkazish
        return jsonDecode(response.body);
      } else {
        // Xatolik bo'lsa, serverdan kelgan JSON xatoni to'g'ridan-to'g'ri qaytarish
        throw jsonDecode(response.body);
      }
    } catch (e) {
      // Asl xatolikni (masalan, SocketException) o'zgartirmasdan qayta yuborish
      rethrow;
    }
  }
  
  // 2-BOSQICH: Email ni tasdiqlash
  // Foydalanuvchi email ga kelgan 6 xonali kodni kiritadi
  // Bu funksiya kod to'g'ri bo'lsa JWT token qaytaradi
  static Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/verify-email/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,  // Register qilingan email
          'code': code,    // SMS/Email dan kelgan kod (masalan: "894722")
        }),
      );
      
      print('Verify Email Response Status: ${response.statusCode}');
      print('Verify Email Response Body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw jsonDecode(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // LOGIN: Allaqachon ro'yxatdan o'tgan foydalanuvchilar uchun
  // Email va parol bilan tizimga kirish
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login/'), // Bu URL ni tekshiring - to'g'ri URL bormi?
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw jsonDecode(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // PROFILE: Foydalanuvchi ma'lumotlarini olish
  // JWT token bilan foydalanuvchi haqida ma'lumot olish
  static Future<Map<String, dynamic>> getUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile/'), // Bu URL ni tekshiring
        headers: {
          'Content-Type': 'application/json',
          // JWT token formatda yuborish - "Bearer" so'zi kerak
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Get User Data Response Status: ${response.statusCode}');
      print('Get User Data Response Body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw jsonDecode(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // RESEND CODE: Kodni qayta yuborish
  // Agar foydalanuvchi kodni olmasa yoki kod vaqti tugasa
  static Future<Map<String, dynamic>> resendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/resend-code/'), // Bu URL mavjudmi? Tekshiring
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
        }),
      );
      
      print('Resend Code Response Status: ${response.statusCode}');
      print('Resend Code Response Body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw jsonDecode(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }
}