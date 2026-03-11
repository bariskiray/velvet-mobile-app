import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class NavigationMapView extends StatefulWidget {
  final double currentLatitude;
  final double currentLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final String destinationName;

  const NavigationMapView({
    Key? key,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.destinationName,
  }) : super(key: key);

  @override
  State<NavigationMapView> createState() => _NavigationMapViewState();
}

class _NavigationMapViewState extends State<NavigationMapView> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  late CameraPosition _initialCameraPosition;
  StreamSubscription<Position>? _positionStream;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _setupMap();
    _startLocationTracking();
    _fitBoundsToMarkers();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  void _setupMap() {
    // Initial camera position (current location)
    _initialCameraPosition = CameraPosition(
      target: LatLng(widget.currentLatitude, widget.currentLongitude),
      zoom: 15.0,
    );

    // Setup markers
    _markers = {
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(widget.currentLatitude, widget.currentLongitude),
        infoWindow: const InfoWindow(
          title: 'Your Current Location',
          snippet: 'You are here',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.destinationLatitude, widget.destinationLongitude),
        infoWindow: InfoWindow(
          title: widget.destinationName,
          snippet: 'Closest parking spot',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  void _fitBoundsToMarkers() async {
    // Wait a bit for the map to be ready
    await Future.delayed(const Duration(milliseconds: 500));

    final GoogleMapController controller = await _controller.future;

    // Calculate bounds between current location and destination
    double minLat = widget.currentLatitude < widget.destinationLatitude ? widget.currentLatitude : widget.destinationLatitude;
    double maxLat = widget.currentLatitude > widget.destinationLatitude ? widget.currentLatitude : widget.destinationLatitude;
    double minLng = widget.currentLongitude < widget.destinationLongitude ? widget.currentLongitude : widget.destinationLongitude;
    double maxLng = widget.currentLongitude > widget.destinationLongitude ? widget.currentLongitude : widget.destinationLongitude;

    // Add padding
    double padding = 0.002;

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - padding, minLng - padding),
          northeast: LatLng(maxLat + padding, maxLng + padding),
        ),
        100.0,
      ),
    );
  }

  void _startLocationTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);

        // Update current location marker
        _markers.removeWhere((marker) => marker.markerId.value == 'current_location');
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(
              title: 'Your Current Location',
              snippet: 'Updated location',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });

      // Update camera to follow current location (optional)
      _updateCamera(position.latitude, position.longitude);
    });
  }

  void _updateCamera(double lat, double lng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(LatLng(lat, lng)),
    );
  }

  void _fitBounds() async {
    _fitBoundsToMarkers();
  }

  double _calculateDistance() {
    final currentLat = _currentPosition?.latitude ?? widget.currentLatitude;
    final currentLng = _currentPosition?.longitude ?? widget.currentLongitude;

    return Geolocator.distanceBetween(
      currentLat,
      currentLng,
      widget.destinationLatitude,
      widget.destinationLongitude,
    );
  }

  String _getEstimatedTime(double distanceInMeters) {
    // Assume average walking speed of 5 km/h for parking lot navigation
    double timeInHours = (distanceInMeters / 1000) / 5;
    int timeInMinutes = (timeInHours * 60).round();
    return timeInMinutes < 1 ? '< 1 min' : '$timeInMinutes min';
  }

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Closest Parking Spot',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong, color: Colors.white),
            onPressed: _fitBounds,
            tooltip: 'Show both locations',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
          ),

          // Close button (X) - Top right
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Get.back();
                Get.back();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.grey[700],
                  size: 24,
                ),
              ),
            ),
          ),

          // Top info card
          Positioned(
            top: 70, // Moved down to avoid close button
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[50]!,
                      Colors.white,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_parking,
                          color: Colors.red[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.destinationName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.straighten,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Distance: ${(distance / 1000).toStringAsFixed(2)} km',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.green[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Walking time: ${_getEstimatedTime(distance)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom info bar
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.blue[900],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Blue marker: Your location • Red marker: Closest parking spot',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
