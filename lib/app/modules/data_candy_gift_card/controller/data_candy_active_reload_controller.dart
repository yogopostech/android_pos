import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/models/card_activate_model.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/models/increment_balance_model.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/print_receipt/esc_card_activate_receipt.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/print_receipt/esc_data_candy_increment_receipt.dart';
import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import '../../../services/base/base_model.dart';
import '../../../services/controller/base_controller.dart';
import '../../../utils/logger.dart';
import '../../../utils/urls.dart';
import '../../pos/controllers/pos_controller.dart';
import '../../pos/dine-in/repo/datacandy_payment_repo.dart';
import '../../pos/order/models/order_model.dart';

class DataCandyActiveAndReloadController extends GetxController {
  static DataCandyActiveAndReloadController get to => Get.find();
  final GlobalKey<FormState> amountFormKey = GlobalKey<FormState>();

  TextEditingController cardController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  String? selectedCardType;
  List<String> cardList = [
    "VISA",
    "MASTERCARD",
    "AMEX",
    "DEBIT_CARD",
    "CASH",
  ];
  var isLoading = false.obs;
  String capitalizeEachErrorWord(String text) {
    if (text.isEmpty) return text;

    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      // Find first alphabetic character
      int index = word.indexOf(RegExp(r'[A-Za-z]'));
      if (index == -1) return word; // No letters, return as is
      return word.substring(0, index) +
          word[index].toUpperCase() +
          word.substring(index + 1).toLowerCase();
    }).join(' ');
  }

  String capitalizeEachWord(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  Map<String, String> parseErrorText(String text) {
    if (text.isEmpty) return {'code': '', 'message': ''};

    // Split at the first colon (:)
    final parts = text.split(':');
    final code = parts.isNotEmpty ? parts.first.trim() : '';
    final message = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

    // Capitalize each word of the message
    String capitalizeEachWord(String text) {
      if (text.isEmpty) return text;
      return text.split(' ').map((word) {
        if (word.isEmpty) return '';
        int index = word.indexOf(RegExp(r'[A-Za-z]'));
        if (index == -1) return word;
        return word.substring(0, index) +
            word[index].toUpperCase() +
            word.substring(index + 1).toLowerCase();
      }).join(' ');
    }

    return {
      'code': code,
      'message': capitalizeEachWord(message),
    };
  }

  final List<int> values = List.generate(20, (index) => (index + 1) * 5);

  Future<bool> activeCard(
      {required PaymentModel payment, bool isPrint = false}) async {
    try {
      Map<String, dynamic> body = {
        "CID": cardController.text.replaceAll("-", "").trim(),
        "payment": payment.toJson(),
      };
      PopupDialog.showLoadingDialog();
      BaseModel response = await BaseController.to.apiService.makePostRequest(
        URLS.cardActivate,
        body,
      );
      selectedCardType = null;
      cardController.clear();
      amountController.clear();
      PopupDialog.closeLoadingDialog();

      if (response.statusCode == 200) {
        debugPrint(response.data.toString());

        Get.back();
        update();

        showAnimatedSuccessDialog(Get.context!, title: "Card Activated!");
        OrderModel orderData =
            OrderModel.fromJson(response.data["data"]["orderResult"]);
        PosController.to.myOrder = orderData;
        PosController.to.update();
        DataCandyActiveCardModel dataCandy = DataCandyActiveCardModel.fromJson(
            response.data["data"]["dataCandy"]);
        // todo:print
        if (isPrint) {
          PrintUtils().directPrint(
              data: escDataCandyCardActivateReceipt(
                  cardActivate: dataCandy,
                  server: orderData.employee?.firstName),
              printer: Preferences.counterPrinter);
        }
        return true;
      } else {
        final result = parseErrorText(response.data["message"]);
        Get.back();
        selectedCardType = null;
        showAnimatedErrorDialog(Get.context!,
            title: "Error ${result['code']} : ${result['message']}");
        return false;
      }
    } catch (e) {
      Get.back();
      showAnimatedErrorDialog(Get.context!, title: e.toString());
      kLogger.e(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> reloadCard(
      {required PaymentModel payment, bool isPrint = false}) async {
    try {
      Map<String, dynamic> body = {
        "CID": cardController.text.replaceAll("-", "").trim(),
        "payment": payment.toJson(),
      };
      PopupDialog.showLoadingDialog();
      BaseModel response = await BaseController.to.apiService.makePostRequest(
        URLS.reloadCard,
        body,
      );
      selectedCardType = null;
      cardController.clear();
      amountController.clear();
      PopupDialog.closeLoadingDialog();

      if (response.statusCode == 200) {
        Get.back();
        update();

        debugPrint(response.data.toString());

        // show success popup safely
        // showAnimatedSuccessDialog(Get.context!,title: "Card Reloaded!",message: capitalizeEachWord(response.data["message"]));
        showAnimatedSuccessDialog(Get.context!, title: "Card Reloaded!");

        OrderModel orderData =
            OrderModel.fromJson(response.data["data"]["orderResult"]);
        PosController.to.myOrder = orderData;
        PosController.to.update();
        DataCandyCardReloadModel dataCandy = DataCandyCardReloadModel.fromJson(
            response.data["data"]["dataCandy"]);

        kLogger.e("shetu ${dataCandy.toJson()}");
        if (isPrint) {
          // todo:print
          PrintUtils().directPrint(
            data: escDataCandyIncrementReceipt(
                data: dataCandy, server: orderData.employee?.firstName),
            printer: Preferences.counterPrinter,
          );
        }
        return true;
      } else {
        final result = parseErrorText(response.data["message"]);
        Get.back();
        selectedCardType = null;
        showAnimatedErrorDialog(Get.context!,
            title: "Error ${result['code']} : ${result['message']}");
        return false;
      }
    } catch (e) {
      Get.back();
      showAnimatedErrorDialog(Get.context!, title: e.toString());
      kLogger.e(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
