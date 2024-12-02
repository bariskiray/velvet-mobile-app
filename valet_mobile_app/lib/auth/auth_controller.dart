import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valet_mobile_app/views/business/business_home/view/business_home_view.dart';
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
        final credentials = 'Basic ' + base64Encode(utf8.encode('$email:$password'));

        final businessUser = BusinessUser(
          email: email,
          credentials: credentials,
          businessName: email.split('@')[0],
          phoneNumber: '',
          businessId: response.data['business_id'],
          id: response.data['id'],
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('business_credentials', credentials);
        await prefs.setString('business_user', jsonEncode(businessUser.toJson()));

        currentUser.value = businessUser;
        _credentials.value = credentials;
        isLoggedIn.value = true;

        print('Login successful - User Data: ${businessUser.toJson()}');

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
      await prefs.setString(CREDENTIALS_KEY, credentials);
      await prefs.setString(USER_KEY, jsonEncode(userData));

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
            Get.offAll(() => const BusinessHomeView());
          });
        } else {
          await Get.offAllNamed('/login')?.catchError((error) {
            print('Navigation error: $error');
            Get.offAll(() => const BusinessHomeView());
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
      final savedCredentials = prefs.getString('business_credentials');
      final savedUserData = prefs.getString('business_user');

      print('CheckAuthStatus - Saved Credentials: $savedCredentials');
      print('CheckAuthStatus - Saved User Data: $savedUserData');

      if (savedCredentials != null && savedUserData != null) {
        try {
          final userData = jsonDecode(savedUserData) as Map<String, dynamic>;
          print('CheckAuthStatus - Decoded User Data: $userData');

          currentUser.value = BusinessUser(
            email: userData['email'] ?? '',
            credentials: userData['credentials'] ?? '',
            businessName: userData['business_name'] ?? '',
            phoneNumber: userData['phone_number'] ?? '',
            businessId: int.tryParse(userData['business_id'].toString()),
            id: int.tryParse(userData['id'].toString()),
          );

          print('CheckAuthStatus - Current User: ${currentUser.value?.toJson()}');
          print('CheckAuthStatus - Business ID: ${currentUser.value?.businessId}');
          print('CheckAuthStatus - Valet ID: ${currentUser.value?.id}');

          isLoggedIn.value = true;
        } catch (e) {
          print('CheckAuthStatus - Parse Error: $e');
          await logout();
        }
      } else {
        print('CheckAuthStatus - No saved data found');
        isLoggedIn.value = false;
      }
    } catch (e) {
      print('CheckAuthStatus - Error: $e');
      await logout();
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Tüm kimlik bilgilerini temizle
      await prefs.remove('business_credentials');
      await prefs.remove('valet_credentials');
      await prefs.remove('user_type');

      // Kullanıcı durumunu sıfırla
      currentUser.value = null;

      // Ana sayfaya yönlendir
      Get.offAllNamed('/mainPage');

      Get.snackbar(
        'Success',
        'Successfully logged out',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Logout Error: $e');
      Get.snackbar(
        'Error',
        'Failed to logout: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

  Map<String, String> getBasicAuthHeaders(String email, String password) {
    final basicAuth = 'Basic ' + base64Encode(utf8.encode('$email:$password'));
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': basicAuth,
    };
  }
}
