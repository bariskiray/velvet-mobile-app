import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import 'package:valet_mobile_app/api_service/api_service.dart';

class ValetHomeController extends GetxController {
  final hasNewAssignment = false.obs;
  final carDetails = Rx<Map<String, dynamic>?>(null);
  final isWorking = true.obs;
  final parkingSpots = <Map<String, dynamic>>[].obs;
  final isLoadingSpots = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkForAssignments();
  }

  Future<void> checkForAssignments() async {
    try {
      final closedTickets = await ApiService.getClosedTickets();
      print('Closed Tickets: $closedTickets'); // Debug log

      final assignedTicket = closedTickets.firstWhereOrNull((ticket) => ticket['progress_status'] == 3);
      print('Assigned Ticket: $assignedTicket'); // Debug log

      if (assignedTicket != null) {
        final car = assignedTicket['car'] as Map<String, dynamic>;
        print('Car Details: $car'); // Debug log

        carDetails.value = {
          'ticketId': assignedTicket['ticket_id'].toString(),
          'brand': car['brand'],
          'plate': car['license_plate'],
          'color': car['color'],
          'location': assignedTicket['parking_spot'].toString(),
        };
        print('Set Car Details: ${carDetails.value}'); // Debug log

        hasNewAssignment.value = true;
        print('Has New Assignment: ${hasNewAssignment.value}'); // Debug log
      } else {
        hasNewAssignment.value = false;
        carDetails.value = null;
        print('No Assignment Found'); // Debug log
      }
    } catch (e) {
      print('Check Assignments Error: $e');
      hasNewAssignment.value = false;
      carDetails.value = null;
    }
  }

  Future<void> confirmCarDelivery() async {
    try {
      if (carDetails.value == null) return;

      await ApiService.deliverCar(int.parse(carDetails.value!['ticketId']));

      hasNewAssignment.value = false;
      carDetails.value = null;
      Get.back();
      Get.snackbar(
        'Success',
        'Car delivery confirmed',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Check new status
      await checkForAssignments();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Car delivery failed: ${e.toString()}',
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

  Future<void> fetchParkingSpots() async {
    try {
      isLoadingSpots.value = true;

      final spots = await ApiService.getParkingSpots();
      parkingSpots.value = spots;
    } catch (e) {
      print('Fetch Parking Spots Error: $e');
      Get.snackbar(
        'Error',
        'Failed to load parking spots',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingSpots.value = false;
    }
  }

  void showParkingSpotsDialog() {
    fetchParkingSpots().then((_) {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Parking Spots',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(() => isLoadingSpots.value
                    ? const CircularProgressIndicator()
                    : Container(
                        height: Get.height * 0.5,
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: parkingSpots.length,
                          itemBuilder: (context, index) {
                            final spot = parkingSpots[index];
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors:
                                      spot['isOccupied'] ? [Colors.red[200]!, Colors.red[400]!] : [Colors.green[200]!, Colors.green[400]!],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  spot['spot'].toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )),
              ],
            ),
          ),
        ),
      );
    });
  }
}
