// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:yogo_pos/app/utils/extension/string_manipulation_extension.dart';
//
// import '../../../../services/base/preferences.dart';
// import '../../../../utils/logger.dart';
// import '../../../../utils/print_utils.dart';
// import '../../../../utils/static_colors.dart';
// import '../../../../widgets/custom_Btn.dart';
// import '../../../../widgets/custom_textfield.dart';
// import '../../../../widgets/popup_dialogs.dart';
// import '../../../custom_keyboard/custom_keyboard.dart';
// import '../../controller/gift_card_controller.dart';
// import '../../models/card_activate_model.dart';
// import '../../print_receipt/card_activate_receipt.dart';
//
// class NewUpdataDataCandyView extends StatefulWidget {
//   const NewUpdataDataCandyView({super.key});
//
//   @override
//   State<NewUpdataDataCandyView> createState() => _NewUpdataDataCandyViewState();
// }
//
// class _NewUpdataDataCandyViewState extends State<NewUpdataDataCandyView> {
//   GiftCardController controller = Get.find<GiftCardController>();
//   @override
//   void initState() {
//     super.initState();
//     // controller.nameController.addListener(() {
//     //   final text = controller.nameController.text;
//     //   if (text != text.toUpperCase()) {
//     //     controller.nameController.value = controller.nameController.value.copyWith(
//     //       text: text.toUpperCase(),
//     //       selection: TextSelection.collapsed(offset: text.length),
//     //     );
//     //   }
//     // });
//     //
//     // // ✅ Phone number formatting listener
//     // controller.phoneController.addListener(() {
//     //   String text = controller.phoneController.text;
//     //   String digits = text.replaceAll(RegExp(r'[^0-9]'), '');
//     //
//     //   if (digits.length > 10) {
//     //     digits = digits.substring(0, 10);
//     //   }
//     //
//     //   String newText = '';
//     //   if (digits.isNotEmpty) {
//     //     newText = digits.substring(0, digits.length.clamp(0, 3));
//     //   }
//     //   if (digits.length > 3) {
//     //     newText += '-' + digits.substring(3, digits.length.clamp(3, 6));
//     //   }
//     //   if (digits.length > 6) {
//     //     newText += '-' + digits.substring(6, digits.length);
//     //   }
//     //
//     //   if (newText != controller.phoneController.text) {
//     //     controller.phoneController.value = controller.phoneController.value.copyWith(
//     //       text: newText,
//     //       selection: TextSelection.collapsed(offset: newText.length),
//     //     );
//     //   }
//     // });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Align(
//               alignment: Alignment.center,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // add card button
//                   Padding(
//                     padding: const EdgeInsets.only(right: 50),
//                     child: PrimaryBtn(
//                       textMaxSize: 32,
//                       textMinSize: 24,
//                       height: 170,
//                       width: 170,
//                       onPressed: (){
//                         PopupDialog.customDialog2(
//                           // borderColor: Colors.amber,
//                             width: 900,
//                             height: 470,
//                             // height: 600,
//                             child: Form(
//                               key: controller.formKey,
//                               child: Center(
//                                 child: Column(
//                                   // mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     //crud number and price text field row
//                                     Row(
//                                       children: [
//                                         // ✅ Card Number
//                                         Expanded(
//                                           flex: 3,
//                                           child: SizedBox(
//                                             // color: Colors.red,
//                                             height: 180 ,
//                                             child: CustomTextField(
//                                               extralabeldownpadding:28,
//                                               padding: EdgeInsets.all(26),
//                                               errorStyle: TextStyle(
//                                                   height: 1,
//                                                   fontSize: 16,
//                                                   overflow: TextOverflow.ellipsis
//                                               ),
//                                               inputFormatters: [
//                                                 // FilteringTextInputFormatter.digitsOnly,
//                                                 CardNumberFormatter(),
//                                               ],
//                                               controller: controller.cardController,
//                                               hintText: "xxxx xxxx xxxx xxxxx",
//                                               extraLabel: "Card Number",
//                                               extraLabelFontSize: 40,
//
//                                               // extraLabelStyle: TextStyle(fontSize: 24,fontWeight: FontWeight.w900),
//                                               hintStyle: TextStyle(fontSize: 30),
//                                               style: TextStyle(
//                                                 fontSize: 30,
//                                                 color: Theme.of(context).colorScheme.surface,
//                                               ),
//                                               validator: (value) {
//                                                 if (value == null || value.trim().isEmpty) {
//                                                   return "Card number is required";
//                                                 }
//                                                 if (value.replaceAll("-", "").length < 12 ||
//                                                     value.replaceAll("-", "").length > 19) {
//                                                   return "Card number must be 12–19 digits";
//                                                 }
//                                                 return null;
//                                               },
//                                               onTap: () {
//                                                 CustomKeyboard.open(
//                                                   keyboardType: KeyboardType.number,
//                                                   onChange: (value) {
//                                                     String digits =
//                                                     value.replaceAll(RegExp(r'[^0-9]'), '');
//                                                     if (digits.length > 19) {
//                                                       digits = digits.substring(0, 19);
//                                                     }
//                                                     String newText = '';
//                                                     for (int i = 0; i < digits.length; i++) {
//                                                       if (i > 0 && i % 4 == 0) newText += '-';
//                                                       newText += digits[i];
//                                                     }
//                                                     controller.cardController.text = newText;
//                                                     controller.cardController.selection =
//                                                         TextSelection.fromPosition(
//                                                           TextPosition(offset: newText.length),
//                                                         );
//                                                   },
//                                                 );
//                                               },
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 40),
//
//                                         // ✅ Amount
//                                         Expanded(
//                                           child: Padding(
//                                             padding: const EdgeInsets.only(top: 10),
//                                             child: SizedBox(
//                                               height: 180,
//
//
//
//                                               child:CustomTextField(
//                                                 extralabeldownpadding:28,
//                                                 inputFormatters: [
//                                                   // FilteringTextInputFormatter.digitsOnly,
//                                                 ],
//                                                 padding: EdgeInsets.all(26),
//                                                 errorStyle: const TextStyle(
//                                                   fontSize: 16,
//                                                   height: 1,
//                                                   overflow: TextOverflow.fade,
//                                                 ),
//                                                 readOnly: true,
//                                                 controller: controller.amountController,
//                                                 extraLabelFontSize: 40,
//                                                 hintStyle: const TextStyle(fontSize: 30),
//                                                 hintText: "Amount",
//                                                 extraLabel: "Amount",
//                                                 style: TextStyle(
//                                                   fontSize: 30,
//                                                   color: Theme.of(context).colorScheme.surface,
//                                                 ),
//                                                 validator: (value) {
//                                                   if (value == null || value.trim().isEmpty) {
//                                                     return "Amount is required";
//                                                   }
//
//                                                   // ✅ শুধু সংখ্যা (integer বা decimal) allow
//                                                   final numberRegExp = RegExp(r'^\d+(\.\d+)?$');
//                                                   if (!numberRegExp.hasMatch(value)) {
//                                                     return "Only numeric values are allowed";
//                                                   }
//
//                                                   final numValue = num.tryParse(value);
//                                                   if (numValue == null) {
//                                                     return "Invalid number";
//                                                   }
//
//                                                   // ✅ Range check: 5–500 এর মধ্যে হতে হবে
//                                                   if (numValue < 5 || numValue > 500) {
//                                                     return "Amount must be between 5 and 500";
//                                                   }
//
//                                                   return null;
//                                                 },
//                                                 onTap: () {
//                                                   int initValue =
//                                                   ((num.tryParse(controller.amountController.text) ?? 0) * 100)
//                                                       .toInt();
//
//                                                   CustomKeyboard.open(
//                                                       keyboardType: KeyboardType.number,
//                                                       changeKeybordType: false,
//                                                       initialValue: initValue.toString(),
//                                                       // regExp: RegExp(r'^\d{0,5}(\.\d{0,2})?$'),
//                                                       // regExp: RegExp(r'^\d{0,7}$'),
//                                                       regExp: RegExp(r'^\d{0,6}$'),
//                                                       // regExp: RegExp(r'^(?:[0-9]{1,4}|[1-4][0-9]{4}|50000)$'),
//                                                       onChange: (value) {
//                                                         controller.amountController.text = value.toDecimalFormat();
//                                                         kLogger.e(value);
//                                                       });
//                                                   // int initValue =
//                                                   // ((num.tryParse(controller.amountController.text) ?? 0) * 100).toInt();
//                                                   //
//                                                   // CustomKeyboard.open(
//                                                   //   keyboardType: KeyboardType.number,
//                                                   //   changeKeybordType: false,
//                                                   //   initialValue: initValue.toString(),
//                                                   //   // ✅ 1 থেকে 3 digit + optional decimal
//                                                   //   regExp: RegExp(r'^\d{0,3}(\.\d{0,500})?$'),
//                                                   //   onChange: (value) {
//                                                   //     controller.amountController.text = value.toDecimalFormat();
//                                                   //   },
//                                                   // );
//                                                 },
//                                               ),
//
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: 30,),
//                                     PrimaryBtn(
//                                         textMaxSize: 32,
//                                         textMinSize: 24,
//                                         width: 140,
//                                         height: 120,
//                                         color:StaticColors.greenColor,
//
//                                         onPressed:  ()async {
//
//                                           if (controller.formKey.currentState!.validate()) {
//                                             bool isUpdate = await controller.commitTransaction();
//                                             // controller.fetchGiftCards();
//                                             // if(isUpdate){
//                                             //   await  PrintUtils().directPrint(
//                                             //       child:await dataCandyCardActivatePrintReceipt(cardActivate: controller.cardActivateModel.value ?? CardActivateModel(),
//                                             //       ),
//                                             //       printerName: Preferences.counterPrinter);
//                                             // }else{
//                                             //   print("print card activate failed");
//                                             // }
//                                             controller.textControllerRemove();
//                                             Get.back();
//
//                                           }
//                                         }, text: "Add Card")
//                                   ],
//                                 ),
//                               ),
//                             ));
//                       }, text: "Add Card",color: StaticColors.greenColor,),
//                   ),
//                   // SizedBox(width: 70,),
//                   //add funds button
//                   Padding(
//                     padding: const EdgeInsets.only(right: 50),
//                     child: PrimaryBtn(
//                       textMaxSize: 32,
//                       textMinSize: 24,
//                       height: 170,
//                       width: 170,
//                       onPressed: (){
//                         PopupDialog.customDialog2(
//                           // borderColor: Colors.amber,
//                             width: 900,
//                             height: 470,
//                             // height: 600,
//                             child: Form(
//                               key: controller.formKey,
//                               child: Center(
//                                 child: Column(
//                                   // mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     //crud number and price text field row
//                                     Row(
//                                       children: [
//                                         // ✅ Card Number
//                                         Expanded(
//                                           flex: 3,
//                                           child: SizedBox(
//                                             // color: Colors.red,
//                                             height: 180,
//                                             child: CustomTextField(
//                                               extralabeldownpadding:28,
//                                               padding: EdgeInsets.all(26),
//                                               errorStyle: TextStyle(
//                                                   height: 1,
//                                                   fontSize: 16,
//                                                   overflow: TextOverflow.ellipsis
//                                               ),
//                                               inputFormatters: [
//                                                 // FilteringTextInputFormatter.digitsOnly,
//                                                 CardNumberFormatter(),
//                                               ],
//                                               controller: controller.cardController,
//                                               hintText: "xxxx xxxx xxxx xxxxx",
//                                               extraLabel: "Card Number",
//                                               extraLabelFontSize: 40,
//
//                                               // extraLabelStyle: TextStyle(fontSize: 24,fontWeight: FontWeight.w900),
//                                               hintStyle: TextStyle(fontSize: 30),
//                                               style: TextStyle(
//                                                 fontSize: 30,
//                                                 color: Theme.of(context).colorScheme.surface,
//                                               ),
//                                               validator: (value) {
//                                                 if (value == null || value.trim().isEmpty) {
//                                                   return "Card number is required";
//                                                 }
//                                                 if (value.replaceAll("-", "").length < 12 ||
//                                                     value.replaceAll("-", "").length > 19) {
//                                                   return "Card number must be 12–19 digits";
//                                                 }
//                                                 return null;
//                                               },
//                                               onTap: () {
//                                                 CustomKeyboard.open(
//                                                   keyboardType: KeyboardType.number,
//                                                   onChange: (value) {
//                                                     String digits =
//                                                     value.replaceAll(RegExp(r'[^0-9]'), '');
//                                                     if (digits.length > 19) {
//                                                       digits = digits.substring(0, 19);
//                                                     }
//                                                     String newText = '';
//                                                     for (int i = 0; i < digits.length; i++) {
//                                                       if (i > 0 && i % 4 == 0) newText += '-';
//                                                       newText += digits[i];
//                                                     }
//                                                     controller.cardController.text = newText;
//                                                     controller.cardController.selection =
//                                                         TextSelection.fromPosition(
//                                                           TextPosition(offset: newText.length),
//                                                         );
//                                                   },
//                                                 );
//                                               },
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 40),
//
//                                         // ✅ Amount
//                                         Expanded(
//                                           child: Padding(
//                                             padding: const EdgeInsets.only(top: 10),
//                                             child: SizedBox(
//                                               height: 180,
//
//
//
//                                               child:CustomTextField(
//                                                 extralabeldownpadding:28,
//                                                 inputFormatters: [
//                                                   // FilteringTextInputFormatter.digitsOnly,
//                                                 ],
//                                                 padding: EdgeInsets.all(26),
//                                                 errorStyle: const TextStyle(
//                                                   fontSize: 16,
//                                                   height: 1,
//                                                   overflow: TextOverflow.fade,
//                                                 ),
//                                                 readOnly: true,
//                                                 controller: controller.amountController,
//                                                 extraLabelFontSize: 40,
//                                                 hintStyle: const TextStyle(fontSize: 30),
//                                                 hintText: "Amount",
//                                                 extraLabel: "Amount",
//                                                 style: TextStyle(
//                                                   fontSize: 30,
//                                                   color: Theme.of(context).colorScheme.surface,
//                                                 ),
//                                                 validator: (value) {
//                                                   if (value == null || value.trim().isEmpty) {
//                                                     return "Amount is required";
//                                                   }
//
//                                                   // ✅ শুধু সংখ্যা (integer বা decimal) allow
//                                                   final numberRegExp = RegExp(r'^\d+(\.\d+)?$');
//                                                   if (!numberRegExp.hasMatch(value)) {
//                                                     return "Only numeric values are allowed";
//                                                   }
//
//                                                   final numValue = num.tryParse(value);
//                                                   if (numValue == null) {
//                                                     return "Invalid number";
//                                                   }
//
//                                                   // ✅ Range check: 5–500 এর মধ্যে হতে হবে
//                                                   if (numValue < 5 || numValue > 500) {
//                                                     return "Amount must be between 5 and 500";
//                                                   }
//
//                                                   return null;
//                                                 },
//                                                 onTap: () {
//                                                   int initValue =
//                                                   ((num.tryParse(controller.amountController.text) ?? 0) * 100)
//                                                       .toInt();
//
//                                                   CustomKeyboard.open(
//                                                       keyboardType: KeyboardType.number,
//                                                       changeKeybordType: false,
//                                                       initialValue: initValue.toString(),
//                                                       // regExp: RegExp(r'^\d{0,5}(\.\d{0,2})?$'),
//                                                       // regExp: RegExp(r'^\d{0,7}$'),
//                                                       regExp: RegExp(r'^\d{0,6}$'),
//                                                       // regExp: RegExp(r'^(?:[0-9]{1,4}|[1-4][0-9]{4}|50000)$'),
//                                                       onChange: (value) {
//                                                         controller.amountController.text = value.toDecimalFormat();
//                                                         kLogger.e(value);
//                                                       });
//                                                   // int initValue =
//                                                   // ((num.tryParse(controller.amountController.text) ?? 0) * 100).toInt();
//                                                   //
//                                                   // CustomKeyboard.open(
//                                                   //   keyboardType: KeyboardType.number,
//                                                   //   changeKeybordType: false,
//                                                   //   initialValue: initValue.toString(),
//                                                   //   // ✅ 1 থেকে 3 digit + optional decimal
//                                                   //   regExp: RegExp(r'^\d{0,3}(\.\d{0,500})?$'),
//                                                   //   onChange: (value) {
//                                                   //     controller.amountController.text = value.toDecimalFormat();
//                                                   //   },
//                                                   // );
//                                                 },
//                                               ),
//
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: 30,),
//                                     PrimaryBtn(
//                                         textMaxSize: 32,
//                                         textMinSize: 24,
//                                         width: 140,
//                                         height: 120,
//                                         color:StaticColors.greenColor,
//
//                                         onPressed:  ()async {
//
//                                           if (controller.formKey.currentState!.validate()) {
//                                             bool isUpdate = await controller.commitTransaction();
//                                             // controller.fetchGiftCards();
//                                             if(isUpdate){
//                                               await  PrintUtils().directPrint(
//                                                   child:await dataCandyCardActivatePrintReceipt(cardActivate: controller.cardActivateModel.value ?? CardActivateModel(),
//                                                   ),
//                                                   printerName: Preferences.counterPrinter);
//                                             }else{
//                                               print("print card activate failed");
//                                             }
//                                             controller.textControllerRemove();
//                                             Get.back();
//
//                                           }
//                                         }, text: "Add Funds")
//                                   ],
//                                 ),
//                               ),
//                             ));
//                       }, text: "Add Funds",color: StaticColors.greenColor,),
//                   ),
//                   //redeem button
//                   Padding(
//                     padding: const EdgeInsets.only(right: 50),
//                     child: PrimaryBtn(
//                       textMaxSize: 32,
//                       textMinSize: 24,
//                       height: 170,
//                       width: 170,
//                       onPressed: (){
//                         PopupDialog.customDialog2(
//                           // borderColor: Colors.amber,
//                             width: 900,
//                             height: 470,
//                             // height: 600,
//                             child: Form(
//                               key: controller.formKey,
//                               child: Center(
//                                 child: Column(
//                                   // mainAxisAlignment: MainAxisAlignment.center,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     //crud number and price text field row
//                                     Row(
//                                       children: [
//                                         // ✅ Card Number
//                                         Expanded(
//                                           flex: 3,
//                                           child: SizedBox(
//                                             // color: Colors.red,
//                                             height: 180,
//                                             child: CustomTextField(
//                                               extralabeldownpadding:28,
//                                               padding: EdgeInsets.all(26),
//                                               errorStyle: TextStyle(
//                                                   height: 1,
//                                                   fontSize: 16,
//                                                   overflow: TextOverflow.ellipsis
//                                               ),
//                                               inputFormatters: [
//                                                 // FilteringTextInputFormatter.digitsOnly,
//                                                 CardNumberFormatter(),
//                                               ],
//                                               controller: controller.cardController,
//                                               hintText: "xxxx xxxx xxxx xxxxx",
//                                               extraLabel: "Card Number",
//                                               extraLabelFontSize: 40,
//
//                                               // extraLabelStyle: TextStyle(fontSize: 24,fontWeight: FontWeight.w900),
//                                               hintStyle: TextStyle(fontSize: 30),
//                                               style: TextStyle(
//                                                 fontSize: 30,
//                                                 color: Theme.of(context).colorScheme.surface,
//                                               ),
//                                               validator: (value) {
//                                                 if (value == null || value.trim().isEmpty) {
//                                                   return "Card number is required";
//                                                 }
//                                                 if (value.replaceAll("-", "").length < 12 ||
//                                                     value.replaceAll("-", "").length > 19) {
//                                                   return "Card number must be 12–19 digits";
//                                                 }
//                                                 return null;
//                                               },
//                                               onTap: () {
//                                                 CustomKeyboard.open(
//                                                   keyboardType: KeyboardType.number,
//                                                   onChange: (value) {
//                                                     String digits =
//                                                     value.replaceAll(RegExp(r'[^0-9]'), '');
//                                                     if (digits.length > 19) {
//                                                       digits = digits.substring(0, 19);
//                                                     }
//                                                     String newText = '';
//                                                     for (int i = 0; i < digits.length; i++) {
//                                                       if (i > 0 && i % 4 == 0) newText += '-';
//                                                       newText += digits[i];
//                                                     }
//                                                     controller.cardController.text = newText;
//                                                     controller.cardController.selection =
//                                                         TextSelection.fromPosition(
//                                                           TextPosition(offset: newText.length),
//                                                         );
//                                                   },
//                                                 );
//                                               },
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 40),
//
//                                         // ✅ Amount
//                                         Expanded(
//                                           child: Padding(
//                                             padding: const EdgeInsets.only(top: 10),
//                                             child: SizedBox(
//                                               height: 180,
//
//
//
//                                               child:CustomTextField(
//                                                 extralabeldownpadding:28,
//                                                 inputFormatters: [
//                                                   // FilteringTextInputFormatter.digitsOnly,
//                                                 ],
//                                                 padding: EdgeInsets.all(26),
//                                                 errorStyle: const TextStyle(
//                                                   fontSize: 16,
//                                                   height: 1,
//                                                   overflow: TextOverflow.fade,
//                                                 ),
//                                                 readOnly: true,
//                                                 controller: controller.amountController,
//                                                 extraLabelFontSize: 40,
//                                                 hintStyle: const TextStyle(fontSize: 30),
//                                                 hintText: "Amount",
//                                                 extraLabel: "Amount",
//                                                 style: TextStyle(
//                                                   fontSize: 30,
//                                                   color: Theme.of(context).colorScheme.surface,
//                                                 ),
//                                                 validator: (value) {
//                                                   if (value == null || value.trim().isEmpty) {
//                                                     return "Amount is required";
//                                                   }
//
//                                                   // ✅ শুধু সংখ্যা (integer বা decimal) allow
//                                                   final numberRegExp = RegExp(r'^\d+(\.\d+)?$');
//                                                   if (!numberRegExp.hasMatch(value)) {
//                                                     return "Only numeric values are allowed";
//                                                   }
//
//                                                   final numValue = num.tryParse(value);
//                                                   if (numValue == null) {
//                                                     return "Invalid number";
//                                                   }
//
//                                                   // ✅ Range check: 5–500 এর মধ্যে হতে হবে
//                                                   if (numValue < 5 || numValue > 500) {
//                                                     return "Amount must be between 5 and 500";
//                                                   }
//
//                                                   return null;
//                                                 },
//                                                 onTap: () {
//                                                   int initValue =
//                                                   ((num.tryParse(controller.amountController.text) ?? 0) * 100)
//                                                       .toInt();
//
//                                                   CustomKeyboard.open(
//                                                       keyboardType: KeyboardType.number,
//                                                       changeKeybordType: false,
//                                                       initialValue: initValue.toString(),
//                                                       // regExp: RegExp(r'^\d{0,5}(\.\d{0,2})?$'),
//                                                       // regExp: RegExp(r'^\d{0,7}$'),
//                                                       regExp: RegExp(r'^\d{0,6}$'),
//                                                       // regExp: RegExp(r'^(?:[0-9]{1,4}|[1-4][0-9]{4}|50000)$'),
//                                                       onChange: (value) {
//                                                         controller.amountController.text = value.toDecimalFormat();
//                                                         kLogger.e(value);
//                                                       });
//                                                   // int initValue =
//                                                   // ((num.tryParse(controller.amountController.text) ?? 0) * 100).toInt();
//                                                   //
//                                                   // CustomKeyboard.open(
//                                                   //   keyboardType: KeyboardType.number,
//                                                   //   changeKeybordType: false,
//                                                   //   initialValue: initValue.toString(),
//                                                   //   // ✅ 1 থেকে 3 digit + optional decimal
//                                                   //   regExp: RegExp(r'^\d{0,3}(\.\d{0,500})?$'),
//                                                   //   onChange: (value) {
//                                                   //     controller.amountController.text = value.toDecimalFormat();
//                                                   //   },
//                                                   // );
//                                                 },
//                                               ),
//
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: 30,),
//                                     PrimaryBtn(
//                                         textMaxSize: 32,
//                                         textMinSize: 24,
//                                         width: 140,
//                                         height: 120,
//                                         color:StaticColors.greenColor,
//
//                                         onPressed:  ()async {
//
//                                           if (controller.formKey.currentState!.validate()) {
//                                             bool isUpdate = await controller.commitTransaction();
//                                             // controller.fetchGiftCards();
//                                             if(isUpdate){
//                                               await  PrintUtils().directPrint(
//                                                   child:await dataCandyCardActivatePrintReceipt(cardActivate: controller.cardActivateModel.value ?? CardActivateModel(),
//                                                   ),
//                                                   printerName: Preferences.counterPrinter);
//                                             }else{
//                                               print("print card activate failed");
//                                             }
//                                             controller.textControllerRemove();
//                                             Get.back();
//
//                                           }
//                                         }, text: "Redeem")
//                                   ],
//                                 ),
//                               ),
//                             ));
//                       }, text: "Redeem",color: StaticColors.greenColor,),
//                   ),
//                   //cancel transaction button
//                   PrimaryBtn(
//                     textMaxSize: 32,
//                     textMinSize: 24,
//                     height: 170,
//                     width: 170,
//                     onPressed: (){
//                       PopupDialog.customDialog2(
//                         // borderColor: Colors.amber,
//                           width: 900,
//                           height: 700,
//                           // height: 600,
//                           child: Form(
//                             key: controller.formKey,
//                             child: Center(
//                               child: Column(
//                                 // mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   //crud number and price text field row
//                                   Row(
//                                     children: [
//                                       // ✅ Card Number
//                                       Expanded(
//                                         flex: 3,
//                                         child: SizedBox(
//                                           // color: Colors.red,
//                                           height: 180,
//                                           child: CustomTextField(
//                                             extralabeldownpadding:28,
//                                             padding: EdgeInsets.all(26),
//                                             errorStyle: TextStyle(
//                                                 height: 1,
//                                                 fontSize: 16,
//                                                 overflow: TextOverflow.ellipsis
//                                             ),
//                                             inputFormatters: [
//                                               // FilteringTextInputFormatter.digitsOnly,
//                                               CardNumberFormatter(),
//                                             ],
//                                             controller: controller.cardController,
//                                             hintText: "xxxx xxxx xxxx xxxxx",
//                                             extraLabel: "Card Number",
//                                             extraLabelFontSize: 40,
//
//                                             // extraLabelStyle: TextStyle(fontSize: 24,fontWeight: FontWeight.w900),
//                                             hintStyle: TextStyle(fontSize: 30),
//                                             style: TextStyle(
//                                               fontSize: 30,
//                                               color: Theme.of(context).colorScheme.surface,
//                                             ),
//                                             validator: (value) {
//                                               if (value == null || value.trim().isEmpty) {
//                                                 return "Card number is required";
//                                               }
//                                               if (value.replaceAll("-", "").length < 12 ||
//                                                   value.replaceAll("-", "").length > 19) {
//                                                 return "Card number must be 12–19 digits";
//                                               }
//                                               return null;
//                                             },
//                                             onTap: () {
//                                               CustomKeyboard.open(
//                                                 keyboardType: KeyboardType.number,
//                                                 onChange: (value) {
//                                                   String digits =
//                                                   value.replaceAll(RegExp(r'[^0-9]'), '');
//                                                   if (digits.length > 19) {
//                                                     digits = digits.substring(0, 19);
//                                                   }
//                                                   String newText = '';
//                                                   for (int i = 0; i < digits.length; i++) {
//                                                     if (i > 0 && i % 4 == 0) newText += '-';
//                                                     newText += digits[i];
//                                                   }
//                                                   controller.cardController.text = newText;
//                                                   controller.cardController.selection =
//                                                       TextSelection.fromPosition(
//                                                         TextPosition(offset: newText.length),
//                                                       );
//                                                 },
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 40),
//
//                                       // ✅ Amount
//                                       Expanded(
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(top: 10),
//                                           child: SizedBox(
//                                             height: 180,
//
//
//
//                                             child:CustomTextField(
//                                               extralabeldownpadding:28,
//                                               inputFormatters: [
//                                                 // FilteringTextInputFormatter.digitsOnly,
//                                               ],
//                                               padding: EdgeInsets.all(26),
//                                               errorStyle: const TextStyle(
//                                                 fontSize: 16,
//                                                 height: 1,
//                                                 overflow: TextOverflow.fade,
//                                               ),
//                                               readOnly: true,
//                                               controller: controller.amountController,
//                                               extraLabelFontSize: 40,
//                                               hintStyle: const TextStyle(fontSize: 30),
//                                               hintText: "Amount",
//                                               extraLabel: "Amount",
//                                               style: TextStyle(
//                                                 fontSize: 30,
//                                                 color: Theme.of(context).colorScheme.surface,
//                                               ),
//                                               validator: (value) {
//                                                 if (value == null || value.trim().isEmpty) {
//                                                   return "Amount is required";
//                                                 }
//
//                                                 // ✅ শুধু সংখ্যা (integer বা decimal) allow
//                                                 final numberRegExp = RegExp(r'^\d+(\.\d+)?$');
//                                                 if (!numberRegExp.hasMatch(value)) {
//                                                   return "Only numeric values are allowed";
//                                                 }
//
//                                                 final numValue = num.tryParse(value);
//                                                 if (numValue == null) {
//                                                   return "Invalid number";
//                                                 }
//
//                                                 // ✅ Range check: 5–500 এর মধ্যে হতে হবে
//                                                 if (numValue < 5 || numValue > 500) {
//                                                   return "Amount must be between 5 and 500";
//                                                 }
//
//                                                 return null;
//                                               },
//                                               onTap: () {
//                                                 int initValue =
//                                                 ((num.tryParse(controller.amountController.text) ?? 0) * 100)
//                                                     .toInt();
//
//                                                 CustomKeyboard.open(
//                                                     keyboardType: KeyboardType.number,
//                                                     changeKeybordType: false,
//                                                     initialValue: initValue.toString(),
//                                                     // regExp: RegExp(r'^\d{0,5}(\.\d{0,2})?$'),
//                                                     // regExp: RegExp(r'^\d{0,7}$'),
//                                                     regExp: RegExp(r'^\d{0,6}$'),
//                                                     // regExp: RegExp(r'^(?:[0-9]{1,4}|[1-4][0-9]{4}|50000)$'),
//                                                     onChange: (value) {
//                                                       controller.amountController.text = value.toDecimalFormat();
//                                                       kLogger.e(value);
//                                                     });
//                                                 // int initValue =
//                                                 // ((num.tryParse(controller.amountController.text) ?? 0) * 100).toInt();
//                                                 //
//                                                 // CustomKeyboard.open(
//                                                 //   keyboardType: KeyboardType.number,
//                                                 //   changeKeybordType: false,
//                                                 //   initialValue: initValue.toString(),
//                                                 //   // ✅ 1 থেকে 3 digit + optional decimal
//                                                 //   regExp: RegExp(r'^\d{0,3}(\.\d{0,500})?$'),
//                                                 //   onChange: (value) {
//                                                 //     controller.amountController.text = value.toDecimalFormat();
//                                                 //   },
//                                                 // );
//                                               },
//                                             ),
//
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 30,),
//                                   Row(
//                                     children: [
//                                       // ✅ Confirmation No.
//                                       Expanded(
//                                         child: SizedBox(
//                                           height: 180,
//                                           child: CustomTextField(
//                                             extralabeldownpadding: 28,
//                                             padding: const EdgeInsets.all(26),
//                                             errorStyle: const TextStyle(
//                                               height: 1,
//                                               fontSize: 16,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                             inputFormatters: [
//                                               FilteringTextInputFormatter.digitsOnly,
//                                               LengthLimitingTextInputFormatter(5), // ✅ max 5 digit
//                                             ],
//                                             controller: controller.tcnController,
//                                             hintText: "Confirmation No.",
//                                             extraLabel: "Confirmation No.",
//                                             extraLabelFontSize: 40,
//                                             hintStyle: const TextStyle(fontSize: 30),
//                                             style: TextStyle(
//                                               fontSize: 30,
//                                               color: Theme.of(context).colorScheme.surface,
//                                             ),
//                                             validator: (value) {
//                                               if (value == null || value.trim().isEmpty) {
//                                                 return "Confirmation No. is required";
//                                               }
//                                               if (value.length != 5) {
//                                                 return "Confirmation No. must be exactly 5 digits";
//                                               }
//                                               return null;
//
//
//                                             },
//                                             onTap: () {
//                                               CustomKeyboard.open(
//                                                 keyboardType: KeyboardType.number,
//                                                 changeKeybordType: false,
//                                                 regExp: RegExp(r'^\d{0,5}$'), // ✅ 0–5 digit only
//                                                 initialValue: controller.tcnController.text,
//                                                 onChange: (value) {
//                                                   controller.tcnController.text = value;
//                                                   controller.tcnController.selection =
//                                                       TextSelection.fromPosition(
//                                                         TextPosition(offset: value.length),
//                                                       );
//                                                 },
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 40),
//
//                                       // ✅ Invoice No.
//                                       Expanded(
//                                         child: SizedBox(
//                                           height: 180,
//                                           child: CustomTextField(
//                                             extralabeldownpadding: 28,
//                                             padding: const EdgeInsets.all(26),
//                                             errorStyle: const TextStyle(
//                                               fontSize: 16,
//                                               height: 1,
//                                               overflow: TextOverflow.fade,
//                                             ),
//                                             inputFormatters: [
//                                               FilteringTextInputFormatter.digitsOnly,
//                                               LengthLimitingTextInputFormatter(4), // ✅ max 4 digit
//                                             ],
//                                             controller: controller.invoiceController,
//                                             hintText: "Invoice No.",
//                                             extraLabel: "Invoice No.",
//                                             extraLabelFontSize: 40,
//                                             hintStyle: const TextStyle(fontSize: 30),
//                                             style: TextStyle(
//                                               fontSize: 30,
//                                               color: Theme.of(context).colorScheme.surface,
//                                             ),
//                                             validator: (value) {
//                                               if (value == null || value.trim().isEmpty) {
//                                                 return "Invoice No. is required";
//                                               }
//                                               if (value.length != 4) {
//                                                 return "Invoice No. must be exactly 4 digits";
//                                               }
//                                               return null;
//                                             },
//                                             onTap: () {
//                                               CustomKeyboard.open(
//                                                 keyboardType: KeyboardType.number,
//                                                 changeKeybordType: false,
//                                                 regExp: RegExp(r'^\d{0,4}$'), // ✅ 0–4 digit only
//                                                 initialValue: controller.invoiceController.text,
//                                                 onChange: (value) {
//                                                   controller.invoiceController.text = value;
//                                                   controller.invoiceController.selection =
//                                                       TextSelection.fromPosition(
//                                                         TextPosition(offset: value.length),
//                                                       );
//                                                 },
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//
//                                   SizedBox(height: 30,),
//                                   PrimaryBtn(
//                                       textMaxSize: 32,
//                                       textMinSize: 24,
//                                       width: 140,
//                                       height: 120,
//                                       color:StaticColors.orangeColor,
//
//                                       onPressed:  ()async {
//
//                                         if (controller.formKey.currentState!.validate()) {
//                                           bool isUpdate = await controller.commitTransaction();
//                                           // controller.fetchGiftCards();
//                                           if(isUpdate){
//                                             await  PrintUtils().directPrint(
//                                                 child:await dataCandyCardActivatePrintReceipt(cardActivate: controller.cardActivateModel.value ?? CardActivateModel(),
//                                                 ),
//                                                 printerName: Preferences.counterPrinter);
//                                           }else{
//                                             print("print card activate failed");
//                                           }
//                                           controller.textControllerRemove();
//                                           Get.back();
//
//                                         }
//                                       }, text: "Cancel Trans.")
//                                 ],
//                               ),
//                             ),
//                           ));
//                     }, text: "Cancel Transaction",color: StaticColors.orangeColor,),
//
//                 ],
//               ),
//             ),
//             SizedBox(height: 100,),
//             Row(
//               // mainAxisAlignment: MainAxisAlignment.spaceAround,
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 //check balance button
//                 PrimaryBtn(
//                   textMaxSize: 32,
//                   textMinSize: 24,
//                   height: 170,
//                   width: 170,
//                   onPressed: (){
//                     PopupDialog.customDialog2(
//                       // borderColor: Colors.amber,
//                         width: 900,
//                         height: 470,
//                         // height: 600,
//                         child: Form(
//                           key: controller.formKey,
//                           child: Center(
//                             child: Column(
//                               // mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 //crud number and price text field row
//                                 Row(
//                                   children: [
//                                     // ✅ Card Number
//                                     Expanded(
//                                       flex: 3,
//                                       child: SizedBox(
//                                         // color: Colors.red,
//                                         height: 180,
//                                         child: CustomTextField(
//                                           extralabeldownpadding:28,
//                                           padding: EdgeInsets.all(26),
//                                           errorStyle: TextStyle(
//                                               height: 1,
//                                               fontSize: 16,
//                                               overflow: TextOverflow.ellipsis
//                                           ),
//                                           inputFormatters: [
//                                             // FilteringTextInputFormatter.digitsOnly,
//                                             CardNumberFormatter(),
//                                           ],
//                                           controller: controller.cardController,
//                                           hintText: "xxxx xxxx xxxx xxxxx",
//                                           extraLabel: "Card Number",
//                                           extraLabelFontSize: 40,
//
//                                           // extraLabelStyle: TextStyle(fontSize: 24,fontWeight: FontWeight.w900),
//                                           hintStyle: TextStyle(fontSize: 30),
//                                           style: TextStyle(
//                                             fontSize: 30,
//                                             color: Theme.of(context).colorScheme.surface,
//                                           ),
//                                           validator: (value) {
//                                             if (value == null || value.trim().isEmpty) {
//                                               return "Card number is required";
//                                             }
//                                             if (value.replaceAll("-", "").length < 12 ||
//                                                 value.replaceAll("-", "").length > 19) {
//                                               return "Card number must be 12–19 digits";
//                                             }
//                                             return null;
//                                           },
//                                           onTap: () {
//                                             CustomKeyboard.open(
//                                               keyboardType: KeyboardType.number,
//                                               onChange: (value) {
//                                                 String digits =
//                                                 value.replaceAll(RegExp(r'[^0-9]'), '');
//                                                 if (digits.length > 19) {
//                                                   digits = digits.substring(0, 19);
//                                                 }
//                                                 String newText = '';
//                                                 for (int i = 0; i < digits.length; i++) {
//                                                   if (i > 0 && i % 4 == 0) newText += '-';
//                                                   newText += digits[i];
//                                                 }
//                                                 controller.cardController.text = newText;
//                                                 controller.cardController.selection =
//                                                     TextSelection.fromPosition(
//                                                       TextPosition(offset: newText.length),
//                                                     );
//                                               },
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 40),
//
//                                     // ✅ Amount
//
//                                   ],
//                                 ),
//                                 SizedBox(height: 30,),
//                                 PrimaryBtn(
//                                     textMaxSize: 32,
//                                     textMinSize: 24,
//                                     width: 140,
//                                     height: 120,
//                                     color:StaticColors.greenColor,
//
//                                     onPressed:  ()async {
//
//                                       if (controller.formKey.currentState!.validate()) {
//                                         bool isUpdate = await controller.commitTransaction();
//                                         // controller.fetchGiftCards();
//                                         if(isUpdate){
//                                           await  PrintUtils().directPrint(
//                                               child:await dataCandyCardActivatePrintReceipt(cardActivate: controller.cardActivateModel.value ?? CardActivateModel(),
//                                               ),
//                                               printerName: Preferences.counterPrinter);
//                                         }else{
//                                           print("print card activate failed");
//                                         }
//                                         controller.textControllerRemove();
//                                         Get.back();
//
//                                       }
//                                     }, text: "Check Balance")
//                               ],
//                             ),
//                           ),
//                         ));
//                   }, text: "Check Balance",color: StaticColors.greenColor,),
//
//               ],
//             )
//           ],
//         ),
//     );
//   }
// }
