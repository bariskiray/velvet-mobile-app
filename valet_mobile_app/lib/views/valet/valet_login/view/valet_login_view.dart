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
      appBar: _buildAppBar(),
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
                  const _HeaderText(),
                  const SizedBox(height: 30.0),
                  _ErrorMessageWidget(controller: controller),
                  _LoginForm(controller: controller),
                  const SizedBox(height: 20.0),
                  _LoginButton(controller: controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      );
}

class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
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
}

class _ErrorMessageWidget extends StatelessWidget {
  final ValetLoginController controller;

  const _ErrorMessageWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
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
}

class _LoginForm extends StatelessWidget {
  final ValetLoginController controller;

  const _LoginForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: controller.emailController,
          labelText: 'Email',
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email,
          validator: (value) => controller.validateEmail(value),
          onChanged: (value) {},
        ),
        const SizedBox(height: 20.0),
        CustomPasswordField(
          controller: controller.passwordController,
          label: 'Password',
          validator: (value) => controller.validatePassword(value),
          onChanged: (value) {},
        ),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  final ValetLoginController controller;

  const _LoginButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () async {
                  if (controller.formKey.currentState!.validate()) {
                    final result = await controller.login();
                    if (result['success'] == true) {
                      Get.off(() => const ValetHomeView());
                    } else {
                      Get.snackbar(
                        'Error',
                        result['message'] ?? 'Login failed',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 3),
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
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Login',
                  style: TextStyle(fontSize: 18.0),
                ),
        ));
  }
}
