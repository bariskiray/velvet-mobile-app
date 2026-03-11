import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BusinessParkingSpotsController extends GetxController {
  // Form Controllers
  final nameController = TextEditingController();
  final searchController = TextEditingController();

  // Pagination variables
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  final currentPage = 1.obs;
  final pageSize = 10;

  // Observable değişkenler
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final isEmpty = true.obs;
  final selectedLocation = Rx<LatLng?>(null);
  final markers = Rx<Set<Marker>>({});
  final parkingSpots = RxList<Map<String, dynamic>>([]);
  final filteredParkingSpots = RxList<Map<String, dynamic>>([]);
  final selectedSpotId = RxnInt();

  // Modal değişkenleri
  final isAddMode = true.obs;

  // Google Maps değişkenleri
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  final isMapReady = false.obs;

  // Dinamik başlangıç kamera pozisyonu
  final Rx<CameraPosition> initialCameraPosition = const CameraPosition(
    target: LatLng(41.0082, 28.9784),
    zoom: 14.0,
  ).obs;

  // Varsayılan kamera pozisyonu (İstanbul) - sadece fallback için
  final defaultCameraPosition = const CameraPosition(
    target: LatLng(41.0082, 28.9784),
    zoom: 14.0,
  );

  // Harita Oluşturulduğunda
  void onMapCreated(GoogleMapController controller) {
    mapController.value = controller;
    isMapReady.value = true;
    // getCurrentLocation(); artık burda çağırmıyoruz, başlangıçta zaten ayarlandı
  }

  // Konum seçme
  void selectLocation(LatLng location) {
    print('Selecting location: ${location.latitude}, ${location.longitude}');

    // Önce mevcut markers'ı temizle
    markers.value = {};

    // Sonra konumu güncelle
    selectedLocation.value = location;

    // Marker'ları hemen güncelle
    updateMapMarkers();

    // Haritayı işaretçinin konumuna merkeze al
    if (mapController.value != null) {
      mapController.value!.animateCamera(
        CameraUpdate.newLatLng(location),
      );
    }

    // Debug
    print('Konum seçildi ve marker oluşturuldu: ${location.latitude}, ${location.longitude}');
  }

  // Mevcut konumu alma
  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;

      // Konum izinlerini kontrol et
      bool serviceEnabled;
      LocationPermission permission;

      // Konum servisi açık mı?
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Service Disabled',
          'Please enable location services to continue',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Konum izinleri kontrolü
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permission Denied',
            'Location permission was denied',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Denied',
          'Location permissions are permanently denied. Please enable them in settings.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Mevcut konumu al
      final position = await Geolocator.getCurrentPosition();

      // Kamerayı mevcut konuma taşı
      final currentLocation = LatLng(position.latitude, position.longitude);

      if (mapController.value != null && isMapReady.value) {
        mapController.value!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation,
              zoom: 15,
            ),
          ),
        );
      }

      // Konumu seç
      selectLocation(currentLocation);
    } catch (e) {
      print('Get Current Location Error: $e');
      Get.snackbar(
        'Error',
        'Could not get location: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Tüm park yerlerini getirme
  Future<void> fetchParkingSpots({bool isRefresh = true}) async {
    try {
      if (isRefresh) {
        print('DEBUG: Refresh başlatılıyor - sayfa 1\'e sıfırlanıyor');
        isLoading.value = true;
        currentPage.value = 1;
        hasMoreData.value = true;
      } else {
        print('DEBUG: Daha fazla veri yükleniyor - sayfa: ${currentPage.value}');
        if (!hasMoreData.value || isLoadingMore.value) {
          print('DEBUG: Daha fazla veri yok veya zaten yükleniyor');
          return;
        }
        isLoadingMore.value = true;
      }

      print('DEBUG: API çağrısı yapılıyor - sayfa: ${currentPage.value}, boyut: $pageSize');

      // Use getParkingLocations with pagination
      final apiResponse = await ApiService.getParkingLocations(
        page: currentPage.value,
        size: pageSize,
      );

      final response = apiResponse['items'] as List<Map<String, dynamic>>;
      final paginationInfo = apiResponse['pagination'] as Map<String, dynamic>;

      print('DEBUG: ${response.length} park yeri alındı');
      print('DEBUG: Pagination bilgisi: $paginationInfo');

      // API'den gelen veri yapısını detaylı olarak incele
      print('Yüklenen park yerleri: $response');
      if (response.isNotEmpty) {
        print('İlk park yerinin yapısı:');
        response[0].forEach((key, value) {
          print('$key: $value (${value.runtimeType})');
        });
      }

      // Veri yapısını düzenleyerek kullanma
      final processedSpots = response.map((spot) {
        // Her bir park yerinin id alanını kontrol et ve düzelt
        if (!spot.containsKey('id') && spot.containsKey('location_id')) {
          spot['id'] = spot['location_id']; // location_id'yi id olarak da ekleyelim
        }
        return spot;
      }).toList();

      if (isRefresh) {
        print('DEBUG: Park yerleri listesi sıfırlanıyor ve ${processedSpots.length} öğe ekleniyor');
        parkingSpots.value = processedSpots;
      } else {
        print('DEBUG: Mevcut listeye ${processedSpots.length} öğe ekleniyor');
        parkingSpots.addAll(processedSpots);
      }

      // Pagination bilgisini kullanarak hasMoreData'yı doğru ayarla
      final currentPageFromApi = paginationInfo['page'] as int;
      final totalPages = paginationInfo['pages'] as int;
      final totalItems = paginationInfo['total'] as int;

      if (currentPageFromApi >= totalPages) {
        print('DEBUG: Son sayfaya ulaşıldı ($currentPageFromApi >= $totalPages)');
        hasMoreData.value = false;
      } else {
        print('DEBUG: Daha fazla sayfa var ($currentPageFromApi < $totalPages)');
        hasMoreData.value = true;
      }

      print('DEBUG: Toplam öğe: $totalItems, Toplam sayfa: $totalPages, Mevcut sayfa: $currentPageFromApi');

      filterParkingSpots(); // İlk yüklemede tüm listeyi göster
      updateMapMarkers();

      // Refresh/Load complete çağrılarını başarılı durumda yap
      if (isRefresh) {
        refreshController.refreshCompleted();
        print('DEBUG: Refresh tamamlandı - hasMoreData: ${hasMoreData.value}');
        print('DEBUG: Toplam park yeri sayısı: ${parkingSpots.length}');
        print('DEBUG: Filtrelenmiş park yeri sayısı: ${filteredParkingSpots.length}');
      }
    } catch (e) {
      print('Park Yerlerini Yükleme Hatası: $e');
      Get.snackbar(
        'Error',
        'Failed to load parking spots: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      if (isRefresh) {
        refreshController.refreshFailed();
        print('DEBUG: Refresh başarısız');
      }
    } finally {
      if (isRefresh) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  // Load more parking spots
  Future<void> loadMoreParkingSpots() async {
    print('DEBUG: loadMoreParkingSpots çağrıldı - mevcut sayfa: ${currentPage.value}');
    print('DEBUG: hasMoreData: ${hasMoreData.value}, isLoadingMore: ${isLoadingMore.value}');

    if (!hasMoreData.value) {
      print('DEBUG: Daha fazla veri yok, loadNoData çağrılıyor');
      refreshController.loadNoData();
      return;
    }

    if (isLoadingMore.value) {
      print('DEBUG: Zaten yükleniyor, çıkılıyor');
      return;
    }

    // Sayfa numarasını artır
    final previousPage = currentPage.value;
    currentPage.value++;
    print('DEBUG: Sayfa artırıldı: $previousPage -> ${currentPage.value}');

    try {
      await fetchParkingSpots(isRefresh: false);

      // Başarılı yükleme sonrası SmartRefresher durumunu güncelle
      if (hasMoreData.value) {
        refreshController.loadComplete();
        print('DEBUG: Load complete çağrıldı - daha fazla veri var');
      } else {
        refreshController.loadNoData();
        print('DEBUG: Load no data çağrıldı - daha fazla veri yok');
      }
    } catch (e) {
      // Hata durumunda sayfa numarasını geri al
      currentPage.value = previousPage;
      refreshController.loadFailed();
      print('DEBUG: Hata nedeniyle sayfa geri alındı: ${currentPage.value} -> $previousPage');
      rethrow;
    }
  }

  // Refresh parking spots
  Future<void> refreshParkingSpots() async {
    print('DEBUG: refreshParkingSpots çağrıldı');
    print('DEBUG: Refresh öncesi - currentPage: ${currentPage.value}, hasMoreData: ${hasMoreData.value}');
    print('DEBUG: Refresh öncesi - toplam park yeri: ${parkingSpots.length}');

    currentPage.value = 1; // API 1'den başladığı için 1'e ayarla
    hasMoreData.value = true;

    // SmartRefresher'ın footer durumunu sıfırla
    refreshController.resetNoData();

    print('DEBUG: Refresh için ayarlandı - currentPage: ${currentPage.value}, hasMoreData: ${hasMoreData.value}');

    await fetchParkingSpots(isRefresh: true);
  }

  // Keep the old method for backward compatibility
  Future<void> loadParkingSpots() async {
    print('DEBUG: loadParkingSpots çağrıldı');
    currentPage.value = 1; // API 1'den başladığı için 1'e ayarla
    hasMoreData.value = true;
    // SmartRefresher'ın footer durumunu sıfırla
    refreshController.resetNoData();
    await fetchParkingSpots(isRefresh: true);
  }

  // Park yerlerini filtreleme
  void filterParkingSpots() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      filteredParkingSpots.value = parkingSpots;
    } else {
      filteredParkingSpots.value = parkingSpots.where((spot) {
        return spot['name'].toString().toLowerCase().contains(query);
      }).toList();
    }
  }

  // Park yeri kaydetme
  Future<void> saveParkingSpot() async {
    try {
      if (nameController.text.isEmpty) {
        Get.snackbar(
          'Warning',
          'Please enter a name for the parking spot',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      if (selectedLocation.value == null) {
        Get.snackbar(
          'Warning',
          'Please select a location on the map',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      if (isAddMode.value) {
        // Yeni park yeri ekleme
        final response = await ApiService.createParkingLocation(
          name: nameController.text,
          latitude: selectedLocation.value!.latitude,
          longitude: selectedLocation.value!.longitude,
          is_empty: isEmpty.value,
        );

        print('Oluşturma yanıtı: ${response.data}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar(
            'Success',
            'Parking spot created successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          resetForm();
          // Pagination'ı sıfırla ve refresh yap
          print('DEBUG: Park yeri eklendi, pagination sıfırlanıyor');
          currentPage.value = 1;
          hasMoreData.value = true;
          // SmartRefresher'ın footer durumunu sıfırla
          refreshController.resetNoData();
          print('DEBUG: SmartRefresher durumu sıfırlandı, refresh yapılıyor');
          await fetchParkingSpots(isRefresh: true);
        } else {
          throw Exception('Park yeri oluşturulamadı: ${response.statusCode}');
        }
      } else {
        // Mevcut park yerini güncelleme
        if (selectedSpotId.value == null) {
          print('HATA: Güncelleme modunda selectedSpotId null');

          // Tüm park yerlerini ekrana yazdır, sorunun kaynağını bulmak için
          print('Mevcut park yerleri:');
          for (var spot in parkingSpots) {
            print('Park yeri: ${spot['name']}, ID: ${spot['id'] ?? spot['location_id'] ?? 'ID bulunamadı'}');
          }

          // Kullanıcıya bildirme
          Get.snackbar(
            'Hata',
            'Güncellenecek park yeri seçilemedi. Lütfen tekrar deneyin.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return;
        }

        print('Güncelleniyor: ID=${selectedSpotId.value}, Name=${nameController.text}');
        final response = await ApiService.updateParkingLocation(
          locationId: selectedSpotId.value!,
          name: nameController.text,
          latitude: selectedLocation.value!.latitude,
          longitude: selectedLocation.value!.longitude,
          is_empty: isEmpty.value,
        );

        print('Güncelleme yanıtı: ${response.data}');

        if (response.statusCode == 200) {
          Get.snackbar(
            'Başarılı',
            'Park yeri başarıyla güncellendi',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          resetForm();
          // Pagination'ı sıfırla ve refresh yap
          print('DEBUG: Park yeri güncellendi, pagination sıfırlanıyor');
          currentPage.value = 1;
          hasMoreData.value = true;
          // SmartRefresher'ın footer durumunu sıfırla
          refreshController.resetNoData();
          print('DEBUG: SmartRefresher durumu sıfırlandı, refresh yapılıyor');
          await fetchParkingSpots(isRefresh: true);
        } else {
          throw Exception('Park yeri güncellenemedi: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Park Yeri Kaydetme Hatası: $e');
      Get.snackbar(
        'Hata',
        'Park yeri kaydedilemedi: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Park yeri silme
  Future<void> deleteParkingSpot(int spotId) async {
    try {
      isLoading.value = true;

      print('Silinecek park yeri ID: $spotId');

      // API'ye silinecek id'yi doğru şekilde iletiyoruz
      final response = await ApiService.deleteParkingLocation(spotId);

      print('Silme yanıtı: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar(
          'Başarılı',
          'Park yeri başarıyla silindi',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        // Pagination'ı sıfırla ve refresh yap
        print('DEBUG: Park yeri silindi, pagination sıfırlanıyor');
        currentPage.value = 1;
        hasMoreData.value = true;
        // SmartRefresher'ın footer durumunu sıfırla
        refreshController.resetNoData();
        print('DEBUG: SmartRefresher durumu sıfırlandı, refresh yapılıyor');
        await fetchParkingSpots(isRefresh: true);
      } else {
        throw Exception('Park yeri silinemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Park Yeri Silme Hatası: $e');
      Get.snackbar(
        'Hata',
        'Park yeri silinemedi: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Düzenleme moduna geçme
  void editParkingSpot(Map<String, dynamic> spot) {
    isAddMode.value = false;

    // API'den gelen veri yapısına göre doğru id'yi alıyoruz
    // API'den gelen veri parking_location_id içeriyor
    if (spot.containsKey('parking_location_id')) {
      selectedSpotId.value = spot['parking_location_id'];
      print('DEBUG: Düzenleme için parking_location_id kullanılıyor: ${selectedSpotId.value}');
    } else if (spot.containsKey('id')) {
      selectedSpotId.value = spot['id'];
      print('DEBUG: Düzenleme için id kullanılıyor: ${selectedSpotId.value}');
    } else {
      print('HATA: Park yeri ID bulunamadı. Veri yapısı: $spot');
      Get.snackbar(
        'Hata',
        'Park yeri ID bilgisi bulunamadı',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print('DEBUG: Düzenleme için seçilen park yeri ID: ${selectedSpotId.value}');

    nameController.text = spot['name'];
    isEmpty.value = spot['is_empty'] ?? true;

    final lat = spot['latitude'] is String ? double.parse(spot['latitude']) : spot['latitude'] as double;
    final lng = spot['longitude'] is String ? double.parse(spot['longitude']) : spot['longitude'] as double;

    selectedLocation.value = LatLng(lat, lng);

    // Haritayı güncelle
    if (mapController.value != null) {
      mapController.value!.animateCamera(
        CameraUpdate.newLatLng(selectedLocation.value!),
      );
    }
  }

  // Formu sıfırlama
  void resetForm() {
    // Explicitly set to add mode when resetting the form
    isAddMode.value = true;
    nameController.clear();
    selectedLocation.value = null;
    markers.value = {};
    isEmpty.value = true;
    selectedSpotId.value = null;
  }

  // Haritadaki işaretçileri güncelleme
  void updateMapMarkers() {
    print('Harita işaretçileri güncelleniyor');
    final Set<Marker> newMarkers = {};

    // Eğer seçilen bir konum varsa mutlaka ekle
    if (selectedLocation.value != null) {
      print('Seçilen konum işaretçisi ekleniyor: ${selectedLocation.value!.latitude}, ${selectedLocation.value!.longitude}');

      // Kırmızı marker'i ekle
      newMarkers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: selectedLocation.value!,
          infoWindow: const InfoWindow(title: 'Seçilen Konum'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          visible: true,
          draggable: true,
          onDragEnd: (newPosition) {
            selectedLocation.value = newPosition;
          },
        ),
      );
    }

    // Tüm park yerlerini haritaya ekle
    for (var i = 0; i < parkingSpots.length; i++) {
      final spot = parkingSpots[i];

      // ID bilgisini doğru şekilde al (id, parking_location_id olabilir)
      final spotId = spot['parking_location_id'] ?? spot['id'];
      if (spotId == null) {
        print('UYARI: ID bilgisi olmayan park yeri: ${spot['name']}');
        continue; // ID'si olmayan park yerini atla
      }

      final lat = spot['latitude'] is String ? double.parse(spot['latitude']) : spot['latitude'] as double;
      final lng = spot['longitude'] is String ? double.parse(spot['longitude']) : spot['longitude'] as double;

      final spotLatLng = LatLng(lat, lng);

      newMarkers.add(
        Marker(
          markerId: MarkerId('parking_spot_$spotId'),
          position: spotLatLng,
          infoWindow: InfoWindow(
            title: spot['name'],
            snippet: spot['is_empty'] ? 'Müsait' : 'Dolu',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            spot['is_empty'] ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRose,
          ),
          onTap: () {
            // Haritada bir park yeri seçildiğinde bilgisini göster
            Get.snackbar(
              spot['name'],
              spot['is_empty'] ? 'Müsait' : 'Dolu',
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

  @override
  void onClose() {
    nameController.dispose();
    searchController.dispose();
    mapController.value?.dispose();
    refreshController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    // Pagination değişkenlerini başlangıçta ayarla
    currentPage.value = 1; // API 1'den başladığı için 1'e ayarla
    hasMoreData.value = true;

    // İlk olarak kullanıcının konumunu almaya çalış
    _setInitialLocation();

    // Park yerlerini yükle
    loadParkingSpots();

    // selectedLocation değiştiğinde markers'ı güncelle
    ever(selectedLocation, (_) => updateMapMarkers());

    // Park yerleri değiştiğinde filtrelenmiş listeyi güncelle
    ever(parkingSpots, (_) => filterParkingSpots());

    // Arama metni değiştiğinde filtrelemeyi güncelle
    searchController.addListener(filterParkingSpots);
  }

  // Başlangıç konumunu ayarlama
  Future<void> _setInitialLocation() async {
    try {
      // Konum servisinin açık olup olmadığını kontrol et
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Konum servisi kapalı, varsayılan konum kullanılıyor');
        return;
      }

      // Konum izinlerini kontrol et
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          print('Konum izni reddedildi, varsayılan konum kullanılıyor');
          return;
        }
      }

      // Mevcut konumu al
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      // Başlangıç kamera pozisyonunu kullanıcının konumuna ayarla
      initialCameraPosition.value = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15.0,
      );

      print('Başlangıç konumu ayarlandı: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Başlangıç konumu alınamadı, varsayılan konum kullanılıyor: $e');
      // Hata durumunda varsayılan konum zaten ayarlı
    }
  }
}
