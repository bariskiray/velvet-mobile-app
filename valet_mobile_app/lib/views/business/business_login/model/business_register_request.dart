class BusinessRegisterRequest {
  final String email;
  final String phoneNumber;
  final String businessName;
  final String password;

  BusinessRegisterRequest({
    required this.email,
    required this.phoneNumber,
    required this.businessName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone_number': phoneNumber,
      'business_name': businessName,
      'password': password,
    };
  }
}
