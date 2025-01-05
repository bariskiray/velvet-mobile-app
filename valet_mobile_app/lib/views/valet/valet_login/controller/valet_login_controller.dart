import 'dart:async';
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

  // Input değişikliklerini debounce ile yönetmek için
  final _debouncer = Debouncer(milliseconds: 300);
  Worker? _worker;

  @override
  void onInit() {
    super.onInit();
    // Input değişikliklerini dinle
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  void _onEmailChanged() {
    _debouncer.run(() {
      // Email validasyonu sadece gerektiğinde yapılır
      if (formKey.currentState != null) {
        formKey.currentState!.validate();
      }
    });
  }

  void _onPasswordChanged() {
    _debouncer.run(() {
      // Şifre validasyonu sadece gerektiğinde yapılır
      if (formKey.currentState != null) {
        formKey.currentState!.validate();
      }
    });
  }

  Future<Map<String, dynamic>> login() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final credentials = 'Basic ' + base64Encode(utf8.encode('${emailController.text.trim()}:${passwordController.text}'));

      final request = ValetLoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final response = await ApiService.loginValet(request, credentials);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('valet_credentials', credentials);
        await prefs.setString('valet_email', request.email);

        return {'success': true, 'message': 'Giriş başarılı', 'data': response.data};
      } else {
        final message = response.data is Map ? response.data['message'] ?? 'Giriş başarısız' : 'Giriş başarısız';
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Giriş hatası: $e'};
    } finally {
      isLoading.value = false;
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
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
    _debouncer.dispose();
    emailController.removeListener(_onEmailChanged);
    passwordController.removeListener(_onPasswordChanged);
    emailController.dispose();
    passwordController.dispose();
    _worker?.dispose();
    super.onClose();
  }
}

// Debouncer sınıfı
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
