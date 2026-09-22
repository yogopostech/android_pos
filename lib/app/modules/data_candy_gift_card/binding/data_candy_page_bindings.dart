import 'package:get/get.dart';
import '../controller/data_candy_active_reload_controller.dart';

class DataCandyPageBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<DataCandyActiveAndReloadController>(()=>DataCandyActiveAndReloadController());
  }

}