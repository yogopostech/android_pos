import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_order_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/split_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/widgets/dialogs/split_print/split_amount/esc_split_amount_print_receipt.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/moneris/dialogs/moneris_purchase_dialog.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/moneris/dialogs/moneris_split_purchase_dialog.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/utils/extension/num_extensions.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/moneris_cash_and_card_dialog.dart';
import 'package:yogo_pos/app/widgets/payment_dialog.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class MonerisSplitDialog extends GetView<SplitOrderController> {
  final int index;
  final bool isSplitOrder;
  const MonerisSplitDialog(
      {super.key, required this.index, required this.isSplitOrder});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryBtn(
                height: 103,
                color: StaticColors.blueColor,
                width: double.infinity,
                onPressed: () async {
                  Get.back();

                  if (PosController.to.terminals != null) {
                    String terminalId = Preferences.terminalId;

                    if (terminalId.isEmpty == true) {
                      PopupDialog.showErrorMessage(
                          "There is no terminal active");
                      return;
                    }
                    // PopupDialog.showLoadingDialog();
                    monerisSplitPurchaseDialog(
                        index: index,
                        isSplitOrder: isSplitOrder,
                        orderId: isSplitOrder
                            ? controller.listOfSpitChecksByItems[index].orderId
                            : controller
                                .splitAmountChecks.splitAmounts[index].orderId,
                        terminalId: terminalId,
                        totalAmount:
                            "${((isSplitOrder ? controller.listOfSpitChecksByItems[index].totalOrderAmount : controller.splitAmountChecks.splitAmounts[index].total) * 100).toInt()}",
                            
                            //  declineAttempt: isSplitOrder
                            // ? controller.listOfSpitChecksByItems[index].declineAttempt
                            // : controller
                            //     .splitAmountChecks.splitAmounts[index].declineAttempt,
                            );
                    // PopupDialog.closeLoadingDialog();
                  } else {
                    PopupDialog.showErrorMessage("There is no terminal active");
                  }
                },
                text: "PAY",
                padding: const EdgeInsets.symmetric(horizontal: 12),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: Colors.white),
                borderColor: Colors.transparent,
                isOutline: true,
              ),
            ),
            10.width,
            Expanded(
              child: PrimaryBtn(
                height: 103,
                color: StaticColors.blueColor,
                width: double.infinity,
                onPressed: () {
                  Get.back();
                  PopupDialog.customDialog(
                    width: 600,
                    child: PaymentDialog(
                      paymentMethod: "CASH",
                      minPay: PosController.to.myOrder.totalOrderAmount,
                      onPay: (value) async {
                        if (value == null) {
                          return;
                        }
                        if (isSplitOrder) {
                          // Handle split order payment
                          await controller.splitOrderPayment(index, value);
                        } else {
                          // Handle regular payment
                          controller.splitAmountChecks.splitAmounts[index]
                              .payment = value;
                          await controller.paySplitAmount();
                        }
                      },
                      onPayAndPrint: (value) async {
                        if (value == null) {
                          return;
                        }
                        if (isSplitOrder) {
                          // Handle split order payment
                          await controller.splitOrderPayment(index, value);
                          // for printer
                          await PrintUtils().directPrint(
                              data:  escOrderPrintReceipt(
                                  order: controller
                                      .listOfSpitChecksByItems[index]),
                              printer: Preferences.counterPrinter);
                        } else {
                          // Handle regular payment
                          controller.splitAmountChecks.splitAmounts[index]
                              .payment = value;
                          await controller.paySplitAmount();

                          //for print//
                          final printerName = Preferences.counterPrinter;
                          await PrintUtils().directPrint(
                              data:  escSplitAmountPrintReceipt(
                                  isCustomerCopy: true,
                                  order: controller
                                      .splitAmountChecks.splitAmounts[index]),
                              printer: printerName);
                        }
                      },
                    ),
                  );
                },
                text: "CASH",
                padding: const EdgeInsets.symmetric(horizontal: 12),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: Colors.white),
                borderColor: Colors.transparent,
                isOutline: true,
              ),
            ),
          ],
        ),
        10.height,
        Row(
          children: [
            Expanded(
              child: PrimaryBtn(
                height: 103,
                color: StaticColors.blueColor,
                width: double.infinity,
                onPressed: () {
                  Get.back();

                  PopupDialog.customDialog(
                    width: 600,
                    child: MonerisCashAndCardDialog(
                      minPay: PosController.to.myOrder.totalOrderAmount,
                      onPay: (paymentData) {
                        // Handle pay action
                        if (paymentData == null) {
                          return;
                        }
                        Get.back();
                        String terminalId = Preferences.terminalId;
                        if (terminalId.isEmpty == true) {
                          PopupDialog.showErrorMessage(
                              "There is no terminal active");
                          return;
                        }
                        monerisPurchaseDialog(
                          orderId: PosController.to.myOrder.orderId,
                          terminalId: terminalId,
                          totalAmount:
                              paymentData.cardPaidAmount.toCents(),
                          isCashAndCard: true,
                          isKitchenPrint: true,
                          isPlaceOrder: true,
                          cash: paymentData.cashPaidAmount,
                          cashTip: paymentData.cashTipAmount,
                          // declineAttempt: PosController.to.myOrder.declineAttempt,
                        );
                      },
                      onPayAndPrint: (paymentData) {
                        if (paymentData == null) {
                          return;
                        }
                        Get.back();
                         String terminalId = Preferences.terminalId;
                        if (terminalId.isEmpty == true) {
                          PopupDialog.showErrorMessage(
                              "There is no terminal active");
                          return;
                        }
                        monerisPurchaseDialog(
                          orderId: PosController.to.myOrder.orderId,
                          terminalId: terminalId,
                          totalAmount:
                              paymentData.cardPaidAmount.toCents(),
                          isCashAndCard: true,
                          isKitchenPrint: true,
                          isPlaceOrder: true,
                          cash: paymentData.cashPaidAmount,
                          cashTip: paymentData.cashTipAmount,
                          // declineAttempt: PosController.to.myOrder.declineAttempt,
                        );
                      },
                    ),
                  );
                },
                text: "CASH AND CARD",
                padding: const EdgeInsets.symmetric(horizontal: 12),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: Colors.white),
                borderColor: Colors.transparent,
                isOutline: true,
              ),
            ),
          ],
        )
      ],
    );
  }
}
