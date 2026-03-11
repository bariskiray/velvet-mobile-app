import 'package:get/get.dart';
import 'package:valet_mobile_app/auth/auth_controller.dart';
import 'package:valet_mobile_app/auth/auth_models.dart';
import '../../../../api_service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BusinessLoginController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      // LoginRequest nesnesi oluştur
      final loginRequest = LoginRequest(
        email: email,
        password: password,
      );

      // ApiService ile login işlemi yap
      final response = await ApiService.login(loginRequest, scope: 'business');

      if (response.statusCode == 200) {
        // JWT token'ı al
        final accessToken = response.data['access_token'];
        final jwtCredential = 'Bearer $accessToken';

        // Business bilgileri endpoint'i olmadığı için basit bir kullanıcı oluşturuyoruz
        final businessUser = BusinessUser(
          email: email,
          credentials: jwtCredential,
          businessName: email.split('@')[0],
          phoneNumber: '',
          businessId: 1, // Varsayılan değer
          id: 1, // Varsayılan değer
        );

        // AuthController'a kullanıcı bilgilerini kaydet
        _authController.currentUser.value = businessUser;
        _authController.isLoggedIn.value = true;

        // SharedPreferences'a kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('business_credentials', jwtCredential);
        await prefs.setString('business_user', jsonEncode(businessUser.toJson()));

        print('Business girişi başarılı');
        return {'success': true, 'message': 'Giriş başarılı'};
      } else {
        errorMessage.value = 'Giriş başarısız: ${response.statusCode}';
        return {'success': false, 'message': errorMessage.value};
      }
    } catch (e) {
      print('Business Login Error: $e');
      errorMessage.value = 'Giriş başarısız: $e';
      return {'success': false, 'message': errorMessage.value};
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authController.logout();
    } catch (e) {
      print('Business Logout Error: $e');
      // Still navigate to login page even if there's an error
      Get.offAllNamed('/login');
    }
  }

  // Helper method to check if user is logged in
  bool get isLoggedIn => _authController.isLoggedIn.value;

  // Helper method to get current user
  BusinessUser? get currentUser => _authController.currentUser.value;
}
