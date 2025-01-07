import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../api_service/api_service.dart';
import '../model/valet_register_model.dart';

class ValetRegisterController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final valetNameController = TextEditingController();
  final valetSurnameController = TextEditingController();
  final phoneNumberController = TextEditingController();

  Future<Map<String, dynamic>> register() async {
    try {
      final request = ValetRegisterRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
        valetName: valetNameController.text.trim(),
        valetSurname: valetSurnameController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
      );

      print('Register Request: ${request.toJson()}');

      final response = await ApiService.registerValet(request);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Registration completed successfully', 'data': response.data};
      } else {
        final errorMessage = response.data is Map ? response.data['message'] ?? 'Registration failed' : 'Registration failed';

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('Register Error: $e');

      if (e.toString().contains('credentials not found')) {
        return {
          'success': false,
          'message': 'Please login to your business account first.',
        };
      }

      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email field is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName field is required';
    }
    return null;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    valetNameController.dispose();
    valetSurnameController.dispose();
    phoneNumberController.dispose();
    super.onClose();
  }
}
