import 'package:valet_mobile_app/api_service/api_service.dart';
import 'package:valet_mobile_app/views/business/business_login/model/business_register_request.dart';

class BusinessRegisterController {
  Future<Map<String, dynamic>> register({
    required String email,
    required String phoneNumber,
    required String businessName,
    required String password,
  }) async {
    try {
      final request = BusinessRegisterRequest(
        email: email,
        phoneNumber: phoneNumber,
        businessName: businessName,
        password: password,
      );

      final response = await ApiService.registerBusiness(request);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Kayıt işlemi başarıyla tamamlandı', 'data': response.data};
      } else {
        final errorMessage =
            response.data is Map ? response.data['message'] ?? 'Kayıt işlemi başarısız oldu' : 'Kayıt işlemi başarısız oldu';

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('Register Error: $e');
      return {
        'success': false,
        'message': 'Bir hata oluştu: $e',
      };
    }
  }
}
