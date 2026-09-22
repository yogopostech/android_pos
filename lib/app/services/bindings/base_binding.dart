import 'package:yogo_pos/app/services/base/api_service.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:get/get.dart';

class BaseBinding extends Bindings {
  final ApiService apiService;

  BaseBinding({required this.apiService});

  @override
  void dependencies() {
    Get.put(BaseController(apiService: apiService), permanent: true);
    Get.put(ConfigController(), permanent: true);
   
    // Get.put(PosController(), permanent: true);
  }
}
