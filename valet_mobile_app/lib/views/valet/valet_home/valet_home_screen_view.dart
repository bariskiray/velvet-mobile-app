import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:valet_mobile_app/views/valet/valet_complete_ticket/controller/valet_complete_ticket_controller.dart';
import 'package:valet_mobile_app/views/valet/valet_complete_ticket/view/valet_complete_ticket_view.dart';
import 'package:valet_mobile_app/views/valet/valet_create_ticket/controller/valet_create_ticket_controller.dart';
import 'package:valet_mobile_app/views/valet/valet_create_ticket/view/valet_create_ticket_view.dart';
import 'package:valet_mobile_app/auth/auth_controller.dart';
import 'package:valet_mobile_app/views/valet/valet_home/controller/valet_home_controller.dart';

class ValetHomeView extends StatefulWidget {
  const ValetHomeView({super.key});

  @override
  State<ValetHomeView> createState() => _ValetHomeViewState();
}

class _ValetHomeViewState extends State<ValetHomeView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final controller = Get.put(ValetHomeController());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Valet Panel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[900],
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))),
        actions: [
          IconButton(
            icon: Icon(
              Icons.local_parking,
              color: Colors.white,
            ),
            onPressed: () => controller.showParkingSpotsDialog(),
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Color.fromARGB(255, 146, 35, 27),
            ),
            onPressed: () => controller.logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.checkForAssignments();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_car_rounded,
                            size: 32,
                            color: Colors.blue[900],
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Back',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Valet Service',
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(() => AnimatedSlide(
                        duration: const Duration(milliseconds: 500),
                        offset: controller.hasNewAssignment.value ? Offset.zero : const Offset(0, -2),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: controller.hasNewAssignment.value ? 1 : 0,
                          child: controller.hasNewAssignment.value ? _buildNewAssignmentCard() : const SizedBox.shrink(),
                        ),
                      )),
                  const SizedBox(height: 50),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildActionButton(
                        title: 'Create Ticket',
                        icon: Icons.add_circle_outline,
                        color: Colors.blue[900]!,
                        onPressed: () {
                          Get.put(ValetCreateTicketController());
                          Get.to(() => const ValetCreateTicketView());
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildActionButton(
                        title: 'Complete Ticket',
                        icon: Icons.check_circle_outline,
                        color: Colors.green[700]!,
                        onPressed: () {
                          Get.put(ValetCompleteTicketController());
                          Get.to(() => const ValetCompleteTicketView());
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(icon, size: 30, color: color),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewAssignmentCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDeliveryConfirmation(),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[900]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue[900]!.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Car Assignment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            'Location: ${controller.carDetails.value?['locationName'] ?? ''}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          )),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeliveryConfirmation() {
    final isConfirmed = false.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Car Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Brand', '${controller.carDetails.value?['brand']}'),
                      _buildDetailRow('Plate', controller.carDetails.value?['plate'] ?? ''),
                      _buildDetailRow('Color', controller.carDetails.value?['color'] ?? ''),
                      _buildDetailRow('Location', controller.carDetails.value?['locationName'] ?? ''),
                      _buildDetailRow('Ticket ID', controller.carDetails.value?['ticketId'] ?? ''),
                      const SizedBox(height: 20),

                      // Map Container
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Obx(
                          () => controller.isLoadingLocation.value
                              ? const Center(child: CircularProgressIndicator())
                              : controller.selectedLocation.value != null
                                  ? GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: controller.selectedLocation.value!,
                                        zoom: 17.0,
                                      ),
                                      markers: controller.markers.value,
                                      mapType: MapType.normal,
                                      onMapCreated: controller.onMapCreated,
                                      myLocationEnabled: true,
                                      myLocationButtonEnabled: true,
                                      zoomControlsEnabled: true,
                                      compassEnabled: true,
                                    )
                                  : Center(
                                      child: Text(
                                        'No location information found',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Obx(() => CheckboxListTile(
                            value: isConfirmed.value,
                            onChanged: (value) => isConfirmed.value = value!,
                            title: const Text('I confirm that I delivered the car to the customer.'),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.blue[700],
                            contentPadding: EdgeInsets.zero,
                          )),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: Obx(() => ElevatedButton(
                              onPressed: isConfirmed.value ? () => controller.confirmCarDelivery() : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Confirm Delivery'),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
