// Login için request model
class LoginRequest {
  final String email;
  final String password;
  final String userType;

  LoginRequest({
    required this.email,
    required this.password,
    required this.userType,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'user_type': userType,
      };
}

// Login response model
class LoginResponse {
  final UserData user;
  final String token;

  LoginResponse({
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    print('API Response: $json'); // Debug için

    return LoginResponse(
      user: UserData.fromJson(json['data'] ?? {}), // data içinden user bilgilerini al
      token: json['token'] ?? '',
    );
  }
}

// Valet register request model
class ValetRegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  ValetRegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
      };
}

// User data model
class UserData {
  final String? id;
  final String email;
  final String? businessName;
  final String? phoneNumber;
  final String? userType;

  UserData({
    this.id,
    required this.email,
    this.businessName,
    this.phoneNumber,
    this.userType,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString(),
      email: json['email'] ?? '',
      businessName: json['business_name'],
      phoneNumber: json['phone_number'],
      userType: json['user_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'business_name': businessName,
      'phone_number': phoneNumber,
      'user_type': userType,
    };
  }
}
