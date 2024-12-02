// Login için request model
import 'package:get/get.dart';

class LoginRequest {
  final String email;
  final String password;
  final String? businessName;
  final String? phoneNumber;

  LoginRequest({
    required this.email,
    required this.password,
    this.businessName,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'business_name': businessName,
      'phone_number': phoneNumber,
    };
  }
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

class BusinessUser {
  final String email;
  final String credentials;
  final String businessName;
  final String phoneNumber;
  final int? businessId;
  final int? id;

  BusinessUser({
    required this.email,
    required this.credentials,
    required this.businessName,
    required this.phoneNumber,
    this.businessId,
    this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'credentials': credentials,
      'business_name': businessName,
      'phone_number': phoneNumber,
      'business_id': businessId,
      'id': id,
    };
  }

  factory BusinessUser.fromJson(Map<String, dynamic> json) {
    return BusinessUser(
      email: json['email'] ?? '',
      credentials: json['credentials'] ?? '',
      businessName: json['business_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      businessId: json['business_id'],
      id: json['id'],
    );
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String businessName;
  final String phoneNumber;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.businessName,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'business_name': businessName,
      'phone_number': phoneNumber,
    };
  }
}
