import 'package:get/get.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';

class GeneralController extends GetxController {
  static GeneralController get to => Get.find();

  bool isNotificationSound = Preferences.isNotificationSound;
  bool isCustomKeyboard = Preferences.customKeyboard;
  bool isKeyboardSound = Preferences.keyboardSound;

  onChangeNotificationSound(bool value) {
    isNotificationSound = value;
    Preferences.isNotificationSound = value;
    BaseController.to.update();
    update();
  }

  onChangeCustomKeyboard(bool value) {
    isCustomKeyboard = value;
    Preferences.customKeyboard = value;
    update();
  }
  onChangeKeyboardSound(bool value) {
    isKeyboardSound = value;
    Preferences.keyboardSound = value;
    update();
  }
}
