import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../auth/auth_controller.dart';
import '../view/valet_login_view.dart';

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

      await AuthController.to.registerValet(
        email: emailController.text,
        password: passwordController.text,
        firstName: firstnameController.text,
        lastName: lastnameController.text,
      );

      Get.off(() => ValetLoginView());
      Get.snackbar(
        'Success',
        'Registration successful! Please login.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
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

  void goToLogin() => Get.off(() => ValetLoginView());

  @override
  void onClose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
