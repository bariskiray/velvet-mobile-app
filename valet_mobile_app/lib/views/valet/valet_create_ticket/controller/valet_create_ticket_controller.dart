import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:valet_mobile_app/views/valet/valet_complete_ticket/controller/valet_complete_ticket_controller.dart';
import 'package:valet_mobile_app/views/valet/valet_complete_ticket/view/valet_complete_ticket_view.dart';
import 'package:valet_mobile_app/views/valet/valet_create_ticket/model/valet_create_ticket_request.dart';

class ValetCreateTicketController extends GetxController {
  // Text editing controller
  final ticketIdController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final hasOpenTicket = false.obs;
  final openTicketId = ''.obs;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void onInit() {
    super.onInit();
    checkOpenTickets();
  }

  Future<void> checkOpenTickets() async {
    try {
      final openTickets = await ApiService.getOpenTickets();

      // Sadece progress_status = 1 olan biletler gelecek
      if (openTickets.isNotEmpty) {
        hasOpenTicket.value = true;
        openTicketId.value = openTickets.first['ticket_id'].toString();

        Get.snackbar(
          'Warning',
          'Found uncompleted ticket: #${openTicketId.value}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          mainButton: TextButton(
            onPressed: goToCompleteTicket,
            child: const Text(
              'Complete Ticket',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        hasOpenTicket.value = false;
      }
    } catch (e) {
      print('Check Open Tickets Error: $e');
    }
  }

  // QR tarama işlevi -> QR scanning function
  Future<void> scanQR() async {
    try {
      if (hasOpenTicket.value) {
        Get.snackbar(
          'Error',
          'Please complete the open ticket (#${openTicketId.value}) first',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

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
    } catch (e) {
      print('Scan QR Error: $e');
      errorMessage.value = 'QR scanning error: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
    try {
      if (hasOpenTicket.value) {
        Get.snackbar(
          'Error',
          'Please complete the open ticket (#${openTicketId.value}) first',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (ticketIdController.text.isEmpty) {
        errorMessage.value = 'Please enter a ticket ID';
        return;
      }

      try {
        isLoading.value = true;

        final ticketRequest = TicketCreateRequest(
          ticketId: int.parse(ticketIdController.text),
        );

        print('Create Ticket Request: ${ticketRequest.toJson()}');
        await ApiService.createTicket(ticketRequest);

        Get.back(closeOverlays: true);
        Get.snackbar(
          'Success',
          'Ticket created successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print('Create Ticket Error: $e');
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
    } catch (e) {
      print('Create Ticket Error: $e');
      errorMessage.value = 'Failed to create ticket: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void goToCompleteTicket() {
    if (openTicketId.value.isNotEmpty) {
      try {
        final completeController = Get.put(ValetCompleteTicketController());
        completeController.ticketIdController.text = openTicketId.value;

        Get.to(
          () => ValetCompleteTicketView(),
          transition: Transition.rightToLeft,
        )?.then((_) {
          // Complete ticket sayfasından dönüldüğünde tekrar kontrol et
          checkOpenTickets();
        });
      } catch (e) {
        print('Navigation Error: $e');
        Get.snackbar(
          'Error',
          'Failed to navigate to page',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  void onClose() {
    ticketIdController.dispose();
    super.onClose();
  }
}
