import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/models/all_card_data_candy_model.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/models/cancel_transaction_model.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/models/check_balance_model.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/print_receipt/esc_data_candy_balance_check_receipt.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/models/meta_model.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/repo/datacandy_payment_repo.dart';
import 'package:yogo_pos/app/services/base/base_model.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/custom_Btn.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

import '../../../widgets/my_custom_text.dart';
import '../models/card_activate_model.dart';
import '../models/increment_balance_model.dart';
import '../models/redeem_balance_model.dart';


enum CheckBalanceResultType { success, needActivation, notFound, error }
class GiftCardController extends GetxController {

  var incrementBalanceModel = Rxn<ReloadModelDataCandy>();
  var checkBalanceModel = Rxn<CheckBalanceModelDataCandy>();
  var redeemBalanceModel = Rxn<RedeemResponse>();
  var cancelTransactionModel = Rxn<CancelTransactionModelDataCandy>();
  var cardActivateModel = Rxn<CardActivationResponse>();
  final formKey = GlobalKey<FormState>();
  final searchFormKey = GlobalKey<FormState>();
  MetaModel? metaModel;


  TextEditingController cardController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController amountCustomController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController invoiceController = TextEditingController();
  TextEditingController tcnController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  void textControllerRemove(){
    cardController.clear();
    amountController.clear();
    searchController.clear();
    tcnController.clear();
    invoiceController.clear();
  }
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  String capitalizeEachWord(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) =>
    word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : '')
        .join(' ');
  }

  var isLoading = false.obs;
  String tcnIncrement="";
  String invoiceIncrement = "";
  // @override
  // void onInit() {
  //   super.onInit();
  //   // fetchGiftCards();
  // }

  Future<void> showAnimatedErrorDialog(BuildContext context,
      {String? title, String? message, bool autoDismiss = true}) async {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) =>  AnimatedMessageDialog(
        height: 350,
        width: 750,
        title:title ?? "Payment Failed!",
        // message: message ?? "Something went wrong while processing your payment.",
        type: DialogType.error,
      ),
    );
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
      return text
          .split(' ')
          .map((word) {
        if (word.isEmpty) return '';
        int index = word.indexOf(RegExp(r'[A-Za-z]'));
        if (index == -1) return word;
        return word.substring(0, index) +
            word[index].toUpperCase() +
            word.substring(index + 1).toLowerCase();
      })
          .join(' ');
    }

    return {
      'code': code,
      'message': capitalizeEachWord(message),
    };
  }
  // /// Random invoice number generate
  //  String _generateInvoice6Digists() {
  //    final rand = Random();
  //    return (100000 + rand.nextInt(900000)).toString(); // 100000–999999
  // }
  // String _generateInvoice() {
  //   final rand = Random();
  //   return (1000 + rand.nextInt(9000)).toString(); // 1000–9999
  // }

  /// 1st API Call




  Future<bool> checkBlance() async {
    try {
      Map<String, dynamic> queryParameters = {
        "WAN": "1",
        "WSN": "1",
        "CID": cardController.text.replaceAll("-", "").trim(),
      };
     PopupDialog.showLoadingDialog();
      BaseModel res = await BaseController.to.apiService
          .makeGetRequest(URLS.checkBlance, queryParameters: queryParameters);
      PopupDialog.closeLoadingDialog();


      if (res.statusCode == 200) {
        Get.back();
        checkBalanceModel.value = CheckBalanceModelDataCandy.fromJson(res.data);
        PopupDialog.customDialog2(
          // height:350,
          // borderColor: Theme.of(context).hintColor,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusGeometry.circular(6),
                  ),
                  child: MyCustomText(
                    "Gift Card Balance",
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
                SizedBox(height: 16,),
                // Divider(),
                SizedBox(
                  height: 40,
                ),
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment:  Alignment.center,
                        child: MyCustomText(
                          fontSize: 45,
                          "\$${(checkBalanceModel.value?.data?.balance == null)
                              ? "0.00"
                              : checkBalanceModel.value?.data?.balance?.toStringAsFixed(2)}",
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 55,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Print Check
                    PrimaryBtnWithChild(
                      onPressed: () async{
                          // todo:print
                        PrintUtils().directPrint(
                          data:  escDataCandyCheckBalanceReceipt(

                          ), printer: Preferences.counterPrinter,);
                        Get.back();
                        textControllerRemove();

                        PopupDialog.showSuccessDialog("Print success");

                      },
                      height: 70,
                      width: 200,
                      color: StaticColors.blueColor,
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.print,
                            color: Colors.white,
                            size: 25,
                          ).marginOnly(right: 12),
                          const FittedBox(
                            child: MyCustomText(
                              'Print',
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                        ],
                      ),
                    ).marginOnly(right: 50),
                    // No Print
                    PrimaryBtnWithChild(
                      onPressed: () {
                        Get.back();
                      },
                      height: 70,
                      width: 200,
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.do_disturb_alt,
                            size: 25,
                            color: Colors.white,
                          ).marginOnly(right: 12),
                          const FittedBox(
                            child: MyCustomText(
                              color: Colors.white,
                              'No Print',
                              fontSize: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
          width: 500,
          height: 470,
        );
        return true;

      }  else {
        Get.back();
        final result = parseErrorText(res.data["message"]);
        showAnimatedErrorDialog(Get.context!,title: "Error ${result['code']} : ${result['message']}");
        return false;
      }

    } catch (e) {
      showAnimatedErrorDialog(Get.context!,title: e.toString());
      // PopupDialog.showErrorMessage("Something went wrong. Try again.");
      return false;
    }
  }


  Future<bool> cancelTranSection() async {
    try {

      Map<String, dynamic> queryParameters = {
        "WSN": "1",
        "CID": cardController.text.replaceAll("-","").trim(),
        "AMT": amountController.text.trim(),
        "TCN": tcnController.text.trim(),
        "INV": invoiceController.text.trim()
      };
     PopupDialog.showLoadingDialog();
      BaseModel res = await BaseController.to.apiService.makePostRequest(
        URLS.cancelTransaction,
        null,
        queryParameters: queryParameters,
      );
      PopupDialog.closeLoadingDialog();
      // Get.back();
      if (res.statusCode == 200) {
        Get.back();
        showAnimatedSuccessDialog(Get.context!,title: "Transaction Canceled!");
        final result = CancelTransactionModelDataCandy.fromJson(res.data);
        cancelTransactionModel.value = result;
        // PopupDialog.showSuccessDialog(
        //     "Cancel Transaction Successful!");

       textControllerRemove();
        return true;
      } else {
       // textControllerRemove();
        final result = parseErrorText(res.data["message"]);
        // print(result['code']);     // 101
        // print(result['message']);
        showAnimatedErrorDialog(Get.context!,title: "Error ${result['code']} : ${result['message']}");
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      showAnimatedErrorDialog(Get.context!,title: e.toString());
      return false;
    }
  }


  var cards = <GiftCardModel>[].obs;

  // Future<void> fetchGiftCards({String? search,String? page}) async {
  //   try {
  //     Map<String,dynamic> queryPerameters ={
  //      if(search != null) "search": search,
  //      if(page != null) "page": page,
  //       "limit": 7,
  //     };
  //     isLoading.value = true;
  //     BaseModel response =await BaseController.to.apiService.makeGetRequest(URLS.allGiftCard,queryParameters:queryPerameters );
  //     if (response.statusCode == 200 ) {
  //       var data = response.data["data"] as List;
  //       cards.value = data.map((e) => GiftCardModel.fromJson(e)).toList();
  //       metaModel = MetaModel.fromJson(response.data['meta']);
  //       update();
  //     }else{
  //       kLogger.e(response.data["message"]);
  //     }
  //   } catch (e) {
  //     kLogger.e("Error fetching gift cards: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }


  @override
  void onClose() {
    cardController.dispose();
    amountController.dispose();
    tcnController.dispose();
    invoiceController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }







}
