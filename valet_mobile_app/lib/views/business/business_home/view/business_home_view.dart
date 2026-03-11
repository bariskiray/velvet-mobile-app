import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/auth/auth_controller.dart';
import 'package:valet_mobile_app/views/business/business_home/controller/business_home_controller.dart';
import 'package:valet_mobile_app/views/business/business_tickets/view/business_tickets_view.dart';
import 'package:valet_mobile_app/views/business/business_tickets/controller/business_tickets_controller.dart';
import 'package:valet_mobile_app/views/business/devices/view/business_devices_view.dart';
import 'package:valet_mobile_app/views/business/business_home/view/valet_list_view.dart';
import 'package:valet_mobile_app/views/business/statistics/statistics_view.dart';
import 'package:valet_mobile_app/views/business/statistics/statistics_controller.dart';
import 'package:valet_mobile_app/views/business/checkout/view/business_checkout_view.dart';
import 'package:valet_mobile_app/views/business/checkout/controller/business_checkout_controller.dart';
import 'package:valet_mobile_app/views/business/payment/view/business_payment_view.dart';
import 'package:valet_mobile_app/views/business/payment/controller/business_payment_controller.dart';
import 'package:valet_mobile_app/views/valet/valet_login/view/valet_register_view.dart';
import 'package:valet_mobile_app/views/business/parking_spots/view/business_parking_spots_view.dart';
import 'package:valet_mobile_app/views/business/parking_spots/controller/business_parking_spots_controller.dart';

class BusinessHomeView extends StatelessWidget {
  BusinessHomeView({Key? key}) : super(key: key);

  // Lazy getter to access controller when needed
  BusinessHomeController get controller => Get.find<BusinessHomeController>();

  // Navigate to pages with their controllers properly initialized
  void _navigateToTickets() {
    if (!Get.isRegistered<BusinessTicketsController>()) {
      Get.put(BusinessTicketsController());
    }
    Get.to(() => const BusinessTicketsView());
  }

  void _navigateToValets() {
    Get.to(() => const ValetListView());
  }

  void _navigateToDevices() {
    Get.to(() => BusinessDevicesView());
  }

  void _navigateToStatistics() {
    if (!Get.isRegistered<StatisticsController>()) {
      Get.put(StatisticsController());
    }
    Get.to(() => const StatisticsView());
  }

  void _navigateToAddValet() {
    Get.to(() => ValetRegisterView());
  }

  void _navigateToCheckout() {
    if (!Get.isRegistered<BusinessCheckoutController>()) {
      Get.put(BusinessCheckoutController());
    }
    Get.to(() => BusinessCheckoutView());
  }

  void _navigateToPayment() {
    if (!Get.isRegistered<BusinessPaymentController>()) {
      Get.put(BusinessPaymentController());
    }
    Get.to(() => const BusinessPaymentView());
  }

  void _navigateToAddParkingSpot() {
    if (!Get.isRegistered<BusinessParkingSpotsController>()) {
      Get.put(BusinessParkingSpotsController());
    }
    Get.to(() => const BusinessParkingSpotsView());
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already initialized
    if (!Get.isRegistered<BusinessHomeController>()) {
      Get.put(BusinessHomeController());
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthController.to.logout();
            },
          ),
        ],
      ),
      body: Obx(() => controller.isLoading.value ? const Center(child: CircularProgressIndicator()) : _buildBody()),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        controller.refreshData();
        controller.fetchValets();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Top info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A73E8),
                    Color(0xFF0D47A1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: () {
                            controller.refreshData();
                            Get.snackbar(
                              'Refreshing',
                              'Dashboard data updated',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.blue,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 1),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Daily stats overview
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Today\'s Visits',
                          '${controller.todayTicketCount}',
                          Icons.confirmation_number,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Today\'s Revenue',
                          '\$${controller.todayRevenue.toStringAsFixed(2)}',
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Main menu section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Main Menu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildActionCard(
                        'Tickets',
                        Icons.confirmation_number_outlined,
                        const Color(0xFF42A5F5),
                        _navigateToTickets,
                      ),
                      _buildActionCard(
                        'Valets',
                        Icons.people_outline,
                        const Color(0xFF66BB6A),
                        _navigateToValets,
                      ),
                      _buildActionCard(
                        'Devices',
                        Icons.phone_android_outlined,
                        const Color(0xFFFFB74D),
                        _navigateToDevices,
                      ),
                      _buildActionCard(
                        'Statistics',
                        Icons.bar_chart_outlined,
                        const Color(0xFFF06292),
                        _navigateToStatistics,
                      ),
                      _buildActionCard(
                        'Add Valet',
                        Icons.person_add,
                        const Color(0xFF26A69A),
                        _navigateToAddValet,
                      ),
                      _buildActionCard(
                        'Checkout',
                        Icons.point_of_sale,
                        const Color(0xFFEF5350),
                        _navigateToCheckout,
                      ),
                      _buildActionCard(
                        'Payment',
                        Icons.payment,
                        const Color(0xFF9575CD),
                        _navigateToPayment,
                      ),
                      _buildActionCard(
                        'Add Parking Spot',
                        Icons.local_parking,
                        const Color(0xFF26C6DA),
                        _navigateToAddParkingSpot,
                      ),
                      _buildActionCard(
                        'Settings',
                        Icons.settings,
                        const Color(0xFF78909C),
                        () => Get.snackbar(
                          'Coming Soon',
                          'Settings page is under development',
                          snackPosition: SnackPosition.BOTTOM,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
