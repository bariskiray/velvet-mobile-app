import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valet_mobile_app/views/business/business_home/business_home_screen_view.dart';
import 'dart:convert';
import '../api_service/api_service.dart';
import '../auth/auth_models.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final currentUser = Rxn<BusinessUser>();
  final _credentials = RxnString();

  static const String CREDENTIALS_KEY = 'auth_credentials';
  static const String USER_KEY = 'user_data';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      isLoading.value = true;

      final loginRequest = LoginRequest(
        email: email,
        password: password,
      );

      final response = await ApiService.login(loginRequest);

      if (response.statusCode == 200) {
        // Basic Auth string'ini oluştur
        final credentials = 'Basic ' + base64Encode(utf8.encode('$email:$password'));

        // Basit bir business user oluştur
        final businessUser = BusinessUser(
          email: email,
          credentials: credentials,
          businessName: email.split('@')[0],
          phoneNumber: '',
        );

        // SharedPreferences kullanarak user'ı kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('business_credentials', credentials); // Credentials'ı kaydet
        await prefs.setString('business_user', jsonEncode(businessUser.toJson()));

        currentUser.value = businessUser;
        isLoggedIn.value = true;

        return {'success': true, 'message': 'Giriş başarılı'};
      }

      return {'success': false, 'message': 'Giriş başarısız'};
    } catch (e) {
      print('Login Error: $e');
      return {'success': false, 'message': e.toString()};
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveAuthData({
    required String credentials,
    required Map<String, dynamic> userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Save data
      await prefs.setString(CREDENTIALS_KEY, credentials);
      await prefs.setString(USER_KEY, jsonEncode(userData));

      // Verify save
      final savedCred = prefs.getString(CREDENTIALS_KEY);
      final savedUser = prefs.getString(USER_KEY);

      if (savedCred == null || savedUser == null) {
        throw Exception('Failed to verify saved data');
      }

      print('Auth data saved and verified');
    } catch (e) {
      print('Save auth data error: $e');
      throw Exception('Failed to save auth data: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    ever(isLoggedIn, (bool logged) async {
      try {
        if (logged) {
          await Get.offAllNamed('/home')?.catchError((error) {
            print('Navigation error: $error');
            // Hata durumunda alternatif route
            Get.offAll(() => const BusinessHome());
          });
        } else {
          await Get.offAllNamed('/login')?.catchError((error) {
            print('Navigation error: $error');
            // Hata durumunda alternatif route
            Get.offAll(() => const BusinessHome());
          });
        }
      } catch (e) {
        print('Route error: $e');
      }
    });
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCredentials = prefs.getString(CREDENTIALS_KEY);
      final savedUserData = prefs.getString(USER_KEY);

      print('Saved Credentials: $savedCredentials'); // Debug
      print('Saved User Data: $savedUserData'); // Debug

      if (savedCredentials != null && savedUserData != null) {
        try {
          _credentials.value = savedCredentials;
          final userData = jsonDecode(savedUserData) as Map<String, dynamic>;

          // fromJson metodunu güvenli bir şekilde kullan
          currentUser.value = BusinessUser(
            email: userData['email'] ?? '',
            credentials: userData['credentials'] ?? '',
            businessName: userData['business_name'] ?? '',
            phoneNumber: userData['phone_number'] ?? '',
          );

          isLoggedIn.value = true;
        } catch (e) {
          print('User data parse error: $e');
          await logout(); // Hatalı veri varsa logout yap
        }
      } else {
        print('No saved credentials or user data found');
        isLoggedIn.value = false;
      }
    } catch (e) {
      print('Auth check error: $e');
      await logout();
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(CREDENTIALS_KEY);
      await prefs.remove(USER_KEY);

      _credentials.value = null;
      currentUser.value = null;
      isLoggedIn.value = false;

      print('Logout successful'); // Debug
    } catch (e) {
      print('Logout error: $e');
    } finally {
      Get.offAllNamed('/login');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      await ApiService.forgotPassword(email);

      Get.back();
      Get.snackbar(
        'Success',
        'Password reset instructions have been sent to your email.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      ApiService.handleError(e);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Getter for auth headers
  Map<String, String> get authHeaders {
    if (_credentials.value != null) {
      return {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': _credentials.value!,
      };
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  // For login request specifically
  Map<String, String> getBasicAuthHeaders(String email, String password) {
    final basicAuth = 'Basic ' + base64Encode(utf8.encode('$email:$password'));
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': basicAuth,
    };
  }
}
