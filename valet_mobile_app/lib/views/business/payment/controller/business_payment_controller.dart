import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:valet_mobile_app/views/business/business_home/view/business_home_view.dart';
import 'package:valet_mobile_app/views/business/payment/model/business_payment_model.dart';

class BusinessPaymentController extends GetxController {
  final selectedPaymentMethod = 'Credit Card'.obs;
  final isLoading = false.obs;
  final amount = 0.0.obs;
  final tip = 0.0.obs;
  final ticketId = ''.obs;
  final parkingDuration = ''.obs;
  final isCheckingTicket = false.obs;
  final selectedTipPercentage = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> checkTicket(String id) async {
    if (id.isEmpty) return;

    isCheckingTicket.value = true;
    try {
      final response = await ApiService.getTicketById(int.parse(id));

      // Calculate duration
      final openDate = DateTime.parse(response['open_date']);
      final closeDate = response['close_date'] != null ? DateTime.parse(response['close_date']) : DateTime.now();

      final duration = closeDate.difference(openDate);

      // Format duration
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      parkingDuration.value = '$hours hours ${minutes > 0 ? '$minutes minutes' : ''}';

      // Calculate fee (Example: $10 per hour)
      final hourlyRate = 10.0;
      amount.value = (hours + (minutes / 60)) * hourlyRate;

      // Round amount
      amount.value = double.parse(amount.value.toStringAsFixed(2));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get ticket information: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      parkingDuration.value = '';
      amount.value = 0.0;
    } finally {
      isCheckingTicket.value = false;
    }
  }

  Future<void> processPayment() async {
    if (amount.value <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount');
      return;
    }

    if (ticketId.value.isEmpty) {
      Get.snackbar('Error', 'Please enter a ticket ID');
      return;
    }

    try {
      isLoading.value = true;

      final response = await ApiService.createPayment(
        amount: amount.value,
        paymentMethod: selectedPaymentMethod.value.toLowerCase(),
        tip: tip.value,
        ticketId: int.parse(ticketId.value),
      );

      final payment = BusinessPaymentModel(
        paymentId: response.data['id'] ?? 1,
        paymentDate: DateTime.now(),
        amount: amount.value,
        paymentMethod: selectedPaymentMethod.value,
        ticketId: ticketId.value,
        tip: tip.value,
      );

      print('Payment successful: ${payment.toJson()}');

      resetValues();

      // Başarılı ödeme snackbar'ı
      await Get.snackbar(
        'Success',
        'Payment Completed',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      Get.snackbar(
        'Payment Failed',
        'Error: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetValues() {
    selectedPaymentMethod.value = 'Credit Card';
    amount.value = 0.0;
    tip.value = 0.0;
    ticketId.value = '';
    parkingDuration.value = '';
    isLoading.value = false;
    isCheckingTicket.value = false;
  }

  void increaseAmount() {
    amount.value += 1;
  }

  void decreaseAmount() {
    if (amount.value > 0) {
      amount.value -= 1;
    }
  }

  void increaseTip() {
    tip.value += 1;
  }

  void decreaseTip() {
    if (tip.value > 0) {
      tip.value -= 1;
    }
  }

  void setTipPercentage(double percentage) {
    selectedTipPercentage.value = percentage;
    tip.value = (amount.value * percentage).roundToDouble();
  }

  @override
  void onClose() {
    resetValues();
    super.onClose();
  }
}
