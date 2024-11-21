class ValetRegisterRequest {
  final String email;
  final String phoneNumber;
  final String valetName;
  final String valetSurname;
  final String password;

  ValetRegisterRequest({
    required this.email,
    required this.phoneNumber,
    required this.valetName,
    required this.valetSurname,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone_number': phoneNumber,
      'valet_name': valetName,
      'valet_surname': valetSurname,
      'password': password,
    };
  }

  factory ValetRegisterRequest.fromJson(Map<String, dynamic> json) {
    return ValetRegisterRequest(
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      valetName: json['valet_name'] ?? '',
      valetSurname: json['valet_surname'] ?? '',
      password: json['password'] ?? '',
    );
  }
}

// İsteğe bağlı: API yanıtı için model
class ValetRegisterResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ValetRegisterResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ValetRegisterResponse.fromJson(Map<String, dynamic> json) {
    return ValetRegisterResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}
