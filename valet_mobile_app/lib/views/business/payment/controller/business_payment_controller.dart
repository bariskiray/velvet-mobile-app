import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/views/business/payment/model/business_payment_model.dart';

class BusinessPaymentController extends GetxController {
  final selectedPaymentMethod = 'Credit Card'.obs;
  final isLoading = false.obs;
  final amount = 0.0.obs;
  final ticketId = ''.obs;
  final parkingDuration = ''.obs;
  final isCheckingTicket = false.obs;

  @override
  void onInit() {
    ever(ticketId, (_) => checkTicket(ticketId.value));
    super.onInit();
  }

  Future<void> checkTicket(String id) async {
    if (id.isEmpty) return;

    isCheckingTicket.value = true;
    try {
      // Mock data için delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock park süresi
      if (id == "123") {
        parkingDuration.value = "2 saat 15 dakika";
        amount.value = 50.0;
      } else if (id == "456") {
        parkingDuration.value = "5 saat 30 dakika";
        amount.value = 120.0;
      } else {
        throw Exception("Ticket bulunamadı");
      }
    } catch (e) {
      Get.snackbar('Hata', 'Ticket bilgisi alınamadı');
      parkingDuration.value = '';
      amount.value = 0.0;
    } finally {
      isCheckingTicket.value = false;
    }
  }

  Future<void> processPayment() async {
    if (amount.value <= 0) {
      Get.snackbar('Hata', 'Lütfen geçerli bir tutar giriniz');
      return;
    }

    if (ticketId.value.isEmpty) {
      Get.snackbar('Hata', 'Lütfen ticket ID giriniz');
      return;
    }

    try {
      isLoading.value = true;

      // Mock payment işlemi
      await Future.delayed(const Duration(seconds: 1));

      final payment = BusinessPaymentModel(
        paymentId: 1,
        paymentDate: DateTime.now(),
        amount: amount.value,
        paymentMethod: selectedPaymentMethod.value,
        ticketId: ticketId.value,
      );

      print('Ödeme başarılı: ${payment.toJson()}');

      Get.snackbar('Başarılı', 'Ödeme işlemi tamamlandı');
      Get.offAllNamed('/business/home');
    } catch (e) {
      Get.snackbar('Hata', 'Ödeme işlemi başarısız');
    } finally {
      isLoading.value = false;
    }
  }

  void resetValues() {
    selectedPaymentMethod.value = 'Credit Card';
    amount.value = 0.0;
    ticketId.value = '';
    parkingDuration.value = '';
    isLoading.value = false;
    isCheckingTicket.value = false;
  }
}
