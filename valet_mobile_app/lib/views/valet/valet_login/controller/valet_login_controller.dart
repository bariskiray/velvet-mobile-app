import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:valet_mobile_app/views/valet/valet_login/model/valet_login_request.dart';
import '../../../../api_service/api_service.dart';

class ValetLoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final formKey = GlobalKey<FormState>();

  Future<Map<String, dynamic>> login() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final credentials = 'Basic ' + base64Encode(utf8.encode('${emailController.text.trim()}:${passwordController.text}'));

      final request = ValetLoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      print('Valet Login attempt for: ${request.email}');

      final response = await ApiService.loginValet(request, credentials);

      if (response.statusCode == 200) {
        // Vale bilgilerini kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('valet_credentials', credentials);
        await prefs.setString('valet_email', request.email);

        return {'success': true, 'message': 'Giriş başarılı', 'data': response.data};
      } else {
        final message = response.data is Map ? response.data['message'] ?? 'Giriş başarısız' : 'Giriş başarısız';

        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      print('Valet Login Error: $e');
      return {
        'success': false,
        'message': 'Giriş hatası: $e',
      };
    } finally {
      isLoading.value = false;
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email alanı zorunludur';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Geçerli bir email adresi giriniz';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre alanı zorunludur';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    errorMessage.value = '';
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
