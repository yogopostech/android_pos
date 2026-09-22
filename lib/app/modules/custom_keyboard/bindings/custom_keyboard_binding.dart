import 'package:get/get.dart';

import '../controllers/custom_keyboard_controller.dart';

class CustomKeyboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomKeyboardController>(
      () => CustomKeyboardController(),
    );
  }
}
