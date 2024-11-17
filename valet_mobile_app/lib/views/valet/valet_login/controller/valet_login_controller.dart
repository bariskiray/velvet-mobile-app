import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../auth/auth_controller.dart';

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

      // AuthController üzerinden login işlemi
      await AuthController.to.login(usernameController.text, passwordController.text, 'valet');
    } catch (e) {
      errorMessage.value = 'Login failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Form validasyonu
  bool validateForm() {
    if (usernameController.text.isEmpty) {
      errorMessage.value = 'Email is required';
      return false;
    }

    if (!GetUtils.isEmail(usernameController.text)) {
      errorMessage.value = 'Please enter a valid email';
      return false;
    }

    if (passwordController.text.isEmpty) {
      errorMessage.value = 'Password is required';
      return false;
    }

    errorMessage.value = '';
    return true;
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
