import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ValetCreateTicketController extends GetxController {
  // Text editing controller
  final ticketIdController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // QR tarama işlevi
  Future<void> scanQR() async {
    try {
      // QR tarama işlemi
      // Örnek:
      // final qrText = await QRScanner.scan();
      // ticketIdController.text = qrText;
    } catch (e) {
      errorMessage.value = 'Failed to scan QR code: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Ticket tamamlama işlevi
  Future<void> createTicket() async {
    if (ticketIdController.text.isEmpty) {
      errorMessage.value = 'Please enter or scan a ticket ID';
      return;
    }

    try {
      isLoading.value = true;

      // Ticket tamamlama işlemleri burada yapılacak
      // Örnek:
      // await ticketService.completeTicket(ticketIdController.text);

      Get.back(); // Başarılı olduğunda önceki sayfaya dön
      Get.snackbar(
        'Success',
        'Ticket created successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Failed to create ticket: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    ticketIdController.dispose();
    super.onClose();
  }
}
