import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_order_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/split_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/widgets/dialogs/split_print/split_amount/esc_split_amount_print_receipt.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/elavon-terminal/views/elavon_split_purchase_dialog.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/moneris/dialogs/moneris_split_purchase_dialog.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/num_extensions.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/utils/receipt.dart' hide FontWeight;
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/widgets/moneris_cash_and_card_dialog.dart';
import 'package:yogo_pos/app/widgets/payment_dialog.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class PaymentMethodDialog extends StatefulWidget {
  final int orderIndex;
  final bool isSplitOrder;

  const PaymentMethodDialog({
    super.key,
    required this.orderIndex,
    required this.isSplitOrder,
  });

  @override
  State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  final List<String> _methodList = [
    "VISA",
    "MASTERCARD",
    "AMEX",
    "DEBIT_CARD",
    "CASH",
    "CASH_AND_CARD",
    "OTHERS",
    // "GIFT_CARD"
  ];

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'Select Payment Method',
          style: theme.textTheme.titleLarge,
        ).marginOnly(bottom: 16),
        // Payment Method
        Visibility(
          visible: BaseController.to.posMonerisTerminal,
          child: PrimaryBtn(
            onPressed: () {
              Get.back();

              if (PosController.to.terminals != null) {
                String terminalId = Preferences.terminalId;

                if (terminalId.isEmpty == true) {
                  PopupDialog.showErrorMessage("There is no terminal active");
                  return;
                }
                // PopupDialog.showLoadingDialog();
                monerisSplitPurchaseDialog(
                  index: widget.orderIndex,
                  isSplitOrder: widget.isSplitOrder,
                  orderId: widget.isSplitOrder
                      ? SplitOrderController
                            .to
                            .listOfSpitChecksByItems[widget.orderIndex]
                            .orderId
                      : SplitOrderController
                            .to
                            .splitAmountChecks
                            .splitAmounts[widget.orderIndex]
                            .orderId,
                  terminalId: terminalId,
                  totalAmount:
                      "${((widget.isSplitOrder ? SplitOrderController.to.listOfSpitChecksByItems[widget.orderIndex].totalOrderAmount : SplitOrderController.to.splitAmountChecks.splitAmounts[widget.orderIndex].total) * 100).toInt()}",
                );
              } else {
                PopupDialog.showErrorMessage("There is no terminal active");
              }
            },
            text: "Moneris Pay".toUpperCase(),
            isOutline: true,
            width: double.infinity,
            borderColor: StaticColors.blueColor,
            color: StaticColors.blueColor,
            textColor: Colors.white,
            fontWeight: FontWeight.w800,
            borderWidth: 1.5,
            height: 70,
          ).marginOnly(bottom: 8),
        ),
        Visibility(
          visible: BaseController.to.posMonerisTerminal,
          child: PrimaryBtn(
            onPressed: () {
              Get.back();
              elavonSplitPurchaseDialog(
                index: widget.orderIndex,
                isSplitOrder: widget.isSplitOrder,
                amountCents: widget.isSplitOrder
                    ? SplitOrderController
                          .to
                          .listOfSpitChecksByItems[widget.orderIndex]
                          .totalOrderAmount
                          .toCentsInt()
                    : SplitOrderController
                          .to
                          .splitAmountChecks
                          .splitAmounts[widget.orderIndex]
                          .total
                          .toCentsInt(),
                terminalIp: Preferences.terminalIp,
                terminalPort: Preferences.terminalPort,
              );
            },
            text: "Elavon Pay".toUpperCase(),
            isOutline: true,
            width: double.infinity,
            borderColor: StaticColors.blueColor,
            color: StaticColors.blueColor,
            textColor: Colors.white,
            fontWeight: FontWeight.w800,
            borderWidth: 1.5,
            height: 70,
          ).marginOnly(bottom: 8),
        ),
        StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: List.generate(_methodList.length, (index) {
            return PrimaryBtn(
              isOutline: true,
              borderWidth: 1.5,
              maxLines: 1,
              height: 70,
              textColor: Colors.white,
              fontWeight: FontWeight.w800,
              borderColor: StaticColors.blueColor,
              color: StaticColors.blueColor,
              onPressed: () {
                Get.back();
                if (_methodList[index] == "CASH_AND_CARD" &&
                    BaseController.to.hybridPaymen) {
                  PopupDialog.customDialog(
                    width:
                        (BaseController.to.posMonerisTerminal &&
                            BaseController.to.posElavonTerminal)
                        ? 550
                        : 400,
                    child: Column(
                      children: [
                        Text(
                          "Select Payment Processor",
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            //! for moneris
                            Visibility(
                              visible: BaseController.to.posMonerisTerminal,
                              child: Expanded(
                                child: PrimaryBtn(
                                  onPressed: () {
                                    Get.back();
                                    PopupDialog.customDialog(
                                      width: 600,
                                      child: MonerisCashAndCardDialog(
                                        minPay: widget.isSplitOrder
                                            ? SplitOrderController
                                                  .to
                                                  .listOfSpitChecksByItems[widget
                                                      .orderIndex]
                                                  .totalOrderAmount
                                            : SplitOrderController
                                                  .to
                                                  .splitAmountChecks
                                                  .splitAmounts[widget
                                                      .orderIndex]
                                                  .total,
                                        onPay: (paymentData) {
                                          // Handle pay action
                                          if (paymentData == null) {
                                            return;
                                          }
                                          Get.back();
                                          String terminalId =
                                              Preferences.terminalId;
                                          if (terminalId.isEmpty == true) {
                                            PopupDialog.showErrorMessage(
                                              "There is no terminal active",
                                            );
                                            return;
                                          }
                                          monerisSplitPurchaseDialog(
                                            index: widget.orderIndex,
                                            isSplitOrder: widget.isSplitOrder,
                                            isCashAndCard: true,
                                            orderId: widget.isSplitOrder
                                                ? SplitOrderController
                                                      .to
                                                      .listOfSpitChecksByItems[widget
                                                          .orderIndex]
                                                      .orderId
                                                : SplitOrderController
                                                      .to
                                                      .splitAmountChecks
                                                      .splitAmounts[widget
                                                          .orderIndex]
                                                      .orderId,
                                            terminalId: terminalId,
                                            cash: paymentData.cashPaidAmount,
                                            cashTip: paymentData.cashTipAmount,
                                            totalAmount:
                                                "${((paymentData.cardPaidAmount) * 100).toInt()}",
                                          );
                                        },
                                        onPayAndPrint: (paymentData) {
                                          if (paymentData == null) {
                                            return;
                                          }
                                          Get.back();
                                          String terminalId =
                                              Preferences.terminalId;
                                          if (terminalId.isEmpty == true) {
                                            PopupDialog.showErrorMessage(
                                              "There is no terminal active",
                                            );
                                            return;
                                          }
                                          monerisSplitPurchaseDialog(
                                            index: widget.orderIndex,
                                            isSplitOrder: widget.isSplitOrder,
                                            isCashAndCard: true,
                                            isOrderPrint: true,
                                            orderId: widget.isSplitOrder
                                                ? SplitOrderController
                                                      .to
                                                      .listOfSpitChecksByItems[widget
                                                          .orderIndex]
                                                      .orderId
                                                : SplitOrderController
                                                      .to
                                                      .splitAmountChecks
                                                      .splitAmounts[widget
                                                          .orderIndex]
                                                      .orderId,
                                            terminalId: terminalId,
                                            cash: paymentData.cashPaidAmount,
                                            cashTip: paymentData.cashTipAmount,
                                            totalAmount:
                                                "${((paymentData.cardPaidAmount) * 100).toInt()}",
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  text: 'Moneris'.toUpperCase(),
                                  height: 103,
                                  color: StaticColors.blueColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  textMaxSize: 20,
                                  textMinSize: 20,
                                  borderColor: Colors.transparent,
                                  isOutline: true,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: BaseController.to.posMonerisTerminal,
                              child: SizedBox(width: 16),
                            ),
                            //! for elavon
                            Visibility(
                              visible: BaseController.to.posElavonTerminal,
                              child: Expanded(
                                child: PrimaryBtn(
                                  onPressed: () {
                                    Get.back();
                                    PopupDialog.customDialog(
                                      width: 600,
                                      child: MonerisCashAndCardDialog(
                                        minPay: widget.isSplitOrder
                                            ? SplitOrderController
                                                  .to
                                                  .listOfSpitChecksByItems[widget
                                                      .orderIndex]
                                                  .totalOrderAmount
                                            : SplitOrderController
                                                  .to
                                                  .splitAmountChecks
                                                  .splitAmounts[widget
                                                      .orderIndex]
                                                  .total,
                                        onPay: (paymentData) {
                                          // Handle pay action
                                          if (paymentData == null) {
                                            return;
                                          }
                                          Get.back();

                                          elavonSplitPurchaseDialog(
                                            index: widget.orderIndex,
                                            isSplitOrder: widget.isSplitOrder,
                                            isCashAndCard: true,

                                            cash: paymentData.cashPaidAmount,
                                            cashTip: paymentData.cashTipAmount,
                                            amountCents: paymentData
                                                .cardPaidAmount
                                                .toCentsInt(),
                                            terminalIp: Preferences.terminalIp,
                                            terminalPort:
                                                Preferences.terminalPort,
                                          );
                                        },
                                        onPayAndPrint: (paymentData) {
                                          if (paymentData == null) {
                                            return;
                                          }
                                          Get.back();
                                          String terminalId =
                                              Preferences.terminalId;
                                          if (terminalId.isEmpty == true) {
                                            PopupDialog.showErrorMessage(
                                              "There is no terminal active",
                                            );
                                            return;
                                          }
                                          monerisSplitPurchaseDialog(
                                            index: widget.orderIndex,
                                            isSplitOrder: widget.isSplitOrder,
                                            isCashAndCard: true,
                                            isOrderPrint: true,
                                            orderId: widget.isSplitOrder
                                                ? SplitOrderController
                                                      .to
                                                      .listOfSpitChecksByItems[widget
                                                          .orderIndex]
                                                      .orderId
                                                : SplitOrderController
                                                      .to
                                                      .splitAmountChecks
                                                      .splitAmounts[widget
                                                          .orderIndex]
                                                      .orderId,
                                            terminalId: terminalId,
                                            cash: paymentData.cashPaidAmount,
                                            cashTip: paymentData.cashTipAmount,
                                            totalAmount:
                                                "${((paymentData.cardPaidAmount) * 100).toInt()}",
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  text: 'Elavon'.toUpperCase(),
                                  height: 103,
                                  color: StaticColors.blueColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  textMaxSize: 20,
                                  textMinSize: 20,
                                  borderColor: Colors.transparent,
                                  isOutline: true,
                                ),
                              ),
                            ),
                            Visibility(
                              // visible: BaseController.to.posElavonTerminal,
                              child: SizedBox(width: 16),
                            ),
                            //for standalone
                            Expanded(
                              child: PrimaryBtn(
                                onPressed: () {
                                  Get.back();
                                  PopupDialog.customDialog(
                                    width: 700,
                                    child: PaymentDialog(
                                      paymentMethod: _methodList[index],
                                      minPay: widget.isSplitOrder
                                          ? SplitOrderController
                                                .to
                                                .listOfSpitChecksByItems[widget
                                                    .orderIndex]
                                                .totalOrderAmount
                                          : SplitOrderController
                                                .to
                                                .splitAmountChecks
                                                .splitAmounts[widget.orderIndex]
                                                .total,
                                      onPay: (value) async {
                                        if (value != null) {
                                          if (widget.isSplitOrder) {
                                            SplitOrderController.to
                                                .splitOrderPayment(
                                                  widget.orderIndex,
                                                  value,
                                                );
                                          } else {
                                            SplitOrderController
                                                    .to
                                                    .splitAmountChecks
                                                    .splitAmounts[widget
                                                        .orderIndex]
                                                    .payment =
                                                value;
                                            SplitOrderController.to
                                                .paySplitAmount();
                                            Get.back();
                                          }

                                          if (value.methods.contains("CASH") ||
                                              value.methods.contains(
                                                "CASH_AND_CARD",
                                              )) {
                                            final counterPrinter =
                                                Preferences.counterPrinter;
                                            if (counterPrinter.isNotEmpty) {
                                              // todo:print or open drawed receipt
                                              await PrintUtils().directPrint(
                                                data: Receipt()
                                                    .openDrawer()
                                                    .bytes,
                                                printer:
                                                    Preferences.counterPrinter,
                                              );
                                            }
                                          }
                                        }
                                      },
                                      onPayAndPrint: (value) async {
                                        if (value != null) {
                                          // kLogger.e(
                                          //     value.toJson());
                                          if (widget.isSplitOrder) {
                                            await SplitOrderController.to
                                                .splitOrderPayment(
                                                  widget.orderIndex,
                                                  value,
                                                );
                                            // for printer
                                            await PrintUtils().directPrint(
                                              data: escOrderPrintReceipt(
                                                order:
                                                    SplitOrderController
                                                        .to
                                                        .listOfSpitChecksByItems[widget
                                                        .orderIndex],
                                              ),
                                              printer:
                                                  Preferences.counterPrinter,
                                            );
                                          } else {
                                            SplitOrderController
                                                    .to
                                                    .splitAmountChecks
                                                    .splitAmounts[widget
                                                        .orderIndex]
                                                    .payment =
                                                value;
                                            await SplitOrderController.to
                                                .paySplitAmount();
                                            Get.back();
                                            final printerName =
                                                Preferences.counterPrinter;
                                            if (printerName.isNotEmpty) {
                                              await PrintUtils().directPrint(
                                                data: escSplitAmountPrintReceipt(
                                                  isCustomerCopy: true,
                                                  order:
                                                      SplitOrderController
                                                          .to
                                                          .splitAmountChecks
                                                          .splitAmounts[widget
                                                          .orderIndex],
                                                ),
                                                printer: printerName,
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  );
                                },
                                text: 'standalone'.toUpperCase(),
                                height: 103,
                                color: StaticColors.blueColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                textMaxSize: 20,
                                textMinSize: 20,
                                borderColor: Colors.transparent,
                                isOutline: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  PopupDialog.customDialog(
                    width: 700,
                    child: PaymentDialog(
                      paymentMethod: _methodList[index],
                      minPay: widget.isSplitOrder
                          ? SplitOrderController
                                .to
                                .listOfSpitChecksByItems[widget.orderIndex]
                                .totalOrderAmount
                          : SplitOrderController
                                .to
                                .splitAmountChecks
                                .splitAmounts[widget.orderIndex]
                                .total,
                      onPay: (value) async {
                        if (value != null) {
                          if (widget.isSplitOrder) {
                            SplitOrderController.to.splitOrderPayment(
                              widget.orderIndex,
                              value,
                            );
                          } else {
                            SplitOrderController
                                    .to
                                    .splitAmountChecks
                                    .splitAmounts[widget.orderIndex]
                                    .payment =
                                value;
                            SplitOrderController.to.paySplitAmount();
                            Get.back();
                          }

                          // Get.back();
                          if (value.methods.contains("CASH") ||
                              value.methods.contains("CASH_AND_CARD")) {
                            final counterPrinter = Preferences.counterPrinter;
                            if (counterPrinter.isNotEmpty) {
                              // todo:print or open drawed receipt
                              await PrintUtils().directPrint(
                                data: Receipt().openDrawer().bytes,
                                printer: Preferences.counterPrinter,
                              );
                            }
                          }
                        }
                      },
                      onPayAndPrint: (value) async {
                        if (value != null) {
                          // kLogger.e(
                          //     value.toJson());
                          if (widget.isSplitOrder) {
                            await SplitOrderController.to.splitOrderPayment(
                              widget.orderIndex,
                              value,
                            );
                            // for printer
                            await PrintUtils().directPrint(
                              data: escOrderPrintReceipt(
                                order: SplitOrderController
                                    .to
                                    .listOfSpitChecksByItems[widget.orderIndex],
                              ),
                              printer: Preferences.counterPrinter,
                            );
                          } else {
                            SplitOrderController
                                    .to
                                    .splitAmountChecks
                                    .splitAmounts[widget.orderIndex]
                                    .payment =
                                value;
                            await SplitOrderController.to.paySplitAmount();
                            Get.back();
                            final printerName = Preferences.counterPrinter;
                            if (printerName.isNotEmpty) {
                              await PrintUtils().directPrint(
                                data: escSplitAmountPrintReceipt(
                                  isCustomerCopy: true,
                                  order: SplitOrderController
                                      .to
                                      .splitAmountChecks
                                      .splitAmounts[widget.orderIndex],
                                ),
                                printer: printerName,
                              );
                            }
                          }
                        }
                      },
                    ),
                  );
                }
              },
              text: _methodList[index].replaceAll("_", " "),
            );
          }),
        ),
      ],
    );
  }
}
