import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:valet_mobile_app/api_service/api_service.dart';

class ValetHomeController extends GetxController {
  final hasNewAssignment = false.obs;
  final carDetails = Rx<Map<String, dynamic>?>(null);
  final isWorking = true.obs;

  @override
  void onInit() {
    super.onInit();
    // TODO: Listen to real-time updates for new assignments
    listenToAssignments();
  }

  void listenToAssignments() {
    // Mock data based on the database table
    carDetails.value = {
      'ticketId': '11',
      'businessId': '1',
      'openDate': '2024-12-29 21:02:22',
      'closeDate': null,
      'progressStatus': '1',
      'note': null,
      'parkingSpot': null,
      'damage': null,
      'carId': null,
      'valetId': '1',
      // Additional car details that would come from car table
      'brand': 'BMW',
      'plate': '34ABC123',
      'color': 'Black',
      'location': '56' // This would come from parking_spot table
    };
    hasNewAssignment.value = true;
  }

  Future<void> confirmCarDelivery() async {
    try {
      // TODO: API integration will be added
      await Future.delayed(Duration(milliseconds: 500));
      hasNewAssignment.value = false;
      carDetails.value = null;
      Get.back();
      Get.snackbar(
        'Success',
        'Car delivery confirmed',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to confirm delivery',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> logout() async {
    try {
      print('Starting logout process...'); // Debug log

      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to end your shift and logout?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      print('Confirmation dialog result: $confirm'); // Debug log

      if (confirm == true) {
        print('Showing loading dialog...'); // Debug log

        // Show loading dialog
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(),
          ),
          barrierDismissible: false,
        );

        try {
          print('Calling logout API...'); // Debug log

          // Call logout API endpoint
          final response = await ApiService.logoutValet();

          print('API Response: ${response.statusCode}'); // Debug log

          // Close loading dialog
          Get.back();

          if (response.statusCode == 200) {
            print('Logout successful, clearing storage...'); // Debug log

            // Clear local storage
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('valet_credentials');
            await prefs.remove('valet_email');

            // Update working status
            isWorking.value = false;

            print('Navigating to main page...'); // Debug log

            // Show success message before navigation
            Get.snackbar(
              'Success',
              'Logged out successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );

            // Navigate to main page after a short delay
            await Future.delayed(Duration(milliseconds: 500));
            Get.offAllNamed('/mainPage');
          } else {
            Get.snackbar(
              'Error',
              'Failed to logout. Please try again.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } catch (e) {
          print('Error in logout process: $e'); // Debug log

          // Close loading dialog
          Get.back();

          Get.snackbar(
            'Error',
            'Failed to logout: ${e.toString()}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Unexpected error in logout: $e'); // Debug log
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
