import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/views/business/business_login/model/business_register_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valet_mobile_app/views/valet/valet_login/model/valet_login_request.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_models.dart';
import 'dart:convert';

import '../views/valet/valet_login/model/valet_register_model.dart';
import 'dart:io';

// Sabitler
const String CREDENTIALS_KEY = 'business_credentials';
const String USER_KEY = 'business_user';

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
  static Future<dio.Response> createTicket(Map<String, dynamic> ticketData) async {
    try {
      return await _dio.post(
        'api/tickets',
        data: ticketData,
        options: dio.Options(headers: AuthController.to.authHeaders),
      );
    } catch (e) {
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
      final response = await _dio.post(
        '/api/valets/login',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
          },
        ),
      );

      print('Valet Login Response: ${response.data}');
      return response;
    } catch (e) {
      print('Valet Login Error: $e');
      handleError(e);
      rethrow;
    }
  }
}
