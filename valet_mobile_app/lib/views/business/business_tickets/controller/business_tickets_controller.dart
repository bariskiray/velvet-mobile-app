import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../api_service/api_service.dart';
import 'package:flutter/material.dart';

class BusinessTicketsController extends GetxController {
  final tickets = [].obs;
  final isLoading = false.obs;
  final RefreshController refreshController = RefreshController();

  // Araç detaylarını tutmak için map
  final carDetails = <int, Map<String, dynamic>>{}.obs;

  // Vale detaylarını tutmak için map
  final valetDetails = <int, Map<String, dynamic>>{}.obs;

  final int limit = 10;
  final currentOffset = 0.obs;

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

  @override
  void onInit() {
    super.onInit();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    try {
      isLoading.value = true;
      final response = await ApiService.getTickets(
        startDate: selectedStartDate.value?.toIso8601String(),
        endDate: selectedEndDate.value?.toIso8601String(),
        progressStatus: selectedStatus.value,
        limit: limit,
        offset: currentOffset.value,
      );

      // Önce tüm ID'leri toplayalım
      final Set<int> carIds = {};
      final Set<int> valetIds = {};
      final Set<int> ticketIds = {};

      for (var ticket in response) {
        if (ticket['car_id'] != null) carIds.add(ticket['car_id']);
        if (ticket['valet_id'] != null) valetIds.add(ticket['valet_id']);
        if (ticket['ticket_id'] != null) ticketIds.add(ticket['ticket_id']);
      }

      // Tüm detayları paralel olarak getirelim
      await Future.wait([
        ...carIds.map((id) => fetchCarDetails(id)),
        ...valetIds.map((id) => fetchValetDetails(id)),
        ...ticketIds.map((id) => fetchPaymentStatus(id)),
      ]);

      tickets.value = response;
      refreshController.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
      Get.snackbar(
        'Error',
        'Failed to load tickets: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilters() {
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    selectedStatus.value = null;
    fetchTickets();
  }

  // Araç detaylarını getiren metod
  Future<void> fetchCarDetails(int carId) async {
    try {
      final details = await ApiService.getCarDetails(carId);
      carDetails[carId] = details;
    } catch (e) {
      print('Araç detayları alınamadı: $e');
    }
  }

  // Vale detaylarını getiren metod
  Future<void> fetchValetDetails(int valetId) async {
    try {
      final details = await ApiService.getValetById(valetId);
      valetDetails[valetId] = details;
    } catch (e) {
      print('Vale detayları alınamadı: $e');
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
}
