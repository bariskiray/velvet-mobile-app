import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/auth/auth_controller.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:valet_mobile_app/views/business/business_home/view/business_home_view.dart';
import 'package:valet_mobile_app/views/business/business_home/view/valet_list_view.dart';
import 'package:valet_mobile_app/views/business/business_login/view/business_login_view.dart';
import 'package:valet_mobile_app/views/mainPage.dart';
import 'package:valet_mobile_app/views/valet/valet_home/valet_home_screen_view.dart';
import 'package:valet_mobile_app/views/valet/valet_login/view/valet_login_view.dart';

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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/mainPage',
      getPages: [
        GetPage(
          name: '/business-login',
          page: () => const BusinessLoginView(),
        ),
        GetPage(
          name: '/valet-login',
          page: () => const ValetLoginView(),
        ),
        GetPage(
          name: '/valet-home',
          page: () => const ValetHomeView(),
        ),
        GetPage(name: '/businessHome', page: () => const BusinessHomeView()),
        GetPage(name: '/mainPage', page: () => const MainPage()),
        GetPage(name: '/valetList', page: () => const ValetListView()),
      ],
      defaultTransition: Transition.fade,
    );
  }
}
