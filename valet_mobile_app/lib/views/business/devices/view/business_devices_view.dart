import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/auth/auth_controller.dart';

import 'package:valet_mobile_app/views/business/devices/controller/devices_controller.dart';
import 'package:valet_mobile_app/views/business/devices/model/device_model.dart';

class BusinessDevicesView extends StatelessWidget {
  final DevicesController controller = Get.put(DevicesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddDeviceDialog(context),
          ),
        ],
      ),
      body: Obx(() => AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: controller.isLoading.value ? Center(child: CircularProgressIndicator()) : _buildBody(),
          )),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: controller.refreshDevices,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatisticsSection(),
            SizedBox(height: 20),
            Expanded(
              child: Obx(
                () => controller.devices.isEmpty
                    ? Center(
                        child: Text('No devices added yet'),
                      )
                    : ListView.builder(
                        itemCount: controller.devices.length,
                        itemBuilder: (context, index) {
                          return _buildDeviceCard(controller.devices[index]);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Total Devices', '${controller.devices.length}'),
          _buildStatCard('Assigned', '${controller.assignedDevices.length}'),
          _buildStatCard('Available', '${controller.availableDevices.length}'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(Device device) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ExpansionTile(
        leading: Icon(
          Icons.smartphone,
          color: device.isAssigned ? Colors.green : Colors.grey,
        ),
        title: Text(device.type),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (device.isAssigned) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      device.valetName ?? 'Loading...',
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${device.isAssigned ? "Assigned" : "Available"}'),
                Text('Battery: ${device.battery}%'),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showDeviceLogs(device),
                      icon: Icon(Icons.history),
                      label: Text('Logs'),
                    ),
                    TextButton(
                      onPressed: () => device.isAssigned ? _showUnassignConfirmation(device) : controller.showAssignDialog(device),
                      child: Text(device.isAssigned ? 'Unassign' : 'Assign Valet'),
                    ),
                    TextButton(
                      onPressed: () => _showDeleteConfirmation(device),
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceDialog(BuildContext context) {
    final typeController = TextEditingController();
    final batteryController = TextEditingController(text: '100');

    Get.dialog(
      AlertDialog(
        title: Text('Add New Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeController,
              decoration: InputDecoration(
                labelText: 'Device Type',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: batteryController,
              decoration: InputDecoration(
                labelText: 'Battery Level',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (typeController.text.isNotEmpty) {
                final request = DeviceCreateRequest(
                  type: typeController.text,
                  battery: int.parse(batteryController.text),
                  businessId: AuthController.to.currentUser.value?.businessId ?? 0,
                );
                controller.addDevice(request);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(Device device) {
    final valeController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Assign Valet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Device ID: ${device.deviceId}'),
            SizedBox(height: 16),
            TextField(
              controller: valeController,
              decoration: InputDecoration(
                labelText: 'Valet ID',
                border: OutlineInputBorder(),
                hintText: 'Enter valet ID number',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (valeController.text.isNotEmpty) {
                controller.assignDevice(device, int.parse(valeController.text));
              } else {
                Get.snackbar(
                  'Warning',
                  'Please enter a valet ID',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              }
            },
            child: Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showUnassignConfirmation(Device device) {
    Get.dialog(
      AlertDialog(
        title: Text('Unassign Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to unassign this device?'),
            SizedBox(height: 12),
            Text('Device ID: ${device.deviceId}'),
            if (device.valetId != null) Text('Valet ID: ${device.valetId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () {
              Get.back();
              controller.unassignDevice(device);
            },
            child: Text('Unassign'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Device device) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Device'),
        content: Text('Are you sure you want to delete this device?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => controller.deleteDevice(device),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeviceLogs(Device device) {
    controller.fetchDeviceLogs(device.deviceId);

    Get.dialog(
      AlertDialog(
        title: Text('Device Logs'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: Obx(() {
            if (controller.isLoadingLogs.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (controller.deviceLogs.isEmpty) {
              return Center(child: Text('No logs found'));
            }

            return ListView.builder(
              itemCount: controller.deviceLogs.length,
              itemBuilder: (context, index) {
                final log = controller.deviceLogs[index];
                final assignDate = DateTime.parse(log['assign_date']);
                final unassignDate = log['unassign_date'] != null ? DateTime.parse(log['unassign_date']) : null;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: unassignDate == null ? Colors.green : Colors.blue,
                          width: 4,
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: unassignDate == null ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                        child: Icon(
                          unassignDate == null ? Icons.check_circle : Icons.history,
                          color: unassignDate == null ? Colors.green : Colors.blue,
                        ),
                      ),
                      title: Text(
                        'Log #${log['log_id']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Assigned: ${assignDate.toString().split('.')[0]}'),
                          if (unassignDate != null) Text('Unassigned: ${unassignDate.toString().split('.')[0]}'),
                          Text(
                              'Valet: ${log['valet_name'] != null && log['valet_surname'] != null ? '${log['valet_name']} ${log['valet_surname']}' : 'Valet #${log['valet_id']}'}'),
                          Text('Status: ${unassignDate == null ? 'Active' : 'Completed'}'),
                        ],
                      ),
                      trailing: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: unassignDate == null ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // Implement date formatting logic here
    return dateTime.toString();
  }

  String _calculateDuration(DateTime start, DateTime? end) {
    // Implement duration calculation logic here
    return '0 days';
  }
}
