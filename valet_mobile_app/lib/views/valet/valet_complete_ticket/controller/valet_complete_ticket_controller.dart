import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:valet_mobile_app/views/valet/valet_complete_ticket/model/valet_complete_ticket_model.dart';

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

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // Mevcut değişkenlere ek olarak:
  final currentStep = 0.obs;

  var pageController = PageController();
  final currentPage = 0.obs;

  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedImage = Rx<File?>(null);

  // Yeni değişkenler ekleyelim
  final noteController = TextEditingController();
  final parkingSpotController = TextEditingController();
  final isDamaged = false.obs;

  // Açık bilet bilgilerini tutmak için
  final hasOpenTicket = false.obs;
  final openTicketId = ''.obs;

  // Form validation
  bool validateForm() {
    if (ticketIdController.text.isEmpty) {
      errorMessage.value = 'Ticket ID is required';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (licensePlateController.text.isEmpty) {
      errorMessage.value = 'License plate is required';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (brandController.text.isEmpty) {
      errorMessage.value = 'Brand is required';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (colorController.text.isEmpty) {
      errorMessage.value = 'Color is required';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (parkingSpotController.text.isEmpty) {
      errorMessage.value = 'Parking spot is required';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  // Create ticket method
  Future<void> completeTicket() async {
    try {
      if (!validateForm()) return;

      isLoading.value = true;

      final ticketModel = ValetCompleteTicketModel(
        ticketId: int.parse(ticketIdController.text),
        note: noteController.text.isEmpty ? null : noteController.text,
        parkingSpot: int.parse(parkingSpotController.text),
        damage: isDamaged.value,
        licensePlate: licensePlateController.text,
        brand: brandController.text,
        color: colorController.text,
      );

      print('Completing ticket with data: ${ticketModel.toJson()}');

      final response = await ApiService.updateTicketStatus(ticketModel);

      if (response.statusCode == 200) {
        clearForm();
        Get.back();
        Get.snackbar(
          'Success',
          'Ticket completed successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Could not complete ticket: ${response.statusCode}');
      }
    } catch (e) {
      print('Complete Ticket Error: $e');
      errorMessage.value = 'Could not complete ticket: ${e.toString()}';
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
    ticketIdController.clear();
    licensePlateController.clear();
    brandController.clear();
    colorController.clear();
    noteController.clear();
    parkingSpotController.clear();
    isDamaged.value = false;
    selectedImage.value = null;
    errorMessage.value = '';
  }

  void scanQR() {
    print("Starting QR Scan...");
    Get.to(() => Scaffold(
          appBar: AppBar(
            title: const Text('Scan QR Code'),
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
    print("QR View created");
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        print("QR Code read: ${scanData.code}");
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

  @override
  void onClose() {
    // Controller'ları dispose et
    licensePlateController.dispose();
    brandController.dispose();
    typeController.dispose();
    colorController.dispose();
    customerNameController.dispose();
    customerSurnameController.dispose();
    noteController.dispose();
    parkingSpotController.dispose();
    pageController.dispose();
    super.onClose();
  }

  // Fotoğraf çekildikten veya galeriden seçildikten sonra AI analizi yap
  Future<void> processImageWithAI(File imageFile) async {
    try {
      isLoading.value = true;

      final response = await ApiService.uploadImageToAI(imageFile);
      final aiResponse = response.data;

      print('AI Response in Controller: $aiResponse');

      if (aiResponse != null) {
        // Plaka
        if (aiResponse['license_plate'] != null) {
          licensePlateController.text = aiResponse['license_plate'].toString();
        }

        // Marka ve renk features içinden geliyor
        if (aiResponse['brand'] != null) {
          brandController.text = aiResponse['brand'].toString();
        }

        if (aiResponse['color'] != null) {
          colorController.text = aiResponse['color'].toString();
        }

        if (licensePlateController.text.isEmpty && brandController.text.isEmpty && colorController.text.isEmpty) {
          Get.snackbar(
            'Warning',
            'AI analysis returned empty results. Please fill in the information manually.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Success',
            'Vehicle information filled automatically',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('AI Processing Error: $e');
      Get.snackbar(
        'Error',
        'Failed to get vehicle information',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Mevcut takePhoto metodunu güncelle
  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        selectedImage.value = File(photo.path);
        await processImageWithAI(selectedImage.value!);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not take photo: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Mevcut pickFromGallery metodunu güncelle
  Future<void> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        await processImageWithAI(selectedImage.value!);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not select photo: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Seçilen fotoğrafı göstermek için view'da kullanılacak widget
  Widget? get imageWidget {
    if (selectedImage.value != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: FileImage(selectedImage.value!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return null;
  }

  void nextPage() {
    if (currentPage.value < 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value++;
    }
  }

  void removeImage() {
    selectedImage.value = null;
    Get.snackbar(
      'Success',
      'Photo removed successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void initializeData() {
    // Tüm değerleri temizle
    fetchOpenTicket(); // Açık biletleri getir
  }

  @override
  void onInit() {
    super.onInit();
    currentPage.value = 0; // Sayfa durumunu sıfırla
    pageController = PageController(initialPage: 0);
    fetchOpenTicket();
  }

  @override
  void onReady() {
    super.onReady();
    fetchOpenTicket();
  }

  // View'a her girişte çağrılacak metod
  void refreshTickets() {
    fetchOpenTicket();
  }

  Future<void> fetchOpenTicket() async {
    try {
      isLoading.value = true;
      final openTickets = await ApiService.getOpenTickets();

      if (openTickets.isNotEmpty) {
        final ticket = openTickets.first;
        ticketIdController.text = ticket['ticket_id'].toString();
      } else {
        Get.snackbar(
          'Warning',
          'No open tickets found',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        Get.back();
      }
    } catch (e) {
      print('Fetch Open Ticket Error: $e');
      Get.snackbar(
        'Error',
        'Failed to get open tickets',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
