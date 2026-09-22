/// Elavon Commerce Web Services (CWS) — Purchase Dialog
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/elavon-cws/services/cws_gratuity.dart';
import 'package:yogo_pos/app/utils/logger.dart';

import 'cws_base_dialog.dart';
import '../models/cws_model.dart';
import '../providers/cws_provider.dart';

void cwsPurchaseDialog({
  required int amountCents,
  String? invoiceNum,
  num cash = 0,
  num cashTip = 0,
  bool isPlaceOrder = false,
  bool isCashAndCard = false,
  CwsGratuity gratuity = CwsGratuity.none, // tip config (default: no tip)
}) {
  showDialog<void>(
    context: Get.context!,
    barrierDismissible: false,
    builder: (_) => _PurchaseDialog(
      amountCents: amountCents,
      invoiceNum: invoiceNum,
      cash: cash,
      cashTip: cashTip,
      isPlaceOrder: isPlaceOrder,
      isCashAndCard: isCashAndCard,
      gratuity: gratuity,
    ),
  );
}

class _PurchaseDialog extends StatelessWidget {
  final int amountCents;
  final String? invoiceNum;
  final num cash;
  final num cashTip;
  final bool isPlaceOrder;
  final bool isCashAndCard;
  final CwsGratuity gratuity;

  const _PurchaseDialog({
    required this.amountCents,
    this.invoiceNum,
    required this.cash,
    required this.cashTip,
    required this.isPlaceOrder,
    required this.isCashAndCard,
    required this.gratuity,
  });

  @override
  Widget build(BuildContext context) {
    return CwsBaseDialog(
      title: 'Purchase',
      onExecute: (ref) async {
        final result = await ref
            .read(cwsPaymentProvider.notifier)
            .purchase(
              amountCents: amountCents,
              invoiceNum: invoiceNum,
              gratuity: gratuity,
            );

        if (result != null && result.isApproved) {
          await _updateOrder(result);
        }
      },
    );
  }

  Future<void> _updateOrder(CwsPaymentResult result) async {
    try {
      if (isCashAndCard) {
        PosController.to.myOrder.payment = PaymentModel(
          methods: ["CASH_AND_CARD"],
          cardPaidAmount: result.amountDollars,
          cardTipAmount: result.tipAmountDollars,
          cashPaidAmount: cash,
          cashTipAmount: cashTip,
          cardType: result.cardName ?? 'OTHERS',
          transactionId: result.authCode ?? result.transactionId,
          maskedPan: result.maskedPan ?? "",
          entryMode: result.entryMode ?? "",
          providerName: "Elavon",
        );
      } else {
        PosController.to.myOrder.payment = PaymentModel(
          methods: [(result.cardName ?? 'OTHERS').toUpperCase()],
          cardPaidAmount: result.amountDollars,
          cardTipAmount: result.tipAmountDollars,
          transactionId: result.authCode ?? result.transactionId,
          maskedPan: result.maskedPan ?? "",
          entryMode: result.entryMode ?? "",
          providerName: "Elavon",
        );
      }

      PosController.to.myOrder.orderStatus = "COMPLETED";
      PosController.to.myOrder.paymentStatus = "PAID";
      PosController.to.calculateTotalPrice();

      if (isPlaceOrder) {
        Get.back();
        await PosController.to.onPlaseOrder(
          orderStatus: "COMPLETED",
          paymentStatus: "PAID",
          isPrint: false,
          isElavonPay: true,
          isDirectPay: false,
        );
        DataUpdateHelper.getDataByCheckType();
      } else {
        bool isUpdated = await PosController.to.onUpdateOrder(
          PosController.to.myOrder.id,
        );
        if (isUpdated) {
          DataUpdateHelper.getDataByCheckType();
        }
      }

      kLogger.i('[CWS] Purchase order updated');
    } catch (e) {
      kLogger.e('[CWS] Error updating order: $e');
    }
  }
}