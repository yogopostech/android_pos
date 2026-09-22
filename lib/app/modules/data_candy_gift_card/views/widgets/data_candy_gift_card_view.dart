// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:yogo_pos/app/modules/custom_keyboard/custom_keyboard.dart';
// import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/gift_card_controller.dart';
// import 'package:yogo_pos/app/modules/data_candy_gift_card/models/all_card_data_candy_model.dart';
// import 'package:yogo_pos/app/modules/data_candy_gift_card/models/card_activate_model.dart';
// import 'package:yogo_pos/app/modules/data_candy_gift_card/views/widgets/gift_card_table.dart';
// import 'package:yogo_pos/app/routes/app_pages.dart';
// import 'package:yogo_pos/app/services/base/preferences.dart';
// import 'package:yogo_pos/app/utils/extension/string_manipulation_extension.dart';
// import 'package:yogo_pos/app/utils/print_utils.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';
// import 'package:yogo_pos/app/widgets/custom_btn.dart';
// import 'package:yogo_pos/app/widgets/custom_textfield.dart';
// import 'package:yogo_pos/app/widgets/my_custom_text.dart' show MyCustomText;
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
//
// import '../../../../utils/logger.dart';
// import '../../../../widgets/custom_pagination.dart';
// import '../../print_receipt/card_activate_receipt.dart';
// import '../screens/transaction_details_page.dart';
//
// class DataCandyGiftCardView extends StatefulWidget {
//   const DataCandyGiftCardView({super.key});
//
//   @override
//   State<DataCandyGiftCardView> createState() => _DataCandyGiftCardViewState();
// }
//
// class _DataCandyGiftCardViewState extends State<DataCandyGiftCardView> {
//   GiftCardController controller = Get.find<GiftCardController>();
//   @override
//   void initState() {
//     super.initState();
//     controller.nameController.addListener(() {
//       final text = controller.nameController.text;
//       if (text != text.toUpperCase()) {
//         controller.nameController.value = controller.nameController.value.copyWith(
//           text: text.toUpperCase(),
//           selection: TextSelection.collapsed(offset: text.length),
//         );
//       }
//     });
//
//     // ✅ Phone number formatting listener
//     controller.phoneController.addListener(() {
//       String text = controller.phoneController.text;
//       String digits = text.replaceAll(RegExp(r'[^0-9]'), '');
//
//       if (digits.length > 10) {
//         digits = digits.substring(0, 10);
//       }
//
//       String newText = '';
//       if (digits.isNotEmpty) {
//         newText = digits.substring(0, digits.length.clamp(0, 3));
//       }
//       if (digits.length > 3) {
//         newText += '-' + digits.substring(3, digits.length.clamp(3, 6));
//       }
//       if (digits.length > 6) {
//         newText += '-' + digits.substring(6, digits.length);
//       }
//
//       if (newText != controller.phoneController.text) {
//         controller.phoneController.value = controller.phoneController.value.copyWith(
//           text: newText,
//           selection: TextSelection.collapsed(offset: newText.length),
//         );
//       }
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//
//     String lastValidValue = "";
//     final theme = Theme.of(context);
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//
//
//               // ✅ Amount field
//               Form(
//                 key: controller.searchFormKey,
//                 child: Row(
//                   children: [
//
//                     Padding(
//                       padding: const EdgeInsets.only(top: 10),
//                       child: Container(
//                         // color: Colors.red,
//                         height: 130,
//                         width: 450,
//                         child: CustomTextField(
//                           padding: EdgeInsets.all(23),
//
//                           inputFormatters: [
//
//                               // FilteringTextInputFormatter.digitsOnly,
//                               CardNumberFormatter(),
//
//                           ],
//                           controller: controller.searchController,
//                           extraLabel: "Card Number",
//                           extraLabelFontSize: 24,
//
//                           hintText: "Search by Card No. & Phone No.",
//                           hintStyle: TextStyle(fontSize: 20),
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return "Card number is required";
//                             }
//                             if (
//                                 value.replaceAll("-", "").length > 19) {
//                               return "Card number cannot be more than 19 digits";
//                             }
//                             return null;
//                           },
//
//                           // extraLabel: "Card Number",
//                           fontSize: 20,
//                           style: TextStyle(
//                             fontSize: 20,
//                             color: Theme.of(context).colorScheme.surface,
//                           ),
//                           onChange: (value){
//                             String pureNumber = value.replaceAll("-", "");
//                             debugPrint("Digits: $pureNumber");
//                           },
//                           onTap: () {
//                             CustomKeyboard.open(
//                               keyboardType: KeyboardType.number,
//                               onChange: (value) {
//                                 String formatCardNumber(String input) {
//                                   String digits = input.replaceAll(RegExp(r'[^0-9]'), '');
//                                   if (digits.length > 19) {
//                                     digits = digits.substring(0, 19);
//                                   }
//                                   String newText = '';
//                                   for (int i = 0; i < digits.length; i++) {
//                                     if (i > 0 && i % 4 == 0) newText += '-';
//                                     newText += digits[i];
//                                   }
//                                   return newText;
//                                 }
//                                 String formattedValue = formatCardNumber(value);
//                                 controller.searchController.text = formattedValue;
//                                 controller.searchController.selection = TextSelection.fromPosition(
//                                   TextPosition(offset: formattedValue.length),
//                                 );
//
//                                 // controller.searchController.text = value;
//                                 // controller.searchController.selection =
//                                 //     TextSelection.fromPosition(
//                                 //   TextPosition(
//                                 //     offset: controller.searchController.text.length,
//                                 //   ),
//                                 // );
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 30),
//                     // ✅ Amount field
//
//                     Padding(
//                       padding: const EdgeInsets.only(top: 18),
//                       child: PrimaryBtn(
//                         height: 70,
//                         width: 220,
//                         color: StaticColors.greenColor,
//                         onPressed: () {
//                           if (controller.searchFormKey.currentState!.validate()) {
//                             controller.fetchGiftCards(
//                               search: controller.searchController.text.replaceAll("-", "").trim(),
//                             );
//                           }
//                           // controller.fetchGiftCards(search: controller.searchController.text.replaceAll("-", "").trim());
//                         },
//                         text: "Search",
//                         textMaxSize: 24,
//                         textMinSize: 18,
//                         style: TextStyle(fontSize: 50,letterSpacing: 1.5),
//                       ),
//                     ),
//                       SizedBox(width: 30,),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 18),
//                       child: PrimaryBtn(
//                         height: 70,
//                         width: 220,
//                         color: StaticColors.orangeColor,
//                         onPressed: () {
//
//                             controller.fetchGiftCards(
//
//                             );
//                             controller.textControllerRemove();
//
//                           // controller.fetchGiftCards(search: controller.searchController.text.replaceAll("-", "").trim());
//                         },
//                         text: "Clear",
//                         textMaxSize: 24,
//                         textMinSize: 18,
//                         style: TextStyle(fontSize: 50,letterSpacing: 1.5),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(top: 27),
//                     child: PrimaryBtn(
//                       textMaxSize: 24,
//                       textMinSize: 24,
//                       height: 70,
//                       width: 220,
//                       color: StaticColors.greenColor,
//                       onPressed: () {
//                         PopupDialog.customDialog(
//                           width: 800,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 35),
//                             child: Form(
//                               key: controller.formKey, // ✅ Form key
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       // ✅ Card Number
//                                       Expanded(
//                                         flex: 3,
//                                         child: SizedBox(
//                                           // color: Colors.red,
//                                           height: 130,
//                                           child: CustomTextField(
//                                             padding: EdgeInsets.all(22),
//                                             errorStyle: TextStyle(
//                                               height: 1,
//                                               overflow: TextOverflow.ellipsis
//                                             ),
//                                             inputFormatters: [
//                                               // FilteringTextInputFormatter.digitsOnly,
//                                               CardNumberFormatter(),
//                                             ],
//                                             controller: controller.cardController,
//                                             hintText: "xxxx xxxx xxxx xxxxx",
//                                             extraLabel: "Card Number",
//                                             extraLabelFontSize: 24,
//                                             // extraLabelStyle: TextStyle(fontSize: 24,fontWeight: FontWeight.w900),
//                                             hintStyle: TextStyle(fontSize: 20),
//                                             style: TextStyle(
//                                               fontSize: 22,
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
//                                       const SizedBox(width: 20),
//
//                                       // ✅ Amount
//                                       Expanded(
//                                         child: SizedBox(
//                                           height: 135,
//
//
//
//                                           child:CustomTextField(
//                                             inputFormatters: [
//                                               // FilteringTextInputFormatter.digitsOnly,
//                                             ],
//                                             padding: EdgeInsets.all(22),
//                                             errorStyle: const TextStyle(
//                                               height: 1,
//                                               overflow: TextOverflow.fade,
//                                             ),
//                                             readOnly: true,
//                                             controller: controller.amountController,
//                                             extraLabelFontSize: 24,
//                                             hintStyle: const TextStyle(fontSize: 20),
//                                             hintText: "Amount",
//                                             extraLabel: "Amount",
//                                             style: TextStyle(
//                                               fontSize: 22,
//                                               color: Theme.of(context).colorScheme.surface,
//                                             ),
//                                             validator: (value) {
//                                               if (value == null || value.trim().isEmpty) {
//                                                 return "Amount is required";
//                                               }
//
//                                               // ✅ শুধু সংখ্যা (integer বা decimal) allow
//                                               final numberRegExp = RegExp(r'^\d+(\.\d+)?$');
//                                               if (!numberRegExp.hasMatch(value)) {
//                                                 return "Only numeric values are allowed";
//                                               }
//
//                                               final numValue = num.tryParse(value);
//                                               if (numValue == null) {
//                                                 return "Invalid number";
//                                               }
//
//                                               // ✅ Range check: 5–500 এর মধ্যে হতে হবে
//                                               if (numValue < 5 || numValue > 500) {
//                                                 return "Amount must be between 5 and 500";
//                                               }
//
//                                               return null;
//                                             },
//                                             onTap: () {
//                                               int initValue =
//                                               ((num.tryParse(controller.amountController.text) ?? 0) * 100)
//                                                   .toInt();
//
//                                               CustomKeyboard.open(
//                                                   keyboardType: KeyboardType.number,
//                                                   changeKeybordType: false,
//                                                   initialValue: initValue.toString(),
//                                                   // regExp: RegExp(r'^\d{0,5}(\.\d{0,2})?$'),
//                                                   // regExp: RegExp(r'^\d{0,7}$'),
//                                                   regExp: RegExp(r'^\d{0,6}$'),
//                                                   // regExp: RegExp(r'^(?:[0-9]{1,4}|[1-4][0-9]{4}|50000)$'),
//                                                   onChange: (value) {
//                                                     controller.amountController.text = value.toDecimalFormat();
//                                                     kLogger.e(value);
//                                                   });
//                                               // int initValue =
//                                               // ((num.tryParse(controller.amountController.text) ?? 0) * 100).toInt();
//                                               //
//                                               // CustomKeyboard.open(
//                                               //   keyboardType: KeyboardType.number,
//                                               //   changeKeybordType: false,
//                                               //   initialValue: initValue.toString(),
//                                               //   // ✅ 1 থেকে 3 digit + optional decimal
//                                               //   regExp: RegExp(r'^\d{0,3}(\.\d{0,500})?$'),
//                                               //   onChange: (value) {
//                                               //     controller.amountController.text = value.toDecimalFormat();
//                                               //   },
//                                               // );
//                                             },
//                                           ),
//
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//
//                                   const SizedBox(height: 20),
//
//                                   Row(
//                                     children: [
//                                       // ✅ Name
//                                       Expanded(
//                                         child: SizedBox(
//                                           height:130,
//                                           child: CustomTextField(
//                                             errorStyle: TextStyle(
//                                               height: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                             controller: controller.nameController,
//                                             padding: EdgeInsets.all(22),
//                                             hintText: "Name",
//                                             extraLabel: "Customer Name",
//                                             extraLabelFontSize: 24,
//                                             hintStyle: TextStyle(fontSize: 20),
//                                             style: TextStyle(
//                                               fontSize: 20,
//                                               color: Theme.of(context).colorScheme.surface,
//                                             ),
//                                             inputFormatters: [
//                                               LengthLimitingTextInputFormatter(20), // ✅ max 20 char
//                                             ],
//                                             validator: (value) {
//                                               if (value == null || value.trim().isEmpty) {
//                                                 return "Name is required";
//                                               }
//                                               if (value.length > 20) {
//                                                 return "Name cannot be more than 20 characters";
//                                               }
//                                               return null;
//                                             },
//                                             onTap: () {
//                                               CustomKeyboard.open(
//                                                 keyboardType: KeyboardType.alphabet,
//                                                 onChange: (value) {
//                                                   final upperValue = value.toUpperCase();
//                                                   if (upperValue.length <= 20) {   // ✅ max 20 check for custom keyboard
//                                                     controller.nameController.text = upperValue;
//                                                     controller.nameController.selection = TextSelection.fromPosition(
//                                                       TextPosition(offset: upperValue.length),
//                                                     );
//                                                   }
//                                                 },
//                                               );
//                                             },
//                                           ),
//
//                                         ),
//                                       ),
//                                       const SizedBox(width: 20),
//
//                                       // ✅ Phone Number
//                                       Expanded(
//                                         child: SizedBox(
//                                           height: 130,
//                                           child: CustomTextField(
//                                             // read
//                                            inputFormatters: [
//
//                                            ],
//                                             hintStyle: TextStyle(fontSize: 20),
//                                           extraLabelFontSize: 24,
//                                           padding: EdgeInsets.all(22),
//
//                                           readOnly: false,
//                                             errorStyle: TextStyle(
//                                               height: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                             controller: controller.phoneController,
//                                             hintText: "Phone No.",
//                                             extraLabel: "Phone No.",
//                                             style: TextStyle(
//                                               fontSize: 22,
//                                               color: Theme.of(context).colorScheme.surface,
//                                             ),
//                                             validator: (value) {
//                                               if (value == null || value.trim().isEmpty) {
//                                                 return "Phone No. is required";
//                                               }
//                                               if (value.replaceAll("-", "").length != 10) {
//                                                 return "Enter a valid phone number";
//                                               }
//                                               return null;
//                                             },
//                                             onTap: () {
//                                               CustomKeyboard.open(
//                                                 keyboardType: KeyboardType.number,
//                                                 onChange: (value) {
//
//                                                   String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
//
//
//                                                   if (digits.length > 10) {
//                                                     digits = digits.substring(0, 10);
//                                                   }
//
//
//                                                   String newText = '';
//                                                   if (digits.length > 0) {
//                                                     newText = digits.substring(0, digits.length.clamp(0, 3));
//                                                   }
//                                                   if (digits.length > 3) {
//                                                     newText += '-' + digits.substring(3, digits.length.clamp(3, 6));
//                                                   }
//                                                   if (digits.length > 6) {
//                                                     newText += '-' + digits.substring(6, digits.length);
//                                                   }
//
//                                                   controller.phoneController.text = newText;
//                                                   controller.phoneController.selection = TextSelection.fromPosition(
//                                                     TextPosition(offset: newText.length),
//                                                   );
//                                                 },
//                                               );
//                                             },
//                                           ),
//                                         )
//
//                                       ),
//                                     ],
//                                   ),
//
//                                   const SizedBox(height: 35),
//
//                                   // ✅ Submit Button
//                                   PrimaryBtn(
//                                     width: 120,
//                                     height: 90,
//                                     color: StaticColors.greenColor,
//                                     onPressed: ()async {
//
//                                       if (controller.formKey.currentState!.validate()) {
//                                        bool isUpdate = await controller.commitTransaction();
//                                         controller.fetchGiftCards();
//                                         if(isUpdate){
//                                         await  PrintUtils().directPrint(
//                                               child:await dataCandyCardActivatePrintReceipt(cardActivate: controller.cardActivateModel.value ?? CardActivateModel(),
//                                                    ),
//                                               printerName: Preferences.counterPrinter);
//                                         }else{
//                                           print("print card activate failed");
//                                         }
//                                         controller.textControllerRemove();
//                                         Get.back();
//
//                                       }
//                                     },
//                                     text: "Activate Card",
//                                     fontWeight: FontWeight.w900,
//
//
//                                     textMaxSize: 24,
//                                     textMinSize: 18,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//
//
//                       },
//                       text: "Add Card",
//                       style: TextStyle(fontSize: 12,letterSpacing: 1.5),
//                     ),
//                   ),
//
//                 ],
//               ),
//
//
//             ],
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           Expanded(
//             child: GiftCardTableWidget(),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 GetBuilder<GiftCardController>(
//                     builder: (controller) {
//                       return CustomPagination(
//                         numOfPages:
//                         controller.metaModel?.totalPages ?? 1,
//                         selectedPage:
//                         controller.metaModel?.currentPage ?? 1,
//                         pagesVisible: 5,
//                         onPageChanged: (page) async {
//                           debugPrint("data is coming");
//                           await controller.fetchGiftCards(page: "$page");
//                           debugPrint("data is coming");
//                         },
//                       );
//                     })
//               ],
//             ),
//           )
//
//         ],
//       ),
//     );
//   }
// }
