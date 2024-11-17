import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_models.dart';

class ApiService {
  static final _dio = dio.Dio(dio.BaseOptions(
    baseUrl: 'http://localhost:8000/', // Backend URL'i - değiştirilecek
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    contentType: 'application/json',
    validateStatus: (status) => status! < 500,
  ));

  // Initialize Dio interceptors
  static void initializeInterceptors() {
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (dio.DioException e, handler) {
        debugPrint('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        return handler.next(e);
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
      return await _dio.post(
        'api/${request.userType}s/login',
        options: dio.Options(
          headers: {
            'Authorization': 'Basic ${AuthController.to.getAuthHeader(request.email, request.password)}',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> verifyToken(String userType) async {
    try {
      return await _dio.get(
        'api/${userType}s/verify',
        options: dio.Options(headers: AuthController.to.authHeaders),
      );
    } catch (e) {
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
