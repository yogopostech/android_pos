/// Elavon Commerce Web Services (CWS) — Refund Dialog
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
import 'package:yogo_pos/app/utils/logger.dart';

import 'cws_base_dialog.dart';
import '../models/cws_model.dart';
import '../providers/cws_provider.dart';

// ============================================================================
// Entry point — amountCents is mandatory
// ============================================================================

void cwsRefundDialog({
  required int amountCents,
  String? invoiceNum,
  String? customerRef,
  String? orderId,
}) {
  showDialog<void>(
    context: Get.context!,
    barrierDismissible: false,
    builder: (_) => _RefundDialog(
      amountCents: amountCents,
      invoiceNum: invoiceNum,
      customerRef: customerRef,
      orderId: orderId,
    ),
  );
}

// ============================================================================
// Dialog Widget
// ============================================================================

class _RefundDialog extends StatelessWidget {
  final int amountCents;
  final String? invoiceNum;
  final String? customerRef;
  final String? orderId;

  const _RefundDialog({
    required this.amountCents,
    this.invoiceNum,
    this.customerRef,
    this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return CwsBaseDialog(
      title: 'Refund',
      onExecute: (ref) async {
        final result = await ref.read(cwsPaymentProvider.notifier).refund(
              amountCents: amountCents,
              invoiceNum: invoiceNum,
              customerRef: customerRef,
            );

        if (result != null && result.isApproved) {
          await _onRefunded(result);
        }
      },
    );
  }

  Future<void> _onRefunded(CwsPaymentResult result) async {
    try {
      if (orderId != null) {
        PosController.to.myOrder.payment = PaymentModel(
          methods: [(result.cardName ?? 'Card').toUpperCase()],
          cardPaidAmount: result.totalAmountDollars,
          cardType: result.cardName ?? 'Card',
          transactionId: result.transactionId,
          paymentIntent: orderId!,
          providerName: "Elavon",
        );

        PosController.to.myOrder.orderStatus = "REFUNDED";
        PosController.to.myOrder.paymentStatus = "REFUNDED";

        bool isUpdated =
            await PosController.to.onUpdateOrder(PosController.to.myOrder.id);
        if (isUpdated) {
          DataUpdateHelper.getDataByCheckType();
        }
      }

      kLogger.i('[CWS] Refund completed — ref=${result.referenceNumber}');
    } catch (e) {
      kLogger.e('[CWS] Error updating refunded order: $e');
    }
  }
}