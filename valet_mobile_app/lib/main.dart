import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/auth/auth_controller.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:valet_mobile_app/views/business/business_home/business_home_screen_view.dart';
import 'package:valet_mobile_app/views/business/business_login/view/business_login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize controllers
  Get.put(AuthController()); // AuthController'ı initialize et

  // Initialize API Service
  ApiService.initializeInterceptors();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Valet App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const BusinessLoginView()),
        GetPage(name: '/home', page: () => const BusinessHome()),
      ],
    );
  }
}
