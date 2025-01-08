import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/views/business/business_home/view/business_home_view.dart';
import 'package:valet_mobile_app/views/valet/valet_login/view/valet_login_view.dart';
import '../../../../components/custom_password_field.dart';
import '../../../../components/custom_text_field.dart';
import '../../../../components/error_message.dart';
import '../controller/valet_register_controller.dart';

class ValetRegisterView extends StatelessWidget {
  ValetRegisterView({super.key}) {
    Get.put(ValetRegisterController());
  }

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
            child: Form(
              key: controller.formKey,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Valet Registration',
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
          controller: controller.valetNameController,
          labelText: 'Name',
          hintText: 'Type valet\'s name',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 20.0),
        CustomTextField(
          controller: controller.valetSurnameController,
          labelText: 'Surname',
          hintText: 'Type valet\'s surname',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 20.0),
        CustomTextField(
          controller: controller.emailController,
          labelText: 'Email',
          hintText: 'Type valet\'s email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20.0),
        CustomTextField(
          controller: controller.phoneNumberController,
          labelText: 'Phone Number',
          hintText: 'Type valet\'s phone number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20.0),
        CustomPasswordField(
          controller: controller.passwordController,
          label: 'Enter Password',
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value ? null : _handleRegister,
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
                  'Register',
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

  Future<void> _handleRegister() async {
    if (!controller.formKey.currentState!.validate()) return;

    try {
      controller.isLoading.value = true;

      final result = await controller.register();

      if (result['success'] == true) {
        Get.snackbar(
          'Success',
          'Valet registration completed successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
        );
        await Future.delayed(const Duration(seconds: 2));
        Get.off(() => const BusinessHomeView());
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Registration failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      controller.isLoading.value = false;
    }
  }
}
