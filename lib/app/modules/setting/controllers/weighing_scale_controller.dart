import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:get/get.dart';

class WeighingScaleController extends GetxController {
  static WeighingScaleController get to => Get.find();

  RxString serialPort = Preferences.wingScale.obs;
  RxList<String> availablePorts = <String>[].obs;

  void onChangeSerialPort(dynamic value) {
    if (value != null) {
      if (value is DropDownValueModel) {
        Preferences.wingScale = value.name;
        serialPort.value = value.name;
      }
    }
  }
}
