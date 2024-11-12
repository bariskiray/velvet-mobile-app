import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  // Observable variables
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final currentUser = Rxn<User>();

  // Credentials
  final _credentials = RxnString();

  // SharedPreferences keys
  static const String CREDENTIALS_KEY = 'auth_credentials';
  static const String USER_KEY = 'user_data';

  // Base64 encoded credentials oluştur
  String getAuthHeader(String email, String password) {
    final credentials = '$email:$password';
    final encodedCredentials = base64Encode(utf8.encode(credentials));
    return encodedCredentials;
  }

  // HTTP Header oluştur
  Map<String, String> get authHeaders {
    if (_credentials.value == null) return {};
    return {
      'Authorization': 'Basic ${_credentials.value}',
      'Content-Type': 'application/json',
    };
  }

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  // Uygulama başladığında auth durumunu kontrol et
  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCredentials = prefs.getString(CREDENTIALS_KEY);

      if (savedCredentials != null) {
        // Credentials varsa kullanıcı bilgilerini al
        final userData = prefs.getString(USER_KEY);
        if (userData != null) {
          currentUser.value = User.fromJson(userData);
          _credentials.value = savedCredentials;
          isLoggedIn.value = true;
        }
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
      logout();
    }
  }

  // Login işlemi
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      // Base64 encoded credentials oluştur
      final encodedCredentials = getAuthHeader(email, password);

      // API isteği yapılacak
      // final response = await dio.get(
      //   'api/auth/login',
      //   options: Options(
      //     headers: {
      //       'Authorization': 'Basic $encodedCredentials',
      //       'Content-Type': 'application/json',
      //     },
      //   ),
      // );

      // Örnek response
      final response = {
        'user': {'id': 1, 'email': email, 'name': 'Test User', 'role': 'valet'}
      };

      // Credentials ve kullanıcı bilgilerini kaydet
      await _saveAuthData(encodedCredentials, response['user']!);

      // State'i güncelle
      _credentials.value = encodedCredentials;
      currentUser.value = User.fromMap(response['user']!);
      isLoggedIn.value = true;

      // Ana sayfaya yönlendir
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Register işlemi
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      isLoading.value = true;

      // API isteği yapılacak
      // final response = await dio.post(
      //   'api/auth/register',
      //   data: {
      //     'email': email,
      //     'password': password,
      //     'firstName': firstName,
      //     'lastName': lastName,
      //   },
      // );

      // Başarılı kayıt sonrası login sayfasına yönlendir
      Get.offAllNamed('/login');
      Get.snackbar(
        'Success',
        'Registration successful! Please login.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Registration failed: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Logout işlemi
  Future<void> logout() async {
    try {
      // Local storage'dan verileri temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(CREDENTIALS_KEY);
      await prefs.remove(USER_KEY);

      // State'i temizle
      _credentials.value = null;
      currentUser.value = null;
      isLoggedIn.value = false;

      // Login sayfasına yönlendir
      Get.offAllNamed('/login');
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  // Auth verilerini kaydet
  Future<void> _saveAuthData(String credentials, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(CREDENTIALS_KEY, credentials);
      await prefs.setString(USER_KEY, User.fromMap(userData).toJson());
    } catch (e) {
      debugPrint('Save auth data error: $e');
    }
  }

  // Forgot Password işlemi
  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;

      // API isteği yapılacak
      // final response = await dio.post(
      //   'api/auth/forgot-password',
      //   data: {
      //     'email': email,
      //   },
      // );

      // Başarılı istek sonrası login sayfasına yönlendir
      Get.back(); // Forgot password sayfasından çık
      Get.snackbar(
        'Success',
        'Password reset instructions have been sent to your email.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send reset instructions: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow; // Hatayı yukarı fırlat ki controller'da yakalayabilelim
    } finally {
      isLoading.value = false;
    }
  }
}

// User model
class User {
  final int id;
  final String email;
  final String name;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      role: map['role'],
    );
  }

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
  }

  String toJson() => json.encode(toMap());
}
