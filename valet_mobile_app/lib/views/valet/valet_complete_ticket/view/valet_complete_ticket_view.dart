import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/components/base_text_field.dart';
import 'package:valet_mobile_app/views/valet/valet_complete_ticket/controller/valet_complete_ticket_controller.dart';

class ValetCompleteTicketView extends GetView<ValetCompleteTicketController> {
  const ValetCompleteTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    // View'a her girişte verileri yenile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshTickets();
    });

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
                    // İlk Sayfa - Ticket Kartı veya Boş Durum
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.blue[900],
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Text(
                                    'Open Ticket',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Click on the ticket to complete',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (controller.ticketIdController.text.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.note_add_outlined,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Open Tickets',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'You haven\'t created any tickets yet.\nPlease create a ticket first.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: InkWell(
                                  onTap: () => controller.nextPage(),
                                  borderRadius: BorderRadius.circular(15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[900]!.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.local_parking,
                                                color: Colors.blue[900],
                                                size: 30,
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Ticket #${controller.ticketIdController.text}',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Status: Waiting for completion',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.grey[400],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // İkinci Sayfa - Mevcut araç detayları sayfası
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          // Fotoğraf çekme alanı
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
                          // Seçilen fotoğraf
                          if (controller.selectedImage.value != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Stack(
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
                                  // AI işlemi sırasında loading göstergesi
                                  if (controller.isLoading.value)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                        child: const Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(color: Colors.white),
                                              SizedBox(height: 8),
                                              Text(
                                                'AI Analysis in Progress...',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  // Silme butonu
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
                            ),
                          // Form alanları
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Araç bilgileri
                                BaseTextField(
                                  controller: controller.licensePlateController,
                                  labelText: 'Plate',
                                  hintText: 'Enter plate',
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 16),
                                BaseTextField(
                                  controller: controller.brandController,
                                  labelText: 'Brand',
                                  hintText: 'Enter brand',
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 16),
                                BaseTextField(
                                  controller: controller.colorController,
                                  labelText: 'Color',
                                  hintText: 'Enter color',
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 16),
                                // Park bilgileri
                                BaseTextField(
                                  controller: controller.parkingSpotController,
                                  labelText: 'Parking Spot',
                                  hintText: 'Enter parking spot',
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                BaseTextField(
                                  controller: controller.noteController,
                                  labelText: 'Note',
                                  hintText: 'Enter note',
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 16),
                                // Hasar durumu
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: ListTile(
                                    title: const Text(
                                      'Damage on Vehicle',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: Obx(() => Switch(
                                          value: controller.isDamaged.value,
                                          onChanged: (value) => controller.isDamaged.value = value,
                                        )),
                                  ),
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
              // Alt kısım - Butonlar
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
