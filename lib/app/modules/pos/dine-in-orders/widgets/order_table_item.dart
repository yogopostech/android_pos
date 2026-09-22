// import 'package:flutter/material.dart';
// import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in-orders/controllers/dine_in_order_controller.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in/views/order_details_view.dart';
// import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
// import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/utils/extension/my_extension.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';
// import 'package:yogo_pos/app/widgets/my_custom_text.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'print/print_order_dialog.dart';

// class OrderTableItem extends StatelessWidget {
//   final OrderModel order;
//   final String no;
//   const OrderTableItem({
//     super.key,
//     required this.order,
//     required this.no,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const double titleFontSize = 14;
//     const FontWeight fontWeight = FontWeight.w400;
//     const double gap = 2;

//     return Obx(() {
//       return Container(
//         // decoration: BoxDecoration(
//         //   border: Border.symmetric(
//         //     horizontal: BorderSide(
//         //       width: 2,
//         //       color: theme.colorScheme.surface,
//         //     ),
//         //   ),
//         // ),
//         // padding: const EdgeInsets.symmetric(vertical: 14),
//         margin: const EdgeInsets.only(bottom: 10),
//         child: Row(
//           children: [
//             SizedBox(
//                 width: 50,
//                 child: MyCustomText(
//                   no,
//                   fontSize: titleFontSize,
//                   fontWeight: fontWeight,
//                 )),
//             const SizedBox(width: gap),
//             Expanded(
//                 child: Center(
//               child: MyCustomText(
//                 order.splitAmounts.isNotEmpty || order.splitOrders.isNotEmpty
//                     ? "${order.orderId}-SC"
//                     : order.orderId,
//                 fontSize: titleFontSize,
//                 fontWeight: fontWeight,
//               ),
//             )),
//             const SizedBox(width: gap),
//             Expanded(
//                 child: Center(
//               child: MyCustomText(
//                 order.employee?.firstName.toUpperCase() ?? "",
//                 fontSize: titleFontSize,
//                 fontWeight: fontWeight,
//               ),
//             )),
//             if (DineInOrderController.to.selectedOrderType=="DINE_IN")
//               const SizedBox(width: gap),
//             if (DineInOrderController.to.selectedOrderType=="DINE_IN")
//               Expanded(
//                   child: Center(
//                 child: MyCustomText(
//                   order.tableName,
//                   fontSize: titleFontSize,
//                   fontWeight: fontWeight,
//                 ),
//               )),
//             // const SizedBox(width: gap),
//             SizedBox(
//                 width: 200,
//                 child: Center(
//                   child: MyCustomText(
//                     order.createdAt.toStringAsPrimaryFormat(),
//                     fontSize: titleFontSize,
//                     fontWeight: fontWeight,
//                   ),
//                 )),
//             // const SizedBox(width: gap),
//             SizedBox(
//                 width: 200,
//                 child: Center(
//                   child: MyCustomText(
//                     order.updatedAt.toStringAsPrimaryFormat(),
//                     fontSize: titleFontSize,
//                     fontWeight: fontWeight,
//                   ),
//                 )),
//             // const SizedBox(width: gap),
//             Expanded(
//                 child: Center(
//               child: MyCustomText(
//                 order.orderType.replaceAll("_", "-"),
//                 fontSize: titleFontSize,
//                 fontWeight: fontWeight,
//               ),
//             )),
//             const SizedBox(width: gap),
//             Expanded(
//                 child: Center(
//               child: MyCustomText(
//                 order.payment?.methods.join(', ').replaceAll('_', ' ') ?? "N/A",
//                 fontSize: titleFontSize,
//                 fontWeight: fontWeight,
//               ),
//             )),
//             const SizedBox(width: gap),
//             Expanded(
//                 flex: 2,
//                 child: Center(
//                   child: MyCustomText(
//                     order.orderStatus,
//                     fontSize: titleFontSize,
//                     fontWeight: fontWeight,
//                   ),
//                 )),
//             const SizedBox(width: gap),
//             Expanded(
//                 child: Center(
//               child: MyCustomText(
//                 order.tip.toStringAsFixed(2),
//                 fontSize: titleFontSize,
//                 fontWeight: fontWeight,
//               ),
//             )),
//             const SizedBox(width: gap),
//             Expanded(
//                 child: Center(
//               child: MyCustomText(
//                 order.totalDiscount.toStringAsFixed(2),
//                 fontSize: titleFontSize,
//                 fontWeight: fontWeight,
//               ),
//             )),
//             const SizedBox(width: gap),
//             Expanded(
//                 child: Center(
//               child: MyCustomText(
//                 order.totalGst.toStringAsFixed(2),
//                 fontSize: titleFontSize,
//                 fontWeight: fontWeight,
//               ),
//             )),
//             const SizedBox(width: gap),
//             Expanded(
//                 child: Center(
//               child: MyCustomText(
//                 order.totalPst.toStringAsFixed(2),
//                 fontSize: titleFontSize,
//                 fontWeight: fontWeight,
//               ),
//             )),
//             const SizedBox(width: gap),
//             Expanded(
//                 child: Center(
//               child: MyCustomText(
//                 order.totalGratuity.toStringAsFixed(2),
//                 fontSize: titleFontSize,
//                 fontWeight: fontWeight,
//               ),
//             )),
//             const SizedBox(width: gap),
//             Expanded(
//                 child: Center(
//               child: MyCustomText(
//                 order.extraAmount.toStringAsFixed(2),
//                 fontSize: titleFontSize,
//                 fontWeight: fontWeight,
//               ),
//             )),
//             if (DineInOrderController.to.selectedOrderType=="TAKEOUT") ...{
//               const SizedBox(width: gap),
//               Expanded(
//                   child: Center(
//                 child: MyCustomText(
//                   order.packagingCost.toStringAsFixed(2),
//                   fontSize: titleFontSize,
//                   fontWeight: fontWeight,
//                 ),
//               )),
//             },
//             const SizedBox(width: gap),
//             Expanded(
//                 child: Center(
//               child: MyCustomText(
//                 order.refund ? 'YES' : 'N/A',
//                 fontSize: titleFontSize,
//                 fontWeight: fontWeight,
//               ),
//             )),
//             const SizedBox(width: gap),
//             Expanded(
//                 child: Center(
//               child: MyCustomText(
//                 order.recall ? 'YES' : 'N/A',
//                 fontSize: titleFontSize,
//                 fontWeight: fontWeight,
//               ),
//             )),
//             const SizedBox(width: gap),
//             Expanded(
//                 child: Center(
//               child: MyCustomText(
//                 order.subTotal.toStringAsFixed(2),
//                 fontSize: titleFontSize,
//                 fontWeight: fontWeight,
//               ),
//             )),
//             const SizedBox(width: gap),
//             Expanded(
//                 child: Center(
//               child: MyCustomText(
//                 order.totalOrderAmount.toStringAsFixed(2),
//                 fontSize: titleFontSize,
//                 fontWeight: fontWeight,
//               ),
//             )),
//             const SizedBox(width: gap),
//             SizedBox(
//                 width: 100,
//                 child: Center(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Transform.scale(
//                         scale: 1,
//                         child: IconButton(
//                           onPressed: () async {
//                             BaseController.to.playTapSound();
//                             PosController.to.myOrder = order;
//                             PosController.to.selectedItemList.clear();
//                             Get.to(() => const OrderDetailsView());
//                           },
//                           icon: const Icon(
//                             FontAwesomeIcons.eye,
//                             size: 18,
//                             color: StaticColors.orangeColor,
//                           ),
//                         ),
//                       ),
//                       Transform.scale(
//                         scale: 1,
//                         child: IconButton(
//                           // onPressed: onPrint,
//                           onPressed: () {
//                             BaseController.to.playTapSound();
//                             PopupDialog.customDialog(
//                                 color: Colors.white,
//                                 iconColor: Colors.black,
//                                 width: 435,
//                                 child: PrintOrderDialog(
//                                   order: order,
//                                 ));
//                           },
//                           icon: const Icon(
//                             FontAwesomeIcons.print,
//                             size: 18,
//                             color: StaticColors.greenColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )),
//           ],
//         ),
//       );
//     });
//   }
// }
