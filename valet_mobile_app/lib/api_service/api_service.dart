import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/views/business/business_home/model/valet_response.dart';
import 'package:valet_mobile_app/views/business/business_login/model/business_register_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valet_mobile_app/views/business/devices/model/device_model.dart';
import 'package:valet_mobile_app/views/valet/valet_create_ticket/model/valet_create_ticket_request.dart';
import 'package:valet_mobile_app/views/valet/valet_login/model/valet_login_request.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_models.dart';
import 'dart:convert';

import '../views/valet/valet_login/model/valet_register_model.dart';
import 'dart:io';
import '../views/valet/valet_complete_ticket/model/valet_complete_ticket_model.dart';
import 'package:http_parser/http_parser.dart';

// Sabitler
const String CREDENTIALS_KEY = 'auth_credentials';
const String USER_KEY = 'user_data';

class ApiService {
  static var _dio = dio.Dio(dio.BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/',
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
  ));

  static void initializeInterceptors() {
    final baseUrl = 'http://127.0.0.1:8000/';

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
        throw Exception('Authentication credentials not found');
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
        throw Exception('Server error: ${response.data}');
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

  static Future<dio.Response> updateTicketStatus(ValetCompleteTicketModel ticket) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      print('Update Ticket Request Data: ${ticket.toJson()}');

      final response = await _dio.put(
        'api/tickets/update',
        data: {
          'ticket_id': ticket.ticketId,
          'note': ticket.note,
          'parking_spot': ticket.parkingSpot,
          'damage': ticket.damage,
          'license_plate': ticket.licensePlate,
          'brand': ticket.brand,
          'color': ticket.color,
        },
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Update Ticket Status Response: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Ticket update failed: ${response.statusCode}');
      }

      return response;
    } on dio.DioException catch (e) {
      print('Update Ticket Status DioError: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Update Ticket Status Error: $e');
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
        throw Exception('Authentication credentials not found');
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

      throw Exception('Unexpected data format');
    } catch (e) {
      print('Get Valets Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> updateTicket(ValetCompleteTicketModel ticket) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      print('Update Ticket Request Data: ${ticket.toJson()}'); // Debug log

      final response = await _dio.put(
        'api/tickets/${ticket.ticketId}',
        data: ticket.toJson(),
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 600,
        ),
      );

      print('Update Ticket Response Status: ${response.statusCode}');
      print('Update Ticket Response Data: ${response.data}');

      if (response.statusCode == 500) {
        print('Server Error Details: ${response.data}');
        if (response.data is Map) {
          print('Error Detail: ${response.data['detail']}');
        }
        throw Exception('Server error: ${response.data}');
      }

      return response;
    } catch (e) {
      if (e is dio.DioException) {
        print('DioError Response Data: ${e.response?.data}');
        if (e.response?.data is Map) {
          print('Error Detail: ${e.response?.data['detail']}');
        }
      }
      print('Update Ticket Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> uploadImageToAI(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(imageFile.path),
      });

      print('Uploading image to AI...');

      final response = await _dio.post(
        'api/AI',
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(minutes: 2),
          responseType: dio.ResponseType.json,
        ),
      );

      print('AI Upload Response: ${response.data}');

      if (response.statusCode == 200 && response.data['results'] != null) {
        final results = response.data['results'];
        return dio.Response(
          data: {
            'license_plate': results['plate'],
            'brand': results['features']['brand'],
            'color': results['features']['color'],
          },
          statusCode: 200,
          requestOptions: response.requestOptions,
        );
      }

      print('AI Response Format: ${response.data}');
      throw Exception('Unexpected response format');
    } catch (e) {
      print('AI Upload Error: $e');
      rethrow;
    }
  }

  static Future<List<dynamic>> getOpenTickets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/tickets/open',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Open Tickets Response: ${response.data}');

      if (response.statusCode == 200) {
        // Sadece progress_status = 1 olan biletleri filtrele
        final tickets = response.data as List<dynamic>;
        return tickets.where((ticket) => ticket['progress_status'] == 1).toList();
      } else {
        throw Exception('Failed to get open tickets: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Open Tickets Error: $e');
      rethrow;
    }
  }

  static Future<dio.Response> createDevice(DeviceCreateRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.post(
        'api/devices',
        data: request.toJson(),
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Create Device Response: ${response.data}');
      return response;
    } catch (e) {
      print('Create Device Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<List<Device>> getDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/devices',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Get Devices Response: ${response.data}');

      if (response.data is List) {
        return (response.data as List).map<Device>((json) => Device.fromJson(json)).toList();
      } else if (response.data is Map && response.data['data'] is List) {
        return (response.data['data'] as List).map<Device>((json) => Device.fromJson(json)).toList();
      }

      throw Exception('Unexpected data format');
    } catch (e) {
      print('Get Devices Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> assignDevice(int deviceId, int valetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.put(
        'api/devices/assign',
        data: {
          'device_id': deviceId,
          'valet_id': valetId,
        },
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Assign Device Response: ${response.data}');
      return response;
    } catch (e) {
      print('Assign Device Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> unassignDevice(int deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.put(
        'api/devices/unassign?device_id=$deviceId',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Unassign Device Raw Response: ${response.data}');
      print('Unassign Device Status Code: ${response.statusCode}');

      if (response.statusCode == 422) {
        print('Validation Error Details: ${response.data}');
        throw Exception('API Validation Error: ${response.data}');
      }

      return response;
    } catch (e) {
      print('Unassign Device Detailed Error: $e');
      if (e is dio.DioException) {
        print('Response Data: ${e.response?.data}');
      }
      handleError(e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getValetById(int valetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/valets/$valetId',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Get Valet Response: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get valet information');
      }
    } catch (e) {
      print('Get Valet Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> logoutValet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('valet_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.post(
        'api/valets/logout',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Valet Logout Response: ${response.data}');
      return response;
    } catch (e) {
      print('Valet Logout Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> checkoutTicket(int ticketId, int valetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.put(
        'api/tickets/checkout',
        queryParameters: {
          'ticket_id': ticketId,
          'valet_id': valetId,
        },
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Ticket checkout operation failed: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      print('Checkout Ticket Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<List<dynamic>> getClosedTickets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/tickets/closed',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Closed Tickets Response: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to get closed tickets: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Closed Tickets Error: $e');
      rethrow;
    }
  }

  static Future<dio.Response> deliverCar(int ticketId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.put(
        'api/tickets/deliver_car',
        queryParameters: {
          'ticket_id': ticketId,
        },
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Car delivery operation failed: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      print('Deliver Car Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> createPayment({
    required double amount,
    required String paymentMethod,
    required double tip,
    required int ticketId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.post(
        'api/payments',
        data: {
          'amount': amount,
          'payment_method': paymentMethod,
          'tip': tip,
          'ticket_id': ticketId,
        },
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Create Payment Response: ${response.data}');

      // 201 ve 200 durumlarını başarılı kabul et
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Payment failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Create Payment Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<List<dynamic>> getTickets({
    String? startDate,
    String? endDate,
    int? progressStatus,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      // Query parametrelerini oluştur
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };

      // Opsiyonel parametreleri ekle
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (progressStatus != null) queryParams['progress_status'] = progressStatus;

      final response = await _dio.get(
        'api/tickets',
        queryParameters: queryParams,
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Get Tickets Response: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to get tickets: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Tickets Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getCarDetails(int carId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/cars/$carId',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Get Car Details Response: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get vehicle information: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Car Details Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getTicketById(int ticketId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/tickets/$ticketId',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Get Ticket By ID Response: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get ticket information: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Ticket By ID Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getParkingSpots() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('valet_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/parking-spots',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Parking Spots Response: ${response.data}');

      if (response.statusCode == 200) {
        final availableSpots = List<int>.from(response.data);

        // Create full spots list (1-60)
        final allSpots = List.generate(
            60,
            (index) => {
                  'spot': index + 1,
                  'isOccupied': !availableSpots.contains(index + 1), // If not in available list, it means occupied
                });

        return allSpots;
      } else {
        throw Exception('Failed to get parking spots: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Parking Spots Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getPaymentByTicketId(int ticketId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/payments/$ticketId',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Get Payment Response: ${response.data}');

      // 404 durumunda null dön
      if (response.statusCode == 404) {
        return null;
      }

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get payment: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Payment Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<List<dynamic>> getDeviceLogs(int deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/devices/$deviceId/logs',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Get Device Logs Response: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to get device logs: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Device Logs Error: $e');
      handleError(e);
      rethrow;
    }
  }
}
