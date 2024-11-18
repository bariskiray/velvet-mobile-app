import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/auth/auth_controller.dart';

class BusinessHome extends StatelessWidget {
  const BusinessHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşletme Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthController.to.logout(),
          ),
        ],
      ),
      body: const Center(
        child: Text('Hoş Geldiniz'),
      ),
    );
  }
}
