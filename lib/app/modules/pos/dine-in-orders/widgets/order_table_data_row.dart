// import 'package:flutter/material.dart';
// import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in/views/order_details_view.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';

// import '../../../../utils/static_colors.dart';
// import '../../../../widgets/my_custom_text.dart';

// class OrderTableDataRow extends StatelessWidget {
//   const OrderTableDataRow({
//     super.key,
//     required this.sl,
//     required this.tableNo,
//     required this.userName,
//     this.orderDateTime = "",
//     required this.orderType,
//     required this.orderStatus,
//     required this.totalAmount,
//     required this.paymetStatus,
//     this.onOrderDetails,
//     this.onPrint,
//     required this.orderId,
//     required this.id,
//   });

//   final int sl;
//   final String id;
//   final String orderId;
//   final String tableNo;
//   final String userName;
//   final String orderDateTime;
//   final String orderType;
//   final String orderStatus;
//   final double totalAmount;
//   final String paymetStatus;
//   final VoidCallback? onOrderDetails;
//   final VoidCallback? onPrint;

//   @override
//   Widget build(BuildContext context) {
//     const double titleFontSize = 16;
//     const double contentFontSize = 14;
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//               child: MyCustomText(
//             sl.toString(),
//             fontSize: contentFontSize,
//           )),
//           const SizedBox(width: 4.0),
//           Expanded(
//               child: MyCustomText(
//             tableNo.toString(),
//             fontSize: contentFontSize,
//           )),
//           const SizedBox(width: 4.0),
//           Expanded(
//               flex: 1,
//               child: MyCustomText(
//                 userName,
//                 fontSize: contentFontSize,
//               )),
//           const SizedBox(width: 4.0),
//           Expanded(
//               child: MyCustomText(
//             orderId,
//             fontSize: contentFontSize,
//           )),
//           const SizedBox(width: 4.0),
//           Expanded(
//               flex: 2,
//               child: MyCustomText(
//                 orderDateTime,
//                 fontSize: contentFontSize,
//               )),
//           const SizedBox(width: 4.0),
//           Expanded(
//               child: MyCustomText(
//             orderType,
//             fontSize: contentFontSize,
//           )),
//           const SizedBox(width: 4.0),
//           Expanded(
//               child: MyCustomText(
//             orderStatus,
//             fontSize: contentFontSize,
//           )),
//           const SizedBox(width: 4.0),
//           Expanded(
//               child: Column(
//             children: [
//               MyCustomText(
//                 totalAmount.toStringAsFixed(2),
//                 fontSize: contentFontSize,
//               ),
//               const SizedBox(height: 4.0),
//               MyCustomText(
//                 paymetStatus,
//                 fontSize: titleFontSize,
//               ),
//             ],
//           )),
//           const SizedBox(width: 4.0),
//           Expanded(
//             child: Row(
//               children: [
//                 Transform.scale(
//                   scale: 1.5,
//                   child: IconButton(
//                     onPressed: () async {
//                       PopupDialog.showLoadingDialog();
//                       var hasData = await DineInController.to.getOrderById(id);
//                       PopupDialog.closeLoadingDialog();
//                       if (hasData) {
//                          PosController.to.selectedItemList.clear();
//                         Get.to(() => const OrderDetailsView());
//                       }
//                     },
//                     icon: const Icon(
//                       FontAwesomeIcons.eye,
//                       size: 18,
//                       color: StaticColors.orangeColor,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 20.0),
//                 Transform.scale(
//                   scale: 1.5,
//                   child: IconButton(
//                     // onPressed: onPrint,
//                     onPressed: () {},
//                     icon: const Icon(
//                       FontAwesomeIcons.print,
//                       size: 18,
//                       color: StaticColors.greenColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
