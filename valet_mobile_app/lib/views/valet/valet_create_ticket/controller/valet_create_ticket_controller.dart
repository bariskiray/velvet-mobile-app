import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:valet_mobile_app/views/valet/valet_create_ticket/model/valet_create_ticket_request.dart';
import 'package:valet_mobile_app/auth/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  // Ticket oluşturma işlevi
  Future<void> createTicket() async {
    if (ticketIdController.text.isEmpty) {
      errorMessage.value = 'Lütfen bir bilet ID girin veya tarayın';
      return;
    }

    try {
      isLoading.value = true;

      final ticketRequest = TicketCreateRequest(
        ticketId: int.parse(ticketIdController.text),
      );

      print('Create Ticket Request: ${ticketRequest.toJson()}'); // Debug
      await ApiService.createTicket(ticketRequest);

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Bilet başarıyla oluşturuldu',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Create Ticket Error: $e');
      errorMessage.value = 'Bilet oluşturulamadı: ${e.toString()}';
      Get.snackbar(
        'Hata',
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
