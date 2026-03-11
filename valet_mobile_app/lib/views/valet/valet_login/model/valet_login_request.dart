class ValetLoginRequest {
  final String email;
  final String password;
  final String? fcmToken;

  ValetLoginRequest({
    required this.email,
    required this.password,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
    };

    if (fcmToken != null) {
      data['fcm_token'] = fcmToken;
    }

    return data;
  }

  factory ValetLoginRequest.fromJson(Map<String, dynamic> json) {
    return ValetLoginRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      fcmToken: json['fcm_token'],
    );
  }
}

// İsteğe bağlı: API yanıtı için model
class ValetLoginResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ValetLoginResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ValetLoginResponse.fromJson(Map<String, dynamic> json) {
    return ValetLoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}

// Vale bilgilerini tutmak için model (isteğe bağlı)
class ValetUser {
  final String email;
  final String credentials;
  final String valetName;
  final String valetSurname;
  final String phoneNumber;

  ValetUser({
    required this.email,
    required this.credentials,
    required this.valetName,
    required this.valetSurname,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'credentials': credentials,
      'valet_name': valetName,
      'valet_surname': valetSurname,
      'phone_number': phoneNumber,
    };
  }

  factory ValetUser.fromJson(Map<String, dynamic> json) {
    return ValetUser(
      email: json['email'] ?? '',
      credentials: json['credentials'] ?? '',
      valetName: json['valet_name'] ?? '',
      valetSurname: json['valet_surname'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }
}
