import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:yogo_pos/app/modules/pos/order/models/cashout_model.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/receipt.dart';

Uint8List escCashOutPrintReceipt(CashoutModel data) {
  final receipt = Receipt();
  // final receipt = StarReceipt();

  // Title
  receipt
      .header(data.title.toUpperCase(), fontSize: 2)
      .space()
      .box(
        'REPORT PULL DAY: ${data.day.toUpperCase()}\nPRINTED AT: ${DateFormat('hh:mm a').format(DateTime.now())}, ${MyFunc.getTimeZoneAbbr(Preferences.myTimeZone)}\nDATE RANGE: ${data.date}\nTIME RANGE: ${data.open.toUpperCase()} - ${data.close.toUpperCase()}',
        style: BoxStyle.ascii,
      );

  // All Employees Summary — shown right after the header info
  for (final emp in data.employeesReport) {
    receipt
        .space()
        .text(
          "SUMMARY REPORT FOR: ${emp.employeeName.toUpperCase()}",
          fontWeight: FontWeight.bold,
        )
        .separator()
        .row(left: 'Checks:', right: '${emp.serverSales}')
        .row(left: 'Gratuity:', right: '\$${emp.serverTotalGratuity}')
        .row(left: 'Cash Tips:', right: '\$${emp.serverCashTips}')
        .row(left: 'Card Tips:', right: '\$${emp.serverCardTips}')
        .row(left: 'Take-Home:', right: '\$${emp.serverCheckout}');
  }
  receipt.space();

  final showPaymentSummary =
      BaseController.to.employeeData?.posSummaryReport?.paymentSummaryReport ??
      false;

  if (showPaymentSummary) {
    // Payment Section Header
    receipt.flexRow(
      children: [
        Col.fixed('PAY.', width: 10, fontWeight: FontWeight.bold),
        Col.flex('DISC.', align: Align.center, fontWeight: FontWeight.bold),
        Col.flex('GRAT.', align: Align.center, fontWeight: FontWeight.bold),
        Col.flex('TIPS', align: Align.center, fontWeight: FontWeight.bold),
        Col.flex('SUBTOTAL', align: Align.right, fontWeight: FontWeight.bold),
      ],
    );

    receipt.separator();

    // Payment Items
    for (int i = 0; i < data.totalPay.length - 1; i++) {
      var payData = data.totalPay[i];
      receipt.flexRow(
        children: [
          Col.fixed(payData.title, width: 10),
          Col.flex(
            '\$${payData.discount.toStringAsFixed(2)}',
            align: Align.center,
          ),
          Col.flex(
            '\$${payData.gratuity.toStringAsFixed(2)}',
            align: Align.center,
          ),
          Col.flex(
            '\$${payData.tips.toStringAsFixed(2)}',
            align: Align.center,
          ),
          Col.flex('\$${payData.pay.toStringAsFixed(2)}', align: Align.right),
        ],
      );
    }

    receipt.separator();

    // Payment Total
    var payTotal = data.totalPay.last;
    receipt
        .flexRow(
          children: [
            Col.fixed(
              payTotal.title.toUpperCase(),
              width: 10,
              fontWeight: FontWeight.bold,
            ),
            Col.flex(
              '\$${payTotal.discount.toStringAsFixed(2)}',
              align: Align.center,
            ),
            Col.flex(
              '\$${payTotal.gratuity.toStringAsFixed(2)}',
              align: Align.center,
            ),
            Col.flex(
              '\$${payTotal.tips.toStringAsFixed(2)}',
              align: Align.center,
            ),
            Col.flex(
              '\$${payTotal.pay.toStringAsFixed(2)}',
              align: Align.right,
            ),
          ],
        )
        .space();

    // Tips Section
    receipt.bold('TIPS').separator();

    for (int i = 0; i < data.totalTips.length - 1; i++) {
      var tipData = data.totalTips[i];
      receipt.row(
        left: tipData.title,
        right: '\$${tipData.total.toStringAsFixed(2)}',
      );
    }

    receipt.separator();

    var tipTotal = data.totalTips.last;
    receipt
        .row(
          left: tipTotal.title.toUpperCase(),
          right: '\$${tipTotal.total.toStringAsFixed(2)}',
          fontWeight: FontWeight.bold,
        )
        .space();
    // Category Section Header
    receipt.flexRow(
      children: [
        Col.fixed('CATEGORY', width: 10, fontWeight: FontWeight.bold),
        Col.flex('DISC.', align: Align.center, fontWeight: FontWeight.bold),
        Col.flex('GRAT.', align: Align.center, fontWeight: FontWeight.bold),
        Col.flex('TIPS', align: Align.center, fontWeight: FontWeight.bold),
        Col.flex('SALES', align: Align.right, fontWeight: FontWeight.bold),
      ],
    );

    receipt.separator();

    // Category Items
    for (int i = 0; i < data.totalCategorySales.length - 1; i++) {
      var catData = data.totalCategorySales[i];
      receipt.flexRow(
        children: [
          Col.fixed(catData.title.toUpperCase(), width: 10),
          Col.flex(
            '\$${catData.discount.toStringAsFixed(2)}',
            align: Align.center,
          ),
          Col.flex('-', align: Align.center),

          Col.flex('-', align: Align.center),
          Col.flex(
            '\$${catData.sales.toStringAsFixed(2)}',
            align: Align.right,
          ),
        ],
      );
    }

    receipt.separator();

    // Category Total
    var catTotal = data.totalCategorySales.last;
    receipt
        .flexRow(
          children: [
            Col.fixed(
              catTotal.title.toUpperCase(),
              width: 10,
              fontWeight: FontWeight.bold,
            ),
            Col.flex(
              '\$${catTotal.discount.toStringAsFixed(2)}',
              align: Align.center,
            ),
            Col.flex(
              '\$${catTotal.gratuity.toStringAsFixed(2)}',
              align: Align.center,
            ),

            Col.flex(
              '\$${catTotal.tip.toStringAsFixed(2)}',
              align: Align.center,
            ),
            Col.flex(
              '\$${catTotal.sales.toStringAsFixed(2)}',
              align: Align.right,
            ),
          ],
        )
        .space();

    // Tax and Fees Summary
  receipt
      .row(
        left: 'Total Discount:',
        right: '(-) \$${data.totalDiscount.toStringAsFixed(2)}',
      )
      .row(
        left: 'Total Gratuity:',
        right: '(-) \$${data.totalGratuity.toStringAsFixed(2)}',
      )
      .row(
        left: 'Total Tips:',
        right: '(-) \$${data.totalTipAmount.toStringAsFixed(2)}',
      )
      .row(left: 'Total GST:', right: '\$${data.totalGst.toStringAsFixed(2)}');
  if (data.totalPst > 0) {
    receipt.row(
      left: 'LIQUOR PST:',
      right: '\$${data.totalPst.toStringAsFixed(2)}',
    );
  }
  if (data.totalPst2 > 0) {
    receipt.row(
      left: 'SODA PST:',
      right: '\$${data.totalPst2.toStringAsFixed(2)}',
    );
  }

  // if (data.totalMaintenanceFee > 0) {
  //   receipt.row(
  //     left: 'Total Service Fee:',
  //     right: '\$${data.totalMaintenanceFee.toStringAsFixed(2)}',
  //   );
  // }

  if (data.totalPackagingCost > 0) {
    receipt.row(
      left: 'Total Packaging Cost:',
      right: '\$${data.totalPackagingCost.toStringAsFixed(2)}',
    );
  }

  if (data.totalDeliveryFee > 0) {
    receipt.row(
      left: 'Total Delivery Fee:',
      right: '\$${data.totalDeliveryFee.toStringAsFixed(2)}',
    );
  }

  receipt
      .separator()
      .row(
        left: 'Grand Total:',
        right: '\$${data.grandTotal.toStringAsFixed(2)}',
        fontWeight: FontWeight.bold,
      )
      .row(left: 'All Checks:', right: '${data.orders}')
      .space();
  }

  // Cut paperbeepSuccess()
  receipt.space(2).cut();

  return receipt.bytes;
}

// String get _serverName {
//   final emp = BaseController.to.employeeData;
//   final first = emp?.firstName ?? '';
//   final lastInitial = (emp?.lastName.isNotEmpty ?? false)
//       ? ' ${emp!.lastName[0]}.'
//       : '';
//   return '$first$lastInitial'.toUpperCase();
// }
