import 'package:get/get.dart';

import '../controllers/online_order_controller.dart';

class OnlineOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnlineOrderController>(
      () => OnlineOrderController(),
    );
  }
}
