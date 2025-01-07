import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import '../controller/business_tickets_controller.dart';
import 'package:intl/intl.dart';

class BusinessTicketsView extends GetView<BusinessTicketsController> {
  const BusinessTicketsView({Key? key}) : super(key: key);

  Widget _buildFilterButton() {
    return IconButton(
      icon: const Icon(Icons.filter_list),
      onPressed: () {
        Get.bottomSheet(
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Start Date
                ListTile(
                  title: const Text('Start Date'),
                  subtitle: Obx(() => Text(
                        controller.selectedStartDate.value != null
                            ? DateFormat('MM/dd/yyyy').format(controller.selectedStartDate.value!)
                            : 'Not selected',
                      )),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: Get.context!,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      controller.selectedStartDate.value = date;
                    }
                  },
                ),
                // End Date
                ListTile(
                  title: const Text('End Date'),
                  subtitle: Obx(() => Text(
                        controller.selectedEndDate.value != null
                            ? DateFormat('MM/dd/yyyy').format(controller.selectedEndDate.value!)
                            : 'Not selected',
                      )),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: Get.context!,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      controller.selectedEndDate.value = date;
                    }
                  },
                ),
                // Status Dropdown with updated options
                ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: const Text('Status'),
                  ),
                  subtitle: Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<int?>(
                          value: controller.selectedStatus.value,
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: const Text('Select status'),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All'),
                            ),
                            ...List.generate(4, (index) {
                              final status = index + 1;
                              return DropdownMenuItem<int?>(
                                value: status,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        gradient: LinearGradient(
                                          colors: controller.getStatusGradientColor(status),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(controller.getStatusText(status)),
                                  ],
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            controller.selectedStatus.value = value;
                          },
                        ),
                      )),
                ),
                const SizedBox(height: 12),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        controller.resetFilters();
                        Get.back();
                      },
                      child: const Text('Reset'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        controller.fetchTickets();
                        Get.back();
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          isScrollControlled: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tickets'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          _buildFilterButton(),
        ],
      ),
      body: Obx(() => SmartRefresher(
            controller: controller.refreshController,
            onRefresh: controller.fetchTickets,
            child: controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = controller.tickets[index];
                      return TweenAnimationBuilder(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // Detay sayfasına git
                                },
                                child: Column(
                                  children: [
                                    _buildTicketHeader(ticket),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          _buildCarInfo(ticket),
                                          const SizedBox(height: 16),
                                          _buildParkingInfo(ticket),
                                          if (ticket['note']?.isNotEmpty ?? false) _buildNoteSection(ticket['note']),
                                          if (ticket['damage'] == 1) _buildDamageSection(),
                                          InkWell(
                                            onTap: controller.isTicketPaid(ticket['ticket_id'])
                                                ? () => _showPaymentDetails(context, ticket['ticket_id'])
                                                : null,
                                            child: Container(
                                              margin: const EdgeInsets.only(top: 12),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: controller.isTicketPaid(ticket['ticket_id']) ? Colors.green[50] : Colors.red[50],
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: controller.isTicketPaid(ticket['ticket_id']) ? Colors.green : Colors.red,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    controller.isTicketPaid(ticket['ticket_id']) ? Icons.check_circle : Icons.pending,
                                                    size: 16,
                                                    color: controller.isTicketPaid(ticket['ticket_id']) ? Colors.green : Colors.red,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    controller.isTicketPaid(ticket['ticket_id']) ? 'Paid' : 'Pending',
                                                    style: TextStyle(
                                                      color: controller.isTicketPaid(ticket['ticket_id']) ? Colors.green : Colors.red,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          )),
    );
  }

  Widget _buildTicketHeader(Map<String, dynamic> ticket) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: controller.getStatusGradientColor(ticket['progress_status']),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${ticket['ticket_id']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDate(ticket['open_date']),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              controller.getStatusText(ticket['progress_status']),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarInfo(Map<String, dynamic> ticket) {
    final carId = ticket['car_id'] ?? 0;
    final valetId = ticket['valet_id'] ?? 0;

    final car = carId != 0 ? controller.getCarDetails(carId) : null;
    final valet = valetId != 0 ? controller.getValetDetails(valetId) : null;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.directions_car, color: Colors.black54),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (car != null) ...[
                Text(
                  car['license_plate']?.toString() ?? 'No plate',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${car['brand'] ?? 'Unknown'} - ${car['color'] ?? 'Unknown'}',
                  style: TextStyle(
                    color: const Color(0xFF757575),
                    fontSize: 14,
                  ),
                ),
              ] else
                const Text(
                  'Car details not available',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              if (valet != null)
                Text(
                  'Valet: ${valet['valet_name'] ?? ''} ${valet['valet_surname'] ?? ''}',
                  style: TextStyle(
                    color: const Color(0xFF757575),
                    fontSize: 14,
                  ),
                )
              else
                const Text(
                  'Valet details not available',
                  style: TextStyle(
                    color: const Color(0xFF757575),
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParkingInfo(Map<String, dynamic> ticket) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_parking, color: Colors.black54),
          const SizedBox(width: 12),
          Text(
            'Parking Spot: ${ticket['parking_spot'] ?? 'Not parked yet'}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(String note) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.note, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              note,
              style: TextStyle(color: Colors.blue[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDamageSection() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Vehicle has damage',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return DateFormat('dd MMM yyyy HH:mm').format(dateTime);
  }

  void _showPaymentDetails(BuildContext context, int ticketId) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 20,
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
              const Divider(),
              // Payment Details
              FutureBuilder<Map<String, dynamic>?>(
                future: ApiService.getPaymentByTicketId(ticketId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error loading payment details',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    );
                  }

                  final payment = snapshot.data;
                  if (payment == null) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No payment details found'),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        _buildPaymentDetailRow(
                          'Amount',
                          '\$${(payment['amount'] ?? 0).toStringAsFixed(2)}',
                          Icons.attach_money,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentDetailRow(
                          'Tip',
                          '\$${(payment['tip'] ?? 0).toStringAsFixed(2)}',
                          Icons.volunteer_activism,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentDetailRow(
                          'Total',
                          '\$${((payment['amount'] ?? 0) + (payment['tip'] ?? 0)).toStringAsFixed(2)}',
                          Icons.calculate,
                          isTotal: true,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentDetailRow(
                          'Payment Method',
                          payment['payment_method'] ?? 'N/A',
                          Icons.credit_card,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentDetailRow(
                          'Date',
                          payment['payment_date'] != null
                              ? DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(payment['payment_date']))
                              : 'N/A',
                          Icons.calendar_today,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, String value, IconData icon, {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTotal ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTotal ? Colors.blue[200]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTotal ? Colors.blue[100] : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isTotal ? Colors.blue[900] : Colors.grey[700],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: isTotal ? Colors.blue[900] : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
