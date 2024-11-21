import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/components/base_text_field.dart';
import 'package:valet_mobile_app/views/valet/valet_complete_ticket/valet_complete_ticket_controller.dart';

class ValetCompleteTicketView extends GetView<ValetCompleteTicketController> {
  const ValetCompleteTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Complete Ticket'),
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: Obx(() => SingleChildScrollView(
            child: Column(
              children: [
                // Üst kısım - Mavi alan
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                            label: const Text(
                              'Scan QR',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.camera_alt, color: Colors.blue),
                            label: const Text(
                              'Take Photo',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Form alanı
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ticket Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Form alanları
                      BaseTextField(
                        controller: controller.ticketIdController,
                        labelText: 'Ticket ID',
                        hintText: 'Enter ticket ID',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      BaseTextField(
                        controller: controller.licensePlateController,
                        labelText: 'License Plate',
                        hintText: 'Enter license plate',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      BaseTextField(
                        controller: controller.brandController,
                        labelText: 'Brand',
                        hintText: 'Enter car brand',
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 16),
                      BaseTextField(
                        controller: controller.typeController,
                        labelText: 'Car Type',
                        hintText: 'Enter car type',
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 16),
                      BaseTextField(
                        controller: controller.colorController,
                        labelText: 'Color',
                        hintText: 'Enter car color',
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 16),
                      BaseTextField(
                        controller: controller.customerNameController,
                        labelText: 'Customer Name',
                        hintText: 'Enter customer name',
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 16),
                      BaseTextField(
                        controller: controller.customerSurnameController,
                        labelText: 'Customer Surname',
                        hintText: 'Enter customer surname',
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 32),

                      // Hata mesajı
                      if (controller.errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Create butonu
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.completeTicket,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Complete Ticket',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
