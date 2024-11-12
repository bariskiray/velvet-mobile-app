import 'package:flutter/material.dart';
import 'package:valet_mobile_app/components/custom_password_field.dart';
import 'package:valet_mobile_app/components/custom_text_field.dart';
import 'package:valet_mobile_app/views/valet/valet_login/controller/valet_forgot_password_controller.dart';
import 'package:valet_mobile_app/views/valet/valet_login/controller/valet_login_controller.dart';

import 'package:get/get.dart';
import 'package:valet_mobile_app/views/valet/valet_login/view/valet_forgot_password_view.dart';
import 'package:valet_mobile_app/views/valet/valet_login/view/valet_register_view.dart';

class ValetLoginView extends GetView<ValetLoginController> {
  const ValetLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ValetLoginController());
    Get.put(ValetForgotPasswordController());
    Get.put(ValetRegisterController());

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
                'Valet Login',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30.0),
              Obx(() => controller.errorMessage.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : const SizedBox.shrink()),
              CustomTextField(
                controller: controller.usernameController,
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
                    onPressed: controller.login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.blue[900],
                            ),
                          ),
                  )),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.to(() => const ValetForgotPasswordView()),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Forgot Password?"),
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => const ValetRegisterView()),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                ),
                child: const Text("Don't have an account? Register here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
