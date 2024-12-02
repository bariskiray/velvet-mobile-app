class ValetResponse {
  final int valetId;
  final String valetName;
  final String valetSurname;
  final String email;
  final String? phoneNumber;
  final int businessId;
  final bool isActive;

  ValetResponse({
    required this.valetId,
    required this.valetName,
    required this.valetSurname,
    required this.email,
    this.phoneNumber,
    required this.businessId,
    this.isActive = true,
  });

  factory ValetResponse.fromJson(Map<String, dynamic> json) {
    return ValetResponse(
      valetId: json['valet_id'],
      valetName: json['valet_name'],
      valetSurname: json['valet_surname'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      businessId: json['business_id'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valet_id': valetId,
      'valet_name': valetName,
      'valet_surname': valetSurname,
      'email': email,
      'phone_number': phoneNumber,
      'business_id': businessId,
      'is_active': isActive,
    };
  }
}
