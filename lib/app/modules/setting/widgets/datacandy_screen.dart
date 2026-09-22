import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/formatter/card_number_formatter.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/transaction_controller.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/views/widgets/user_transaction_table.dart';
import 'package:yogo_pos/app/utils/my_reg_exp.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/custom_Btn.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

import '../../../widgets/custom_textfield.dart';
import '../../data_candy_gift_card/controller/gift_card_controller.dart';

class UpdateDatCandyGiftCardView1 extends StatefulWidget {
  const UpdateDatCandyGiftCardView1({super.key});

  @override
  State<UpdateDatCandyGiftCardView1> createState() =>
      _UpdateDatCandyGiftCardView1State();
}

class _UpdateDatCandyGiftCardView1State
    extends State<UpdateDatCandyGiftCardView1> {
  GiftCardController controller = Get.find<GiftCardController>();
  TransactionController transactionController = Get.put(
    TransactionController(),
  );
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/datacandy.png", height: 70, width: 70),
              MyCustomText(
                "DataCandy",
                fontSize: 43,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          SizedBox(height: 35),

          //Search BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 200),
            child: CustomTextField(
              padding: EdgeInsets.all(23),
              keyboardType: KeyboardType.cardNumberFormatted,
              inputFormatters: [CardNumberFormatter()],
              controller: controller.searchController,
              hintText: "Search by Card / TCN / Invoice Number",
              textAlign: TextAlign.center,
              hintStyle: TextStyle(
                fontSize: 30,
                color: Theme.of(context).hintColor,
              ),
              style: TextStyle(
                fontSize: 30,
                color: Theme.of(context).colorScheme.surface,
              ),
              onChange: (value) {
                // cancel previous timer if typing continues
                if (_debounce?.isActive ?? false) _debounce!.cancel();

                // start new debounce timer
                _debounce = Timer(const Duration(seconds: 1), () async {
                  String pureNumber = value.replaceAll("-", "");
                  debugPrint("Debounced Digits: $pureNumber");

                  // 👉 Place your request call here
                  await transactionController.fetchTransactions(
                    cardSearch: pureNumber,
                    tcnNo: pureNumber,
                    invNo: pureNumber,
                  );
                });
              },
              onKeyboardChang: (value) async {
                String pureNumber = value.replaceAll("-", "");
                debugPrint("Debounced Digits: $pureNumber");

                // 👉 Place your request call here
                await transactionController.fetchTransactions(
                  cardSearch: pureNumber,
                  tcnNo: pureNumber,
                  invNo: pureNumber,
                );
              },
            ),
          ),

          const SizedBox(height: 75),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // DataCandyBtn(onPressed: (){}, text: "Activation",color: const Color.fromRGBO(119, 144, 63, 1),),
              //Check Balance
              Padding(
                padding: const EdgeInsets.only(right: 35),
                child: PrimaryBtn(
                  onPressed: () {
                    //check balance
                    PopupDialog.customDialog2(
                      // borderColor: Colors.amber,
                      width: 900,
                      height: 470,
                      // height: 600,
                      child: Form(
                        key: controller.formKey,
                        child: Center(
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //crud number and price text field row
                              Row(
                                children: [
                                  // ✅ Card Number
                                  Expanded(
                                    flex: 3,
                                    child: SizedBox(
                                      // color: Colors.red,
                                      height: 180,
                                      child: CustomTextField(
                                        keyboardType:
                                            KeyboardType.cardNumberFormatted,
                                        extralabeldownpadding: 28,
                                        padding: EdgeInsets.all(26),
                                        errorStyle: TextStyle(
                                          height: 1,
                                          fontSize: 16,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        inputFormatters: [
                                          // FilteringTextInputFormatter.digitsOnly,
                                          CardNumberFormatter(),
                                        ],
                                        controller: controller.cardController,
                                        hintText: "xxxx xxxx xxxx xxxxx",
                                        extraLabel: "Card Number",
                                        extraLabelFontSize: 40,
                                        hintStyle: TextStyle(
                                          fontSize: 30,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 30,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Card number is required";
                                          }
                                          if (value.replaceAll("-", "").length <
                                                  12 ||
                                              value.replaceAll("-", "").length >
                                                  19) {
                                            return "Card number must be 12–19 digits";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 40),

                                  // ✅ Amount
                                ],
                              ),
                              SizedBox(height: 30),
                              PrimaryBtn(
                                textMaxSize: 30,
                                textMinSize: 30,
                                width: 200,
                                height: 100,
                                fontWeight: FontWeight.w600,
                                color: StaticColors.greenColor,
                                onPressed: () async {
                                  if (controller.formKey.currentState!
                                      .validate()) {
                                    // PopupDialog.showLoadingDialog();
                                    await controller.checkBlance();
                                    // PopupDialog.closeLoadingDialog();
                                    // Get.back();
                                    controller.textControllerRemove();
                                  }
                                },
                                text: "Check Balance",
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  textMaxSize: 30,
                  textMinSize: 30,
                  fontWeight: FontWeight.w600,
                  text: "Check Balance",
                  color: StaticColors.blueColor,
                  height: 110,
                  width: 230,
                ),
              ),
              // activation Card
              // Padding(
              //   padding: const EdgeInsets.only(right: 35),
              //   child: PrimaryBtn(
              //     textMaxSize:30,
              //     textMinSize:30,
              //     fontWeight:FontWeight.w600,
              //     text: "Activate",
              //     color: StaticColors.greenColor,
              //     height: 110,
              //     width: 230,
              //     onPressed: (){
              //       // activate card dialog
              //       PopupDialog.customDialog2(
              //         // borderColor: Colors.amber,
              //           width: 900,
              //           height: 470,
              //           // height: 600,
              //           child: Form(
              //             key: controller.formKey,
              //             child: Center(
              //               child: Column(
              //                 // mainAxisAlignment: MainAxisAlignment.center,
              //                 crossAxisAlignment: CrossAxisAlignment.center,
              //                 children: [
              //                   //crud number and price text field row
              //                   Row(
              //                     children: [
              //                       // ✅ Card Number
              //                       Expanded(
              //                         flex: 3,
              //                         child: SizedBox(
              //                           // color: Colors.red,
              //                           height: 180 ,
              //                           child: CustomTextField(
              //                             extralabeldownpadding:28,
              //                             padding: EdgeInsets.all(26),
              //                             errorStyle: TextStyle(
              //                                 height: 1,
              //                                 fontSize: 16,
              //                                 overflow: TextOverflow.ellipsis
              //                             ),
              //                             inputFormatters: [
              //                               // FilteringTextInputFormatter.digitsOnly,
              //                               CardNumberFormatter(),
              //                             ],
              //                             controller: controller.cardController,
              //                             hintText: "xxxx xxxx xxxx xxxxx",
              //                             hintStyle: TextStyle(fontSize: 30,color: Theme.of(context).hintColor),
              //                             extraLabel: "Card Number",
              //                             extraLabelFontSize: 40,
              //
              //                             // extraLabelStyle: TextStyle(fontSize: 24,fontWeight: FontWeight.w900),
              //
              //                             style: TextStyle(
              //                               fontSize: 30,
              //                               color: Theme.of(context).colorScheme.surface,
              //                             ),
              //                             validator: (value) {
              //                               if (value == null || value.trim().isEmpty) {
              //                                 return "Card number is required";
              //                               }
              //                               if (value.replaceAll("-", "").length < 12 ||
              //                                   value.replaceAll("-", "").length > 19) {
              //                                 return "Card number must be 12–19 digits";
              //                               }
              //                               return null;
              //                             },
              //                             onTap: () {
              //                               CustomKeyboard.open(
              //                                 keyboardType: KeyboardType.number,
              //                                 onChange: (value) {
              //                                   String digits =
              //                                   value.replaceAll(RegExp(r'[^0-9]'), '');
              //                                   if (digits.length > 19) {
              //                                     digits = digits.substring(0, 19);
              //                                   }
              //                                   String newText = '';
              //                                   for (int i = 0; i < digits.length; i++) {
              //                                     if (i > 0 && i % 4 == 0) newText += '-';
              //                                     newText += digits[i];
              //                                   }
              //                                   controller.cardController.text = newText;
              //                                   controller.cardController.selection =
              //                                       TextSelection.fromPosition(
              //                                         TextPosition(offset: newText.length),
              //                                       );
              //                                 },
              //                               );
              //                             },
              //                           ),
              //                         ),
              //                       ),
              //                       const SizedBox(width: 40),
              //
              //                       // ✅ Amount
              //                       Expanded(
              //                         child: Padding(
              //                           padding: const EdgeInsets.only(top: 20),
              //                           child: SizedBox(
              //                             height: 200,
              //                             child:CustomTextField(
              //                               extralabeldownpadding:28,
              //                               inputFormatters: [
              //                                 FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$')),
              //                                 LengthLimitingTextInputFormatter(6),
              //                               ],
              //                               padding: EdgeInsets.all(26),
              //                               errorStyle: const TextStyle(
              //                                 fontSize: 16,
              //                                 height: 1,
              //                                 overflow: TextOverflow.fade,
              //                               ),
              //                               // readOnly: true,
              //                               controller: controller.amountController,
              //                               extraLabelFontSize: 40,
              //                               hintText: "Amount",
              //                               hintStyle: TextStyle(fontSize: 30,color: Theme.of(context).hintColor),
              //                               extraLabel: "Amount",
              //                               style: TextStyle(
              //                                 fontSize: 30,
              //                                 color: Theme.of(context).colorScheme.surface,
              //                               ),
              //                               validator: (value) {
              //                                 if (value == null || value.trim().isEmpty) {
              //                                   return "Amount is required";
              //                                 }
              //
              //                                 // ✅ শুধু সংখ্যা (integer বা decimal) allow
              //                                 final numberRegExp = RegExp(r'^\d+(\.\d+)?$');
              //                                 if (!numberRegExp.hasMatch(value)) {
              //                                   return "Only numeric values are allowed";
              //                                 }
              //
              //                                 final numValue = num.tryParse(value);
              //                                 if (numValue == null) {
              //                                   return "Invalid number";
              //                                 }
              //
              //                                 // ✅ Range check: 5–500 এর মধ্যে হতে হবে
              //                                 if (numValue < 5 || numValue > 500) {
              //                                   return "Amount must be between 5 and 500";
              //                                 }
              //
              //                                 return null;
              //                               },
              //                               onTap: () {
              //                                 int initValue =
              //                                 ((num.tryParse(controller.amountController.text) ?? 0) * 100)
              //                                     .toInt();
              //
              //                                 CustomKeyboard.open(
              //                                     keyboardType: KeyboardType.number,
              //                                     changeKeybordType: false,
              //                                     initialValue: initValue.toString(),
              //                                     // regExp: RegExp(r'^\d{0,5}(\.\d{0,2})?$'),
              //                                     // regExp: RegExp(r'^\d{0,7}$'),
              //                                     regExp: RegExp(r'^\d{0,6}$'),
              //                                     // regExp: RegExp(r'^(?:[0-9]{1,4}|[1-4][0-9]{4}|50000)$'),
              //                                     onChange: (value) {
              //                                       controller.amountController.text = value.toDecimalFormat();
              //                                       kLogger.e(value);
              //                                     });
              //                                 // int initValue =
              //                                 // ((num.tryParse(controller.amountController.text) ?? 0) * 100).toInt();
              //                                 //
              //                                 // CustomKeyboard.open(
              //                                 //   keyboardType: KeyboardType.number,
              //                                 //   changeKeybordType: false,
              //                                 //   initialValue: initValue.toString(),
              //                                 //   // ✅ 1 থেকে 3 digit + optional decimal
              //                                 //   regExp: RegExp(r'^\d{0,3}(\.\d{0,500})?$'),
              //                                 //   onChange: (value) {
              //                                 //     controller.amountController.text = value.toDecimalFormat();
              //                                 //   },
              //                                 // );
              //                               },
              //                             ),
              //
              //                           ),
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                   SizedBox(height: 27.5,),
              //                   PrimaryBtn(
              //                       textMaxSize: 30,
              //                       textMinSize: 30,
              //                       width: 200,
              //                       height: 100,
              //                       fontWeight:FontWeight.w600,
              //                       color:StaticColors.greenColor,
              //                       onPressed:  ()async {
              //                         var cardActivateModel = CardActivationResponse(
              //                           statusCode: 0,
              //                           success: false,
              //                           message: '',
              //                           data: null,
              //                         ).obs;
              //
              //                         if (controller.formKey.currentState!.validate()) {
              //                           bool isUpdate = await controller.commitTransaction();
              //                           // controller.fetchGiftCards();
              //                           // if(isUpdate){
              //                           //   await  PrintUtils().directPrint(
              //                           //       child:await dataCandyCardActivatePrintReceipt(cardActivate: controller.cardActivateModel.value ?? CardActivateModel(),
              //                           //       ),
              //                           //       printerName: Preferences.counterPrinter);
              //                           // }else{
              //                           //   print("print card activate failed");
              //                           // }
              //                           controller.textControllerRemove();
              //                           Get.back();
              //
              //                           if (isUpdate) {
              //                             await PrintUtils().directPrint(child: await dataCandyCardActivatePrintReceipt(cardActivate:  controller.cardActivateModel.value ?? cardActivateModel()), printerName: Preferences.counterPrinter);
              //                           } else {
              //                             // Handle the case when incrementBalanceModel is null
              //                             print("Card Activate model is null!");
              //                           }
              //
              //                         }
              //                       }, text: "Active Card")
              //                 ],
              //               ),
              //             ),
              //           ));
              //       controller.textControllerRemove();
              //     },
              //   ),
              // ),
              // //Reload Card
              // Padding(
              //   padding: const EdgeInsets.only(right: 35),
              //   child: PrimaryBtn(
              //     textMaxSize:30,
              //     textMinSize:30,
              //     fontWeight:FontWeight.w600,
              //     text: "Reload",
              //     color: StaticColors.greenColor,
              //     height: 110,
              //     width: 230,
              //     onPressed: (){
              //       // add funds dialog
              //       PopupDialog.customDialog2(
              //         // borderColor: Colors.amber,
              //           width: 900,
              //           height: 470,
              //           // height: 600,
              //           child: Form(
              //             key: controller.formKey,
              //             child: Center(
              //               child: Column(
              //                 // mainAxisAlignment: MainAxisAlignment.center,
              //                 crossAxisAlignment: CrossAxisAlignment.center,
              //                 children: [
              //                   //crud number and price text field row
              //                   Row(
              //                     children: [
              //                       // ✅ Card Number
              //                       Expanded(
              //                         flex: 3,
              //                         child: SizedBox(
              //                           // color: Colors.red,
              //                           height: 180,
              //                           child: CustomTextField(
              //                             extralabeldownpadding:28,
              //                             padding: EdgeInsets.all(26),
              //                             errorStyle: TextStyle(
              //                                 height: 1,
              //                                 fontSize: 16,
              //                                 overflow: TextOverflow.ellipsis
              //                             ),
              //                             inputFormatters: [
              //                               // FilteringTextInputFormatter.digitsOnly,
              //                               CardNumberFormatter(),
              //                             ],
              //                             controller: controller.cardController,
              //                             hintText: "xxxx xxxx xxxx xxxxx",
              //                             extraLabel: "Card Number",
              //                             extraLabelFontSize: 40,
              //
              //                             // extraLabelStyle: TextStyle(fontSize: 24,fontWeight: FontWeight.w900),
              //                             hintStyle: TextStyle(fontSize: 30,color: Theme.of(context).hintColor),
              //                             style: TextStyle(
              //                               fontSize: 30,
              //                               color: Theme.of(context).colorScheme.surface,
              //                             ),
              //                             validator: (value) {
              //                               if (value == null || value.trim().isEmpty) {
              //                                 return "Card number is required";
              //                               }
              //                               if (value.replaceAll("-", "").length < 12 ||
              //                                   value.replaceAll("-", "").length > 19) {
              //                                 return "Card number must be 12–19 digits";
              //                               }
              //                               return null;
              //                             },
              //                             onTap: () {
              //                               CustomKeyboard.open(
              //                                 keyboardType: KeyboardType.number,
              //                                 onChange: (value) {
              //                                   String digits =
              //                                   value.replaceAll(RegExp(r'[^0-9]'), '');
              //                                   if (digits.length > 19) {
              //                                     digits = digits.substring(0, 19);
              //                                   }
              //                                   String newText = '';
              //                                   for (int i = 0; i < digits.length; i++) {
              //                                     if (i > 0 && i % 4 == 0) newText += '-';
              //                                     newText += digits[i];
              //                                   }
              //                                   controller.cardController.text = newText;
              //                                   controller.cardController.selection =
              //                                       TextSelection.fromPosition(
              //                                         TextPosition(offset: newText.length),
              //                                       );
              //                                 },
              //                               );
              //                             },
              //                           ),
              //                         ),
              //                       ),
              //                       const SizedBox(width: 40),
              //
              //                       // ✅ Amount
              //                       Expanded(
              //                         child: Padding(
              //                           padding: const EdgeInsets.only(top: 20),
              //                           child: SizedBox(
              //                             height: 200,
              //
              //
              //
              //                             child:CustomTextField(
              //                               extralabeldownpadding:28,
              //                               inputFormatters: [
              //                                 FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$')),
              //                                 LengthLimitingTextInputFormatter(6),
              //                               ],
              //                               padding: EdgeInsets.all(26),
              //                               errorStyle: const TextStyle(
              //                                 fontSize: 16,
              //                                 height: 1,
              //                                 overflow: TextOverflow.fade,
              //                               ),
              //                               // readOnly: true,
              //                               controller: controller.amountController,
              //                               extraLabelFontSize: 40,
              //                               hintStyle: TextStyle(fontSize: 30,color: Theme.of(context).hintColor),
              //                               hintText: "Amount",
              //                               extraLabel: "Amount",
              //                               style: TextStyle(
              //                                 fontSize: 30,
              //                                 color: Theme.of(context).colorScheme.surface,
              //                               ),
              //                               validator: (value) {
              //                                 if (value == null || value.trim().isEmpty) {
              //                                   return "Amount is required";
              //                                 }
              //
              //                                 // ✅ শুধু সংখ্যা (integer বা decimal) allow
              //                                 final numberRegExp = RegExp(r'^\d+(\.\d+)?$');
              //                                 if (!numberRegExp.hasMatch(value)) {
              //                                   return "Only numeric values are allowed";
              //                                 }
              //
              //                                 final numValue = num.tryParse(value);
              //                                 if (numValue == null) {
              //                                   return "Invalid number";
              //                                 }
              //
              //                                 // ✅ Range check: 5–500 এর মধ্যে হতে হবে
              //                                 if (numValue < 5 || numValue > 500) {
              //                                   return "Amount must be between 5 and 500";
              //                                 }
              //
              //                                 return null;
              //                               },
              //                               onTap: () {
              //                                 int initValue =
              //                                 ((num.tryParse(controller.amountController.text) ?? 0) * 100)
              //                                     .toInt();
              //
              //                                 CustomKeyboard.open(
              //                                     keyboardType: KeyboardType.number,
              //                                     changeKeybordType: false,
              //                                     initialValue: initValue.toString(),
              //                                     // regExp: RegExp(r'^\d{0,5}(\.\d{0,2})?$'),
              //                                     // regExp: RegExp(r'^\d{0,7}$'),
              //                                     regExp: RegExp(r'^\d{0,6}$'),
              //                                     // regExp: RegExp(r'^(?:[0-9]{1,4}|[1-4][0-9]{4}|50000)$'),
              //                                     onChange: (value) {
              //                                       controller.amountController.text = value.toDecimalFormat();
              //                                       kLogger.e(value);
              //                                     });
              //                                 // int initValue =
              //                                 // ((num.tryParse(controller.amountController.text) ?? 0) * 100).toInt();
              //                                 //
              //                                 // CustomKeyboard.open(
              //                                 //   keyboardType: KeyboardType.number,
              //                                 //   changeKeybordType: false,
              //                                 //   initialValue: initValue.toString(),
              //                                 //   // ✅ 1 থেকে 3 digit + optional decimal
              //                                 //   regExp: RegExp(r'^\d{0,3}(\.\d{0,500})?$'),
              //                                 //   onChange: (value) {
              //                                 //     controller.amountController.text = value.toDecimalFormat();
              //                                 //   },
              //                                 // );
              //                               },
              //                             ),
              //
              //                           ),
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                   SizedBox(height: 30,),
              //                   PrimaryBtn(
              //                       textMaxSize: 30,
              //                       textMinSize: 30,
              //                       width: 200,
              //                       height: 100,
              //                       fontWeight:FontWeight.w600,
              //                       color:StaticColors.greenColor,
              //                       onPressed:  ()async {
              //                         if (controller.formKey.currentState!.validate()) {
              //                         PopupDialog.showLoadingDialog();
              //                          bool isUpdate = await controller.incrementBalance();
              //                          PopupDialog.closeLoadingDialog();
              //                          controller.textControllerRemove();
              //                          Get.back();
              //                           if (isUpdate) {
              //                            await PrintUtils().directPrint(child: await dataCandyIncrementPrintReceipt(), printerName: Preferences.counterPrinter);
              //                           } else {
              //                             // Handle the case when incrementBalanceModel is null
              //                             print("Increment model is null!");
              //                           }
              //                         } else {
              //                           // Validator failed, error text দেখাবে
              //                           print("Validation failed");
              //                         }
              //                         controller.textControllerRemove();
              //                         }, text: "Add Funds")
              //                 ],
              //               ),
              //             ),
              //           ),
              //
              //       );
              //       controller.textControllerRemove();
              //     },
              //   ),
              // ),
              // // Redeem Card
              // Padding(
              //   padding: const EdgeInsets.only(right: 35),
              //   child: PrimaryBtn(
              //     textMaxSize:30,
              //     textMinSize:30,
              //     fontWeight:FontWeight.w600,
              //     onPressed: (){
              //       PopupDialog.customDialog2(
              //         // borderColor: Colors.amber,
              //           width: 900,
              //           height: 470,
              //           // height: 600,
              //           child: Form(
              //             key: controller.formKey,
              //             child: Center(
              //               child: Column(
              //                 // mainAxisAlignment: MainAxisAlignment.center,
              //                 crossAxisAlignment: CrossAxisAlignment.center,
              //                 children: [
              //                   //crud number and price text field row
              //                   Row(
              //                     children: [
              //                       // ✅ Card Number
              //                       Expanded(
              //                         flex: 3,
              //                         child: SizedBox(
              //                           // color: Colors.red,
              //                           height: 180,
              //                           child: CustomTextField(
              //                             extralabeldownpadding:28,
              //                             padding: EdgeInsets.all(26),
              //                             errorStyle: TextStyle(
              //                                 height: 1,
              //                                 fontSize: 16,
              //                                 overflow: TextOverflow.ellipsis
              //                             ),
              //                             inputFormatters: [
              //                               // FilteringTextInputFormatter.digitsOnly,
              //                               CardNumberFormatter(),
              //                             ],
              //                             controller: controller.cardController,
              //                             hintText: "xxxx xxxx xxxx xxxxx",
              //                             extraLabel: "Card Number",
              //                             extraLabelFontSize: 40,
              //
              //                             // extraLabelStyle: TextStyle(fontSize: 24,fontWeight: FontWeight.w900),
              //                             hintStyle: TextStyle(fontSize: 30,color: Theme.of(context).hintColor),
              //                             style: TextStyle(
              //                               fontSize: 30,
              //                               color: Theme.of(context).colorScheme.surface,
              //                             ),
              //                             validator: (value) {
              //                               if (value == null || value.trim().isEmpty) {
              //                                 return "Card number is required";
              //                               }
              //                               if (value.replaceAll("-", "").length < 12 ||
              //                                   value.replaceAll("-", "").length > 19) {
              //                                 return "Card number must be 12–19 digits";
              //                               }
              //                               return null;
              //                             },
              //                             onTap: () {
              //                               CustomKeyboard.open(
              //                                 keyboardType: KeyboardType.number,
              //                                 onChange: (value) {
              //                                   String digits =
              //                                   value.replaceAll(RegExp(r'[^0-9]'), '');
              //                                   if (digits.length > 19) {
              //                                     digits = digits.substring(0, 19);
              //                                   }
              //                                   String newText = '';
              //                                   for (int i = 0; i < digits.length; i++) {
              //                                     if (i > 0 && i % 4 == 0) newText += '-';
              //                                     newText += digits[i];
              //                                   }
              //                                   controller.cardController.text = newText;
              //                                   controller.cardController.selection =
              //                                       TextSelection.fromPosition(
              //                                         TextPosition(offset: newText.length),
              //                                       );
              //                                 },
              //                               );
              //                             },
              //                           ),
              //                         ),
              //                       ),
              //                       const SizedBox(width: 40),
              //
              //                       // ✅ Amount
              //                       Expanded(
              //                         child: Padding(
              //                           padding: const EdgeInsets.only(top: 20),
              //                           child: SizedBox(
              //                             height: 200,
              //                             child:CustomTextField(
              //                               extralabeldownpadding:28,
              //                               inputFormatters: [
              //                                 FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$')),
              //                                 LengthLimitingTextInputFormatter(6),
              //                               ],
              //                               padding: EdgeInsets.all(26),
              //                               errorStyle: const TextStyle(
              //                                 fontSize: 16,
              //                                 height: 1,
              //                                 overflow: TextOverflow.fade,
              //                               ),
              //                               // readOnly: true,
              //                               controller: controller.amountController,
              //                               extraLabelFontSize: 40,
              //                               hintStyle: TextStyle(fontSize: 30,color: Theme.of(context).hintColor),
              //                               hintText: "Amount",
              //                               extraLabel: "Amount",
              //                               style: TextStyle(
              //                                 fontSize: 30,
              //                                 color: Theme.of(context).colorScheme.surface,
              //                               ),
              //                               validator: (value) {
              //                                 if (value == null || value.trim().isEmpty) {
              //                                   return "Amount is required";
              //                                 }
              //                                 // ✅ শুধু সংখ্যা (integer বা decimal) allow
              //                                 final numberRegExp = RegExp(r'^\d+(\.\d+)?$');
              //                                 if (!numberRegExp.hasMatch(value)) {
              //                                   return "Only numeric values are allowed";
              //                                 }
              //                                 final numValue = num.tryParse(value);
              //                                 if (numValue == null) {
              //                                   return "Invalid number";
              //                                 }
              //                                 return null;
              //                               },
              //                               onTap: () {
              //                                 int initValue =
              //                                 ((num.tryParse(controller.amountController.text) ?? 0) * 100)
              //                                     .toInt();
              //
              //                                 CustomKeyboard.open(
              //                                     keyboardType: KeyboardType.number,
              //                                     changeKeybordType: false,
              //                                     initialValue: initValue.toString(),
              //                                     regExp: RegExp(r'^\d{0,8}$'),
              //                                     onChange: (value) {
              //                                       controller.amountController.text = value.toDecimalFormat();
              //                                       kLogger.e(value);
              //                                     });
              //                               },
              //                             ),
              //
              //                           ),
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                   SizedBox(height: 30,),
              //                   PrimaryBtn(
              //                       textMaxSize: 30,
              //                       textMinSize: 30,
              //                       width: 200,
              //                       height: 100,
              //                       fontWeight:FontWeight.w600,
              //                       color:StaticColors.greenColor,
              //
              //                       onPressed:  ()async {
              //                         // PopupDialog.permissionDialog(Get.theme, onSubmit: ()async{
              //
              //                           if (controller.formKey.currentState!.validate()) {
              //                             PopupDialog.showLoadingDialog();
              //                             bool isUpdate = await controller.redeemBalance();
              //                             PopupDialog.closeLoadingDialog();
              //
              //                             Get.back();
              //                           } else {
              //                             // Validator failed, error text দেখাবে
              //                             print("Validation failed");
              //                           }
              //                         // }, title: "Would you like to Redeem?");
              //                         // Get.back();
              //
              //
              //
              //
              //
              //                       }, text: "Redeem")
              //                 ],
              //               ),
              //             ),
              //           ));
              //   },
              //     text: "Redeem",
              //     color: StaticColors.orangeColor,
              //     height: 110,
              //     width: 230,
              //   ),
              // ),
              // Cancel Transaction
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: PrimaryBtn(
                  textMaxSize: 30,
                  textMinSize: 30,
                  fontWeight: FontWeight.w600,
                  onPressed: () {
                    //cancel transaction dialog
                    PopupDialog.customDialog2(
                      // borderColor: Colors.amber,
                      width: 900,
                      height: 660,
                      // height: 600,
                      child: Form(
                        key: controller.formKey,
                        child: Center(
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //crud number and price text field row
                              Row(
                                children: [
                                  // ✅ Card Number
                                  Expanded(
                                    flex: 3,
                                    child: SizedBox(
                                      // color: Colors.red,
                                      height: 180,
                                      child: CustomTextField(
                                        keyboardType:
                                            KeyboardType.cardNumberFormatted,
                                        extralabeldownpadding: 28,
                                        padding: EdgeInsets.all(26),
                                        errorStyle: TextStyle(
                                          height: 1,
                                          fontSize: 16,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        inputFormatters: [
                                          // FilteringTextInputFormatter.digitsOnly,
                                          CardNumberFormatter(),
                                        ],
                                        controller: controller.cardController,
                                        hintText: "xxxx xxxx xxxx xxxxx",
                                        extraLabel: "Card Number",
                                        extraLabelFontSize: 40,

                                        // extraLabelStyle: TextStyle(fontSize: 24,fontWeight: FontWeight.w900),
                                        hintStyle: TextStyle(
                                          fontSize: 30,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        style: TextStyle(
                                          fontSize: 30,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Card number is required";
                                          }
                                          if (value.replaceAll("-", "").length <
                                                  12 ||
                                              value.replaceAll("-", "").length >
                                                  19) {
                                            return "Card number must be 12–19 digits";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 40),

                                  // ✅ Amount
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 18),
                                      child: SizedBox(
                                        height: 200,
                                        child: CustomTextField(
                                          extralabeldownpadding: 28,
                                          padding: EdgeInsets.all(26),
                                          errorStyle: const TextStyle(
                                            fontSize: 16,
                                            height: 1,
                                            overflow: TextOverflow.fade,
                                          ),
                                          keyboardType:
                                              KeyboardType.decimalFormatted,
                                          controller:
                                              controller.amountController,
                                          extraLabelFontSize: 40,
                                          hintStyle: TextStyle(
                                            fontSize: 30,
                                            color: Theme.of(context).hintColor,
                                          ),
                                          hintText: "Amount",
                                          extraLabel: "Amount",
                                          style: TextStyle(
                                            fontSize: 30,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return "Amount is required";
                                            }

                                            final numberRegExp = RegExp(
                                              r'^\d+(\.\d+)?$',
                                            );
                                            if (!numberRegExp.hasMatch(value)) {
                                              return "Only numeric values are allowed";
                                            }

                                            final numValue = num.tryParse(
                                              value,
                                            );
                                            if (numValue == null) {
                                              return "Invalid number";
                                            }

                                            if (numValue < 5 ||
                                                numValue > 500) {
                                              return "Amount must be between 5 and 500";
                                            }

                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30),
                              Row(
                                children: [
                                  // ✅ Confirmation No.
                                  Expanded(
                                    child: SizedBox(
                                      height: 180,
                                      child: CustomTextField(
                                        extralabeldownpadding: 28,
                                        keyboardType: KeyboardType.numeric,
                                        allowRegex:
                                            CommonRegexPatterns.digitsOnlyWithLength(
                                              6,
                                            ),
                                        padding: const EdgeInsets.all(26),
                                        errorStyle: const TextStyle(
                                          height: 1,
                                          fontSize: 16,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        controller: controller.tcnController,
                                        hintText: "TCN No.",
                                        extraLabel: "TCN No.",
                                        extraLabelFontSize: 40,
                                        hintStyle: TextStyle(
                                          fontSize: 30,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        style: TextStyle(
                                          fontSize: 30,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Confirmation No. is required";
                                          }
                                          if (value.length != 5) {
                                            return "Confirmation No. must be exactly 5 digits";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 40),

                                  // ✅ Invoice No.
                                  Expanded(
                                    child: SizedBox(
                                      height: 180,
                                      child: CustomTextField(
                                        keyboardType: KeyboardType.alphaNumeric,
                                        allowRegex:
                                            CommonRegexPatterns.invoiceNumberWithAndLength(
                                              20,
                                            ),
                                        extralabeldownpadding: 28,
                                        padding: const EdgeInsets.all(26),
                                        errorStyle: const TextStyle(
                                          fontSize: 16,
                                          height: 1,
                                          overflow: TextOverflow.fade,
                                        ),
                                        controller:
                                            controller.invoiceController,
                                        hintText: "Invoice No.",
                                        extraLabel: "Invoice No.",
                                        extraLabelFontSize: 40,
                                        hintStyle: TextStyle(
                                          fontSize: 30,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        style: TextStyle(
                                          fontSize: 30,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return "Invoice No. is required";
                                          }
                                          // if (value.length != 6) {
                                          //   return "Invoice No. must be exactly 6 digits";
                                          // }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 45),
                              PrimaryBtn(
                                textMaxSize: 30,
                                textMinSize: 30,
                                width: 200,
                                height: 100,
                                fontWeight: FontWeight.w600,
                                color: StaticColors.orangeColor,
                                onPressed: () async {
                                  if (controller.formKey.currentState!
                                      .validate()) {
                                    PopupDialog.permissionDialog(
                                      Get.theme,
                                      onSubmit: () async {
                                        Get.back();
                                        // Get.back();

                                        Get.put(GiftCardController());

                                        // PopupDialog.showLoadingDialog();
                                        bool isUpdate = await controller
                                            .cancelTranSection();
                                        // PopupDialog.closeLoadingDialog();

                                        if (isUpdate) {
                                          //Todo :print
                                          // await PrintUtils().directPrint(
                                          //     child:
                                          //         await dataCandyCancelTransactionPrintReceipt(),
                                          //     printerName:
                                          //         Preferences.counterPrinter);
                                        } else {
                                          // Handle the case when incrementBalanceModel is null
                                          debugPrint(
                                            "Increment model is null!",
                                          );
                                        }
                                        // Get.back();
                                      },
                                      title: "Cancel transaction?",
                                    );
                                  } else {
                                    debugPrint("Validation failed");
                                  }

                                  debugPrint(
                                    "Cancel clicked for transaction ID: ${controller.cardController.value}",
                                  );
                                },
                                text: "Cancel Transaction",
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  text: "Cancel",
                  color: StaticColors.orangeColor,
                  height: 110,
                  width: 230,
                ),
              ),
            ],
          ),
          SizedBox(height: 75),
          Expanded(child: TransactionTable()),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       Obx(() {
          //         GiftCardController giftCardController = Get.put(GiftCardController());
          //         TransactionController controller = Get.put(TransactionController());
          //
          //         return CustomPagination(
          //           numOfPages: controller.meta.value?.totalPages ?? 1,
          //           selectedPage: controller.meta.value?.currentPage ?? 1,
          //           pagesVisible: 5,
          //           onPageChanged: (page) async {
          //             debugPrint("Page changed: $page");
          //             await controller.fetchTransactions(
          //               cardSearch: giftCardController.searchController.text.replaceAll("-", ""),
          //               page: "$page",
          //             );
          //           },
          //         );
          //       })
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}

class DataCandyBtn extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final Color? color;
  final Color? borderColor;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;
  final AlignmentGeometry? alignment;

  const DataCandyBtn({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.color,
    this.textStyle,
    this.borderRadius,
    this.borderColor,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 250,
      height: height ?? 100,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color ?? Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(0),
          ),
          side: BorderSide(
            color: borderColor ?? Colors.black38, //
            width: 1.5,
          ),
          padding: EdgeInsets.zero, //
        ),
        child: Align(
          alignment: alignment ?? Alignment.bottomLeft, //
          child: Padding(
            padding: const EdgeInsets.all(8.0), //
            child: Text(
              text,
              style:
                  textStyle ??
                  const TextStyle(
                    fontSize: 22,
                    // color: Colors.b,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
