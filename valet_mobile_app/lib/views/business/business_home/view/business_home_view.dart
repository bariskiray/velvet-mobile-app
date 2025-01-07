import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/auth/auth_controller.dart';
import 'package:valet_mobile_app/views/business/business_tickets/controller/business_tickets_controller.dart';
import 'package:valet_mobile_app/views/business/business_tickets/view/business_tickets_view.dart';
import 'package:valet_mobile_app/views/business/checkout/controller/business_checkout_controller.dart';
import 'package:valet_mobile_app/views/business/checkout/view/business_checkout_view.dart';
import 'package:valet_mobile_app/views/business/devices/view/business_devices_view.dart';
import 'package:valet_mobile_app/views/business/payment/controller/business_payment_controller.dart';
import 'package:valet_mobile_app/views/business/payment/view/business_payment_view.dart';
import 'package:valet_mobile_app/views/valet/valet_login/view/valet_register_view.dart';
import 'package:valet_mobile_app/views/business/business_home/controller/business_home_controller.dart';
import 'package:valet_mobile_app/views/business/business_home/view/valet_list_view.dart';

class BusinessHomeView extends StatelessWidget {
  const BusinessHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Panel'),
        backgroundColor: Colors.blue[900],
        elevation: 0,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome,',
                    style: TextStyle(
                      color: Colors.blue[100],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                        AuthController.to.currentUser.value?.businessName ?? 'Business Name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ],
              ),
            ),

            // Main menu grid
            Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  // Add Valet Card
                  _buildMenuCard(
                    context,
                    icon: Icons.person_add,
                    title: 'Add Valet',
                    color: Colors.green,
                    onTap: () => Get.to(() => ValetRegisterView()),
                  ),

                  // Valet List Card
                  _buildMenuCard(
                    context,
                    icon: Icons.people,
                    title: 'Valet List',
                    color: Colors.orange,
                    onTap: () {
                      Get.put(BusinessHomeController());
                      Get.to(() => const ValetListView());
                    },
                  ),

                  _buildMenuCard(
                    context,
                    icon: Icons.edit_document,
                    title: 'Tickets',
                    color: Colors.blue,
                    onTap: () {
                      Get.put(BusinessTicketsController());
                      Get.to(() => const BusinessTicketsView());
                    },
                  ),

                  // Devices Card
                  _buildMenuCard(
                    context,
                    icon: Icons.devices,
                    title: 'Devices',
                    color: Colors.teal,
                    onTap: () {
                      Get.to(() => BusinessDevicesView());
                    },
                  ),

                  // Checkout Card
                  _buildMenuCard(
                    context,
                    icon: Icons.point_of_sale,
                    title: 'Checkout',
                    color: Colors.red,
                    onTap: () {
                      Get.put(BusinessCheckoutController());
                      Get.to(() => BusinessCheckoutView());
                    },
                  ),

                  // Payment Card
                  _buildMenuCard(
                    context,
                    icon: Icons.payment,
                    title: 'Payment',
                    color: Colors.purple,
                    onTap: () {
                      Get.put(BusinessPaymentController());
                      Get.to(() => const BusinessPaymentView());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.7),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
