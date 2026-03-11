import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../api_service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class BusinessTicketsController extends GetxController {
  final tickets = [].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  final RefreshController refreshController = RefreshController();

  // Araç detaylarını tutmak için map
  final carDetails = <int, Map<String, dynamic>>{}.obs;

  // Vale detaylarını tutmak için map
  final valetDetails = <int, Map<String, dynamic>>{}.obs;

  // Park yerlerini tutmak için yeni değişkenler
  final parkingSpots = <Map<String, dynamic>>[].obs;
  final isLoadingParkingSpots = false.obs;
  final markers = <Marker>{}.obs;
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);

  // Harita için başlangıç pozisyonu
  final Rx<CameraPosition> initialCameraPosition = const CameraPosition(
    target: LatLng(41.0082, 28.9784), // İstanbul
    zoom: 14.0,
  ).obs;

  final int pageSize = 10;
  final currentPage = 1.obs;

  // Filtreleme için yeni değişkenler
  final selectedStartDate = Rxn<DateTime>();
  final selectedEndDate = Rxn<DateTime>();
  final selectedStatus = Rxn<int>();

  // Updated status options
  final List<Map<String, dynamic>> statusOptions = [
    {'id': null, 'name': 'All'},
    {'id': 1, 'name': 'Parking'},
    {'id': 2, 'name': 'Parked'},
    {'id': 3, 'name': 'Delivering'},
    {'id': 4, 'name': 'Delivered'},
  ];

  // Ödeme durumlarını tutmak için yeni map
  final paymentStatus = <int, bool>{}.obs;

  // Park yeri detaylarını tutmak için map
  final parkingSpotDetails = <int, Map<String, dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTickets();
    loadParkingSpots();
    _setInitialLocation();
  }

  Future<void> fetchTickets({bool isRefresh = true}) async {
    try {
      if (isRefresh) {
        isLoading.value = true;
        currentPage.value = 1;
        hasMoreData.value = true;
        print('Starting refresh - page: ${currentPage.value}'); // Debug için
      } else {
        if (isLoadingMore.value) return; // Zaten yükleme yapılıyorsa çık
        isLoadingMore.value = true;
        print('Starting load more - page: ${currentPage.value}'); // Debug için
      }

      final response = await ApiService.getTickets(
        startDate: selectedStartDate.value?.toIso8601String(),
        endDate: selectedEndDate.value?.toIso8601String(),
        progressStatus: selectedStatus.value,
        page: currentPage.value,
        size: pageSize,
      );

      // Eğer gelen veri pageSize'dan az ise, daha fazla veri yok demektir
      if (response.length < pageSize) {
        hasMoreData.value = false;
        print('No more data available - received ${response.length} items'); // Debug için
      } else {
        hasMoreData.value = true;
        print('Received ${response.length} items, more data available'); // Debug için
      }

      // Önce tüm ID'leri toplayalım
      final Set<int> carIds = {};
      final Set<int> valetIds = {};
      final Set<int> ticketIds = {};
      final Set<int> parkingLocationIds = {};

      for (var ticket in response) {
        if (ticket['car_id'] != null) carIds.add(ticket['car_id']);
        if (ticket['valet_id'] != null) valetIds.add(ticket['valet_id']);
        if (ticket['ticket_id'] != null) ticketIds.add(ticket['ticket_id']);
        if (ticket['parking_location_id'] != null) parkingLocationIds.add(ticket['parking_location_id']);
      }

      // Tüm detayları paralel olarak getirelim
      await Future.wait([
        ...carIds.map((id) => fetchCarDetails(id)),
        ...valetIds.map((id) => fetchValetDetails(id)),
        ...ticketIds.map((id) => fetchPaymentStatus(id)),
        ...parkingLocationIds.map((id) => fetchParkingSpotDetails(id)),
      ]);

      if (isRefresh) {
        tickets.value = response;
        refreshController.refreshCompleted();
        // Refresh sonrası pagination durumunu sıfırla
        if (hasMoreData.value) {
          refreshController.resetNoData();
        }
        print('Refresh completed - hasMoreData: ${hasMoreData.value}, items: ${response.length}'); // Debug için
      } else {
        tickets.addAll(response);
        if (hasMoreData.value) {
          refreshController.loadComplete();
        } else {
          refreshController.loadNoData();
        }
        print('Load more completed - total items: ${tickets.length}'); // Debug için
      }
    } catch (e) {
      print('Ticket fetch error: $e'); // Debug için
      if (isRefresh) {
        refreshController.refreshFailed();
      } else {
        refreshController.loadFailed();
      }
      Get.snackbar(
        'Hata',
        'Biletler yüklenemedi: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreTickets() async {
    if (!hasMoreData.value || isLoadingMore.value || isLoading.value) return;

    print('Loading more tickets - Current page: ${currentPage.value}'); // Debug için
    currentPage.value++;
    await fetchTickets(isRefresh: false);
  }

  void resetFilters() {
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    selectedStatus.value = null;
    currentPage.value = 1;
    hasMoreData.value = true;
    refreshController.resetNoData(); // Refresh controller'ı sıfırla
    fetchTickets();
  }

  // Araç detaylarını getiren metod
  Future<void> fetchCarDetails(int carId) async {
    try {
      final details = await ApiService.getCarDetails(carId);
      carDetails[carId] = details;
    } catch (e) {
      print('Could not load car details: $e');
    }
  }

  // Vale detaylarını getiren metod
  Future<void> fetchValetDetails(int valetId) async {
    try {
      final details = await ApiService.getValetById(valetId);
      valetDetails[valetId] = details;
    } catch (e) {
      print('Could not load valet details: $e');
    }
  }

  // Araç detaylarına kolay erişim için yardımcı metod
  Map<String, dynamic>? getCarDetails(int carId) {
    return carDetails[carId];
  }

  // Vale detaylarına kolay erişim için yardımcı metod
  Map<String, dynamic>? getValetDetails(int valetId) {
    return valetDetails[valetId];
  }

  // Progress status için string'den int'e dönüşüm
  int getProgressStatusFromString(String? status) {
    if (status == null) return 0;

    switch (status.toLowerCase()) {
      case 'parking':
        return 1;
      case 'parked':
        return 2;
      case 'delivering':
        return 3;
      case 'delivered':
        return 4;
      default:
        return 0;
    }
  }

  List<Color> getStatusGradientColor(dynamic status) {
    final statusCode = status is String ? getProgressStatusFromString(status) : (status as int? ?? 0);

    switch (statusCode) {
      case 1: // Parking
        return [Colors.orange, Colors.orange[700]!];
      case 2: // Parked
        return [Colors.green, Colors.green[700]!];
      case 3: // Delivering
        return [Colors.blue, Colors.blue[700]!];
      case 4: // Delivered
        return [Colors.purple, Colors.purple[700]!];
      default:
        return [Colors.grey, Colors.grey[700]!];
    }
  }

  String getStatusText(dynamic status) {
    final statusCode = status is String ? getProgressStatusFromString(status) : (status as int? ?? 0);

    switch (statusCode) {
      case 1:
        return 'Parking';
      case 2:
        return 'Parked';
      case 3:
        return 'Delivering';
      case 4:
        return 'Delivered';
      default:
        return 'Unknown';
    }
  }

  // Ödeme durumunu kontrol eden metod
  Future<void> fetchPaymentStatus(int ticketId) async {
    try {
      final payment = await ApiService.getPaymentByTicketId(ticketId);

      // payment null ise (404 durumu) veya detail içeriyorsa ödeme yok demektir
      if (payment == null || payment.containsKey('detail')) {
        paymentStatus[ticketId] = false;
      } else {
        // Ödeme var ve geçerli
        paymentStatus[ticketId] = true;
      }

      print('Payment status for ticket $ticketId: ${paymentStatus[ticketId]}'); // Debug log
    } catch (e) {
      print('Payment status check failed for ticket $ticketId: $e');
      paymentStatus[ticketId] = false;
    }
  }

  // Ödeme durumunu kontrol eden yardımcı metod
  bool isTicketPaid(int ticketId) {
    return paymentStatus[ticketId] ?? false;
  }

  // Park yerlerini yükleme
  Future<void> loadParkingSpots() async {
    try {
      isLoadingParkingSpots.value = true;
      final apiResponse = await ApiService.getParkingLocations();
      final spots = apiResponse['items'] as List<Map<String, dynamic>>;
      parkingSpots.value = spots;
      updateMapMarkers();
    } catch (e) {
      print('Could not load parking spots: $e');
    } finally {
      isLoadingParkingSpots.value = false;
    }
  }

  // Harita işaretçilerini güncelleme
  void updateMapMarkers() {
    final Set<Marker> newMarkers = {};

    for (var spot in parkingSpots) {
      final lat = spot['latitude'] is String ? double.parse(spot['latitude']) : spot['latitude'] as double;
      final lng = spot['longitude'] is String ? double.parse(spot['longitude']) : spot['longitude'] as double;

      final spotLatLng = LatLng(lat, lng);
      final spotId = spot['parking_location_id'] ?? spot['id'];

      newMarkers.add(
        Marker(
          markerId: MarkerId('parking_spot_$spotId'),
          position: spotLatLng,
          infoWindow: InfoWindow(
            title: spot['name'],
            snippet: spot['is_empty'] ? 'Available' : 'Occupied',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            spot['is_empty'] ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
          ),
          onTap: () {
            Get.snackbar(
              spot['name'],
              spot['is_empty'] ? 'Available' : 'Occupied',
              snackPosition: SnackPosition.TOP,
              backgroundColor: spot['is_empty'] ? Colors.green : Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          },
        ),
      );
    }

    markers.value = newMarkers;
  }

  // Harita oluşturulduğunda
  void onMapCreated(GoogleMapController controller) {
    mapController.value = controller;
    updateMapMarkers();
  }

  // Başlangıç konumunu ayarlama
  Future<void> _setInitialLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location service disabled, using default location');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          print('Location permission denied, using default location');
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      initialCameraPosition.value = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15.0,
      );

      print('Initial location set: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Could not get initial location, using default location: $e');
    }
  }

  // Mevcut konumu alma
  Future<void> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final currentLocation = LatLng(position.latitude, position.longitude);

      if (mapController.value != null) {
        mapController.value!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation,
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      print('Konum alınamadı: $e');
      Get.snackbar(
        'Error',
        'Could not get location: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Park yeri detaylarını getiren metod
  Future<void> fetchParkingSpotDetails(int parkingLocationId) async {
    try {
      // Önce mevcut park yerlerinden kontrol et
      final existingSpot = parkingSpots.firstWhereOrNull((spot) => (spot['parking_location_id'] ?? spot['id']) == parkingLocationId);

      if (existingSpot != null) {
        parkingSpotDetails[parkingLocationId] = existingSpot;
        return;
      }

      // Eğer bulunamazsa API'den getir
      final details = await ApiService.getParkingLocationById(parkingLocationId);
      parkingSpotDetails[parkingLocationId] = details;
    } catch (e) {
      print('Could not load parking spot details: $e');
    }
  }

  // Park yeri detaylarına kolay erişim için yardımcı metod
  Map<String, dynamic>? getParkingSpotDetails(int parkingLocationId) {
    return parkingSpotDetails[parkingLocationId];
  }

  // Park yeri adını getiren yardımcı metod
  String getParkingSpotName(int? parkingLocationId) {
    if (parkingLocationId == null) return 'No Park Information';

    final spotDetails = getParkingSpotDetails(parkingLocationId);
    return spotDetails?['name'] ?? 'Parking spot #$parkingLocationId';
  }

  @override
  void onClose() {
    refreshController.dispose();
    mapController.value?.dispose();
    super.onClose();
  }
}
