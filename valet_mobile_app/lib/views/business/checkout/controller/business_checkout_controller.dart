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

      // Filter valets where is_busy is false
      final availableValetsList =
          List<ValetResponse>.from(response).where((valet) => valet.isBusy == false && valet.isWorking == true).toList();

      availableValets.assignAll(availableValetsList);
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while loading valet list',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignValet(ValetResponse valet) async {
    if (ticketIdController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a ticket ID first',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await Get.dialog(
        AlertDialog(
          title: Text('Assignment Confirmation'),
          content: Text('Do you want to assign the vehicle to valet ${valet.valetName}?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                isLoading.value = true;

                await ApiService.checkoutTicket(
                  int.parse(ticketIdController.text),
                  valet.valetId,
                );

                Get.back();
                Get.snackbar(
                  'Success',
                  'Vehicle successfully assigned to valet ${valet.valetName}',
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
      Get.snackbar(
        'Error',
        'Valet assignment failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
