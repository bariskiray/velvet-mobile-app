import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valet_mobile_app/views/valet/valet_login/model/valet_login_request.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'dart:async';
import '../../../../api_service/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart' as dio;
import '../../../../auth/auth_controller.dart';
import '../../../../auth/auth_models.dart';

class ValetLoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final formKey = GlobalKey<FormState>();

  // Input değişikliklerini debounce ile yönetmek için
  final _debouncer = Debouncer(milliseconds: 300);
  Worker? _worker;

  // Dio instance for API calls
  final _dio = dio.Dio(dio.BaseOptions(
    baseUrl: ApiService.getBaseUrl(),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  @override
  void onInit() {
    super.onInit();
    // Input değişikliklerini dinle
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
    // Dio hata ayıklama
    _dio.interceptors.add(dio.LogInterceptor(
      responseBody: true,
      requestBody: true,
      logPrint: (object) => print(object.toString()),
    ));
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

      // FCM Token'ı alma işlemi
      print('====== VALET LOGIN - FCM TOKEN KONTROLÜ ======');
      String? fcmToken;
      try {
        // Platform'u kontrol et
        if (Platform.isIOS) {
          print('iOS platformu tespit edildi, özel token alımı yapılıyor...');

          // iOS'ta izinleri kontrol et
          final settings = await FirebaseMessaging.instance.getNotificationSettings();
          print('iOS izin durumu: ${settings.authorizationStatus}');

          // APNS token kontrolü (simülatörde null olacak)
          final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          print('APNS Token: $apnsToken');

          if (apnsToken == null) {
            // iOS simülatörü tespit edildi - gerçek cihazda çalışmıyor
            print('iOS simülatöründe çalıştığı tespit edildi, simülatör için test token kullanılıyor');
            // Simülatör için test token'ı (51 karakter)
            fcmToken = 'ios_simulator_test_token_${DateTime.now().millisecondsSinceEpoch}';
            print('Simülatör için test token oluşturuldu: $fcmToken');
          } else {
            // Gerçek iOS cihaz
            print('getToken() çağrılıyor...');
            fcmToken = await FirebaseMessaging.instance.getToken();
            print('iOS gerçek cihazdan FCM Token alındı: $fcmToken');
          }
        } else if (Platform.isAndroid) {
          // Android platform kontrolü
          print('Android platformu tespit edildi, FCM token alınıyor...');

          // Android için direkt FCM token almaya çalış
          try {
            // Timeout ile FCM token almaya çalışıyoruz
            fcmToken = await FirebaseMessaging.instance.getToken().timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                print('FCM token alma işlemi timeout oldu');
                return null;
              },
            );

            if (fcmToken != null) {
              print('Android cihazdan FCM Token alındı: $fcmToken');
            } else {
              print('FCM token null, fallback token oluşturuluyor');
              fcmToken = 'android_fallback_test_token_${DateTime.now().millisecondsSinceEpoch}';
            }
          } catch (e) {
            print('FCM token alımında hata: $e');
            // Hata durumunda fallback token oluştur
            fcmToken = 'android_error_fallback_token_${DateTime.now().millisecondsSinceEpoch}';
            print('Android için fallback token oluşturuldu: $fcmToken');
          }
        } else {
          // Diğer platformlar
          print('Firebase Messaging instance oluşturuluyor...');
          final messaging = FirebaseMessaging.instance;
          print('getToken() çağrılıyor...');
          fcmToken = await messaging.getToken();
          print('Diğer platformdan FCM Token alındı: $fcmToken');
        }

        // JWT token almak için istek oluştur
        final loginRequest = ValetLoginRequest(
          email: emailController.text.trim(),
          password: passwordController.text,
          fcmToken: fcmToken,
        );

        // API'ye istek at
        final Map<String, String> params = {
          'username': loginRequest.email,
          'password': loginRequest.password,
          'grant_type': 'password',
          'scope': 'valet',
          'fcm_token': fcmToken ?? '',
        };

        // Dio ile direkt olarak form verilerini gönderelim
        print('Login params: $params');
        print('FCM Token: $fcmToken');

        final response = await _dio.post(
          '/api/token',
          data: dio.FormData.fromMap(params),
          options: dio.Options(
            contentType: 'application/x-www-form-urlencoded',
            headers: {
              'Accept': 'application/json',
            },
          ),
        );

        print('API Response: ${response.data}');

        if (response.statusCode == 200) {
          // JWT token'ı al
          final accessToken = response.data['access_token'];
          final credential = 'Bearer $accessToken';

          // Valet bilgilerini token cevabı geldiğinde oluşturuyoruz
          // /api/valets/me endpoint'i olmadığı için varsayılan değerler kullanılıyor
          final businessUser = BusinessUser(
            email: loginRequest.email,
            credentials: credential,
            businessName: loginRequest.email.split('@')[0],
            phoneNumber: '',
            businessId: 1, // Varsayılan değer
            id: 1, // Varsayılan değer
          );

          // SharedPreferences'a kaydet
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('business_credentials', credential);
          await prefs.setString('valet_credentials', credential);
          await prefs.setString('business_user', jsonEncode(businessUser.toJson()));

          // FCM token varsa, backend'e bildirmemiz gerekiyor mu?
          // Şu anki backend yapısında FCM token'ı loginRequest içinde gönderildi

          // AuthController'ı güncelle
          AuthController.to.currentUser.value = businessUser;
          AuthController.to.isLoggedIn.value = true;

          print('Vale girişi başarılı');
          return {'success': true, 'message': 'Vale giriş işlemi başarılı'};
        } else {
          errorMessage.value = 'Giriş başarısız: ${response.statusCode}';
          return {'success': false, 'message': errorMessage.value};
        }
      } catch (e) {
        print('FCM Token Error: $e');
        errorMessage.value = 'FCM Token hatası: $e';
        return {'success': false, 'message': errorMessage.value};
      }
    } catch (e) {
      print('Vale Login Error: $e');
      errorMessage.value = 'Giriş başarısız: $e';
      return {'success': false, 'message': errorMessage.value};
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
