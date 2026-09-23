import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:get/get.dart';


class PrintersController extends GetxController {
  static PrintersController get to => Get.find();
  // printer List
  // RxList<Printer> availablePrinters = <Printer>[].obs;
  RxString counterPrinter = Preferences.counterPrinter.obs;
  RxString kitchenPrinter = Preferences.kitchenPrinter.obs;

    // text controller
  TextEditingController counterPrinterController = TextEditingController();
  TextEditingController kitchenPrinterController = TextEditingController();

  RxBool oloPrint = Preferences.isOloPrint.obs;
  RxBool oloCustomerPrint = Preferences.oloCustomerReceipt.obs;
  RxBool deliveryOrderPrint = Preferences.isDeliveryOrderPrint.obs;
  RxBool deliveryCustomerReceipt = Preferences.deliveryCustomerReceipt.obs;
  //pos side
  RxBool takeOutCustomerReceipt = Preferences.takeoutCustomerReceipt.obs;
  RxBool deliveryPOSCustomerReceipt =
      Preferences.deliveryPosCustomerReceipt.obs;
  RxBool skipPrint = Preferences.skipEmptyPrinter.obs;

  // Paper Width
  RxString selectedPaperWidth = Preferences.paperWidth.obs;
  List<String> paperWidth = ["80mm", "60mm"];
  void onChangeKitchenPrinter(dynamic value) {
    if (value != null) {
      if (value is DropDownValueModel) {
        Preferences.kitchenPrinter = value.name;
        kitchenPrinter.value = value.name;
      }
    }
  }

  void onChangeCounterPrinter(dynamic value) {
    if (value != null) {
      if (value is DropDownValueModel) {
        Preferences.counterPrinter = value.name;
        counterPrinter.value = value.name;
      }
    }
  }

  void onChangePaperWidth(dynamic value) {
    if (value != null) {
      if (value is DropDownValueModel) {
        Preferences.paperWidth = value.name;
        selectedPaperWidth.value = value.name;
      }
    }
  }

  // olo print
  void onOloPrint(bool value) {
    Preferences.isOloPrint = value;
    oloPrint.value = value;
    debugPrint("oloPrint: ${Preferences.isOloPrint}");
  }

  void onOloCustomerPrint(bool value) {
    Preferences.oloCustomerReceipt = value;
    oloCustomerPrint.value = value;
    debugPrint("oloCustomerPrint: ${Preferences.oloCustomerReceipt}");
  }

  // delivery order print
  void onDeliveryOrderPrint(bool value) {
    Preferences.isDeliveryOrderPrint = value;
    deliveryOrderPrint.value = value;
    debugPrint("deliveryOrderPrint: ${Preferences.isDeliveryOrderPrint}");
  }

  void onDeliveryCustomerOrderPrint(bool value) {
    Preferences.deliveryCustomerReceipt = value;
    deliveryCustomerReceipt.value = value;
    debugPrint(
      "deliveryCustomerReceipt: ${Preferences.deliveryCustomerReceipt}",
    );
  }

  //pos side
  void onTakeOutCustomerReceipt(bool value) {
    Preferences.takeoutCustomerReceipt = value;
    takeOutCustomerReceipt.value = value;
    debugPrint("takeOutCustomerReceipt: ${Preferences.takeoutCustomerReceipt}");
  }

  void onDeliveryPOSCustomerReceipt(bool value) {
    Preferences.deliveryPosCustomerReceipt = value;
    deliveryPOSCustomerReceipt.value = value;
    debugPrint(
      "deliveryPOSCustomerReceipt: ${Preferences.deliveryPosCustomerReceipt}",
    );
  }

  void onSkipPrint(bool value) {
    Preferences.skipEmptyPrinter = value;
    skipPrint.value = value;
    debugPrint("skipEmptyPrinter : ${Preferences.skipEmptyPrinter}");
  }

  void getPrinters() async {
    // availablePrinters.value = await Printing.listPrinters();
  }

  // void updatePrinter(String id, PrinterModel printer) async {
  //   try {
  //     PopupDialog.showLoadingDialog();
  //     await PrintersRepo.update(id, printer);
  //     ConfigController.to.getPrinters();
  //     PopupDialog.closeLoadingDialog();

  //     Get.back();
  //     // ConfigController.to.getPrinters();
  //   } catch (e) {
  //     // Handle error
  //   }
  // }

    @override
  void onInit() {
    counterPrinterController.text=Preferences.counterPrinter;
    kitchenPrinterController.text=Preferences.kitchenPrinter;
    counterPrinterController.addListener(() {
      onChangeCounterPrinter(counterPrinterController.text);
    });
    kitchenPrinterController.addListener(() {
      onChangeKitchenPrinter(kitchenPrinterController.text);
    });
    super.onInit();
  }

  //Printer Type
}
