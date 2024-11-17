import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../auth/auth_controller.dart';

class ValetRegisterController extends GetxController {
  // Text editing controllers
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Register işlemi
  Future<void> register() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      // AuthController üzerinden register işlemi
      await AuthController.to.registerValet(
        email: emailController.text,
        password: passwordController.text,
        firstName: firstnameController.text,
        lastName: lastnameController.text,
      );
    } catch (e) {
      errorMessage.value = 'Registration failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Form validasyonu
  bool validateForm() {
    if (firstnameController.text.isEmpty) {
      errorMessage.value = 'First name is required';
      return false;
    }

    if (lastnameController.text.isEmpty) {
      errorMessage.value = 'Last name is required';
      return false;
    }

    if (emailController.text.isEmpty) {
      errorMessage.value = 'Email is required';
      return false;
    }

    if (!GetUtils.isEmail(emailController.text)) {
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
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
