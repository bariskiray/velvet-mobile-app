import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/components/base_text_field.dart';
import 'package:valet_mobile_app/views/valet/valet_complete_ticket/controller/valet_complete_ticket_controller.dart';

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
      body: Obx(() => Column(
            children: [
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // İlk Sayfa - QR ve Ticket ID
                    SingleChildScrollView(
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
                                      onPressed: () => controller.scanQR(),
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
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: BaseTextField(
                              controller: controller.ticketIdController,
                              labelText: 'Ticket ID',
                              hintText: 'Enter ticket ID',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // İkinci Sayfa - Araba Detayları
                    SingleChildScrollView(
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
                                      onPressed: () => controller.takePhoto(),
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
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => controller.pickFromGallery(),
                                      icon: const Icon(Icons.photo_library, color: Colors.blue),
                                      label: const Text(
                                        'Gallery',
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
                          const SizedBox(height: 16),
                          if (controller.selectedImage.value != null)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selected Photo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Stack(
                                    children: [
                                      Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          image: DecorationImage(
                                            image: FileImage(controller.selectedImage.value!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () => controller.removeImage(),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                BaseTextField(
                                  controller: controller.licensePlateController,
                                  labelText: 'License Plate',
                                  hintText: 'Enter license plate',
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 16),
                                BaseTextField(
                                  controller: controller.brandController,
                                  labelText: 'Brand',
                                  hintText: 'Enter car brand',
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 16),
                                BaseTextField(
                                  controller: controller.typeController,
                                  labelText: 'Car Type',
                                  hintText: 'Enter car type',
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 16),
                                BaseTextField(
                                  controller: controller.colorController,
                                  labelText: 'Color',
                                  hintText: 'Enter car color',
                                  keyboardType: TextInputType.text,
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (controller.currentPage.value > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => controller.previousPage(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (controller.currentPage.value == 0) {
                                  controller.nextPage();
                                } else {
                                  controller.completeTicket();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
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
                            : Text(
                                controller.currentPage.value == 1 ? 'Complete Ticket' : 'Continue',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
