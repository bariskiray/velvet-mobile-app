import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../auth/auth_controller.dart';
import '../../../../auth/auth_models.dart';

class ValetLoginController extends GetxController {
  // Text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Login işlemi
  Future<void> login() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Login request modeli oluştur
      final loginRequest = LoginRequest(
        email: usernameController.text.trim(),
        password: passwordController.text,
        userType: 'valet',
      );

      // AuthController üzerinden login işlemi
      await AuthController.to.login(
        loginRequest.email,
        loginRequest.password,
        loginRequest.userType,
      );

      // Başarılı login sonrası
      _clearForm();
    } catch (e) {
      errorMessage.value = 'Login failed: ${e.toString()}';
      debugPrint('Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Form validasyonu
  bool validateForm() {
    final email = usernameController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      errorMessage.value = 'Email is required';
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      errorMessage.value = 'Please enter a valid email';
      return false;
    }

    if (password.isEmpty) {
      errorMessage.value = 'Password is required';
      return false;
    }

    if (password.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters';
      return false;
    }

    return true;
  }

  // Form temizleme
  void _clearForm() {
    usernameController.clear();
    passwordController.clear();
    errorMessage.value = '';
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
