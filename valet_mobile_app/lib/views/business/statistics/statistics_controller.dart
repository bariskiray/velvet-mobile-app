import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsController extends GetxController with GetSingleTickerProviderStateMixin {
  // Animation controller
  late AnimationController animationController;

  // Loading states
  final isLoadingDailyVisits = false.obs;
  final isLoadingPeakHours = false.obs;
  final isLoadingPeakDays = false.obs;
  final isLoadingMoneyGained = false.obs;
  final isLoadingVisitCountByHours = false.obs;

  // Statistics data
  final dailyVisits = 0.obs;
  final peakHours = <int>[].obs;
  final peakDays = <String>[].obs;
  final moneyGained = 0.0.obs;
  final visitCountByHours = <String, int>{}.obs;

  // Date selections
  final selectedDate = DateTime.now().obs;
  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;

  // Chart data
  final barGroups = <BarChartGroupData>[].obs;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    fetchAllStatistics();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  void fetchAllStatistics() {
    fetchDailyVisits();
    fetchPeakHours();
    fetchPeakDays();
    fetchMoneyGained();
    fetchVisitCountByHours();
  }

  Future<void> fetchDailyVisits() async {
    try {
      isLoadingDailyVisits.value = true;

      // YYYY-MM-DD format with time component
      final formattedDate = DateFormat('yyyy-MM-dd\'T\'00:00:00').format(selectedDate.value);
      print('Sending date: $formattedDate'); // Debug to check the correct format

      final result = await ApiService.getDailyVisits(formattedDate);
      dailyVisits.value = result;
      animationController.forward(from: 0.0);
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while loading daily visits',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Date format error: $e');
    } finally {
      isLoadingDailyVisits.value = false;
    }
  }

  Future<void> fetchPeakHours() async {
    try {
      isLoadingPeakHours.value = true;
      final result = await ApiService.getPeakHours();
      peakHours.value = result;
      _updateHoursChart();
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while loading peak hours: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingPeakHours.value = false;
    }
  }

  Future<void> fetchVisitCountByHours() async {
    try {
      isLoadingVisitCountByHours.value = true;
      final result = await ApiService.getVisitCountByHours();
      visitCountByHours.value = result;
      _updateHoursChart();
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while loading hourly visit counts: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingVisitCountByHours.value = false;
    }
  }

  Future<void> fetchPeakDays() async {
    try {
      isLoadingPeakDays.value = true;
      final result = await ApiService.getPeakDays();
      peakDays.value = result;
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while loading peak days: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingPeakDays.value = false;
    }
  }

  Future<void> fetchMoneyGained() async {
    try {
      isLoadingMoneyGained.value = true;
      final formattedStartDate = DateFormat('yyyy-MM-dd\'T\'00:00:00').format(startDate.value);
      final formattedEndDate = DateFormat('yyyy-MM-dd\'T\'23:59:59').format(endDate.value);
      final result = await ApiService.getMoneyGained(formattedStartDate, formattedEndDate);
      moneyGained.value = result;
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while loading income information: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingMoneyGained.value = false;
    }
  }

  void onDateChanged(DateTime newDate) {
    selectedDate.value = newDate;
    fetchDailyVisits();
  }

  void onDateRangeChanged(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    fetchMoneyGained();
  }

  // Create hour data chart
  void _updateHoursChart() {
    final List<BarChartGroupData> groups = [];

    // Tüm saatler için gruplar oluştur
    for (int hour = 0; hour < 24; hour++) {
      final String hourKey = hour.toString();
      final bool isPeak = peakHours.contains(hour);
      final int visitCount = visitCountByHours[hourKey] ?? 0;
      final color = isPeak ? Colors.blue : Colors.grey;

      groups.add(BarChartGroupData(
        x: hour,
        barRods: [
          BarChartRodData(
            toY: visitCount > 0 ? visitCount.toDouble() : (isPeak ? 10 : 0.5),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.5), color],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));
    }

    barGroups.value = groups;
  }

  String formatHour(int hour) {
    return '$hour:00';
  }

  String getDailyVisitsTitle() {
    return 'Daily Visits: ${DateFormat('dd MMM yyyy').format(selectedDate.value)}';
  }

  String getMoneyGainedTitle() {
    final startFormatted = DateFormat('dd MMM').format(startDate.value);
    final endFormatted = DateFormat('dd MMM').format(endDate.value);
    return 'Income: $startFormatted - $endFormatted';
  }

  String getMoneyGainedAmount() {
    return '\$${moneyGained.value.toStringAsFixed(2)}';
  }
}
