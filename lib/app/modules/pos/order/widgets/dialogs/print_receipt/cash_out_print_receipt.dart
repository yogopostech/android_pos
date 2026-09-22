// import 'package:yogo_pos/app/modules/pos/order/models/cashout_model.dart';
// import 'package:yogo_pos/app/modules/setting/controllers/printers_controller.dart';

// import 'package:yogo_pos/app/utils/my_func.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;

// Future<pw.Widget> cashOutPrintReceipt(CashoutModel data) async {
//   var bold = await MyFunc.loadCustomFont("assets/fonts/RobotoMono-Bold.ttf");
//   bool is80mm = PrintersController.to.selectedPaperWidth.value == "80mm";
//   var titleSmallStyle = pw.TextStyle(
//     fontSize: is80mm ? 12 : 9,
//     height: 3,
//     font: bold,
//     fontWeight: pw.FontWeight.bold,
//   );
//   var bodyStyle = pw.TextStyle(
//     fontSize: is80mm ? 10 : 7,
//     height: 3,
//     font: bold,
//   );

//   var lavelStyle = pw.TextStyle(
//     fontSize: is80mm ? 10 : 7,
//     height: 3,
//     font: bold,
//     fontWeight: pw.FontWeight.bold,
//   );
//   return pw.Column(
//     mainAxisSize: pw.MainAxisSize.min,
//     children: [
//       // ! title area
//       pw.Center(
//           child: pw.Text(
//         data.title.toUpperCase(),
//         textAlign: pw.TextAlign.center,
//         style: titleSmallStyle,
//       )),
//       pw.SizedBox(height: is80mm ? 4 : 2),
//       _row(title: data.date, value: data.time, style: lavelStyle),
//       // ! ====== start and end ======
//       pw.SizedBox(height: is80mm ? 16 : 10),
//       pw.Container(
//           padding: pw.EdgeInsets.all(is80mm ? 6 : 3),
//           decoration: pw.BoxDecoration(
//             border: pw.Border.all(
//               color: PdfColors.black, // Border color
//               width: 1, // Border width
//               style: pw.BorderStyle
//                   .dashed, // Dotted/dashed border style  // Defines the pattern for the dashed border
//             ),
//           ),
//           child: pw.Column(children: [
//             _row(
//                 title: "Day: ${data.day}".toUpperCase(),
//                 value: data.todayDate,
//                 style: lavelStyle),
//             _row(
//                 title: "Open: ${data.open}".toUpperCase(),
//                 value: "Close: ${data.close}".toUpperCase(),
//                 style: lavelStyle),
//           ])),
//       pw.SizedBox(height: is80mm ? 12 : 8),
//       // ! ====== pay ======
//       pw.Row(
//         children: [
//           pw.SizedBox(
//             width: is80mm ? 40 : 30,
//             child: pw.Text(
//               "Pay.".toUpperCase(),
//               style: lavelStyle,
//               textAlign: pw.TextAlign.start,
//             ),
//           ),
//           pw.Expanded(
//             child: pw.Text(
//               "Grat.".toUpperCase(),
//               style: lavelStyle,
//               textAlign: pw.TextAlign.center,
//             ),
//           ),
//           pw.SizedBox(width: is80mm ? 6 : 3),
//           pw.Expanded(
//             child: pw.Text(
//               "Tips".toUpperCase(),
//               style: lavelStyle,
//               textAlign: pw.TextAlign.center,
//             ),
//           ),

//           pw.SizedBox(width: is80mm ? 6 : 3),
//           pw.Expanded(
//             child: pw.Text(
//               "Subtotal".toUpperCase(),
//               style: lavelStyle,
//               textAlign: pw.TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//       pw.Divider(color: PdfColor.fromHex('#303030'), height: 2),
//       //  item
//       pw.SizedBox(
//         height: is80mm ? 6 : 3,
//       ),
//       ...List.generate(data.totalPay.length - 1, (index) {
//         var payData = data.totalPay[index];
//         return pw.Column(children: [
//           pw.Row(
//             children: [
//               pw.SizedBox(
//                   width: is80mm ? 40 : 30,
//                   child: pw.Text(
//                     payData.title,
//                     style: bodyStyle,
//                     textAlign: pw.TextAlign.start,
//                   )),

//               pw.Expanded(
//                 child: pw.Text(
//                   "\$${payData.gratuity.toStringAsFixed(2)}",
//                   style: bodyStyle,
//                   textAlign: pw.TextAlign.center,
//                 ),
//               ),
//               pw.SizedBox(width: is80mm ? 6 : 3),
//               pw.Expanded(
//                 child: pw.Text(
//                   "\$${payData.tips.toStringAsFixed(2)}",
//                   style: bodyStyle,
//                   textAlign: pw.TextAlign.center,
//                 ),
//               ),
//               pw.SizedBox(width: is80mm ? 6 : 3),
//               pw.Expanded(
//                 child: pw.Text(
//                   "\$${payData.pay.toStringAsFixed(2)}",
//                   style: bodyStyle,
//                   textAlign: pw.TextAlign.end,
//                 ),
//               ),

//               // pw.SizedBox(
//               //   width: 20,
//               //   child: pw.Text(
//               //     "0",
//               //     style: bodyStyle,
//               //     textAlign: pw.TextAlign.end,
//               //   ),
//               // ),
//             ],
//           ),
//           pw.SizedBox(height: 3),
//         ]);
//       }),
//       pw.Divider(color: PdfColor.fromHex('#303030'), height: 8),
//       pw.Row(
//         children: [
//           pw.SizedBox(
//               width: is80mm ? 40 : 30,
//               child: pw.Text(
//                 data.totalPay.last.title.toUpperCase(),
//                 style: lavelStyle,
//                 textAlign: pw.TextAlign.start,
//               )),
//           pw.Expanded(
//             child: pw.Text(
//               "\$${data.totalPay.last.gratuity.toStringAsFixed(2)}",
//               style: bodyStyle,
//               textAlign: pw.TextAlign.center,
//             ),
//           ),
//           pw.SizedBox(width: is80mm ? 6 : 3),
//           pw.Expanded(
//             child: pw.Text(
//               "\$${data.totalPay.last.tips.toStringAsFixed(2)}",
//               style: bodyStyle,
//               textAlign: pw.TextAlign.center,
//             ),
//           ),
//           pw.SizedBox(width: is80mm ? 6 : 3),
//           pw.Expanded(
//             child: pw.Text(
//               "\$${data.totalPay.last.pay.toStringAsFixed(2)}",
//               style: bodyStyle,
//               textAlign: pw.TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//       pw.SizedBox(height: is80mm ? 12 : 8),
//       // ! ====== Tip Area =======
//       pw.Align(
//         alignment: pw.Alignment.bottomLeft,
//         child: pw.Text(
//           "Tips".toUpperCase(),
//           style: bodyStyle,
//           textAlign: pw.TextAlign.start,
//         ),
//       ),
//       pw.Divider(color: PdfColor.fromHex('#303030'), height: 2),
//       ...List.generate(data.totalTips.length - 1, (index) {
//         var tipData = data.totalTips[index];
//         return _row(
//             title: tipData.title,
//             value: "\$${tipData.total.toStringAsFixed(2)}",
//             style: bodyStyle);
//       }),
//       pw.Divider(color: PdfColor.fromHex('#303030'), height: 2),
//       _row(
//           title: data.totalTips.last.title.toUpperCase(),
//           value: "\$${data.totalTips.last.total.toStringAsFixed(2)}",
//           style: lavelStyle),
//       pw.SizedBox(height: is80mm ? 12 : 8),
//       // ! ======= Category =======
//       pw.Row(
//         children: [
//           pw.SizedBox(
//             width: is80mm ? 50 : 35,
//             child: pw.Text(
//               "Category".toUpperCase(),
//               style: lavelStyle,
//               textAlign: pw.TextAlign.start,
//             ),
//           ),
//           pw.SizedBox(width: is80mm ? 6 : 3),
//           pw.Expanded(
//             child: pw.Text(
//               "Grat.".toUpperCase(),
//               style: lavelStyle,
//               textAlign: pw.TextAlign.center,
//             ),
//           ),
//           pw.SizedBox(width: is80mm ? 6 : 3),
//           pw.Expanded(
//             child: pw.Text(
//               "TIPS".toUpperCase(),
//               style: lavelStyle,
//               textAlign: pw.TextAlign.center,
//             ),
//           ),
//           pw.SizedBox(width: is80mm ? 6 : 3),
//           pw.Expanded(
//             child: pw.Text(
//               "Sales".toUpperCase(),
//               style: lavelStyle,
//               textAlign: pw.TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//       pw.Divider(color: PdfColor.fromHex('#303030'), height: 8),
//       // ! Item
//       ...List.generate(data.totalCategorySales.length - 1, (index) {
//         var catData = data.totalCategorySales[index];
//         return pw.Row(
//           children: [
//             pw.SizedBox(
//               width: is80mm ? 50 : 35,
//               child: pw.Text(
//                 catData.title.toUpperCase(),
//                 style: bodyStyle,
//                 textAlign: pw.TextAlign.start,
//               ),
//             ),
//             pw.SizedBox(width: is80mm ? 6 : 3),
//             pw.Expanded(
//               child: pw.Text(
//                 // "\$${catData.gratuity.toStringAsFixed(2)}",
//                 "-",
//                 style: bodyStyle,
//                 textAlign: pw.TextAlign.center,
//               ),
//             ),
//             pw.SizedBox(width: is80mm ? 6 : 3),
//             pw.Expanded(
//               child: pw.Text(
//                 // "\$${catData.tip.toStringAsFixed(2)}",
//                 "-",
//                 style: bodyStyle,
//                 textAlign: pw.TextAlign.center,
//               ),
//             ),
//             pw.SizedBox(width: is80mm ? 6 : 3),
//             pw.Expanded(
//               child: pw.Text(
//                 "\$${catData.sales.toStringAsFixed(2)}",
//                 style: bodyStyle,
//                 textAlign: pw.TextAlign.end,
//               ),
//             ),
//           ],
//         );
//       }),
//       pw.Divider(color: PdfColor.fromHex('#303030'), height: is80mm ? 6 : 3),
//       pw.Row(
//         children: [
//           pw.SizedBox(
//             width: is80mm ? 50 : 35,
//             child: pw.Text(
//               data.totalCategorySales.last.title.toUpperCase(),
//               style: lavelStyle,
//               textAlign: pw.TextAlign.start,
//             ),
//           ),
//           pw.SizedBox(width: is80mm ? 6 : 3),
//           pw.Expanded(
//             child: pw.Text(
//               "\$${data.totalCategorySales.last.gratuity.toStringAsFixed(2)}",
//               style: bodyStyle,
//               textAlign: pw.TextAlign.center,
//             ),
//           ),
//           pw.SizedBox(width: is80mm ? 6 : 3),
//           pw.Expanded(
//             child: pw.Text(
//               "\$${data.totalCategorySales.last.tip.toStringAsFixed(2)}",
//               style: bodyStyle,
//               textAlign: pw.TextAlign.center,
//             ),
//           ),
//           pw.SizedBox(width: is80mm ? 6 : 3),
//           pw.Expanded(
//             child: pw.Text(
//               "\$${data.totalCategorySales.last.sales.toStringAsFixed(2)}",
//               style: bodyStyle,
//               textAlign: pw.TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//       pw.SizedBox(height: is80mm ? 12 : 8),
//       // ! ======= End =======

//       _row(
//           title: "Total GST:",
//           value: "\$${data.totalGst.toStringAsFixed(2)}",
//           style: bodyStyle),
//       _row(
//           title: "Total PST:",
//           value: "\$${data.totalPst.toStringAsFixed(2)}",
//           style: bodyStyle),
//       _row(
//           title: "Total PST2:",
//           value: "\$${data.totalPst2.toStringAsFixed(2)}",
//           style: bodyStyle),
//       if (data.totalMaintenanceFee > 0)
//         _row(
//             title: "Total Service Fee:",
//             value: "\$${data.totalMaintenanceFee.toStringAsFixed(2)}",
//             style: bodyStyle),
//       if (data.totalDeliveryFee > 0)
//         _row(
//             title: "Total Delivery Fee:",
//             value: "\$${data.totalDeliveryFee.toStringAsFixed(2)}",
//             style: bodyStyle),
//       _row(
//           title: "Total Discount:",
//           value: "(-) \$${data.totalDiscount.toStringAsFixed(2)}",
//           style: bodyStyle),
//       pw.Divider(color: PdfColor.fromHex('#303030'), height: 2),
//       _row(
//           title: "Grand Total:",
//           value: "\$${data.grandTotal.toStringAsFixed(2)}",
//           style: bodyStyle),
//       pw.SizedBox(height: 12),
//       _row(
//           title: "Server Checks:",
//           value: "${data.serverSales}",
//           style: bodyStyle),
//       _row(title: "All Checks:", value: "${data.orders}", style: bodyStyle),
//       pw.Divider(color: PdfColor.fromHex('#303030'), height: 2),
//     ],
//   );
// }

// pw.Widget _row({
//   pw.TextStyle? style,
//   required String title,
//   required String value,
// }) {
//   return pw.Row(
//     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//     children: [
//       pw.Text(title, style: style),
//       pw.Text(value, style: style),
//     ],
//   );
// }
