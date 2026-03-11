import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:valet_mobile_app/views/business/parking_spots/controller/business_parking_spots_controller.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BusinessParkingSpotsView extends GetView<BusinessParkingSpotsController> {
  const BusinessParkingSpotsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Parking Spots',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Force add mode when clicking the Add Spot button
              controller.resetForm();
              _showAddEditModal(context);
            },
            tooltip: 'Add Spot',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshParkingSpots,
            tooltip: 'Refresh',
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Obx(() => controller.isLoading.value ? const Center(child: CircularProgressIndicator()) : _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Search spots...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        // List of Parking Spots
        Expanded(
          child: _buildListView(),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return Obx(() {
      if (controller.isLoading.value && controller.parkingSpots.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredParkingSpots.isEmpty && !controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_parking,
                size: 70,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Parking Spots Found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a new parking spot using the button below',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      return Obx(() => SmartRefresher(
            controller: controller.refreshController,
            enablePullDown: true,
            enablePullUp: controller.hasMoreData.value,
            onRefresh: controller.refreshParkingSpots,
            onLoading: controller.loadMoreParkingSpots,
            header: const WaterDropHeader(),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus? mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = Text(
                    "Daha fazla yüklemek için yukarı çekin",
                    style: TextStyle(color: Colors.grey[600]),
                  );
                } else if (mode == LoadStatus.loading) {
                  body = Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Yükleniyor...",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  );
                } else if (mode == LoadStatus.failed) {
                  body = GestureDetector(
                    onTap: controller.loadMoreParkingSpots,
                    child: Text(
                      "Yükleme başarısız! Tekrar deneyin",
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  );
                } else if (mode == LoadStatus.canLoading) {
                  body = Text(
                    "Bırakın ve daha fazla yükleyin",
                    style: TextStyle(color: Colors.grey[600]),
                  );
                } else {
                  body = Text(
                    "Daha fazla veri yok",
                    style: TextStyle(color: Colors.grey[500]),
                  );
                }
                return SizedBox(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: controller.filteredParkingSpots.length,
              itemBuilder: (context, index) {
                final spot = controller.filteredParkingSpots[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Slidable(
                    key: ValueKey(spot['id']),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      dismissible: DismissiblePane(
                        onDismissed: () {
                          controller.deleteParkingSpot(spot['id']);
                        },
                      ),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            controller.editParkingSpot(spot);
                            _showAddEditModal(context);
                          },
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            _showDeleteConfirmation(context, spot);
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: spot['is_empty'] ? Colors.green : Colors.red,
                              ),
                              child: const Icon(
                                Icons.local_parking,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            title: Text(
                              spot['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              spot['is_empty'] ? 'Available' : 'Occupied',
                              style: TextStyle(
                                color: spot['is_empty'] ? Colors.green[700] : Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.location_on,
                                    color: Colors.blue[900],
                                  ),
                                  onPressed: () {
                                    _showLocationOnMap(context, spot);
                                  },
                                ),
                                const Icon(Icons.swipe_left, color: Colors.grey),
                              ],
                            ),
                            onTap: () {
                              controller.editParkingSpot(spot);
                              _showAddEditModal(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ));
    });
  }

  void _showLocationOnMap(BuildContext context, Map<String, dynamic> spot) {
    final lat = spot['latitude'] is String ? double.parse(spot['latitude']) : spot['latitude'] as double;

    final lng = spot['longitude'] is String ? double.parse(spot['longitude']) : spot['longitude'] as double;

    final spotLocation = LatLng(lat, lng);
    final Set<Marker> spotMarker = {
      Marker(
        markerId: MarkerId('spot_${spot['id']}'),
        position: spotLocation,
        infoWindow: InfoWindow(
          title: spot['name'],
          snippet: spot['is_empty'] ? 'Available' : 'Occupied',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          spot['is_empty'] ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
      ),
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue[900]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Location of ${spot['name']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: spotLocation,
                            zoom: 15,
                          ),
                          markers: spotMarker,
                          zoomControlsEnabled: false,
                          mapType: MapType.normal,
                          onMapCreated: (controller) {
                            // Handle map creation
                          },
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton(
                            mini: true,
                            backgroundColor: Colors.white,
                            onPressed: controller.getCurrentLocation,
                            child: const Icon(Icons.my_location, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Coordinates: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddEditModal(BuildContext context) {
    // We don't need to reset the form here anymore
    // The form is reset in the specific places where it's needed:
    // 1. When clicking the Add Spot button (in the FloatingActionButton)
    // 2. When clicking edit on a spot (editParkingSpot is called first)

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Obx(() => Text(
                    controller.isAddMode.value ? 'Add New Parking Spot' : 'Edit Parking Spot',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
            ),
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  // Map selection
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        children: [
                          Obx(() => GoogleMap(
                                initialCameraPosition: controller.initialCameraPosition.value,
                                onMapCreated: (mapController) {
                                  try {
                                    controller.mapController.value = mapController;

                                    // If editing, move camera to the spot location
                                    if (!controller.isAddMode.value && controller.selectedLocation.value != null) {
                                      Future.delayed(const Duration(milliseconds: 500), () {
                                        try {
                                          controller.mapController.value!.animateCamera(
                                            CameraUpdate.newLatLng(controller.selectedLocation.value!),
                                          );
                                        } catch (e) {
                                          print('Error animating camera: $e');
                                        }
                                      });
                                    }
                                    // If there's a selected location, update markers
                                    if (controller.selectedLocation.value != null) {
                                      controller.updateMapMarkers();
                                    }
                                  } catch (e) {
                                    print('Error creating map: $e');
                                  }
                                },
                                markers: controller.markers.value,
                                myLocationEnabled: true,
                                mapToolbarEnabled: false,
                                zoomControlsEnabled: false,
                                onTap: (location) {
                                  try {
                                    controller.selectLocation(location);
                                  } catch (e) {
                                    print('Error on map tap: $e');
                                  }
                                },
                              )),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: FloatingActionButton(
                              mini: true,
                              backgroundColor: Colors.white,
                              onPressed: () {
                                try {
                                  controller.getCurrentLocation();
                                } catch (e) {
                                  print('Error getting location: $e');
                                }
                              },
                              child: const Icon(Icons.my_location, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Location info if selected
                  Obx(() {
                    if (controller.selectedLocation.value != null) {
                      return Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.pin_drop, color: Colors.blue[700]),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selected Location',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lat: ${controller.selectedLocation.value!.latitude.toStringAsFixed(6)}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                  ),
                                  Text(
                                    'Lng: ${controller.selectedLocation.value!.longitude.toStringAsFixed(6)}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[800]),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Tap on the map to select a location',
                                style: TextStyle(color: Colors.deepOrange),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
                  const SizedBox(height: 20),
                  // Name field
                  Text(
                    'Spot Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controller.nameController,
                    decoration: InputDecoration(
                      labelText: 'Spot Name',
                      hintText: 'e.g. A1, B2, etc.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: Icon(Icons.edit, color: Colors.blue[900]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Availability toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Obx(() => SwitchListTile(
                          title: const Text(
                            'Is this spot available?',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: controller.isEmpty.value,
                          onChanged: (value) => controller.isEmpty.value = value,
                          activeColor: Colors.green,
                          inactiveTrackColor: Colors.red[100],
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: controller.isEmpty.value ? Colors.green[50] : Colors.red[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.local_parking,
                              color: controller.isEmpty.value ? Colors.green : Colors.red,
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        side: BorderSide(color: Colors.blue[900]!),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value ||
                                  controller.selectedLocation.value == null ||
                                  controller.nameController.text.isEmpty
                              ? null
                              : () {
                                  controller.saveParkingSpot();
                                  Get.back();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  controller.isAddMode.value ? 'Add Spot' : 'Update Spot',
                                  style: const TextStyle(color: Colors.white),
                                ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> spot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Parking Spot'),
        content: Text('Are you sure you want to delete "${spot['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteParkingSpot(spot['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
