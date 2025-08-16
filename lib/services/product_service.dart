// services/product_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/style_item.dart';
import '../providers/auth_provider.dart';

// --- Xatoliklar ---
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  final int statusCode;
  ServerException(this.message, this.statusCode);
  @override
  String toString() => "Server xatoligi ($statusCode): $message";
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class UnexpectedFormatException implements Exception {
  final String message = "Serverdan kutilmagan formatdagi javob keldi.";
  @override
  String toString() => message;
}

class ProductService {
  static const String _baseUrl ='https://beautyaiapp.duckdns.org'; // 🔴 BOSHIDAGI BO'SH JOY O'CHIRILDI
  static const String _productsEndpoint = '/products/';

  Future<List<StyleItem>> fetchProducts(AuthProvider authProvider) async {
    try {
      return await _fetchProductsAttempt(authProvider);
    } on AuthException {
      developer.log('Token yaroqsiz, yangilanmoqda...', name: 'ProductService');
      final refreshed = await authProvider.refreshToken();
      if (refreshed) {
        developer.log('Token yangilandi, so\'rov qaytarilmoqda.', name: 'ProductService');
        return await _fetchProductsAttempt(authProvider);
      } else {
        throw AuthException('Sessiya muddati tugagan. Iltimos, qayta kiring.');
      }
    } on TimeoutException {
      throw NetworkException('Serverdan javob kelmadi. Internet aloqasini tekshiring.');
    } on SocketException {
      throw NetworkException('Internetga ulanishni tekshiring.');
    } catch (e) {
      developer.log('Kutilmagan xatolik', name: 'ProductService', error: e);
      throw Exception('Noma\'lum xatolik: $e');
    }
  }

  Future<List<StyleItem>> _fetchProductsAttempt(AuthProvider authProvider) async {
    final url = Uri.parse('$_baseUrl$_productsEndpoint');
    final accessToken = authProvider.token;

    if (accessToken == null) {
      throw AuthException('Foydalanuvchi tizimga kirmagan.');
    }

    final headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    developer.log('So\'rov: $url', name: 'ProductService');
    final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

    return _handleResponse(response);
  }
List<StyleItem> _handleResponse(http.Response response) {
  final responseBody = utf8.decode(response.bodyBytes);
  developer.log('Javob: ${response.statusCode} | $responseBody', name: 'ProductService');

  if (response.statusCode >= 200 && response.statusCode < 300) {
    final decodedBody = json.decode(responseBody);

    if (decodedBody is List) {
      return _parseStyleItems(decodedBody);
    } else if (decodedBody is Map<String, dynamic>) {
      if (decodedBody.containsKey('results')) {
        return _parseStyleItems(decodedBody['results']);
      } else {
        // Agar results bo'lmasa, butun ob'ektni massiv sifatida qaytarsa
        return _parseStyleItems([decodedBody]);
      }
    } else {
      throw UnexpectedFormatException();
    }
  } else if (response.statusCode == 401 || response.statusCode == 403) {
    throw AuthException('Avtorizatsiya xatoligi (${response.statusCode}).');
  } else {
    throw ServerException('Ma\'lumot olib bo\'lmadi.', response.statusCode);
  }
}
  List<StyleItem> _parseStyleItems(List<dynamic> items) {
    return items.map<StyleItem?>((itemJson) {
      try {
        if (itemJson is Map<String, dynamic>) {
          return StyleItem.fromJson(itemJson);
        }
      } catch (e, stackTrace) {
        developer.log('Parse xatosi: $itemJson', error: e, stackTrace: stackTrace);
      }
      return null;
    }).whereType<StyleItem>().toList();
  }
}