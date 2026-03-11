import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:valet_mobile_app/views/business/business_home/model/valet_response.dart';
import 'package:valet_mobile_app/views/business/devices/model/device_model.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';

class DevicesController extends GetxController {
  final RxList<Device> devices = <Device>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final valets = <ValetResponse>[].obs;
  final selectedValetId = RxnInt();
  final RxList deviceLogs = [].obs;
  final RxBool isLoadingLogs = false.obs;
  final RxBool isLoadingMoreLogs = false.obs;
  final RxBool hasMoreLogData = true.obs;

  final RefreshController refreshController = RefreshController();
  final RefreshController logsRefreshController = RefreshController();
  final int pageSize = 10;
  final currentPage = 1.obs;
  final currentLogPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDevices();
    fetchValets();
  }

  List<Device> get assignedDevices => devices.where((device) => device.isAssigned).toList();

  List<Device> get availableDevices => devices.where((device) => !device.isAssigned).toList();

  Future<void> fetchDevices({bool isRefresh = true}) async {
    try {
      if (isRefresh) {
        isLoading.value = true;
        currentPage.value = 1;
        hasMoreData.value = true;
      } else {
        if (!hasMoreData.value || isLoadingMore.value) return;
        isLoadingMore.value = true;
      }

      final devicesList = await ApiService.getDevices(
        page: currentPage.value,
        size: pageSize,
      );

      // Fetch valet info for each device
      for (var device in devicesList) {
        if (device.valetId != null) {
          try {
            final valetInfo = await ApiService.getValetById(device.valetId!);
            device.valetName = "${valetInfo['valet_name']} ${valetInfo['valet_surname']}";
          } catch (e) {
            print('Error fetching valet info: $e');
          }
        }
      }

      if (isRefresh) {
        devices.assignAll(devicesList);
        refreshController.refreshCompleted();
      } else {
        devices.addAll(devicesList);
        refreshController.loadComplete();
      }

      // Check if we have fewer items than page size, meaning no more data
      if (devicesList.length < pageSize) {
        hasMoreData.value = false;
        refreshController.loadNoData();
      } else {
        currentPage.value++;
      }
    } catch (e) {
      if (isRefresh) {
        refreshController.refreshFailed();
      } else {
        refreshController.loadFailed();
      }
      Get.snackbar(
        'Error',
        'Failed to load devices: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreDevices() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    await fetchDevices(isRefresh: false);
  }

  Future<void> refreshDevices() async {
    return fetchDevices();
  }

  Future<void> addDevice(DeviceCreateRequest request) async {
    try {
      isLoading.value = true;
      final response = await ApiService.createDevice(request);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newDevice = Device.fromJson(response.data);
        devices.add(newDevice);
        Get.back();
        Get.snackbar(
          'Success',
          'Device added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add device: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchValets() async {
    try {
      isLoading.value = true;
      final response = await ApiService.getValets();

      print('Valets Response: $response'); // For debugging

      valets.value = List<ValetResponse>.from(response);
    } catch (e) {
      print('Fetch Valets Error: $e');
      Get.snackbar(
        'Error',
        'Failed to load valets',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignDevice(Device device, int valetId) async {
    try {
      isLoading.value = true;
      final response = await ApiService.assignDevice(device.deviceId, valetId);

      if (response.statusCode == 200) {
        await refreshDevices();
        Get.snackbar(
          'Success',
          'Device assigned successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Assign Device Error: $e');
      Get.snackbar(
        'Error',
        'Failed to assign device',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showAssignDialog(Device device) {
    selectedValetId.value = null;

    fetchValets().then((_) {
      if (valets.isEmpty) {
        Get.snackbar(
          'Warning',
          'No valets available',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      Get.dialog(
        Obx(() => AlertDialog(
              title: const Text('Assign Device'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Device ID: ${device.deviceId}'),
                  const SizedBox(height: 16),
                  Container(
                    height: 300,
                    width: double.maxFinite,
                    child: valets.isEmpty
                        ? Center(child: Text('No valets available'))
                        : ListView.builder(
                            itemCount: valets.length,
                            itemBuilder: (context, index) {
                              final valet = valets[index];
                              return RadioListTile<int>(
                                title: Text('${valet.valetName} ${valet.valetSurname}'),
                                subtitle: Text('ID: ${valet.valetId}'),
                                value: valet.valetId,
                                groupValue: selectedValetId.value,
                                onChanged: (int? value) {
                                  selectedValetId.value = value;
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedValetId.value == null
                      ? null
                      : () {
                          Get.back();
                          assignDevice(device, selectedValetId.value!);
                        },
                  child: const Text('Assign'),
                ),
              ],
            )),
      );
    });
  }

  Future<void> unassignDevice(Device device) async {
    try {
      isLoading.value = true;
      await ApiService.unassignDevice(device.deviceId);

      await fetchDevices();

      Get.snackbar(
        'Success',
        'Device unassigned successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to unassign device: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDevice(Device device) async {
    try {
      devices.remove(device);
      Get.back();
      Get.snackbar('Success', 'Device deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete device');
    }
  }

  Future<void> fetchDeviceLogs(int deviceId, {bool isRefresh = true}) async {
    try {
      if (isRefresh) {
        print('DEBUG: Device logs refresh başlatılıyor - sayfa 1\'e sıfırlanıyor');
        isLoadingLogs.value = true;
        currentLogPage.value = 1;
        hasMoreLogData.value = true;
      } else {
        print('DEBUG: Daha fazla log yükleniyor - sayfa: ${currentLogPage.value}');
        if (!hasMoreLogData.value || isLoadingMoreLogs.value) {
          print('DEBUG: Daha fazla log yok veya zaten yükleniyor');
          return;
        }
        isLoadingMoreLogs.value = true;
      }

      print('DEBUG: Device logs API çağrısı yapılıyor - sayfa: ${currentLogPage.value}, boyut: $pageSize');

      // Use new API format with pagination
      final apiResponse = await ApiService.getDeviceLogs(
        deviceId,
        page: currentLogPage.value,
        size: pageSize,
      );

      final logs = apiResponse['items'] as List<dynamic>;
      final paginationInfo = apiResponse['pagination'] as Map<String, dynamic>;

      print('DEBUG: ${logs.length} log alındı');
      print('DEBUG: Pagination bilgisi: $paginationInfo');

      // Her log için vale bilgilerini al
      for (var log in logs) {
        try {
          final valetInfo = await ApiService.getValetById(log['valet_id']);
          log['valet_name'] = valetInfo['valet_name'];
          log['valet_surname'] = valetInfo['valet_surname'];
        } catch (e) {
          print('Error fetching valet info for log: $e');
        }
      }

      if (isRefresh) {
        print('DEBUG: Device logs listesi sıfırlanıyor ve ${logs.length} öğe ekleniyor');
        deviceLogs.assignAll(logs);
        logsRefreshController.refreshCompleted();
      } else {
        print('DEBUG: Mevcut log listesine ${logs.length} öğe ekleniyor');
        deviceLogs.addAll(logs);
        logsRefreshController.loadComplete();
      }

      // Pagination bilgisini kullanarak hasMoreLogData'yı doğru ayarla
      final currentPageFromApi = paginationInfo['page'] as int;
      final totalPages = paginationInfo['pages'] as int;
      final totalItems = paginationInfo['total'] as int;

      if (currentPageFromApi >= totalPages) {
        print('DEBUG: Son log sayfasına ulaşıldı ($currentPageFromApi >= $totalPages)');
        hasMoreLogData.value = false;
        logsRefreshController.loadNoData();
      } else {
        print('DEBUG: Daha fazla log sayfası var ($currentPageFromApi < $totalPages)');
        hasMoreLogData.value = true;
        currentLogPage.value++;
      }

      print('DEBUG: Toplam log: $totalItems, Toplam sayfa: $totalPages, Mevcut sayfa: $currentPageFromApi');
    } catch (e) {
      print('Failed to load device logs: $e');
      if (isRefresh) {
        logsRefreshController.refreshFailed();
        print('DEBUG: Device logs refresh başarısız');
      } else {
        logsRefreshController.loadFailed();
        print('DEBUG: Device logs load more başarısız');
      }
      Get.snackbar(
        'Error',
        'Failed to load device logs: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingLogs.value = false;
      isLoadingMoreLogs.value = false;
    }
  }

  Future<void> refreshDeviceLogs(int deviceId) async {
    print('DEBUG: refreshDeviceLogs çağrıldı');
    print('DEBUG: Refresh öncesi - currentLogPage: ${currentLogPage.value}, hasMoreLogData: ${hasMoreLogData.value}');
    print('DEBUG: Refresh öncesi - toplam log: ${deviceLogs.length}');

    currentLogPage.value = 1;
    hasMoreLogData.value = true;

    // SmartRefresher'ın footer durumunu sıfırla
    logsRefreshController.resetNoData();

    print('DEBUG: Refresh için ayarlandı - currentLogPage: ${currentLogPage.value}, hasMoreLogData: ${hasMoreLogData.value}');

    await fetchDeviceLogs(deviceId, isRefresh: true);
  }

  Future<void> loadMoreLogs(int deviceId) async {
    print('DEBUG: loadMoreLogs çağrıldı - mevcut sayfa: ${currentLogPage.value}');
    print('DEBUG: hasMoreLogData: ${hasMoreLogData.value}, isLoadingMoreLogs: ${isLoadingMoreLogs.value}');

    if (!hasMoreLogData.value) {
      print('DEBUG: Daha fazla log yok, loadNoData çağrılıyor');
      logsRefreshController.loadNoData();
      return;
    }

    if (isLoadingMoreLogs.value) {
      print('DEBUG: Zaten log yükleniyor, çıkılıyor');
      return;
    }

    await fetchDeviceLogs(deviceId, isRefresh: false);
  }
}
