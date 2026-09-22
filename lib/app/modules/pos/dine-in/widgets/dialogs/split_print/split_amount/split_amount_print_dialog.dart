import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/widgets/dialogs/split_print/split_amount/esc_split_amount_print_receipt.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../../../../config/fonts.dart';
import '../../../../../../../widgets/const.dart';
import '../../../../../../../widgets/my_custom_text.dart';
import '../../../../../order/models/order_model.dart';
import '../../../../controllers/split_order_controller.dart';
import '../../../../models/split_amount_model.dart';

class SplitAmountPrintOrderDialog extends StatelessWidget {
  final SplitAmount order;
  const SplitAmountPrintOrderDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    OrderModel mainOrder = SplitOrderController.to.mainOrder;
    BaseController baseController = Get.find<BaseController>();
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrimaryBtn(
              onPressed: () async {
                final printerName = Preferences.counterPrinter;
                if (printerName.isNotEmpty) {
                  await PrintUtils().directPrint(
                      data:  escSplitAmountPrintReceipt(order: order),
                      printer: printerName);
                  Get.back();
                } else {
                  PopupDialog.showErrorMessage(
                      "You need to select printer first");
                }
              },
              text: " Customer Copy",
              textColor: Colors.white,
            ),
            const SizedBox(width: 6),
            PrimaryBtn(
              onPressed: () async {
                final printerName = Preferences.counterPrinter;
                if (printerName.isNotEmpty) {
                  await PrintUtils().directPrint(
                      data:  escSplitAmountPrintReceipt(
                          isCustomerCopy: false, order: order),
                      printer: printerName);
                  Get.back();
                } else {
                  PopupDialog.showErrorMessage(
                      "You need to select printer first");
                }
              },
              text: " Merchant Copy",
              textColor: Colors.white,
            ),
          ],
        ),
        // header
        if (baseController.printImg != null) ...{
          const SizedBox(height: 16),
          Image.memory(baseController.printByteImgData!, width: 120),
          const SizedBox(height: 12),
        },
        _printText(
            (baseController.restaurantDetails?.restaurant.name ?? "")
                .toUpperCase(),
            fontSize: 36),
        const SizedBox(height: 14),
        _printText(
            (baseController.restaurantDetails?.restaurant.address ?? "")
                .replaceAll("_", "\n"),
            textAlign: TextAlign.center,
            maxLines: 2),
        const SizedBox(height: 10),
        _printText(
            "Phone: ${baseController.restaurantDetails?.restaurant.phone}"),
        const Divider(
          color: Colors.black,
          height: 18,
        ),
        // order details
        Row(
          children: [
            Expanded(
                child: _printText(
                    "Check:${order.orderId}")),
            const SizedBox(width: 6),
            Expanded(
                child: _printText(
              DateFormat('MMM dd,hh:mm a').format(DateTime.now().toTimeZone()),
              textAlign: TextAlign.right,
            )),
          ],
        ),
        Row(
          children: [
            Expanded(
                child: _printText(
                    "Server:${mainOrder.employee?.firstName.toUpperCase()}")),
            const SizedBox(width: 8),
            if (mainOrder.orderType != "TAKEOUT")
              Expanded(
                child: _printText(
                  "${mainOrder.orderType.replaceAll('_', ' ')}:${mainOrder.tableName}",
                  textAlign: TextAlign.right,
                ),
              ),
            if (mainOrder.orderType == "TAKEOUT")
              Expanded(
                child: _printText(
                  "Type:${mainOrder.orderType}",
                  textAlign: TextAlign.right,
                ),
              ),
          ],
        ),
        Row(
          children: [
            if (order.guestName.isNotEmpty)
              Expanded(child: _printText("Guest:${mainOrder.guestName}")),
            if (mainOrder.guestName.isNotEmpty) const SizedBox(width: 8),
            if (mainOrder.orderType != "TAKEOUT")
              Expanded(
                child: _printText(
                  "No. of Guest:${mainOrder.numberOfPeople}",
                  textAlign: order.guestName.isNotEmpty
                      ? TextAlign.right
                      : TextAlign.left,
                ),
              ),
          ],
        ),
        if (mainOrder.guestPhoneNumber.isNotEmpty)
          Row(
            children: [
              Expanded(
                  child: _printText("Number: ${mainOrder.guestPhoneNumber}")),
            ],
          ),
        const Divider(
          color: Colors.black,
          height: 18,
        ),
        // ! total calculation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _printText("Total Amount"),
            _printText("\$${mainOrder.totalOrderAmount.toStringAsFixed(2)}"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _printText("Split Amount"),
            _printText("\$${order.splitAmount.toStringAsFixed(2)}"),
          ],
        ),
        if (order.payment != null) ...[
          // ! for tip (cash)
          if ((order.payment?.cashTipAmount ?? 0) > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _printText("Cash Tip"),
                _printText(
                    '\$${order.payment?.cashTipAmount.toStringAsFixed(2)}'),
              ],
            ),
          // ! for tip (card)
          if ((order.payment?.cardTipAmount ?? 0) > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _printText("Card Tip"),
                _printText(
                    '\$${order.payment?.cardTipAmount.toStringAsFixed(2)}'),
              ],
            ),

          // ! Total paid cash
          // if ((order.payment?.cashPaidAmount ?? 0) > 0)
          if (order.payment?.methods.contains('CASH') ?? false)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _printText("Paid by Cash"),
                _printText(
                    '\$${((order.payment?.cashPaidAmount ?? 0) + (order.payment?.change ?? 0) + (order.payment?.cashTipAmount ?? 0)).toStringAsFixed(2)}'),
              ],
            ),

          // ! Total paid card
          // if ((order.payment?.cardPaidAmount ?? 0) > 0)
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       _printText(
          //           'Paid by ${order.payment?.cardType == "" ? order.payment?.method.replaceAll("_", "").toUpperCase() : order.payment?.cardType}'),
          //       _printText(
          //           '\$${((order.payment?.cardPaidAmount ?? 0) + (order.payment?.cardTipAmount ?? 0)).toStringAsFixed(2)}'),
          //     ],
          //   ),
          // ! change
          if ((order.payment?.change ?? 0) > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _printText("Change"),
                _printText('\$${order.payment?.change.toStringAsFixed(2)}'),
              ],
            ),
        ],
        // ****** Total ******
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _printText(
              order.payment == null ? "Total" : "Total (PAID)",
              fontSize: 18,
            ),
            _printText(
              "\$${(order.splitAmount + (order.payment?.cardTipAmount ?? 0) + (order.payment?.cashTipAmount ?? 0)).toStringAsFixed(2)}",
              fontSize: 18,
            ),
          ],
        ),
        const Divider(
          color: Colors.black,
          height: 18,
        ),
        // !  end
        // const Divider(color: Colors.black, height: 18),
        _printText(
            "Customer Copy: ${order.payment == null ? 'UNPAID' : '${order.payment?.methods.join(', ').replaceAll('_', ' ') ?? ""} Sale'}",
            fontSize: 13),
        const Divider(color: Colors.black, height: 18),
        _printText(
            "Thank you for visiting ${baseController.restaurantDetails?.restaurant.name.toUpperCase()}",
            fontSize: 13,
            textAlign: TextAlign.center),
        const Divider(color: Colors.black, height: 18),
        _printText("Please review us on Google", fontSize: 13),
        // Divider(color: theme.textTheme.bodyLarge?.color, height: 18),
        // _printText("GST NUMBER: ${Restaurant.gst}", fontSize: 13),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.center,
          child: _printText(
            "Powered by ${Yogo.name}",
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  MyCustomText _printText(String text,
          {double fontSize = 15,
          FontWeight fontWeight = FontWeight.bold,
          TextAlign textAlign = TextAlign.start,
          int? maxLines}) =>
      MyCustomText(
        maxLines: maxLines ?? 1,
        text,
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: fontWeight,
        textAlign: textAlign,
        fontFamily: Fonts.secondary,
        height: 1.20,
      );
}
