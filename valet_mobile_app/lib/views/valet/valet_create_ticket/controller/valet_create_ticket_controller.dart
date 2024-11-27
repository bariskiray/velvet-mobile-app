import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ValetCreateTicketController extends GetxController {
  // Text editing controller
  final ticketIdController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // QR tarama işlevi
  void scanQR() {
    Get.to(() => Scaffold(
          appBar: AppBar(
            title: const Text('Scan Ticket ID'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
          ),
          body: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.blue,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
          ),
        ));
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        controller.dispose();
        Get.back();
        ticketIdController.text = scanData.code!;
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
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
