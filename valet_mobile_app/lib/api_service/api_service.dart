import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/views/business/business_home/model/valet_response.dart';
import 'package:valet_mobile_app/views/business/business_login/model/business_register_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valet_mobile_app/views/valet/valet_create_ticket/model/valet_create_ticket_request.dart';
import 'package:valet_mobile_app/views/valet/valet_login/model/valet_login_request.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_models.dart';
import 'dart:convert';

import '../views/valet/valet_login/model/valet_register_model.dart';
import 'dart:io';

// Sabitler
const String CREDENTIALS_KEY = 'auth_credentials';
const String USER_KEY = 'user_data';

class ApiService {
  static late dio.Dio _dio;

  static void initializeInterceptors() {
    final baseUrl = Platform.isIOS
        ? 'http://192.168.1.2:8000/' // Bilgisayarınızın yerel IP adresi
        : 'http://127.0.0.1:8000/';

    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        print('REQUEST[${options.method}] => PATH: ${options.baseUrl}${options.path}');
        print('REQUEST HEADERS: ${options.headers}');
        print('REQUEST DATA: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        print('RESPONSE DATA: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
        print('ERROR DETAILS: ${error.error}');
        print('ERROR MESSAGE: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  // Error handling
  static void handleError(dynamic error) {
    if (error is dio.DioException) {
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
          Get.snackbar(
            'Error',
            'Connection timeout. Please check your internet connection.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          break;

        case dio.DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          String message = 'An error occurred';

          if (error.response?.data is Map) {
            message = error.response?.data['message'] ?? message;
          }

          switch (statusCode) {
            case 401:
              AuthController.to.logout();
              message = 'Unauthorized access. Please login again.';
              break;
            case 403:
              message = 'Access forbidden. You don\'t have permission.';
              break;
            case 404:
              message = 'Resource not found.';
              break;
            case 400:
              message = 'Invalid request. Please check your input.';
              break;
          }

          Get.snackbar(
            'Error',
            message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          break;

        default:
          Get.snackbar(
            'Error',
            'An unexpected error occurred.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
      }
    }
  }

  // Auth endpoints
  static Future<dio.Response> login(LoginRequest request) async {
    try {
      String basicAuth = 'Basic ' + base64Encode(utf8.encode('${request.email}:${request.password}'));

      final response = await _dio.post(
        '/api/businesses/login',
        options: dio.Options(
          headers: {
            'Authorization': basicAuth,
          },
        ),
      );

      print('Raw API Response: ${response.data}');
      return response;
    } catch (e) {
      print('API Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> registerBusiness(BusinessRegisterRequest request) async {
    try {
      return await _dio.post(
        'api/businesses/register',
        data: request.toJson(),
      );
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> registerValet(ValetRegisterRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final businessCredentials = prefs.getString('business_credentials');

      if (businessCredentials == null) {
        throw Exception('Business credentials not found. Please login first.');
      }

      final response = await _dio.post(
        '/api/valets/register',
        data: request.toJson(),
        options: dio.Options(
          headers: {
            'Authorization': businessCredentials,
          },
        ),
      );

      print('Valet Register Response: ${response.data}');
      return response;
    } catch (e) {
      print('Valet Register Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> forgotPassword(String email) async {
    try {
      return await _dio.post(
        'api/auth/forgot-password',
        data: {'email': email},
      );
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }

  // Ticket endpoints
  static Future<dio.Response> createTicket(TicketCreateRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      final requestData = request.toJson();
      print('Create Ticket - Request Data Type Check:');
      print('- ticket_id: ${requestData['ticket_id'].runtimeType}');
      print('- business_id: ${requestData['business_id'].runtimeType}');
      print('- valet_id: ${requestData['valet_id'].runtimeType}');
      print('Create Ticket - Full Request: $requestData');

      if (credentials == null) {
        throw Exception('Kimlik bilgileri bulunamadı');
      }

      final response = await _dio.post(
        'api/tickets/create',
        data: requestData,
        options: dio.Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': credentials,
          },
          validateStatus: (status) => status! < 600,
        ),
      );

      print('Create Ticket Response Status: ${response.statusCode}');
      print('Create Ticket Response Data: ${response.data}');

      if (response.statusCode == 500) {
        print('Server Error Details: ${response.data}');
        if (response.data is Map) {
          print('Error Detail: ${response.data['detail']}');
        }
        throw Exception('Sunucu hatası: ${response.data}');
      }

      return response;
    } catch (e) {
      if (e is dio.DioException) {
        print('DioError Response Data: ${e.response?.data}');
        if (e.response?.data is Map) {
          print('Error Detail: ${e.response?.data['detail']}');
        }
      }
      print('Create Ticket Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> getTickets() async {
    try {
      return await _dio.get(
        'api/tickets',
        options: dio.Options(headers: AuthController.to.authHeaders),
      );
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> getTicketById(String ticketId) async {
    try {
      return await _dio.get(
        'api/tickets/$ticketId',
        options: dio.Options(headers: AuthController.to.authHeaders),
      );
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> updateTicketStatus(String ticketId, String status) async {
    try {
      return await _dio.patch(
        'api/tickets/$ticketId/status',
        data: {'status': status},
        options: dio.Options(headers: AuthController.to.authHeaders),
      );
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> loginValet(
    ValetLoginRequest request,
    String credentials,
  ) async {
    try {
      print('Login Request - Email: ${request.email}'); // Debug
      print('Login Request - Credentials: $credentials'); // Debug

      final response = await _dio.post(
        '/api/valets/login',
        data: {'email': request.email, 'password': request.password},
        options: dio.Options(
          headers: {
            'Authorization': credentials,
          },
        ),
      );

      print('Valet Login Raw Response: ${response.data}'); // Tüm yanıtı görelim
      print('Response Status Code: ${response.statusCode}'); // Status kodu
      print('Response Headers: ${response.headers}'); // Headers

      if (response.statusCode == 200) {
        print('Creating BusinessUser with:'); // Debug
        print('- Email: ${request.email}');
        print('- Credentials: $credentials');
        print('- Business ID from response: ${response.data['business_id']}');
        print('- Valet ID from response: ${response.data['valet_id']}');

        // Business user oluştur
        final businessUser = BusinessUser(
          email: request.email,
          credentials: credentials,
          businessName: request.email.split('@')[0],
          phoneNumber: response.data['phone_number'] ?? '',
          businessId: response.data['business_id'] ?? 1,
          id: response.data['valet_id'] ?? 1,
        );

        print('Created BusinessUser: ${businessUser.toJson()}'); // Debug

        // SharedPreferences'a kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('business_credentials', credentials);
        await prefs.setString('business_user', jsonEncode(businessUser.toJson()));

        print('Saved to SharedPreferences:'); // Debug
        print('- Credentials: ${prefs.getString('business_credentials')}');
        print('- User Data: ${prefs.getString('business_user')}');

        // AuthController'ı güncelle
        AuthController.to.currentUser.value = businessUser;
        AuthController.to.isLoggedIn.value = true;

        print('Updated AuthController:'); // Debug
        print('- Current User: ${AuthController.to.currentUser.value?.toJson()}');
        print('- Is Logged In: ${AuthController.to.isLoggedIn.value}');
      }

      return response;
    } catch (e) {
      print('Valet Login Error: $e');
      print('Error Stack Trace: ${e is Error ? e.stackTrace : ''}');
      handleError(e);
      rethrow;
    }
  }

  static Future<List<ValetResponse>> getValets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Kimlik bilgileri bulunamadı');
      }

      final response = await _dio.get(
        'api/valets',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
          },
        ),
      );

      print('Get Valets Response: ${response.data}');

      if (response.data is List) {
        return (response.data as List).map<ValetResponse>((json) => ValetResponse.fromJson(json)).toList();
      }

      // Eğer data bir liste değilse ve data içinde bir liste varsa
      if (response.data is Map && response.data['data'] is List) {
        return (response.data['data'] as List).map<ValetResponse>((json) => ValetResponse.fromJson(json)).toList();
      }

      throw Exception('Beklenmeyen veri formatı');
    } catch (e) {
      print('Get Valets Error: $e');
      handleError(e);
      rethrow;
    }
  }
}
