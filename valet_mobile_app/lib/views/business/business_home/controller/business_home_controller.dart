import 'package:get/get.dart';
import 'package:valet_mobile_app/api_service/api_service.dart';

import '../model/valet_response.dart';

class BusinessHomeController extends GetxController {
  final valets = <ValetResponse>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchValets();
  }

  Future<void> fetchValets() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      valets.value = await ApiService.getValets();
    } catch (e) {
      errorMessage.value = 'Valet listesi alınamadı: $e';
      print('Fetch Valets Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
