import 'package:flutter/material.dart';
import 'package:valet_mobile_app/components/custom_password_field.dart';

import 'package:valet_mobile_app/components/custom_text_field.dart';
import 'package:valet_mobile_app/components/error_message.dart';
import 'package:valet_mobile_app/views/valet/valet_login/view/valet_login_view.dart';
import 'package:get/get.dart';

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

      // Register işlemleri burada yapılacak
      // Örnek:
      // await authService.register(
      //   firstname: firstnameController.text,
      //   lastname: lastnameController.text,
      //   email: emailController.text,
      //   password: passwordController.text,
      // );

      // Başarılı kayıt sonrası login sayfasına yönlendir
      Get.off(() => const ValetLoginView());
      Get.snackbar(
        'Success',
        'Registration successful! Please login.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Registration failed: ${e.toString()}';
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

    if (passwordController.text.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters';
      return false;
    }

    errorMessage.value = '';
    return true;
  }

  // Login sayfasına git
  void goToLogin() {
    Get.off(() => const ValetLoginView());
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

class ValetRegisterView extends GetView<ValetRegisterController> {
  const ValetRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Register',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20.0),
              CustomTextField(
                controller: controller.firstnameController,
                labelText: 'First Name',
                hintText: 'Enter your first name',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20.0),
              CustomTextField(
                controller: controller.lastnameController,
                labelText: 'Last Name',
                hintText: 'Enter your last name',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20.0),
              CustomTextField(
                controller: controller.emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20.0),
              CustomPasswordField(
                controller: controller.passwordController,
                label: 'Password',
              ),
              const SizedBox(height: 20.0),
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.register,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue[900],
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Get Started',
                            style: TextStyle(fontSize: 18.0),
                          ),
                  )),
              Obx(() => controller.errorMessage.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ErrorMessage(
                        message: controller.errorMessage.value,
                        color: Colors.red,
                      ),
                    )
                  : const SizedBox.shrink()),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: controller.goToLogin,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text("Already have an account? Login here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
