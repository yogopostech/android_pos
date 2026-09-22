/// Ingenico Tetra TSI — Purchase Dialog
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
import 'package:yogo_pos/app/utils/logger.dart';

import 'elavon_base_dialog.dart';
import '../models/elavon_model.dart';
import '../providers/elavon_provider.dart';

// ============================================================================
// Entry point function — call like monerisPurchaseDialog()
// ============================================================================

void elavonPurchaseDialog({
  required int amountCents,
  required String terminalIp,
  int terminalPort = 12000,
  String? invoiceNum,
  String? tenderType,
  num cash = 0,
  num cashTip = 0,
  bool isPlaceOrder = false,
  bool isCashAndCard = false,
  // bool isKitchenPrint = false,
}) {
  showDialog<void>(
    context: Get.context!,
    barrierDismissible: false,
    builder: (_) => _PurchaseDialog(
      amountCents: amountCents,
      terminalIp: terminalIp,
      terminalPort: terminalPort,
      invoiceNum: invoiceNum,
      tenderType: tenderType,
      cash: cash,
      cashTip: cashTip,
      isPlaceOrder: isPlaceOrder,
      isCashAndCard: isCashAndCard,
      // isKitchenPrint: isKitchenPrint,
    ),
  );
}

// ============================================================================
// Dialog Widget
// ============================================================================

class _PurchaseDialog extends StatelessWidget {
  final int amountCents;
  final String terminalIp;
  final int terminalPort;
  final String? invoiceNum;
  final String? tenderType;
  final num cash;
  final num cashTip;
  final bool isPlaceOrder;
  final bool isCashAndCard;
  // final bool isKitchenPrint;

  const _PurchaseDialog({
    required this.amountCents,
    required this.terminalIp,
    required this.terminalPort,
    this.invoiceNum,
    this.tenderType,
    required this.cash,
    required this.cashTip,
    required this.isPlaceOrder,
    required this.isCashAndCard,
    // required this.isKitchenPrint,
  });

  @override
  Widget build(BuildContext context) {
    return ElavonBaseDialog(
      title: 'Purchase',
      onExecute: (ref) async {
        final result = await ref
            .read(elavonPaymentProvider.notifier)
            .purchase(
              host: terminalIp,
              port: terminalPort,
              amountCents: amountCents,
              invoiceNum: invoiceNum,
              tenderType: tenderType,
            );

        if (result != null && result.isApproved) {
          await _updateOrder(result);
        }
      },
    );
  }

  Future<void> _updateOrder(ElavonPaymentResult result) async {
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

      kLogger.i('[Elavon] Purchase order updated');
    } catch (e) {
      kLogger.e('[Elavon] Error updating order: $e');
    }
  }
}
