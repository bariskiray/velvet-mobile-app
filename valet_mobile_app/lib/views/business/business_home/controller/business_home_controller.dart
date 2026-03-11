import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:valet_mobile_app/auth/auth_controller.dart';
import 'package:intl/intl.dart';

import '../model/valet_response.dart';

class BusinessHomeController extends GetxController {
  final valets = <ValetResponse>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  final errorMessage = ''.obs;
  final todayTicketCount = 0.obs;
  final todayRevenue = 0.0.obs;

  final RefreshController refreshController = RefreshController();
  final int pageSize = 10;
  final currentPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchValets();
    fetchDailyStatistics();
  }

  Future<void> fetchValets({bool isRefresh = true}) async {
    try {
      if (isRefresh) {
        isLoading.value = true;
        currentPage.value = 1;
        hasMoreData.value = true;
      } else {
        isLoadingMore.value = true;
      }

      errorMessage.value = '';

      final response = await ApiService.getValets(
        page: currentPage.value,
        size: pageSize,
      );

      // Check if we have fewer items than page size, meaning no more data
      if (response.length < pageSize) {
        hasMoreData.value = false;
      }

      if (isRefresh) {
        valets.value = response;
        refreshController.refreshCompleted();
      } else {
        valets.addAll(response);
        if (hasMoreData.value) {
          refreshController.loadComplete();
        } else {
          refreshController.loadNoData();
        }
      }
    } catch (e) {
      if (isRefresh) {
        refreshController.refreshFailed();
      } else {
        refreshController.loadFailed();
      }
      errorMessage.value = 'Failed to load valets: $e';
      print('Fetch Valets Error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreValets() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    currentPage.value++;
    await fetchValets(isRefresh: false);
  }

  Future<void> fetchDailyStatistics() async {
    try {
      isLoading.value = true;

      // Get today's date in the format required by the API
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Fetch daily visits (equals to ticket count for today)
      final ticketCount = await ApiService.getDailyVisits(today);
      todayTicketCount.value = ticketCount;

      // Fetch revenue for today
      final revenue = await ApiService.getMoneyGained(today, today);
      todayRevenue.value = revenue;
    } catch (e) {
      print('Error fetching daily statistics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshData() {
    fetchDailyStatistics();
  }
}
