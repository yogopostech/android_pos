import 'package:get/get.dart';

// import '../../moneries_response_table/controllers/table_reservations_controller.dart';
import '../controllers/moneris_response_table_controller.dart';

class MonerisResponseTableBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MonerisResponseTableController>(
      () => MonerisResponseTableController(),
    );
  }
}
