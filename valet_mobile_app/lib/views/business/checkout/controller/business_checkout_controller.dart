import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:valet_mobile_app/views/business/business_home/model/valet_response.dart';

class BusinessCheckoutController extends GetxController {
  final ticketIdController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxList<ValetResponse> availableValets = <ValetResponse>[].obs;
  final RxBool useAutoSelect = true.obs;
  final Rx<ValetResponse?> selectedValet = Rx<ValetResponse?>(null);

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

  Future<void> refreshValets() async {
    try {
      final response = await ApiService.getValets();

      // Filter valets where is_busy is false
      final availableValetsList =
          List<ValetResponse>.from(response).where((valet) => valet.isBusy == false && valet.isWorking == true).toList();

      availableValets.assignAll(availableValetsList);

      Get.snackbar(
        'Success',
        'Valet list refreshed successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh valet list',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void toggleAutoSelect() {
    useAutoSelect.value = !useAutoSelect.value;
    if (useAutoSelect.value) {
      selectedValet.value = null;
    }
  }

  void selectValet(ValetResponse valet) {
    if (!useAutoSelect.value) {
      selectedValet.value = valet;
    }
  }

  Future<void> assignValet([ValetResponse? valet]) async {
    if (ticketIdController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a ticket ID first',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Set the valet based on selection mode
    final ValetResponse? selectedVal = useAutoSelect.value ? null : (valet ?? selectedValet.value);
    final String valetInfo = selectedVal != null ? 'valet ${selectedVal.valetName}' : 'automatic valet selection';

    try {
      await Get.dialog(
        AlertDialog(
          title: const Text('Assignment Confirmation'),
          content: Text('Do you want to assign the vehicle to $valetInfo?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                isLoading.value = true;

                final response = await ApiService.checkoutTicket(
                  int.parse(ticketIdController.text),
                  valetId: selectedVal?.valetId,
                );

                // Create success message based on selection mode
                String successMessage = 'Vehicle successfully assigned';

                if (selectedVal != null) {
                  // Manual selection - we know the valet
                  successMessage += ' to valet ${selectedVal.valetName} ${selectedVal.valetSurname}';
                } else if (useAutoSelect.value) {
                  // Auto selection - get valet info using valet_id from response
                  try {
                    if (response.data != null && response.data['valet_id'] != null) {
                      final valetId = response.data['valet_id'];
                      final valetDetails = await ApiService.getValetById(valetId);

                      final valetName = valetDetails['valet_name'] ?? '';
                      final valetSurname = valetDetails['valet_surname'] ?? '';

                      if (valetName.isNotEmpty) {
                        final fullName = valetSurname.isNotEmpty ? '$valetName $valetSurname' : valetName;
                        successMessage += ' to valet $fullName';
                      } else {
                        successMessage += ' using automatic selection';
                      }
                    } else {
                      successMessage += ' using automatic selection';
                    }
                  } catch (e) {
                    print('Error fetching valet details: $e');
                    successMessage += ' using automatic selection';
                  }
                }

                // Clear the ticket ID field after successful assignment
                ticketIdController.clear();

                // Refresh the valet list to update availability
                await fetchAvailableValets();

                Get.back();
                Get.snackbar(
                  'Success',
                  successMessage,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 4),
                );
              },
              child: const Text('Confirm'),
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
