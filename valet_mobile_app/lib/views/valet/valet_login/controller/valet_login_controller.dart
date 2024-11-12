import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../valet_home/valet_home_screen_view.dart';

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

      // Login işlemleri burada yapılacak
      // Örnek:
      // await authService.login(
      //   email: usernameController.text,
      //   password: passwordController.text,
      // );

      // Başarılı login sonrası ana sayfaya yönlendir
      Get.off(() => const ValetHomeView());
    } catch (e) {
      errorMessage.value = 'Login failed: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

    if (passwordController.text.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters';
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
