import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../components/custom_password_field.dart';
import '../../../../components/custom_text_field.dart';
import '../../../../components/error_message.dart';
import '../controller/valet_register_controller.dart';

class ValetRegisterView extends StatelessWidget {
  ValetRegisterView({super.key}) {
    // Controller'ı burada oluştur
    Get.put(ValetRegisterController());
  }

  // Controller'a erişim için getter
  ValetRegisterController get controller => Get.find<ValetRegisterController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 20.0),
                _buildForm(),
                const SizedBox(height: 20.0),
                _buildRegisterButton(),
                _buildErrorMessage(),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Vale Register',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Obx(() => ElevatedButton(
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
        ));
  }

  Widget _buildErrorMessage() {
    return Obx(() => controller.errorMessage.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ErrorMessage(
              message: controller.errorMessage.value,
              color: Colors.red,
            ),
          )
        : const SizedBox.shrink());
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => Get.back(), // Direkt login sayfasına dön
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      child: const Text("Already have an account? Login here"),
    );
  }
}
