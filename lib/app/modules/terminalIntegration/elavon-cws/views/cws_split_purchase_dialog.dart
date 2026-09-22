/// Elavon Commerce Web Services (CWS) — Split Purchase Dialog
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_order_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/split_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/widgets/dialogs/split_print/split_amount/esc_split_amount_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/elavon-cws/models/cws_model.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/elavon-cws/providers/cws_provider.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/elavon-cws/views/cws_base_dialog.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';

void cwsSplitPurchaseDialog({
  required int amountCents,
  required int index,
  bool isSplitOrder = false,
  bool isCashAndCard = false,
  bool isOrderPrint = false,
  num cash = 0,
  num cashTip = 0,
  String? invoiceNum,
}) {
  showDialog<void>(
    context: Get.context!,
    barrierDismissible: false,
    builder: (_) => _SplitPurchaseDialog(
      amountCents: amountCents,
      invoiceNum: invoiceNum,
      index: index,
      isSplitOrder: isSplitOrder,
      isCashAndCard: isCashAndCard,
      isOrderPrint: isOrderPrint,
      cash: cash,
      cashTip: cashTip,
    ),
  );
}

class _SplitPurchaseDialog extends StatelessWidget {
  final int amountCents;
  final String? invoiceNum;

  final int index;
  final bool isSplitOrder;
  final bool isCashAndCard;
  final bool isOrderPrint;

  final num cash;
  final num cashTip;

  const _SplitPurchaseDialog({
    required this.amountCents,
    required this.index,
    required this.isSplitOrder,
    required this.isCashAndCard,
    required this.isOrderPrint,
    required this.cash,
    required this.cashTip,
    this.invoiceNum,
  });

  @override
  Widget build(BuildContext context) {
    return CwsBaseDialog(
      title: "Purchase",
      onExecute: (ref) async {
        final result = await ref.read(cwsPaymentProvider.notifier).purchase(
              amountCents: amountCents,
              invoiceNum: invoiceNum,
            );

        if (result != null && result.isApproved) {
          await _updateSplitOrder(result);
        }
      },
    );
  }

  Future<void> _updateSplitOrder(CwsPaymentResult result) async {
    try {
      PaymentModel paymentModel;

      if (isCashAndCard) {
        paymentModel = PaymentModel(
          methods: ["CASH_AND_CARD"],
          cardPaidAmount: result.amountDollars,
          cardTipAmount: result.tipAmountDollars,
          cashPaidAmount: cash,
          cashTipAmount: cashTip,
          cardType: result.cardName ?? "OTHERS",
          transactionId: result.authCode ?? result.transactionId,
          maskedPan: result.maskedPan ?? "",
          entryMode: result.entryMode ?? "",
          providerName: "Elavon",
        );
      } else {
        paymentModel = PaymentModel(
          methods: [(result.cardName ?? "OTHERS").toUpperCase()],
          cardPaidAmount: result.amountDollars,
          cardTipAmount: result.tipAmountDollars,
          cardType: result.cardName ?? "OTHERS",
          transactionId: result.authCode ?? result.transactionId,
          maskedPan: result.maskedPan ?? "",
          entryMode: result.entryMode ?? "",
          providerName: "Elavon",
        );
      }

      if (isSplitOrder) {
        await SplitOrderController.to.splitOrderPayment(index, paymentModel);

        if (isOrderPrint) {
          await PrintUtils().directPrint(
            data: escOrderPrintReceipt(
              order: SplitOrderController.to.listOfSpitChecksByItems[index],
            ),
            printer: Preferences.counterPrinter,
          );
        }
      } else {
        SplitOrderController
            .to
            .splitAmountChecks
            .splitAmounts[index]
            .payment = paymentModel;

        await SplitOrderController.to.paySplitAmount();

        if (isOrderPrint) {
          await PrintUtils().directPrint(
            data: escSplitAmountPrintReceipt(
              isCustomerCopy: true,
              order: SplitOrderController.to.splitAmountChecks.splitAmounts[index],
            ),
            printer: Preferences.counterPrinter,
          );
        }
      }

      DataUpdateHelper.getDataByCheckType();

      kLogger.i("[CWS] Split payment updated");
    } catch (e) {
      kLogger.e("[CWS] Split payment failed: $e");
    }
  }
}