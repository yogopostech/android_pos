import 'package:get/get.dart';

import '../controllers/table_reservations_controller.dart';

class TableReservationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TableReservationsController>(
      () => TableReservationsController(),
    );
  }
}
