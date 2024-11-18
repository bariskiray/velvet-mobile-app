import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../components/custom_password_field.dart';
import '../../../../components/custom_text_field.dart';
import '../../../../components/error_message.dart';
import '../controller/valet_login_controller.dart';
import 'valet_forgot_password_view.dart';
import 'valet_register_view.dart';

class ValetLoginView extends StatelessWidget {
  ValetLoginView({super.key}) {
    // Controller'ı burada oluştur
    Get.put(ValetLoginController());
  }

  // Controller'a erişim için getter
  ValetLoginController get controller => Get.find<ValetLoginController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 30.0),
                _buildErrorMessage(),
                _buildLoginForm(),
                const SizedBox(height: 20.0),
                _buildLoginButton(),
                _buildForgotPasswordButton(),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Valet Login',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Obx(() => controller.errorMessage.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ErrorMessage(
              message: controller.errorMessage.value,
              color: Colors.red,
            ),
          )
        : const SizedBox.shrink());
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.login,
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
                  'Login',
                  style: TextStyle(fontSize: 18.0),
                ),
        ));
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Get.to(() => ValetForgotPasswordView()),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
        child: const Text("Forgot Password?"),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: () => Get.to(() => ValetRegisterView()),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10.0),
      ),
      child: const Text("Don't have an account? Register here"),
    );
  }
}
