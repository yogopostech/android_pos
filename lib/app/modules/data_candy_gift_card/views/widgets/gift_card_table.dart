//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:yogo_pos/app/modules/custom_keyboard/custom_keyboard.dart';
// import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/gift_card_controller.dart';
// import 'package:yogo_pos/app/modules/data_candy_gift_card/models/all_card_data_candy_model.dart';
// import 'package:yogo_pos/app/modules/data_candy_gift_card/models/increment_balance_model.dart';
// import 'package:yogo_pos/app/modules/data_candy_gift_card/views/screens/transaction_details_page.dart';
// import 'package:yogo_pos/app/services/base/preferences.dart';
// import 'package:yogo_pos/app/utils/extension/my_extension.dart';
// import 'package:yogo_pos/app/utils/extension/string_manipulation_extension.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';
// import 'package:yogo_pos/app/widgets/custom_btn.dart';
// import 'package:yogo_pos/app/widgets/custom_textfield.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
//
// import '../../../../utils/logger.dart';
// import '../../../../utils/print_utils.dart';
// import '../../../../widgets/my_custom_text.dart';
// import '../../print_receipt/data_candy_balance_check_receipt.dart';
// import '../../print_receipt/data_candy_increment_receipt.dart';
//
// class GiftCardTableWidget extends StatelessWidget {
//   const GiftCardTableWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     GiftCardController controller = Get.find<GiftCardController>();
//     return GetX<GiftCardController>(
//       builder: (controller) {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (controller.cards.isEmpty) {
//           return const Center(child: MyCustomText("No Gift Cards Found",fontSize: 35,));
//         }
//
//         return SfDataGrid(
//           // footerFrozenColumnsCount: 1,
//           // frozenColumnsCount: 7,
//           // frozenRowsCount: 7,
//           source: GiftCardDataSource(controller.cards, context),
//           rowHeight: 85,
//
//           // columnWidthMode: ColumnWidthMode.auto,
//           columnWidthMode: ColumnWidthMode.fill,
//            onCellTap: (DataGridCellTapDetails details) {
//             if (details.rowColumnIndex.rowIndex > 0) { // header বাদ
//               final rowIndex = details.rowColumnIndex.rowIndex - 1;
//               final card = controller.cards[rowIndex]; // selected card
//
//               // ✅ Transaction Details Page এ navigate
//
//               Get.to(() => GiftCardTransactionDetailsPage(card: card));
//                 // Get.to(() => GiftCardTransactionDetailsPage(card: card));
//             }
//           },
//           columns: <GridColumn>[
//             // GridColumn(
//             //   columnName: 'actions',
//             //   label: const Center(
//             //     child: Text('Actions',
//             //         style: TextStyle(fontWeight: FontWeight.bold)),
//             //   ),
//             // ),
//             GridColumn(
//               columnName: 'cid',
//               label: const Center(
//                 child: Text('Card No.',
//                     style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24)),
//               ),
//             ),
//             GridColumn(
//               columnName: 'customerName',
//               label: const Center(
//                 child: Text('Name',
//                     style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24)),
//               ),
//             ),
//             GridColumn(
//               columnName: 'customerPhone',
//               label: const Center(
//                 child: Text('Phone No.',
//                     style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24)),
//               ),
//             ),
//             GridColumn(
//               columnName: 'createdAt',
//               label: const Center(
//                 child: Text('Start Date',
//                     style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24)),
//               ),
//             ),
//             GridColumn(
//               columnName: 'lastTransactionDate',
//               label: const Center(
//                 child: Text('Last Transaction',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//               ),
//             ),
//             // GridColumn(
//             //   columnName: 'balance',
//             //   label: const Center(
//             //     child: Text('Balance',
//             //         style: TextStyle(fontWeight: FontWeight.bold)),
//             //   ),
//             // ),
//             // ✅ Only one "Actions" column
//             GridColumn(
//               columnName: 'actions',
//               width: 450, // ✅ Fixed width (change as you need)
//               label: const Center(
//                 child: Text(
//                   'Actions',
//                   style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class GiftCardDataSource extends DataGridSource {
//   GiftCardDataSource(this.cards, this.context) {
//     _rows = cards.map<DataGridRow>((card) {
//       String maskCardNumber(String cardNo) {
//         if (cardNo.length < 8) return cardNo;
//         String first4 = cardNo.substring(0, 4);
//         String last4 = cardNo.substring(cardNo.length - 4);
//         String masked = List.filled(cardNo.length - 8, "X").join();
//         return "$first4$masked$last4";
//       }
//       String formatCardNumber(String input) {
//         // Remove non-digits (in case input has unexpected characters)
//         String digits = input.replaceAll(RegExp(r'[^0-9]'), '');
//
//         // Limit to max 19 digits
//         if (digits.length > 19) {
//           digits = digits.substring(0, 19);
//         }
//
//         // Group digits in 4s with dashes
//         String newText = '';
//         for (int i = 0; i < digits.length; i++) {
//           if (i > 0 && i % 4 == 0) newText += '-';
//           newText += digits[i];
//         }
//
//         return newText;
//       }
//
//       String formatPhoneNumber(String phone) {
//
//         final digits = phone.replaceAll(RegExp(r'\D'), '');
//
//         if (digits.length < 10) {
//
//           return phone.trim();
//         }
//
//
//         final last10 = digits.substring(digits.length - 10);
//
//         return '${last10.substring(0, 3)}-${last10.substring(3, 6)}-${last10.substring(6, 10)}';
//       }
//       return DataGridRow(cells: [
//
//         DataGridCell(columnName: 'cid', value:maskCardNumber(card.cid) ),
//         DataGridCell(columnName: 'customerName', value: card.customerName),
//         DataGridCell(columnName: 'customerPhone', value: formatPhoneNumber(card.customerPhone ?? "")),
//         DataGridCell(columnName: 'createdAt', value: card.createdAt.toFormattedDate()),
//         DataGridCell(
//             columnName: 'lastTransactionDate',
//             value: card.lastTransactionDate.toLocal()),
//         DataGridCell(columnName: 'actions', value: card),
//         // DataGridCell(columnName: 'balance', value: "\$${card.balance}"),
//         // ✅ all buttons here
//       ]);
//     }).toList();
//   }
//
//   final List<GiftCardModel> cards;
//   final BuildContext context;
//   late final List<DataGridRow> _rows;
//
//   @override
//   List<DataGridRow> get rows => _rows;
//
//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     GiftCardController controller = Get.find<GiftCardController>();
//     return DataGridRowAdapter(
//       cells: row.getCells().map<Widget>((cell) {
//         if (cell.columnName == 'actions') {
//           final card = cell.value as GiftCardModel;
//           return Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _actionBtn("Redeem", () {
//                  PopupDialog.customDialog1(
//                   width: 600,
//                   height: 200,
//                   child: Center(
//                     child: Container(
//                       // color: Colors.red,
//                       height: 130,
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child:Form(
//                               key: controller.redeemtFormKey,
//                               child: CustomTextField(
//                                 padding: EdgeInsets.all(22),
//                                 readOnly: true,
//                                 controller: controller.redeemController,
//                                 extraLabel: "Redeem Balance",
//                                 extraLabelFontSize: 24,
//                                 extraLabelStyle: TextStyle(fontWeight: FontWeight.w700),
//                                 hintText: "Balance",
//                                 hintStyle: TextStyle(fontSize: 20),
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   color: Theme.of(context).colorScheme.surface,
//                                 ),
//                                 validator: (value) {
//                                   if (value == null || value.trim().isEmpty) {
//                                     return "Amount is required";
//                                   }
//
//                                   // শুধু সংখ্যা allow
//                                   final numberRegExp = RegExp(r'^\d+(\.\d+)?$');
//                                   if (!numberRegExp.hasMatch(value)) {
//                                     return "Only numeric values are allowed";
//                                   }
//
//                                   final numValue = num.tryParse(value);
//                                   if (numValue == null) {
//                                     return "Invalid number";
//                                   }
//
//                                   // 0–500 এর মধ্যে check
//                                   if (numValue < 0 || numValue > 500) {
//                                     return "Amount must be between 0 and 500";
//                                   }
//
//                                   return null;
//                                 },
//                                 onTap: () {
//                                   int initValue =
//                                   ((num.tryParse(controller.redeemController.text) ?? 0) * 100)
//                                       .toInt();
//
//                                   CustomKeyboard.open(
//                                     keyboardType: KeyboardType.number,
//                                     changeKeybordType: false,
//                                     initialValue: initValue.toString(),
//                                     // 0–50000 cent (0–500) limit enforced
//                                     regExp: RegExp(r'^\d{0,6}$'),
//                                     // regExp: RegExp(r'^(?:[0-9]{1,2}|[0-4][0-9]{2}|500)$'),
//                                     onChange: (value) {
//                                       // decimal format e convert
//                                       controller.redeemController.text = value.toDecimalFormat();
//                                     },
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 7),
//                             child: PrimaryBtn(
//                               height: 70,
//                               textMaxSize: 20,
//                               textMinSize: 20,
//                               color: StaticColors.greenColor,
//                               onPressed: () async {
//                                 if (controller.redeemtFormKey.currentState!.validate()) {
//                                   await controller.redeemBalance(
//
//
//                                   );
//                                   controller.fetchGiftCards();
//                                   Get.back();
//                                   print("amount is: ${controller.redeemController.text}");
//                                 } else {
//                                   // validator failed হলে error দেখাবে
//                                   print("Validation failed");
//                                 }
//                               },
//                               text: "Adjust Balance",
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//
//                 print("Redeem clicked for card number: ${card.cid}");
//               }, StaticColors.blueColor),
//               const SizedBox(width: 20),
//               _actionBtn("Recharge", () {
//                 // PopupDialog.customDialog1(
//                 //   width: 600,
//                 //   height: 200,
//                 //   child: Center(
//                 //     child: Container(
//                 //       // color: Colors.red,
//                 //       height: 130,
//                 //       child: Row(
//                 //         crossAxisAlignment: CrossAxisAlignment.center,
//                 //         children: [
//                 //           Expanded(
//                 //             child: Form(
//                 //               key: controller.incrementFormKey,
//                 //               child: CustomTextField(
//                 //                 padding: EdgeInsets.all(22),
//                 //                 readOnly: true,
//                 //                 controller: controller.blanceController,
//                 //                 extraLabel: "Increment Balance (Modify)",
//                 //                 extraLabelFontSize: 24,
//                 //                 hintStyle: TextStyle(fontSize: 20),
//                 //                 hintText: "Balance",
//                 //                 validator: (value) {
//                 //                   if (value == null || value.trim().isEmpty) {
//                 //                     return "Amount is required";
//                 //                   }
//                 //
//                 //                   final numberRegExp = RegExp(r'^\d+(\.\d+)?$');
//                 //                   if (!numberRegExp.hasMatch(value)) {
//                 //                     return "Only numeric values are allowed";
//                 //                   }
//                 //
//                 //                   final numValue = num.tryParse(value);
//                 //                   if (numValue == null) {
//                 //                     return "Invalid number";
//                 //                   }
//                 //
//                 //                   if (numValue < 5 || numValue > 500) {
//                 //                     return "Amount must be between 5 and 500";
//                 //                   }
//                 //
//                 //                   return null;
//                 //                 },
//                 //                 style: TextStyle(
//                 //                   fontSize: 22,
//                 //                   color: Theme.of(context).colorScheme.surface,
//                 //                 ),
//                 //                 onTap: () {
//                 //                   int initValue =
//                 //                   ((num.tryParse(controller.blanceController.text) ?? 0) * 100)
//                 //                       .toInt();
//                 //
//                 //                   CustomKeyboard.open(
//                 //                     keyboardType: KeyboardType.number,
//                 //                     changeKeybordType: false,
//                 //                     initialValue: initValue.toString(),
//                 //                     // regExp: RegExp(r'^.{0,550}$'),
//                 //                     regExp: RegExp(r'^\d{0,6}$'),
//                 //                     // regExp: RegExp(r'^(?:[0-9]{1,4}|[1-4][0-9]{4}|50000)$'),
//                 //                     // regExp: RegExp(r'^(?:[0-9]{1,4}|[1-4][0-9]{4}|50000)$'),
//                 //                     onChange: (value) {
//                 //                       controller.blanceController.text = value.toDecimalFormat();
//                 //                     },
//                 //                   );
//                 //                 },
//                 //               ),
//                 //             ),
//                 //
//                 //           ),
//                 //           const SizedBox(width: 12),
//                 //           Padding(
//                 //             padding: EdgeInsets.only(top: 7),
//                 //             child: PrimaryBtn(
//                 //               height: 70,
//                 //               textMinSize: 20,
//                 //               textMaxSize: 20,
//                 //               color: StaticColors.greenColor,
//                 //               onPressed: () async{
//                 //
//                 //                 if (controller.incrementFormKey.currentState!.validate()) {
//                 //                 bool isUpdate = await controller.incrementBalance(
//                 //                       card.cid, controller.blanceController.text);
//                 //
//                 //                   if (isUpdate) {
//                 //
//                 //                     PrintUtils().directPrint(child: await dataCandyIncrementPrintReceipt(
//                 //                       increment: controller.incrementBalanceModel.value ?? IncrementBalanceModel(),
//                 //                       customerName: card.customerName,
//                 //                     ), printerName: Preferences.counterPrinter);
//                 //                     // PopupDialog.showSuccessDialog("Print sent");
//                 //
//                 //                   } else {
//                 //                     // Handle the case when incrementBalanceModel is null
//                 //                     print("Increment model is null!");
//                 //                   }
//                 //                   Get.back();
//                 //                 // await  dataCandyIncrementPrintReceipt(increment: controller.incrementBalanceModel.value,cardID: card.customerName);
//                 //                   print("amount is: ${controller.blanceController.text}");
//                 //                 } else {
//                 //                   // Validator failed, error text দেখাবে
//                 //                   print("Validation failed");
//                 //                 }
//                 //                 // Get.back();
//                 //               },
//                 //               text: "Adjust Balance",
//                 //             ),
//                 //           ),
//                 //         ],
//                 //       ),
//                 //     ),
//                 //   ),
//                 // );
//                  controller.textControllerRemove();
//                 print("Recharge clicked for card: ${card.cid}");
//               }, StaticColors.blueColor),
//               const SizedBox(width: 20),
//               _actionBtn("Check Balance", () async {
//                   // get value
//                   // controller.incrementBlance();
//                   PopupDialog.showLoadingDialog();
//                  bool isUpdated =  await controller.checkBlance();
//                   PopupDialog.closeLoadingDialog();
//                   PopupDialog.customDialog2(
//                     // height:350,
//                     // borderColor: Theme.of(context).hintColor,
//                     child: Center(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           SizedBox(
//                             height: 30,
//                           ),
//                           Container(
//                             padding: EdgeInsets.all(15),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadiusGeometry.circular(6),
//                               // border: Border.all(
//                               //   color: Theme.of(context).hintColor,
//                               // )
//                             ),
//                             child: MyCustomText(
//                               "Gift Card Balance",
//                               fontWeight: FontWeight.bold,
//                               fontSize: 40,
//                             ),
//                           ),
//                           SizedBox(height: 16,),
//                           // Divider(),
//                           SizedBox(
//                             height: 40,
//                           ),
//                           Center(
//                             child: Row(
//                              crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 // SizedBox(width: 85,),
//                                 // MyCustomText(
//                                 //   "Total Balance: ",
//                                 //   fontWeight: FontWeight.w700,
//                                 //   fontSize: 24,
//                                 // ),
//                                 // SizedBox(width: 25,),
//                                 Align(
//                             alignment:  Alignment.center,
//                                   child: MyCustomText(
//                                     fontSize: 45,
//                                     "\$${(controller.totalBlance.value == null || controller.totalBlance.value.toString().isEmpty)
//                                         ? "0.00"
//                                         : controller.totalBlance.value}",
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 55,),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               // Print Check
//                               PrimaryBtnWithChild(
//                                 onPressed: () async{
//                                   if(isUpdated){
//                                     // PrintUtils().directPrint(
//                                     //   child: await dataCandyCheckBalancePrintReceipt(
//                                     //   cardNo: card.cid,customerName:card.customerName ,
//                                     //   phoneNumber:card.customerPhone ,
//                                     //   totalBalance: controller.totalBlance.value,
//                                     //   tcnNumber: controller.tcnCheckBalance.value,
//                                     // ), printerName: Preferences.counterPrinter,);
//
//                                   PopupDialog.showSuccessDialog("Print success");
//                                   }else{
//                                   debugPrint("check balance null");
//                                   }
//                                 },
//                                 height: 70,
//                                 width: 200,
//                                 color: StaticColors.blueColor,
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Icon(
//                                       Icons.print,
//                                       color: Colors.white,
//                                       size: 25,
//                                     ).marginOnly(right: 12),
//                                     const FittedBox(
//                                       child: MyCustomText(
//                                         'Print',
//                                         color: Colors.white,
//                                         fontSize: 25,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ).marginOnly(right: 50),
//                               // No Print
//                               PrimaryBtnWithChild(
//                                 onPressed: () {
//                                   Get.back();
//                                 },
//                                 height: 70,
//                                 width: 200,
//                                 textColor: Colors.white,
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Icon(
//                                       Icons.do_disturb_alt,
//                                       size: 25,
//                                       color: Colors.white,
//                                     ).marginOnly(right: 12),
//                                     const FittedBox(
//                                       child: MyCustomText(
//                                         color: Colors.white,
//                                         'No Print',
//                                         fontSize: 25,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 50,
//                           )
//                         ],
//                       ),
//                     ),
//                     width: 500,
//                     height: 450,
//                   );
//                   // if(isUpdated){
//                   //   PrintUtils().directPrint(
//                   //     child: await dataCandyCheckBalancePrintReceipt(
//                   //         cardNo: card.cid,customerName:card.customerName ,
//                   //         phoneNumber:card.customerPhone ,
//                   //         totalBalance: controller.totalBlance.value,
//                   //         tcnNumber: controller.tcnCheckBalance.value,
//                   //     ), printerName: Preferences.counterPrinter,);
//                   //
//                   //  PopupDialog.showSuccessDialog("Print success");
//                   // }else{
//                   //   debugPrint("check balance null");
//                   // }
//
//                   // controller.commitTransaction();
//
//                   // print("Amount: ${controller.amountController.text}");
//                 }, StaticColors.blueColor),
//             ],
//           );
//         } else {
//           return Container(
//             alignment: Alignment.center,
//             padding: const EdgeInsets.all(6),
//             child: Text(
//               cell.value.toString(),
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 24),
//               overflow: TextOverflow.ellipsis,
//             ),
//           );
//         }
//       }).toList(),
//     );
//   }
//
//   Widget _actionBtn(String text, VoidCallback onPressed, Color color) {
//     return SizedBox(
//       height: 65,
//       width: 100,
//       child: PrimaryBtn(
//         fontWeight: FontWeight.w900,
//         textMaxSize: 17,
//         textMinSize: 17,
//         maxLines: 2,
//         color: color,
//         onPressed: onPressed,
//         text: text,
//       ),
//     );
//   }
//
//
// }
//
//
