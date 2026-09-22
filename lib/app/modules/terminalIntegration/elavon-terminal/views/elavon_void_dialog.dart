/// Ingenico Tetra TSI — Void Dialog
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';

import 'elavon_base_dialog.dart';
import '../models/elavon_model.dart';
import '../providers/elavon_provider.dart';

// ============================================================================
// Entry point — all search criteria are optional
// ============================================================================

void elavonVoidDialog({
  required String terminalIp,
  int terminalPort = 12000,
  String? invoiceNum,
  String? authCode,
  String? referenceNum,
  String? panLast4,
  int? amountCents,
  bool isPreAuthVoid = false,
  String? orderId,
}) {
  showDialog<void>(
    context: Get.context!,
    barrierDismissible: false,
    builder: (_) => _VoidDialog(
      terminalIp: terminalIp,
      terminalPort: terminalPort,
      invoiceNum: invoiceNum,
      authCode: authCode,
      referenceNum: referenceNum,
      panLast4: panLast4,
      amountCents: amountCents,
      isPreAuthVoid: isPreAuthVoid,
      orderId: orderId,
    ),
  );
}

// ============================================================================
// Dialog Widget
// ============================================================================

class _VoidDialog extends StatelessWidget {
  final String terminalIp;
  final int terminalPort;
  final String? invoiceNum;
  final String? authCode;
  final String? referenceNum;
  final String? panLast4;
  final int? amountCents;
  final bool isPreAuthVoid;
  final String? orderId;

  const _VoidDialog({
    required this.terminalIp,
    required this.terminalPort,
    this.invoiceNum,
    this.authCode,
    this.referenceNum,
    this.panLast4,
    this.amountCents,
    this.isPreAuthVoid = false,
    this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return ElavonBaseDialog(
      title: 'Void',
      onExecute: (ref) async {
        final result =
            await ref.read(elavonPaymentProvider.notifier).voidTransaction(
                  host: terminalIp,
                  port: terminalPort,
                  invoiceNum: invoiceNum,
                  authCode: authCode,
                  referenceNum: referenceNum,
                  panLast4: panLast4,
                  amountCents: amountCents,
                  isPreAuthVoid: isPreAuthVoid,
                );

        if (result != null && result.isApproved) {
          await _onVoided(result);
        }
      },
    );
  }

  Future<void> _onVoided(ElavonPaymentResult result) async {
    try {
      if (orderId != null) {
        PosController.to.myOrder.orderStatus = "VOIDED";
        PosController.to.myOrder.paymentStatus = "VOIDED";

        bool isUpdated = await PosController.to
            .onUpdateOrder(PosController.to.myOrder.id);
        if (isUpdated) {
          DataUpdateHelper.getDataByCheckType();
        }
      }

      kLogger.i('[Elavon] Void completed — ref=${result.referenceNumber}');
    } catch (e) {
      kLogger.e('[Elavon] Error updating voided order: $e');
    }
  }
}
