import 'package:get/get.dart';
import 'package:valet_mobile_app/auth/auth_controller.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';

class BusinessLoginController {
  final AuthController _authController = Get.find<AuthController>();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // AuthController üzerinden login işlemini gerçekleştir
      await _authController.login(
        email,
        password,
        'business', // userType parametresi
      );

      return {
        'success': true,
        'message': 'Giriş başarılı',
      };
    } catch (e) {
      print('Login Error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<void> logout() async {
    try {
      await _authController.logout();
    } catch (e) {
      print('Logout Error: $e');
      rethrow;
    }
  }
}
