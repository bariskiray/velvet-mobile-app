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
  final String message;
  final UserData user;

  LoginResponse({
    required this.message,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        message: json['message'] ?? '',
        user: UserData.fromJson(json['user']),
      );
}

// Business register request model
class BusinessRegisterRequest {
  final String email;
  final String password;
  final String businessName;

  BusinessRegisterRequest({
    required this.email,
    required this.password,
    required this.businessName,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'business_name': businessName,
      };
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
  final int id;
  final String email;
  final String role;
  final String? businessName; // Business için
  final String? firstName; // Valet için
  final String? lastName; // Valet için
  final String? valetCode; // Valet için

  UserData({
    required this.id,
    required this.email,
    required this.role,
    this.businessName,
    this.firstName,
    this.lastName,
    this.valetCode,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json['id'],
        email: json['email'],
        role: json['role'],
        businessName: json['business_name'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        valetCode: json['valet_code'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        if (businessName != null) 'business_name': businessName,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (valetCode != null) 'valet_code': valetCode,
      };
}
