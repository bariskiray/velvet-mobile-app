class Device {
  final int deviceId;
  final String type;
  final int battery;
  final int businessId;
  int? valetId;
  String? valetName;

  Device({
    required this.deviceId,
    required this.type,
    required this.battery,
    required this.businessId,
    this.valetId,
    this.valetName,
  });

  bool get isAssigned => valetId != null;

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'],
      type: json['type'],
      battery: json['battery'],
      businessId: json['business_id'],
      valetId: json['valet_id'],
      valetName: json['valet_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'type': type,
      'battery': battery,
      'business_id': businessId,
      'valet_id': valetId,
      'valet_name': valetName,
    };
  }
}

class DeviceCreateRequest {
  final String type;
  final int battery;
  final int businessId;
  final int? valetId;

  DeviceCreateRequest({
    required this.type,
    required this.battery,
    required this.businessId,
    this.valetId,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'battery': battery,
      'business_id': businessId,
      'valet_id': valetId,
    };
  }
}
