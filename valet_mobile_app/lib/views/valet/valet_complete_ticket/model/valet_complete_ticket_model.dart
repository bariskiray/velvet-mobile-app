class ValetCompleteTicketModel {
  final int ticketId;
  final String? note;
  final bool damage;
  final String licensePlate;
  final String brand;
  final String color;
  final double? latitude;
  final double? longitude;
  final int? parkingLocationId;

  ValetCompleteTicketModel({
    required this.ticketId,
    this.note,
    required this.damage,
    required this.licensePlate,
    required this.brand,
    required this.color,
    this.latitude,
    this.longitude,
    this.parkingLocationId,
  });

  // JSON'dan model oluşturma
  factory ValetCompleteTicketModel.fromJson(Map<String, dynamic> json) {
    return ValetCompleteTicketModel(
      ticketId: json['ticket_id'] as int,
      note: json['note'] as String?,
      damage: json['damage'] as bool,
      licensePlate: json['license_plate'] as String,
      brand: json['brand'] as String,
      color: json['color'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      parkingLocationId: json['parking_location_id'] as int?,
    );
  }

  // Model'den JSON oluşturma
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'ticket_id': ticketId,
      'note': note,
      'damage': damage,
      'license_plate': licensePlate,
      'brand': brand,
      'color': color,
    };

    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (parkingLocationId != null) data['parking_location_id'] = parkingLocationId;

    return data;
  }

  // Modeli kopyalama ve bazı alanları güncelleme
  ValetCompleteTicketModel copyWith({
    int? ticketId,
    String? note,
    bool? damage,
    String? licensePlate,
    String? brand,
    String? color,
    double? latitude,
    double? longitude,
    int? parkingLocationId,
  }) {
    return ValetCompleteTicketModel(
      ticketId: ticketId ?? this.ticketId,
      note: note ?? this.note,
      damage: damage ?? this.damage,
      licensePlate: licensePlate ?? this.licensePlate,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      parkingLocationId: parkingLocationId ?? this.parkingLocationId,
    );
  }

  @override
  String toString() {
    return 'ValetCompleteTicketModel(ticketId: $ticketId, note: $note, damage: $damage, licensePlate: $licensePlate, brand: $brand, color: $color, latitude: $latitude, longitude: $longitude, parkingLocationId: $parkingLocationId)';
  }
}
