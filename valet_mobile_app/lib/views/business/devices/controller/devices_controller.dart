import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/views/business/business_home/model/valet_response.dart';
import 'package:valet_mobile_app/views/business/devices/model/device_model.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';

class DevicesController extends GetxController {
  final RxList<Device> devices = <Device>[].obs;
  final RxBool isLoading = false.obs;
  final valets = <ValetResponse>[].obs;
  final selectedValetId = RxnInt();
  final RxList deviceLogs = [].obs;
  final RxBool isLoadingLogs = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDevices();
    fetchValets();
  }

  List<Device> get assignedDevices => devices.where((device) => device.isAssigned).toList();

  List<Device> get availableDevices => devices.where((device) => !device.isAssigned).toList();

  Future<void> fetchDevices() async {
    isLoading.value = true;
    try {
      final devicesList = await ApiService.getDevices();

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

      devices.assignAll(devicesList);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load devices: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
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

  Future<void> fetchDeviceLogs(int deviceId) async {
    try {
      isLoadingLogs.value = true;
      final logs = await ApiService.getDeviceLogs(deviceId);

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

      deviceLogs.assignAll(logs);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load device logs: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingLogs.value = false;
    }
  }
}
