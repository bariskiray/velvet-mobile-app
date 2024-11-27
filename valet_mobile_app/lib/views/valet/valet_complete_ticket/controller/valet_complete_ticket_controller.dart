import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:valet_mobile_app/views/valet/valet_complete_ticket/view/qr_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  final pageController = PageController();
  final currentPage = 0.obs;

  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedImage = Rx<File?>(null);

  // Form validation
  bool validateForm() {
    if (ticketIdController.text.isEmpty) {
      errorMessage.value = 'Ticket ID is required';
      return false;
    }
    if (licensePlateController.text.isEmpty) {
      errorMessage.value = 'License plate is required';
      return false;
    }
    if (brandController.text.isEmpty) {
      errorMessage.value = 'Brand is required';
      return false;
    }
    if (typeController.text.isEmpty) {
      errorMessage.value = 'Type is required';
      return false;
    }
    if (colorController.text.isEmpty) {
      errorMessage.value = 'Color is required';
      return false;
    }
    if (customerNameController.text.isEmpty) {
      errorMessage.value = 'Customer name is required';
      return false;
    }
    if (customerSurnameController.text.isEmpty) {
      errorMessage.value = 'Customer surname is required';
      return false;
    }
    return true;
  }

  // Create ticket method
  Future<void> completeTicket() async {
    try {
      if (!validateForm()) return;

      isLoading.value = true;

      // Ticket oluşturma işlemleri burada yapılacak
      // Örnek:
      // final ticket = TicketModel(
      //   licensePlate: licensePlateController.text,
      //   brand: brandController.text,
      //   type: typeController.text,
      //   color: colorController.text,
      //   customerName: customerNameController.text,
      //   customerSurname: customerSurnameController.text,
      // );

      // await ticketService.createTicket(ticket);

      clearForm();
      Get.back(); // Başarılı olduğunda önceki sayfaya dön
      Get.snackbar(
        'Success',
        'Ticket completed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Failed to complete ticket: ${e.toString()}';
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
    licensePlateController.clear();
    brandController.clear();
    typeController.clear();
    colorController.clear();
    customerNameController.clear();
    customerSurnameController.clear();
    errorMessage.value = '';
  }

  void scanQR() {
    print("QR Tarama başlatılıyor..."); // Debug için log
    Get.to(() => Scaffold(
          appBar: AppBar(
            title: const Text('QR Kodu Tara'),
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
    print("QR View oluşturuldu"); // Debug için log
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        print("QR Kod okundu: ${scanData.code}"); // Debug için log
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
    pageController.dispose();
    super.onClose();
  }

  // Fotoğraf çekme fonksiyonu
  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        selectedImage.value = File(photo.path);
        Get.snackbar(
          'Success',
          'Photo taken successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        Get.snackbar(
          'Success',
          'Image selected successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
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

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value--;
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
}
