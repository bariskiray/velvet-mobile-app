import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/views/valet/valet_home/valet_home_screen_view.dart';
import '../../../../components/custom_password_field.dart';
import '../../../../components/custom_text_field.dart';
import '../../../../components/error_message.dart';
import '../controller/valet_login_controller.dart';

class ValetLoginView extends StatefulWidget {
  const ValetLoginView({super.key});

  @override
  State<ValetLoginView> createState() => _ValetLoginViewState();
}

class _ValetLoginViewState extends State<ValetLoginView> {
  late ValetLoginController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ValetLoginController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
                  const SizedBox(height: 30.0),
                  _buildErrorMessage(),
                  _buildLoginForm(),
                  const SizedBox(height: 20.0),
                  _buildLoginButton(),
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

  Widget _buildLoginButton() {
    return Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () async {
                  if (controller.formKey.currentState!.validate()) {
                    final result = await controller.login();
                    if (result['success'] == true) {
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ValetHomeView(),
                        ),
                      );
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message'] ?? 'Giriş başarısız'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
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
                  'Giriş Yap',
                  style: TextStyle(fontSize: 18.0),
                ),
        ));
  }
}
