import 'package:get/get.dart';


class OrdersController extends GetxController {
  static OrdersController get to => Get.find();

  bool isLoadingOrders = false;
  String? selectedCounterPrinter;
  void updateSelectedCounterPrinter(String value) {
    selectedCounterPrinter = value;
    update();
  }

  String? selectedKitchenPrinter;
  void updateSelectedKitchenPrinter(String value) {
    selectedKitchenPrinter = value;
    update();
  }
}
