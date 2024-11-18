import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/views/business/business_login/model/business_register_request.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_models.dart';
import 'dart:convert';

class ApiService {
  static late dio.Dio _dio;

  static void initializeInterceptors() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: 'http://127.0.0.1:8000',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        print('REQUEST[${options.method}] => PATH: ${options.path}');
        print('REQUEST HEADERS: ${options.headers}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        print('RESPONSE DATA: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
        print('ERROR DATA: ${error.response?.data}');
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
      return await _dio.post(
        'api/valets/register',
        data: request.toJson(),
        options: dio.Options(headers: AuthController.to.authHeaders),
      );
    } catch (e) {
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
}
