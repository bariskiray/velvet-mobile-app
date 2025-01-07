import 'package:get/get.dart';
import 'package:valet_mobile_app/auth/auth_controller.dart';
import 'package:valet_mobile_app/auth/auth_models.dart';

class BusinessLoginController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authController.login(email, password);
      print('Controller login result: $result');

      return result;
    } catch (e) {
      print('Controller login error: $e');
      return {
        'success': false,
        'message': 'Login failed: $e',
      };
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
