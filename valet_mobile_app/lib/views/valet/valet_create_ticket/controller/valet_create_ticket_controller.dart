import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:valet_mobile_app/views/valet/valet_complete_ticket/controller/valet_complete_ticket_controller.dart';
import 'package:valet_mobile_app/views/valet/valet_complete_ticket/view/valet_complete_ticket_view.dart';
import 'package:valet_mobile_app/views/valet/valet_create_ticket/model/valet_create_ticket_request.dart';
import 'package:geolocator/geolocator.dart';
import 'package:valet_mobile_app/views/valet/valet_create_ticket/view/navigation_map_view.dart';

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

        // Başarılı ticket oluşturma sonrası navigasyon dialog'unu göster
        _showNavigationDialog();
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

  void _showNavigationDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[50]!,
                Colors.white,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // İkon ve başlık
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.navigation,
                  size: 40,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Start Navigation?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Would you like to start navigation to the closest parking spot for parking the car?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'No',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _startNavigation();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Yes, Start',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // Navigasyon başlatma işlevi
  Future<void> _startNavigation() async {
    try {
      // Loading göster
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        barrierDismissible: false,
      );

      // Konum izni kontrol et
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.back(); // Loading dialog'unu kapat
        Get.snackbar(
          'Error',
          'Location service is turned off. Please enable location service.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.back(); // Loading dialog'unu kapat
          Get.snackbar(
            'Error',
            'Location permission denied.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.back(); // Loading dialog'unu kapat
        Get.snackbar(
          'Error',
          'Location permission permanently denied. Please enable it from settings.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Mevcut konumu al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // En yakın park yerini bul
      final closestParkingSpot = await ApiService.getClosestParkingSpot(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      Get.back(); // Loading dialog'unu kapat

      // Kendi harita sayfamıza git
      Get.to(
        () => NavigationMapView(
          currentLatitude: position.latitude,
          currentLongitude: position.longitude,
          destinationLatitude: closestParkingSpot['latitude'],
          destinationLongitude: closestParkingSpot['longitude'],
          destinationName: closestParkingSpot['name'] ?? 'Parking Spot',
        ),
        transition: Transition.rightToLeft,
      );

      Get.snackbar(
        'Navigation Started',
        'Closest parking spot: ${closestParkingSpot['name'] ?? 'Unknown'}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.back(); // Loading dialog'unu kapat (hata durumunda)
      print('Navigation Error: $e');
      Get.snackbar(
        'Error',
        'An error occurred while starting navigation: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    ticketIdController.dispose();
    super.onClose();
  }
}
