import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:valet_mobile_app/views/business/business_login/view/business_login_view.dart';
import 'package:valet_mobile_app/views/valet/valet_login/view/valet_login_view.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Title
                const Text(
                  'Velvet',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                Text(
                  'Choose your role to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 40),

                // Business Owner Button
                _buildRoleButton(
                  title: 'Business Owner',
                  icon: Icons.business,
                  onTap: () => Get.to(() => const BusinessLoginView()),
                ),
                const SizedBox(height: 20),

                // Valet Button
                _buildRoleButton(
                  title: 'Valet',
                  icon: Icons.directions_car,
                  onTap: () => Get.to(() => ValetLoginView()),
                ),

                const SizedBox(height: 40),

                // Version Info
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.blue[900],
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(
            icon,
            size: 24,
            color: Colors.blue[900],
          ),
        ],
      ),
    );
  }
}
