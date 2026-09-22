import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/modules/pos/order/controllers/order_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/cashout_model.dart';
import 'package:yogo_pos/app/modules/pos/order/widgets/dialogs/print_receipt/esc_cash_out_print_receipt.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:yogo_pos/config/fonts.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:get/get.dart';

// class CashOutDialog extends GetView<OrderController> {
//   const CashOutDialog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     return Column(
//       children: [
//         const SizedBox(height: 16),
//         // btn area
//         GetBuilder<OrderController>(builder: (context) {
//           return Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(context.cashOutTypeList.length, (index) {
//               String cashOutType = context.cashOutTypeList[index];
//               return Expanded(
//                 child: PrimaryBtn(
//                   onPressed: () async {
//                     context.onChangeCashOutType(cashOutType);
//                   },
//                   color: index == 0
//                       ? StaticColors.greenColor
//                       : StaticColors.blueColor,
//                   isOutline:
//                       context.activeCashOutType == cashOutType ? true : false,
//                   borderColor: StaticColors.orangeColor,
//                   text: cashOutType
//                       .replaceAll("_", "-")
//                       .replaceAll("ONLINE", "OLO"),
//                   textColor: Colors.white,
//                   textMaxSize: 14,
//                   textMinSize: 14,
//                 ).marginOnly(
//                     right:
//                         context.cashOutTypeList.length - 1 == index ? 0 : 10),
//               );
//             }),
//           ).marginOnly(bottom: 16);
//         }),
//         GetBuilder<OrderController>(builder: (context) {
//           switch (context.activeCashOutType) {
//             case "ALL":
//               return _mycachOut(theme, context.allCashOut);
//             case "DINE_IN":
//               return _mycachOut(theme, context.dineInCashOut);
//             case "TAKEOUT":
//               return _mycachOut(theme, context.takeOutCashOut);
//             case "DELIVERY":
//               return _mycachOut(theme, context.deliveryCashOut);
//             case "ONLINE":
//               return _mycachOut(theme, context.oloCashOut);
//             default:
//               return const SizedBox();
//           }
//         }),
//       ],
//     );
//   }
// }

// // ! ======  MycachOut =====
// Widget _mycachOut(ThemeData theme, CashoutModel? data) {
//   var labelLarge = theme.textTheme.labelLarge?.copyWith(
//       fontFamily: Fonts.secondary, fontWeight: FontWeight.bold, fontSize: 15);
//   var labelMedium = theme.textTheme.labelMedium?.copyWith(
//     fontSize: 13,
//     fontFamily: Fonts.secondary,
//     fontWeight: FontWeight.bold,
//   );
//   if (data == null) {
//     return const SizedBox();
//   }
//   return Column(
//     children: [
//       // Header area
//       Text(
//         data.title.toUpperCase(),
//         style: theme.textTheme.titleMedium,
//         textAlign: TextAlign.center,
//       ),
//       const SizedBox(height: 5),
//       _row(theme, title: data.date, value: data.time),

//       const SizedBox(height: 16),
//       // ! ====== start and end ======
//       DottedBorder(
//         padding: const EdgeInsets.all(8),
//         color: theme.textTheme.bodyLarge?.color ?? Colors.black,
//         strokeWidth: 1,
//         child: Column(
//           children: [
//             _row(theme,
//                 title: "Day: ${data.day}".toUpperCase(),
//                 value: data.todayDate,
//                 style: labelLarge),
//             _row(theme,
//                 title: "Open: ${data.open}".toUpperCase(),
//                 value: "Close: ${data.close}".toUpperCase(),
//                 style: labelLarge),
//           ],
//         ),
//       ),
//       const SizedBox(height: 16),
//       //end
//       // ! ======== pay ========
//       Row(
//         children: [
//           SizedBox(
//             width: 90,
//             child: Text(
//               "Pay.".toUpperCase(),
//               style: labelLarge,
//               textAlign: TextAlign.start,
//             ),
//           ),
//           // const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               "Grat.".toUpperCase(),
//               style: labelLarge,
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               "Tips".toUpperCase(),
//               style: labelLarge,
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               "Subtotal".toUpperCase(),
//               style: labelLarge,
//               textAlign: TextAlign.end,
//             ),
//           ),

//           // SizedBox(
//           //   width: 40,
//           //   child: Text(
//           //     "#",
//           //     style: labelLarge,
//           //     textAlign: TextAlign.end,
//           //   ),
//           // ),
//         ],
//       ),
//       Divider(
//         color: theme.textTheme.bodyLarge?.color,
//       ),
//       const SizedBox(height: 8),
//       // ! Item
//       ...List.generate(data.totalPay.length - 1, (index) {
//         var payData = data.totalPay[index];
//         return Row(
//           children: [
//             SizedBox(
//               width: 90,
//               child: Text(
//                 payData.title,
//                 style: labelLarge,
//                 textAlign: TextAlign.start,
//               ),
//             ),
//             // const SizedBox(width: 6),
//             Expanded(
//               child: Text(
//                 "\$${payData.gratuity.toStringAsFixed(2)}",
//                 style: labelLarge,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(width: 6),
//             Expanded(
//               child: Text(
//                 "\$${payData.tips.toStringAsFixed(2)}",
//                 style: labelLarge,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(width: 6),
//             Expanded(
//               child: Text(
//                 "\$${payData.pay.toStringAsFixed(2)}",
//                 style: labelLarge,
//                 textAlign: TextAlign.end,
//               ),
//             ),

//             // SizedBox(
//             //   width: 40,
//             //   child: Text(
//             //     "0",
//             //     style: labelLarge,
//             //     textAlign: TextAlign.end,
//             //   ),
//             // ),
//           ],
//         );
//       }),
//       Divider(
//         color: theme.textTheme.bodyLarge?.color,
//         height: 18,
//       ),
//       Row(
//         children: [
//           SizedBox(
//             width: 90,
//             child: Text(
//               data.totalPay.last.title.toUpperCase(),
//               style: labelLarge?.copyWith(fontSize: 16),
//               textAlign: TextAlign.start,
//             ),
//           ),
//           // const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               "\$${data.totalPay.last.gratuity.toStringAsFixed(2)}",
//               style: labelLarge,
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               "\$${data.totalPay.last.tips.toStringAsFixed(2)}",
//               style: labelLarge,
//               textAlign: TextAlign.center,
//             ),
//           ),

//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               "\$${data.totalPay.last.pay.toStringAsFixed(2)}",
//               style: labelLarge,
//               textAlign: TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(height: 16),
//       // ! ====== Tip Area =======
//       Align(
//         alignment: Alignment.bottomLeft,
//         child: Text(
//           "Tips".toUpperCase(),
//           style: labelLarge,
//           textAlign: TextAlign.start,
//         ),
//       ),
//       Divider(
//         color: theme.textTheme.bodyLarge?.color,
//         height: 18,
//       ),
//       ...List.generate(data.totalTips.length - 1, (index) {
//         var tipData = data.totalTips[index];
//         return _row(theme,
//             title: tipData.title,
//             value: "\$${tipData.total.toStringAsFixed(2)}");
//       }),
//       Divider(
//         color: theme.textTheme.bodyLarge?.color,
//         height: 18,
//       ),
//       _row(theme,
//           title: data.totalTips.last.title,
//           value: "\$${data.totalTips.last.total.toStringAsFixed(2)}",
//           style: labelLarge?.copyWith(fontSize: 18)),
//       const SizedBox(height: 22),
//       // ! ======= Others =======
//       Row(
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               "Category".toUpperCase(),
//               style: labelLarge,
//               textAlign: TextAlign.start,
//             ),
//           ),
//           const SizedBox(width: 20),
//           Expanded(
//             child: Text(
//               "Grat.".toUpperCase(),
//               style: labelLarge,
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               "TIPS".toUpperCase(),
//               style: labelLarge,
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               "Sales".toUpperCase(),
//               style: labelLarge,
//               textAlign: TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//       Divider(
//         color: theme.textTheme.bodyLarge?.color,
//       ),
//       const SizedBox(height: 8),
//       // ! Item
//       ...List.generate(data.totalCategorySales.length - 1, (index) {
//         var catData = data.totalCategorySales[index];
//         return Row(
//           children: [
//             SizedBox(
//               width: 120,
//               child: Text(
//                 catData.title.toUpperCase(),
//                 style: labelMedium,
//                 textAlign: TextAlign.start,
//               ),
//             ),
//             const SizedBox(width: 20),
//             Expanded(
//               child: Text(
//                 // "\$${catData.gratuity.toStringAsFixed(2)}",
//                 "-",
//                 style: labelMedium,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(width: 6),
//             Expanded(
//               child: Text(
//                 // "\$${catData.tip.toStringAsFixed(2)}",
//                 "-",
//                 style: labelMedium,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(width: 6),
//             Expanded(
//               child: Text(
//                 "\$${catData.sales.toStringAsFixed(2)}",
//                 style: labelMedium,
//                 textAlign: TextAlign.end,
//               ),
//             ),
//           ],
//         );
//       }),
//       Divider(
//         color: theme.textTheme.bodyLarge?.color,
//         height: 18,
//       ),
//       Row(
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               data.totalCategorySales.last.title.toUpperCase(),
//               style: labelLarge?.copyWith(fontSize: 16),
//               textAlign: TextAlign.start,
//             ),
//           ),
//           const SizedBox(width: 20),
//           Expanded(
//             child: Text(
//               "\$${data.totalCategorySales.last.gratuity.toStringAsFixed(2)}",
//               style: labelLarge,
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               "\$${data.totalCategorySales.last.tip.toStringAsFixed(2)}",
//               style: labelLarge,
//               textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Align(
//               alignment: Alignment.centerRight,
//               child: Text(
//                 "\$${data.totalCategorySales.last.sales.toStringAsFixed(2)}",
//                 style: labelLarge,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(height: 20),
//       // ! ======= End =======
//           _row(theme,
//           title: "Total Discount:",
//           value: "(-) \$${data.totalDiscount.toStringAsFixed(2)}"),
//       _row(theme,
//           title: "Total GST:", value: "\$${data.totalGst.toStringAsFixed(2)}"),
//       _row(theme,
//           title: "Total PST:", value: "\$${data.totalPst.toStringAsFixed(2)}"),
//       _row(theme,
//           title: "Total PST2:",
//           value: "\$${data.totalPst2.toStringAsFixed(2)}"),
//       Visibility(
//           visible: data.totalMaintenanceFee > 0,
//           child: _row(theme,
//               title: "Total Maintenance Fee:",
//               value: "\$${data.totalMaintenanceFee.toStringAsFixed(2)}")),
//       Visibility(
//         visible: data.totalDeliveryFee > 0,
//         child: _row(theme,
//             title: "Total Delivery Fee:",
//             value: "\$${data.totalDeliveryFee.toStringAsFixed(2)}"),
//       ),

//       Divider(
//         color: theme.textTheme.bodyLarge?.color,
//         height: 18,
//       ),
//       _row(theme,
//           title: "Grand Total:",
//           value: "\$${data.grandTotal.toStringAsFixed(2)}"),
//       14.height,
//       _row(theme, title: "Server Checks:", value: "${data.serverSales}"),
//       _row(theme, title: "All Checks:", value: "${data.orders}"),
//       Divider(
//         color: theme.textTheme.bodyLarge?.color,
//         height: 18,
//       ),
//       PrimaryBtn(
//         onPressed: () async {
//           final printerName = Preferences.counterPrinter;
//           if (printerName.isEmpty) {
//             PopupDialog.showErrorMessage("No printer selected.");
//             return;
//           }
//           await PrintUtils().directPrint(
//             data: escCashOutPrintReceipt(data),
//             printerName: printerName,
//           );
//           Get.back();
//         },
//         text: "Print",
//         width: 100,
//         textColor: Colors.white,
//       ).marginOnly(top: 22)
//     ],
//   );
// }

// Widget _row(
//   ThemeData theme, {
//   TextStyle? style,
//   required String title,
//   required String value,
// }) {
//   var labelLarge = theme.textTheme.labelLarge?.copyWith(
//       fontFamily: Fonts.secondary, fontWeight: FontWeight.bold, fontSize: 15);
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(
//         title,
//         style: labelLarge ?? style,
//       ),
//       Text(
//         value,
//         style: labelLarge ?? style,
//       ),
//     ],
//   );
// }

class CashOutDialog extends GetView<OrderController> {
  const CashOutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 16),
        // btn area
        GetBuilder<OrderController>(
          builder: (context) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(context.cashOutTypeList.length, (index) {
                String cashOutType = context.cashOutTypeList[index];
                return Expanded(
                  child:
                      PrimaryBtn(
                        onPressed: () async {
                          context.onChangeCashOutType(cashOutType);
                        },
                        color: index == 0
                            ? StaticColors.greenColor
                            : StaticColors.blueColor,
                        isOutline: context.activeCashOutType == cashOutType
                            ? true
                            : false,
                        borderColor: StaticColors.orangeColor,
                        text: cashOutType
                            .replaceAll("_", "-")
                            .replaceAll("ONLINE", "OLO"),
                        textColor: Colors.white,
                        textMaxSize: 14,
                        textMinSize: 14,
                      ).marginOnly(
                        right: context.cashOutTypeList.length - 1 == index
                            ? 0
                            : 10,
                      ),
                );
              }),
            ).marginOnly(bottom: 16);
          },
        ),
        GetBuilder<OrderController>(
          builder: (context) {
            switch (context.activeCashOutType) {
              case "ALL":
                return _mycachOut(theme, context.allCashOut);
              case "DINE_IN":
                return _mycachOut(theme, context.dineInCashOut);
              case "TAKEOUT":
                return _mycachOut(theme, context.takeOutCashOut);
              case "DELIVERY":
                return _mycachOut(theme, context.deliveryCashOut);
              case "ONLINE":
                return _mycachOut(theme, context.oloCashOut);
              default:
                return const SizedBox();
            }
          },
        ),
      ],
    );
  }
}

// ! ======  MycachOut =====
Widget _mycachOut(ThemeData theme, CashoutModel? data) {
  var labelLarge = theme.textTheme.labelLarge?.copyWith(
    fontFamily: Fonts.secondary,
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );
  var labelMedium = theme.textTheme.labelMedium?.copyWith(
    fontSize: 13,
    fontFamily: Fonts.secondary,
    fontWeight: FontWeight.bold,
  );
  if (data == null) {
    return const SizedBox();
  }
  final showPaymentSummary =
      BaseController.to.employeeData?.posSummaryReport?.paymentSummaryReport ??
      false;
  return Column(
    children: [
      // Header area
      Text(
        data.title.toUpperCase(),
        style: theme.textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),

      // const SizedBox(height: 5),
      // _row(theme, title: data.date, value: ''),
      const SizedBox(height: 16),
      // ! ====== start and end ======
      DottedBorder(
        padding: const EdgeInsets.all(8),
        color: theme.textTheme.bodyLarge?.color ?? Colors.black,
        strokeWidth: 1,
        child: Row(
          children: [
            Text(
              'REPORT PULL DAY: ${data.day.toUpperCase()}\nPRINTED AT: ${DateFormat('hh:mm a').format(DateTime.now())}, ${MyFunc.getTimeZoneAbbr(Preferences.myTimeZone)}\nDATE RANGE: ${data.date}\nTIME RANGE: ${data.open.toUpperCase()} - ${data.close.toUpperCase()}',
              textAlign: TextAlign.start,
              style: labelLarge,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      // ! ====== Employee Summary (all servers) ======
      for (final emp in data.employeesReport) ...[
        6.height,
        SizedBox(
          width: double.infinity,
          child: Text(
            "SUMMARY REPORT FOR: ${emp.employeeName.toUpperCase()}",
            style: labelLarge?.copyWith(fontSize: 16),
            textAlign: TextAlign.start,
          ),
        ),
        Divider(color: theme.textTheme.bodyLarge?.color, height: 18),
        _row(theme, title: "Checks:", value: "${emp.serverSales}"),
        _row(theme, title: "Gratuity:", value: "\$${emp.serverTotalGratuity}"),
        _row(theme, title: "Cash Tips:", value: "\$${emp.serverCashTips}"),
        _row(theme, title: "Card Tips:", value: "\$${emp.serverCardTips}"),
        _row(theme, title: "Take-Home:", value: "\$${emp.serverCheckout}"),
        Divider(color: theme.textTheme.bodyLarge?.color, height: 18),
      ],
      const SizedBox(height: 16),
      //end
      if (showPaymentSummary) ...[
        // ! ======== pay ========
        Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                "Pay.".toUpperCase(),
                style: labelLarge,
                textAlign: TextAlign.start,
              ),
            ),
            // const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Disc.".toUpperCase(),
                style: labelLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Grat.".toUpperCase(),
                style: labelLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),

            Expanded(
              child: Text(
                "Tips".toUpperCase(),
                style: labelLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Subtotal".toUpperCase(),
                style: labelLarge,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        Divider(color: theme.textTheme.bodyLarge?.color),
        const SizedBox(height: 8),
        // ! Item
        ...List.generate(data.totalPay.length - 1, (index) {
          var payData = data.totalPay[index];
          return Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  payData.title,
                  style: labelLarge,
                  textAlign: TextAlign.start,
                ),
              ),
              // const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "\$${payData.discount.toStringAsFixed(2)}",
                  style: labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "\$${payData.gratuity.toStringAsFixed(2)}",
                  style: labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  "\$${payData.tips.toStringAsFixed(2)}",
                  style: labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "\$${payData.pay.toStringAsFixed(2)}",
                  style: labelLarge,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          );
        }),
        Divider(color: theme.textTheme.bodyLarge?.color, height: 18),
        Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                data.totalPay.last.title.toUpperCase(),
                style: labelLarge?.copyWith(fontSize: 16),
                textAlign: TextAlign.start,
              ),
            ),
            // const SizedBox(width: 6),
            Expanded(
              child: Text(
                "\$${data.totalPay.last.discount.toStringAsFixed(2)}",
                style: labelLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "\$${data.totalPay.last.gratuity.toStringAsFixed(2)}",
                style: labelLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),

            Expanded(
              child: Text(
                "\$${data.totalPay.last.tips.toStringAsFixed(2)}",
                style: labelLarge,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "\$${data.totalPay.last.pay.toStringAsFixed(2)}",
                style: labelLarge,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // ! ====== Tip Area =======
        Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            "Tips".toUpperCase(),
            style: labelLarge,
            textAlign: TextAlign.start,
          ),
        ),
        Divider(color: theme.textTheme.bodyLarge?.color, height: 18),
        ...List.generate(data.totalTips.length - 1, (index) {
          var tipData = data.totalTips[index];
          return _row(
            theme,
            title: tipData.title,
            value: "\$${tipData.total.toStringAsFixed(2)}",
          );
        }),
        Divider(color: theme.textTheme.bodyLarge?.color, height: 18),
        _row(
          theme,
          title: data.totalTips.last.title,
          value: "\$${data.totalTips.last.total.toStringAsFixed(2)}",
          style: labelLarge?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 22),
        // ! ======= Others =======
        Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                "Category".toUpperCase(),
                style: labelLarge,
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                "Disc.".toUpperCase(),
                style: labelLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Grat.".toUpperCase(),
                style: labelLarge,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "TIPS".toUpperCase(),
                style: labelLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Sales".toUpperCase(),
                style: labelLarge,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        Divider(color: theme.textTheme.bodyLarge?.color),
        const SizedBox(height: 8),
        // ! Item
        ...List.generate(data.totalCategorySales.length - 1, (index) {
          var catData = data.totalCategorySales[index];
          return Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  catData.title.toUpperCase(),
                  style: labelMedium,
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  "\$${catData.discount.toStringAsFixed(2)}",
                  style: labelMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  // "\$${catData.gratuity.toStringAsFixed(2)}",
                  "-",
                  style: labelMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  // "\$${catData.tip.toStringAsFixed(2)}",
                  "-",
                  style: labelMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "\$${catData.sales.toStringAsFixed(2)}",
                  style: labelMedium,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          );
        }),
        Divider(color: theme.textTheme.bodyLarge?.color, height: 18),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                data.totalCategorySales.last.title.toUpperCase(),
                style: labelLarge?.copyWith(fontSize: 16),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                "\$${data.totalCategorySales.last.discount.toStringAsFixed(2)}",
                style: labelLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "\$${data.totalCategorySales.last.gratuity.toStringAsFixed(2)}",
                style: labelLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),

            Expanded(
              child: Text(
                "\$${data.totalCategorySales.last.tip.toStringAsFixed(2)}",
                style: labelLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "\$${data.totalCategorySales.last.sales.toStringAsFixed(2)}",
                  style: labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // ! ======= End =======
        _row(
          theme,
          title: "Total Discount:",
          value: "(-) \$${data.totalDiscount.toStringAsFixed(2)}",
        ),
        _row(
          theme,
          title: "Total Gratuity:",
          value: "(-) \$${data.totalGratuity.toStringAsFixed(2)}",
        ),
        _row(
          theme,
          title: "Total Tips:",
          value: "(-) \$${data.totalTipAmount.toStringAsFixed(2)}",
        ),
        _row(
          theme,
          title: "Total GST:",
          value: "\$${data.totalGst.toStringAsFixed(2)}",
        ),
        Visibility(
          visible: data.totalPst > 0,
          child: _row(
            theme,
            title: "LIQUOR PST:",
            value: "\$${data.totalPst.toStringAsFixed(2)}",
          ),
        ),
        Visibility(
          visible: data.totalPst2 > 0,
          child: _row(
            theme,
            title: "SODA PST:",
            value: "\$${data.totalPst2.toStringAsFixed(2)}",
          ),
        ),
        // Visibility(
        //     visible: data.totalMaintenanceFee > 0,
        //     child: _row(theme,
        //         title: "Total Service Fee:",
        //         value: "\$${data.totalMaintenanceFee.toStringAsFixed(2)}")),
        Visibility(
          visible: data.totalPackagingCost > 0,
          child: _row(
            theme,
            title: "Total Packaging Cost:",
            value: "\$${data.totalPackagingCost.toStringAsFixed(2)}",
          ),
        ),
        Visibility(
          visible: data.totalDeliveryFee > 0,
          child: _row(
            theme,
            title: "Total Delivery Fee:",
            value: "\$${data.totalDeliveryFee.toStringAsFixed(2)}",
          ),
        ),

        Divider(color: theme.textTheme.bodyLarge?.color, height: 18),
        _row(
          theme,
          title: "Grand Total:",
          value: "\$${data.grandTotal.toStringAsFixed(2)}",
        ),
        _row(theme, title: "All Checks:", value: "${data.orders}"),
      ],

      // Divider(color: theme.textTheme.bodyLarge?.color, height: 18),
      PrimaryBtn(
        onPressed: () async {
          final printerName = Preferences.counterPrinter;
          if (printerName.isEmpty) {
            PopupDialog.showErrorMessage("No printer selected.");
            return;
          }
          await PrintUtils().directPrint(
            data: escCashOutPrintReceipt(data),
            printer: printerName,
          );
          Get.back();
        },
        text: "Print",
        width: 100,
        textColor: Colors.white,
      ).marginOnly(top: 22),
    ],
  );
}

Widget _row(
  ThemeData theme, {
  TextStyle? style,
  required String title,
  required String value,
}) {
  var labelLarge = theme.textTheme.labelLarge?.copyWith(
    fontFamily: Fonts.secondary,
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: labelLarge ?? style),
      Text(value, style: labelLarge ?? style),
    ],
  );
}

String get _serverName {
  final emp = BaseController.to.employeeData;
  final first = emp?.firstName ?? '';
  final lastInitial = (emp?.lastName.isNotEmpty ?? false)
      ? ' ${emp!.lastName[0]}.'
      : '';
  return '$first$lastInitial'.toUpperCase();
}
