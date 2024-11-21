import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ValetCompleteTicketController extends GetxController {
  // Text editing controllers
  final ticketIdController = TextEditingController();
  final licensePlateController = TextEditingController();
  final brandController = TextEditingController();
  final typeController = TextEditingController();
  final colorController = TextEditingController();
  final customerNameController = TextEditingController();
  final customerSurnameController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Form validation
  bool validateForm() {
    if (ticketIdController.text.isEmpty) {
      errorMessage.value = 'Ticket ID is required';
      return false;
    }
    if (licensePlateController.text.isEmpty) {
      errorMessage.value = 'License plate is required';
      return false;
    }
    if (brandController.text.isEmpty) {
      errorMessage.value = 'Brand is required';
      return false;
    }
    if (typeController.text.isEmpty) {
      errorMessage.value = 'Type is required';
      return false;
    }
    if (colorController.text.isEmpty) {
      errorMessage.value = 'Color is required';
      return false;
    }
    if (customerNameController.text.isEmpty) {
      errorMessage.value = 'Customer name is required';
      return false;
    }
    if (customerSurnameController.text.isEmpty) {
      errorMessage.value = 'Customer surname is required';
      return false;
    }
    return true;
  }

  // Create ticket method
  Future<void> completeTicket() async {
    try {
      if (!validateForm()) return;

      isLoading.value = true;

      // Ticket oluşturma işlemleri burada yapılacak
      // Örnek:
      // final ticket = TicketModel(
      //   licensePlate: licensePlateController.text,
      //   brand: brandController.text,
      //   type: typeController.text,
      //   color: colorController.text,
      //   customerName: customerNameController.text,
      //   customerSurname: customerSurnameController.text,
      // );

      // await ticketService.createTicket(ticket);

      clearForm();
      Get.back(); // Başarılı olduğunda önceki sayfaya dön
      Get.snackbar(
        'Success',
        'Ticket completed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Failed to complete ticket: ${e.toString()}';
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

  // Clear form
  void clearForm() {
    licensePlateController.clear();
    brandController.clear();
    typeController.clear();
    colorController.clear();
    customerNameController.clear();
    customerSurnameController.clear();
    errorMessage.value = '';
  }

  @override
  void onClose() {
    // Controller'ları dispose et
    licensePlateController.dispose();
    brandController.dispose();
    typeController.dispose();
    colorController.dispose();
    customerNameController.dispose();
    customerSurnameController.dispose();
    super.onClose();
  }
}
