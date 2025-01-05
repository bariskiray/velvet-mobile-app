class ValetCompleteTicketModel {
  final int? ticketId;
  final String? note;
  final int? parkingSpot;
  final bool? damage;
  final String? licensePlate;
  final String? brand;
  final String? color;

  ValetCompleteTicketModel({
    this.ticketId,
    this.note,
    this.parkingSpot,
    this.damage,
    this.licensePlate,
    this.brand,
    this.color,
  });

  // JSON'dan model oluşturma
  factory ValetCompleteTicketModel.fromJson(Map<String, dynamic> json) {
    return ValetCompleteTicketModel(
      ticketId: json['ticket_id'] as int?,
      note: json['note'] as String?,
      parkingSpot: json['parking_spot'] as int?,
      damage: json['damage'] as bool?,
      licensePlate: json['license_plate'] as String?,
      brand: json['brand'] as String?,
      color: json['color'] as String?,
    );
  }

  // Model'den JSON oluşturma
  Map<String, dynamic> toJson() {
    return {
      'ticket_id': ticketId,
      'note': note,
      'parking_spot': parkingSpot,
      'damage': damage,
      'license_plate': licensePlate,
      'brand': brand,
      'color': color,
    };
  }

  // Modeli kopyalama ve bazı alanları güncelleme
  ValetCompleteTicketModel copyWith({
    int? ticketId,
    String? note,
    int? parkingSpot,
    bool? damage,
    String? licensePlate,
    String? brand,
    String? color,
  }) {
    return ValetCompleteTicketModel(
      ticketId: ticketId ?? this.ticketId,
      note: note ?? this.note,
      parkingSpot: parkingSpot ?? this.parkingSpot,
      damage: damage ?? this.damage,
      licensePlate: licensePlate ?? this.licensePlate,
      brand: brand ?? this.brand,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'ValetCompleteTicketModel(ticketId: $ticketId, note: $note, parkingSpot: $parkingSpot, damage: $damage, licensePlate: $licensePlate, brand: $brand, color: $color)';
  }
}
