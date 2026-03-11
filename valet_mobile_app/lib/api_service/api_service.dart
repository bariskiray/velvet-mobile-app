import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;
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
  // Platform'a göre doğru URL'yi belirle
  static String getBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/'; // Android emülatör
    } else if (Platform.isIOS) {
      return 'http://localhost:8000/'; // iOS simülatör
    } else {
      return 'http://localhost:8000/'; // Diğer platformlar
    }
  }

  static var _dio = dio.Dio(dio.BaseOptions(
    baseUrl: getBaseUrl(),
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
  ));

  static void initializeInterceptors() {
    final baseUrl = getBaseUrl();
    print('API Base URL: $baseUrl (${Platform.isAndroid ? "Android" : Platform.isIOS ? "iOS" : "Diğer"})');

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
  static Future<dio.Response> login(LoginRequest request, {String scope = ''}) async {
    try {
      // OAuth2 standartlarına uygun olarak parametreleri Map olarak oluştur
      final Map<String, String> params = {
        'username': request.email, // username aslında email
        'password': request.password,
        'grant_type': 'password',
        'scope': scope, // business veya valet değeri gelecek
      };

      // Dio ile direkt olarak form verilerini gönderelim
      print('Login params: $params');

      // JWT token almak için /api/token endpoint'ine istek at
      final response = await _dio.post(
        '/api/token',
        data: params,
        options: dio.Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            'Accept': 'application/json',
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
          'damage': ticket.damage,
          'license_plate': ticket.licensePlate,
          'brand': ticket.brand,
          'color': ticket.color,
          'latitude': ticket.latitude,
          'longitude': ticket.longitude,
          'parking_location_id': ticket.parkingLocationId,
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
      print('====== API SERVICE - VALET LOGIN ======');
      print('Login Request - Email: ${request.email}'); // Debug

      // OAuth2 standartlarına uygun olarak parametreleri Map olarak oluştur
      final Map<String, String> params = {
        'username': request.email, // username aslında email
        'password': request.password,
        'grant_type': 'password',
        'scope': 'valet', // Vale için scope değeri
      };

      // FCM token varsa, parametrelere ekle
      if (request.fcmToken != null) {
        params['fcm_token'] = request.fcmToken!;
      }

      // Dio ile direkt olarak form verilerini gönderelim
      print('Login params: $params');

      // JWT token almak için /api/token endpoint'ine istek at
      final response = await _dio.post(
        '/api/token',
        data: params,
        options: dio.Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      print('Valet Login Raw Response: ${response.data}'); // Tüm yanıtı görelim
      print('Response Status Code: ${response.statusCode}'); // Status kodu
      print('Response Headers: ${response.headers}'); // Headers

      if (response.statusCode == 200) {
        // JWT token'ı al ve Bearer formatında kaydet
        final accessToken = response.data['access_token'];
        final jwtCredential = 'Bearer $accessToken';

        // Business user oluştur
        final businessUser = BusinessUser(
          email: request.email,
          credentials: jwtCredential,
          businessName: request.email.split('@')[0],
          phoneNumber: '',
          businessId: 1, // Varsayılan değer
          id: 1, // Varsayılan değer
        );

        print('Created BusinessUser: ${businessUser.toJson()}'); // Debug

        // SharedPreferences'a kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('business_credentials', jwtCredential);
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

  static Future<List<ValetResponse>> getValets({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/valets',
        queryParameters: {
          'page': page,
          'size': size,
        },
        options: dio.Options(
          headers: {
            'Authorization': credentials,
          },
        ),
      );

      print('Get Valets Response: ${response.data}');

      // Check for new format with items key
      if (response.data is Map && response.data['items'] is List) {
        return (response.data['items'] as List).map<ValetResponse>((json) => ValetResponse.fromJson(json)).toList();
      }
      // Check for old format with direct list
      else if (response.data is List) {
        return (response.data as List).map<ValetResponse>((json) => ValetResponse.fromJson(json)).toList();
      }
      // Check for format with data key
      else if (response.data is Map && response.data['data'] is List) {
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

  static Future<List<Device>> getDevices({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/devices',
        queryParameters: {
          'page': page,
          'size': size,
        },
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Get Devices Response: ${response.data}');

      // Check for new format with items key
      if (response.data is Map && response.data['items'] is List) {
        return (response.data['items'] as List).map<Device>((json) => Device.fromJson(json)).toList();
      }
      // Check for old format with direct list
      else if (response.data is List) {
        return (response.data as List).map<Device>((json) => Device.fromJson(json)).toList();
      }
      // Check for format with data key
      else if (response.data is Map && response.data['data'] is List) {
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

  static Future<dio.Response> checkoutTicket(int ticketId, {int? valetId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      // Build query parameters, handling null values correctly
      final Map<String, dynamic> queryParams = {
        'ticket_id': ticketId,
      };

      // Only add valet_id to the query params if it's not null
      // This will make the backend use auto selection
      if (valetId != null) {
        queryParams['valet_id'] = valetId;
      }

      final response = await _dio.put(
        'api/tickets/checkout',
        queryParameters: queryParams,
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
    int page = 1,
    int size = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      // Query parametrelerini oluştur
      final Map<String, dynamic> queryParams = {
        'page': page,
        'size': size,
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
        // API artık {items: [...]} formatında yanıt veriyor
        if (response.data is Map && response.data['items'] is List) {
          return response.data['items'] as List<dynamic>;
        }
        // Eski format için geriye dönük uyumluluk
        else if (response.data is List) {
          return response.data as List<dynamic>;
        } else {
          throw Exception('Unexpected response format: ${response.data}');
        }
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
      var credentials = prefs.getString('valet_credentials');

      // Valet credentials yoksa business credentials kullan
      if (credentials == null) {
        credentials = prefs.getString('business_credentials');
      }

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
        return List<Map<String, dynamic>>.from(response.data);
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

  static Future<Map<String, dynamic>> getDeviceLogs(
    int deviceId, {
    int page = 1,
    int size = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/devices/$deviceId/logs',
        queryParameters: {
          'page': page,
          'size': size,
        },
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Get Device Logs Response: ${response.data}');

      if (response.statusCode == 200) {
        // Check for new format with items and pagination keys
        if (response.data is Map && response.data['items'] is List) {
          return {
            'items': response.data['items'] as List<dynamic>,
            'pagination': response.data['pagination'] ??
                {
                  'total': (response.data['items'] as List).length,
                  'page': page,
                  'size': size,
                  'pages': 1,
                },
          };
        }
        // Check for old format with direct list - create pagination info
        else if (response.data is List) {
          final items = response.data as List<dynamic>;
          return {
            'items': items,
            'pagination': {
              'total': items.length,
              'page': page,
              'size': size,
              'pages': items.length < size ? page : page + 1,
            },
          };
        }
        // Check for format with data key
        else if (response.data is Map && response.data['data'] is List) {
          final items = response.data['data'] as List<dynamic>;
          return {
            'items': items,
            'pagination': response.data['pagination'] ??
                {
                  'total': items.length,
                  'page': page,
                  'size': size,
                  'pages': items.length < size ? page : page + 1,
                },
          };
        } else {
          throw Exception('Unexpected response format: ${response.data}');
        }
      } else {
        throw Exception('Failed to get device logs: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Device Logs Error: $e');
      handleError(e);
      rethrow;
    }
  }

  // İstatistik endpointleri
  static Future<int> getDailyVisits(String date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/statistics/daily-visits',
        queryParameters: {
          'date': date,
        },
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Daily Visits Response: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as int;
      } else {
        throw Exception('Failed to get daily visits: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Daily Visits Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<List<int>> getPeakHours() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/statistics/peak-hours',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Peak Hours Response: ${response.data}');

      if (response.statusCode == 200) {
        return List<int>.from(response.data);
      } else {
        throw Exception('Failed to get peak hours: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Peak Hours Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<List<String>> getPeakDays() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/statistics/peak-days',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Peak Days Response: ${response.data}');

      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      } else {
        throw Exception('Failed to get peak days: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Peak Days Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<double> getMoneyGained(String startDate, String endDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/statistics/money-gained',
        queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
        },
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Money Gained Response: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as double;
      } else {
        throw Exception('Failed to get money gained: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Money Gained Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<Map<String, int>> getVisitCountByHours() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/statistics/visit-count-by-hours',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Visit Count By Hours Response: ${response.data}');

      if (response.statusCode == 200) {
        // API bir liste döndürüyor (her indeks bir saati temsil ediyor)
        if (response.data is List) {
          final List<dynamic> hoursList = response.data;
          final Map<String, int> hourlyVisits = {};

          // Listedeki her elemanı saat:ziyaret_sayısı formatında map'e dönüştür
          for (int i = 0; i < hoursList.length; i++) {
            hourlyVisits[i.toString()] = hoursList[i] as int;
          }
          return hourlyVisits;
        }
        // Eğer API formatı değişirse ve bir Map dönerse
        else if (response.data is Map) {
          final Map<String, dynamic> data = response.data;
          final Map<String, int> hourlyVisits = Map<String, int>.from(data.map(
            (key, value) => MapEntry(key, value as int),
          ));
          return hourlyVisits;
        }

        throw Exception('Beklenmeyen yanıt formatı: visit-count-by-hours');
      } else {
        throw Exception('Failed to get visit count by hours: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Visit Count By Hours Error: $e');
      handleError(e);
      rethrow;
    }
  }

  // Park yeri endpoint'leri
  static Future<Map<String, dynamic>> getParkingLocations({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/parking-locations',
        queryParameters: {
          'page': page,
          'size': size,
        },
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Get Parking Locations Response: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> rawList;
        Map<String, dynamic> paginationInfo = {};

        // Check for new format with items key
        if (response.data is Map && response.data['items'] is List) {
          rawList = response.data['items'] as List<dynamic>;
          // Pagination bilgisini al
          paginationInfo = {
            'total': response.data['total'] ?? 0,
            'page': response.data['page'] ?? page,
            'size': response.data['size'] ?? size,
            'pages': response.data['pages'] ?? 1,
          };
        }
        // Check for old format with direct list
        else if (response.data is List) {
          rawList = response.data as List<dynamic>;
          // Eski format için pagination bilgisi yok
          paginationInfo = {
            'total': rawList.length,
            'page': page,
            'size': size,
            'pages': 1,
          };
        }
        // Check for format with data key
        else if (response.data is Map && response.data['data'] is List) {
          rawList = response.data['data'] as List<dynamic>;
          // Data format için pagination bilgisi kontrol et
          paginationInfo = {
            'total': response.data['total'] ?? rawList.length,
            'page': response.data['page'] ?? page,
            'size': response.data['size'] ?? size,
            'pages': response.data['pages'] ?? 1,
          };
        } else {
          throw Exception('Unexpected response format: ${response.data}');
        }

        // Her bir öğeyi dönüştürürken alanları düzelt
        final processedList = rawList.map((item) {
          final Map<String, dynamic> spot = item as Map<String, dynamic>;

          // API'nin döndüğü parking_location_id'yi, id olarak da ekleyelim
          // Böylece controller'da hem id hem de parking_location_id ile çalışabilecek
          if (spot.containsKey('parking_location_id') && !spot.containsKey('id')) {
            spot['id'] = spot['parking_location_id'];
          }

          // Debug: ID dönüşümünü kontrol et
          print('Park yeri dönüştürüldü: ${spot['name']} - ID: ${spot['id']}, Location ID: ${spot['parking_location_id']}');

          return spot;
        }).toList();

        // Hem veri hem de pagination bilgisini döndür
        return {
          'items': processedList,
          'pagination': paginationInfo,
        };
      } else {
        throw Exception('Failed to get parking locations: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Parking Locations Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> createParkingLocation({
    required String name,
    required double latitude,
    required double longitude,
    bool is_empty = true,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.post(
        'api/parking-locations',
        data: {
          'name': name,
          'latitude': latitude,
          'longitude': longitude,
          'is_empty': is_empty,
        },
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Create Parking Location Response: ${response.data}');
      return response;
    } catch (e) {
      print('Create Parking Location Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getParkingLocationById(int locationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('valet_credentials') ?? prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/parking-locations/$locationId',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get parking location details');
      }
    } catch (e) {
      print('Get Parking Location Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> updateParkingLocation({
    required int locationId,
    required String name,
    required double latitude,
    required double longitude,
    required bool is_empty,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      print('Park yeri güncelleme bilgileri:');
      print('- Location ID: $locationId (URL\'de kullanılacak)');
      print('- Name: $name');
      print('- Latitude: $latitude');
      print('- Longitude: $longitude');
      print('- Is Empty: $is_empty');

      final response = await _dio.put(
        'api/parking-locations/$locationId',
        data: {
          'name': name,
          'is_empty': is_empty,
          'latitude': latitude,
          'longitude': longitude,
        },
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Update Parking Location Response: ${response.data}');
      return response;
    } catch (e) {
      print('Update Parking Location Error: $e');
      handleError(e);
      rethrow;
    }
  }

  static Future<dio.Response> deleteParkingLocation(int locationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('business_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.delete(
        'api/parking-locations/$locationId',
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Delete Parking Location Response: ${response.data}');
      return response;
    } catch (e) {
      print('Delete Parking Location Error: $e');
      handleError(e);
      rethrow;
    }
  }

  // En yakın park yerini bul
  static Future<Map<String, dynamic>> getClosestParkingSpot({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('valet_credentials');

      if (credentials == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await _dio.get(
        'api/parking-spots/closest',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
        options: dio.Options(
          headers: {
            'Authorization': credentials,
            'Accept': 'application/json',
          },
        ),
      );

      print('Get Closest Parking Spot Response: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get closest parking spot: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Closest Parking Spot Error: $e');
      handleError(e);
      rethrow;
    }
  }
}
