/// Elavon Commerce Web Services (CWS) — Void Dialog
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';

import 'cws_base_dialog.dart';
import '../models/cws_model.dart';
import '../providers/cws_provider.dart';

// ============================================================================
// Entry point — reference the original transaction to void
// ============================================================================

void cwsVoidDialog({
  String? transId,
  String? invoiceNum,
  int? amountCents,
  String? orderId,
}) {
  showDialog<void>(
    context: Get.context!,
    barrierDismissible: false,
    builder: (_) => _VoidDialog(
      transId: transId,
      invoiceNum: invoiceNum,
      amountCents: amountCents,
      orderId: orderId,
    ),
  );
}

// ============================================================================
// Dialog Widget
// ============================================================================

class _VoidDialog extends StatelessWidget {
  final String? transId;
  final String? invoiceNum;
  final int? amountCents;
  final String? orderId;

  const _VoidDialog({
    this.transId,
    this.invoiceNum,
    this.amountCents,
    this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return CwsBaseDialog(
      title: 'Void',
      onExecute: (ref) async {
        final result = await ref.read(cwsPaymentProvider.notifier).voidTransaction(
              transId: transId,
              invoiceNum: invoiceNum,
              amountCents: amountCents,
            );

        if (result != null && result.isApproved) {
          await _onVoided(result);
        }
      },
    );
  }

  Future<void> _onVoided(CwsPaymentResult result) async {
    try {
      if (orderId != null) {
        PosController.to.myOrder.orderStatus = "VOIDED";
        PosController.to.myOrder.paymentStatus = "VOIDED";

        bool isUpdated =
            await PosController.to.onUpdateOrder(PosController.to.myOrder.id);
        if (isUpdated) {
          DataUpdateHelper.getDataByCheckType();
        }
      }

      kLogger.i('[CWS] Void completed — ref=${result.referenceNumber}');
    } catch (e) {
      kLogger.e('[CWS] Error updating voided order: $e');
    }
  }
}