import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:valet_mobile_app/views/valet/valet_complete_ticket/controller/valet_complete_ticket_controller.dart';
import 'package:valet_mobile_app/views/valet/valet_complete_ticket/view/valet_complete_ticket_view.dart';
import 'package:valet_mobile_app/views/valet/valet_create_ticket/controller/valet_create_ticket_controller.dart';
import 'package:valet_mobile_app/views/valet/valet_create_ticket/view/valet_create_ticket_view.dart';
import 'package:valet_mobile_app/auth/auth_controller.dart';

class ValetHomeView extends StatefulWidget {
  const ValetHomeView({super.key});

  @override
  State<ValetHomeView> createState() => _ValetHomeViewState();
}

class _ValetHomeViewState extends State<ValetHomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Valet Panel'),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Color.fromARGB(255, 146, 35, 27),
            ),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        AuthController.to.logout();
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.put(ValetCreateTicketController());
                    Get.to(() => const ValetCreateTicketView());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    'Create Ticket',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.put(ValetCompleteTicketController());
                    Get.to(() => const ValetCompleteTicketView());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    'Complete Ticket',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
