import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../api_service/api_service.dart';
import '../auth/auth_models.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  // Observable variables
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final currentUser = Rxn<UserData>();
  final _credentials = RxnString();

  // SharedPreferences keys
  static const String CREDENTIALS_KEY = 'auth_credentials';
  static const String USER_KEY = 'user_data';
  static const String USER_TYPE_KEY = 'user_type';

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  // Base64 encoded credentials oluştur
  String getAuthHeader(String email, String password) {
    final credentials = '$email:$password';
    return base64Encode(utf8.encode(credentials));
  }

  // HTTP Header oluştur
  Map<String, String> get authHeaders {
    if (_credentials.value == null) return {};
    return {
      'Authorization': 'Basic ${_credentials.value}',
      'Content-Type': 'application/json',
    };
  }

  // Login işlemi
  Future<void> login(String email, String password, String userType) async {
    try {
      isLoading.value = true;

      final loginRequest = LoginRequest(
        email: email,
        password: password,
        userType: userType,
      );

      final response = await ApiService.login(loginRequest);
      final loginResponse = LoginResponse.fromJson(response.data);

      final authHeader = getAuthHeader(email, password);
      await _saveAuthData(authHeader, loginResponse.user.toJson(), userType);

      _credentials.value = authHeader;
      currentUser.value = loginResponse.user;
      isLoggedIn.value = true;

      Get.offAllNamed('/home');
    } catch (e) {
      ApiService.handleError(e);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Auth verilerini kaydet
  Future<void> _saveAuthData(
    String credentials,
    Map<String, dynamic> userData,
    String userType,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(CREDENTIALS_KEY, credentials);
      await prefs.setString(USER_KEY, jsonEncode(userData));
      await prefs.setString(USER_TYPE_KEY, userType);
    } catch (e) {
      debugPrint('Save auth data error: $e');
      rethrow;
    }
  }

  // Auth durumunu kontrol et
  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCredentials = prefs.getString(CREDENTIALS_KEY);
      final userType = prefs.getString(USER_TYPE_KEY);

      if (savedCredentials != null && userType != null) {
        final userData = prefs.getString(USER_KEY);
        if (userData != null) {
          final response = await ApiService.verifyToken(userType);

          if (response.statusCode == 200) {
            currentUser.value = UserData.fromJson(jsonDecode(userData));
            _credentials.value = savedCredentials;
            isLoggedIn.value = true;
          } else {
            await logout();
          }
        }
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
      await logout();
    }
  }

  // Register business
  Future<void> registerBusiness({
    required String email,
    required String password,
    required String businessName,
  }) async {
    try {
      isLoading.value = true;

      final request = BusinessRegisterRequest(
        email: email,
        password: password,
        businessName: businessName,
      );

      await ApiService.registerBusiness(request);
      Get.offAllNamed('/login');
    } catch (e) {
      ApiService.handleError(e);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Register valet (requires business auth)
  Future<void> registerValet({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      isLoading.value = true;

      final request = ValetRegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      await ApiService.registerValet(request);
      Get.back(); // veya başka bir yönlendirme
    } catch (e) {
      ApiService.handleError(e);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Logout işlemi
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(CREDENTIALS_KEY);
      await prefs.remove(USER_KEY);
      await prefs.remove(USER_TYPE_KEY);

      _credentials.value = null;
      currentUser.value = null;
      isLoggedIn.value = false;

      Get.offAllNamed('/login');
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  // Forgot Password işlemi
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
}
