import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:valet_mobile_app/views/valet/valet_complete_ticket/model/valet_complete_ticket_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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

  // Park yeri için yeni kontroller
  final parkingLocationNameController = TextEditingController();
  final selectedParkingLocationId = Rx<int?>(null);

  // Park yerleri için veri saklama
  final parkingLocations = <Map<String, dynamic>>[].obs;

  // Pagination değişkenleri
  final currentParkingPage = 1.obs;
  final hasMoreParkingData = true.obs;
  final isLoadingMoreParking = false.obs;
  final parkingPageSize = 50; // Daha fazla park yeri göstermek için sayıyı artırdık

  // Seçilen park yeri
  final selectedParkingLocation = Rx<Map<String, dynamic>?>(null);

  // Açık bilet bilgilerini tutmak için
  final hasOpenTicket = false.obs;
  final openTicketId = ''.obs;

  // Reactive ticket ID
  final ticketId = ''.obs;

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
    if (colorController.text.isEmpty) {
      errorMessage.value = 'Color is required';
      return false;
    }
    // Parking location selection check
    if (selectedParkingLocationId.value == null) {
      errorMessage.value = 'Parking location is required';
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
        damage: isDamaged.value,
        licensePlate: licensePlateController.text,
        brand: brandController.text,
        color: colorController.text,
        parkingLocationId: selectedParkingLocationId.value,
      );

      print('Parking Location ID: ${selectedParkingLocationId.value}');
      print('Selected Parking Location: ${selectedParkingLocation.value}');
      print('Parking Location Controller Text: ${parkingLocationNameController.text}');
      print('Parking Spot Controller Text: ${parkingSpotController.text}');

      print('Completing ticket with data: ${ticketModel.toJson()}');

      final response = await ApiService.updateTicketStatus(ticketModel);

      if (response.statusCode == 200) {
        // Show success snackbar
        Get.snackbar(
          'Success',
          'Ticket completed successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Clear form and navigate to valet_home_view directly
        clearForm();
        Get.back(closeOverlays: true); // Navigate to home view
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
    ticketId.value = ''; // Reactive variable'ı da temizle
    licensePlateController.clear();
    brandController.clear();
    colorController.clear();
    noteController.clear();
    parkingLocationNameController.clear();
    parkingSpotController.clear(); // Add this to clear the parking spot field
    selectedParkingLocationId.value = null;
    selectedParkingLocation.value = null; // Also reset the selected parking location
    isDamaged.value = false;
    selectedImage.value = null;
    hasOpenTicket.value = false;
    errorMessage.value = '';

    // Pagination değişkenlerini sıfırla
    currentParkingPage.value = 1;
    hasMoreParkingData.value = true;
    isLoadingMoreParking.value = false;
  }

  // Park yerlerini getirme (pagination ile)
  Future<void> loadParkingLocations({bool isRefresh = true}) async {
    try {
      if (isRefresh) {
        isLoading.value = true;
        currentParkingPage.value = 1;
        hasMoreParkingData.value = true;
      } else {
        if (isLoadingMoreParking.value || !hasMoreParkingData.value) return;
        isLoadingMoreParking.value = true;
      }

      final apiResponse = await ApiService.getParkingLocations(
        page: currentParkingPage.value,
        size: parkingPageSize,
      );

      final locationsList = apiResponse['items'] as List<Map<String, dynamic>>;
      final paginationInfo = apiResponse['pagination'] as Map<String, dynamic>;

      if (isRefresh) {
        parkingLocations.value = locationsList;
      } else {
        parkingLocations.addAll(locationsList);
      }

      // Pagination durumunu kontrol et
      final currentPageFromApi = paginationInfo['page'] as int;
      final totalPages = paginationInfo['pages'] as int;
      hasMoreParkingData.value = currentPageFromApi < totalPages;

      print('Loaded ${locationsList.length} parking locations (page ${currentParkingPage.value})');
      print('Total parking locations: ${parkingLocations.length}');
    } catch (e) {
      print('Error loading parking locations: $e');
      errorMessage.value = 'Failed to load parking locations';
    } finally {
      if (isRefresh) {
        isLoading.value = false;
      } else {
        isLoadingMoreParking.value = false;
      }
    }
  }

  // Daha fazla park yeri yükleme
  Future<void> loadMoreParkingLocations() async {
    if (!hasMoreParkingData.value || isLoadingMoreParking.value) return;

    currentParkingPage.value++;
    await loadParkingLocations(isRefresh: false);
  }

  // Park yeri seçme
  void selectParkingLocation(Map<String, dynamic> location) {
    selectedParkingLocation.value = location;
    selectedParkingLocationId.value = location['parking_location_id'] as int;
    parkingLocationNameController.text = location['name'] as String;
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
        ticketId.value = scanData.code!; // Reactive variable'ı da güncelle
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
    parkingLocationNameController.dispose();
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
      }
    } catch (e) {
      print('AI Processing Error: $e');
      errorMessage.value = 'Failed to get vehicle information';
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
      print('Could not take photo: ${e.toString()}');
      errorMessage.value = 'Could not take photo: ${e.toString()}';
    }
  }

  // Mevcut pickFromGallery metodunu güncelle
  Future<void> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        await processImageWithAI(selectedImage.value!);
      }
    } catch (e) {
      print('Could not select photo: ${e.toString()}');
      errorMessage.value = 'Could not select photo: ${e.toString()}';
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
  }

  void initializeData() {
    // Tüm değerleri temizle
    fetchOpenTicket(); // Açık biletleri getir
    loadParkingLocations(isRefresh: true); // Park yerlerini baştan getir
  }

  @override
  void onInit() {
    super.onInit();
    currentPage.value = 0; // Sayfa durumunu sıfırla
    pageController = PageController(initialPage: 0);
    fetchOpenTicket();
    loadParkingLocations(isRefresh: true);
  }

  @override
  void onReady() {
    super.onReady();
    fetchOpenTicket();
    loadParkingLocations(isRefresh: true);
  }

  // View'a her girişte çağrılacak metod
  void refreshTickets() {
    fetchOpenTicket();
    loadParkingLocations(isRefresh: true);
  }

  Future<void> fetchOpenTicket() async {
    try {
      isLoading.value = true;
      final openTickets = await ApiService.getOpenTickets();

      if (openTickets.isNotEmpty) {
        final ticket = openTickets.first;
        final ticketIdStr = ticket['ticket_id'].toString();
        ticketIdController.text = ticketIdStr;
        ticketId.value = ticketIdStr; // Reactive variable'ı da güncelle
        hasOpenTicket.value = true;
      } else {
        print('No open tickets found');
        ticketIdController.text = '';
        ticketId.value = '';
        hasOpenTicket.value = false;
        // Get.back(); // Bu satırı kaldırıyoruz, kullanıcı empty state'i görmeli
      }
    } catch (e) {
      print('Fetch Open Ticket Error: $e');
      errorMessage.value = 'Failed to get open tickets';
      ticketIdController.text = '';
      ticketId.value = '';
      hasOpenTicket.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}
