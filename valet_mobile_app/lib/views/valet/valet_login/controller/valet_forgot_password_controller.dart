import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../auth/auth_controller.dart';

class ValetForgotPasswordController extends GetxController {
  // Text editing controller
  final emailController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Şifre sıfırlama kodu gönderme işlemi
  Future<void> sendResetCode() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      // AuthController üzerinden şifre sıfırlama işlemi
      await AuthController.to.forgotPassword(emailController.text);
    } catch (e) {
      errorMessage.value = 'Failed to send reset code: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Form validasyonu
  bool validateForm() {
    if (emailController.text.isEmpty) {
      errorMessage.value = 'Email is required';
      return false;
    }

    if (!GetUtils.isEmail(emailController.text)) {
      errorMessage.value = 'Please enter a valid email';
      return false;
    }

    errorMessage.value = '';
    return true;
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
