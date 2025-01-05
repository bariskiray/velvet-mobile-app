import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/views/business/business_home/controller/business_home_controller.dart';

class ValetListView extends GetView<BusinessHomeController> {
  const ValetListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valet List'),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchValets,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchValets,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (controller.valets.isEmpty) {
          return const Center(
            child: Text('No valets found'),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchValets,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.valets.length,
            itemBuilder: (context, index) {
              final valet = controller.valets[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue[900]!,
                        Colors.blue[700]!,
                      ],
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      child: Text(
                        '${valet.valetName[0]}${valet.valetSurname[0]}',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${valet.valetName} ${valet.valetSurname}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.email, color: Colors.white70, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              valet.email,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        if (valet.phoneNumber != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone, color: Colors.white70, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                valet.phoneNumber!,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: valet.isWorking ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        valet.isWorking ? 'Working' : 'Not Working',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
