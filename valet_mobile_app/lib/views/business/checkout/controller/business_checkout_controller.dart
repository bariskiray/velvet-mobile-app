import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:valet_mobile_app/views/business/business_home/model/valet_response.dart';

class BusinessCheckoutController extends GetxController {
  final ticketIdController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxList<ValetResponse> availableValets = <ValetResponse>[].obs;

  QRViewController? qrController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final Rx<Barcode?> result = Rx<Barcode?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchAvailableValets();
  }

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  void onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      result.value = scanData;
      if (scanData.code != null) {
        ticketIdController.text = scanData.code!;
        Get.back(); // QR tarayıcı sayfasını kapat
      }
    });
  }

  void onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      Get.snackbar('Error', 'Camera permission denied');
    }
  }

  Future<void> scanQRCode() async {
    Get.to(() => Scaffold(
          appBar: AppBar(
            title: Text('Scan QR Code'),
          ),
          body: Column(
            children: [
              Expanded(
                flex: 4,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: onQRViewCreated,
                  onPermissionSet: (ctrl, p) => onPermissionSet(Get.context!, ctrl, p),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> fetchAvailableValets() async {
    try {
      isLoading.value = true;
      final response = await ApiService.getValets();

      // is_busy değeri false olan vale'leri filtrele
      final availableValetsList = List<ValetResponse>.from(response).where((valet) => valet.isBusy == false).toList();

      availableValets.assignAll(availableValetsList);
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Vale listesi yüklenirken bir hata oluştu',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignValet(dynamic valet) async {
    if (ticketIdController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a ticket ID first');
      return;
    }

    try {
      await Get.dialog(
        AlertDialog(
          title: Text('Confirm Assignment'),
          content: Text('Would you like to assign the car to ${valet['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                // TODO: API integration will be added
                Get.back(); // Exit checkout page
                Get.snackbar(
                  'Success',
                  'Car successfully assigned to ${valet['name']}',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              child: Text('Confirm'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to assign valet');
    }
  }
}
