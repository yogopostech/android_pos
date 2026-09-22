import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/data_candy_active_reload_controller.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/controllers/dine_in_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/repo/datacandy_payment_repo.dart';
import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/elavon-terminal/views/elavon_purchase_dialog.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/num_extensions.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/widgets/moneris_cash_and_card_dialog.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:yogo_pos/app/widgets/payment_dialog.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class OrderPaymentDialog extends StatelessWidget {
  const OrderPaymentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GetBuilder<DineInController>(
      builder: (context) {
        return Column(
          children: [
            Text('Select Payment', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 22),
            Visibility(
              visible: false,
              replacement: Column(
                children: [
                  Visibility(
                    visible:
                        BaseController.to.hybridPaymen &&
                        BaseController.to.posMonerisTerminal,
                    child: PrimaryBtn(
                      onPressed: () async {
                        if (PosController.to.terminals != null) {
                          String terminalId = Preferences.terminalId;

                          if (terminalId.isEmpty == true) {
                            PopupDialog.showErrorMessage(
                              "There is no terminal active",
                            );
                            return;
                          }
                          Get.back();
                          PosController.to.myOrder.payment = PaymentModel(
                            cardPaidAmount:
                                PosController.to.myOrder.totalOrderAmount,
                          );
                          PosController.to.calculateTotalPrice();
                          await PosController.to.onPlaseOrder(
                            isMonerisPay: true,
                            isPrint: false,
                            orderStatus: "COMPLETED",
                            paymentStatus: "PAID",
                            isDirectPay: false,
                          );
                        } else {
                          PopupDialog.showErrorMessage(
                            "There is no terminal active",
                          );
                        }
                      },
                      text: "Moneris Pay".toUpperCase(),
                      height: 103,
                      width: double.infinity,
                      color: StaticColors.blueColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textMaxSize: 20,
                      textMinSize: 20,
                      borderColor: Colors.transparent,
                      isOutline: true,
                    ).marginOnly(bottom: 8),
                  ),
                  Visibility(
                    visible:
                        BaseController.to.hybridPaymen &&
                        BaseController.to.posElavonTerminal,
                    child: PrimaryBtn(
                      onPressed: () async {
                        // close previous dialog
                        Get.back();
                        // showDialog(
                        //   context: Get.context!,
                        //   barrierDismissible: false,
                        //   builder: (_) => ElavonPurchaseDialog(
                        //     isPlaceOrder: true,
                        //     amountCents: PosController
                        //         .to
                        //         .myOrder
                        //         .totalOrderAmount
                        //         .toCentsInt(),

                        //     host: Preferences.terminalIp,
                        //     port: Preferences.terminalPort,
                        //   ),
                        // );
                        elavonPurchaseDialog(
                          isPlaceOrder: true,
                          amountCents: PosController.to.myOrder.totalOrderAmount
                              .toCentsInt(),

                          terminalIp: Preferences.terminalIp,
                          terminalPort: Preferences.terminalPort,
                        );
                      },
                      text: "Elavon Pay".toUpperCase(),
                      height: 103,
                      width: double.infinity,
                      color: StaticColors.blueColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textMaxSize: 20,
                      textMinSize: 20,
                      borderColor: Colors.transparent,
                      isOutline: true,
                    ).marginOnly(bottom: 8),
                  ),
                  StaggeredGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: List.generate(context.paymentMathod.length - 2, (
                      index,
                    ) {
                      var data = context.paymentMathod[index];

                      return PrimaryBtn(
                        height: 103,
                        color: StaticColors.blueColor,
                        onPressed: () {
                          Get.back();
                          kLogger.e(data);
                          if (data == "CASH_AND_CARD" &&
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
                                      // ! Moneris
                                      Visibility(
                                        visible: BaseController
                                            .to
                                            .posMonerisTerminal,
                                        child: Expanded(
                                          child: PrimaryBtn(
                                            onPressed: () {
                                              Get.back();
                                              PopupDialog.customDialog(
                                                width: 600,
                                                child: MonerisCashAndCardDialog(
                                                  minPay: PosController
                                                      .to
                                                      .myOrder
                                                      .totalOrderAmount,
                                                  onPay: (paymentData) async {
                                                    // Handle pay action
                                                    if (paymentData == null) {
                                                      return;
                                                    }
                                                    Get.back();
                                                    String terminalId =
                                                        Preferences.terminalId;
                                                    if (terminalId.isEmpty ==
                                                        true) {
                                                      PopupDialog.showErrorMessage(
                                                        "There is no terminal active",
                                                      );
                                                      return;
                                                    }
                                                    PosController
                                                            .to
                                                            .myOrder
                                                            .payment =
                                                        paymentData;
                                                    PosController.to
                                                        .calculateTotalPrice();

                                                    await PosController.to
                                                        .onPlaseOrder(
                                                          isMonerisPay: true,
                                                          isPrint: false,
                                                          orderStatus:
                                                              "COMPLETED",
                                                          paymentStatus: "PAID",
                                                          isDirectPay: false,
                                                        );
                                                  },
                                                  onPayAndPrint: (paymentData) async {
                                                    if (paymentData == null) {
                                                      return;
                                                    }
                                                    Get.back();
                                                    String terminalId =
                                                        Preferences.terminalId;
                                                    if (terminalId.isEmpty ==
                                                        true) {
                                                      PopupDialog.showErrorMessage(
                                                        "There is no terminal active",
                                                      );
                                                      return;
                                                    }
                                                    PosController
                                                            .to
                                                            .myOrder
                                                            .payment =
                                                        paymentData;
                                                    PosController.to
                                                        .calculateTotalPrice();

                                                    await PosController.to
                                                        .onPlaseOrder(
                                                          isMonerisPay: true,
                                                          isPrint: false,
                                                          orderStatus:
                                                              "COMPLETED",
                                                          paymentStatus: "PAID",
                                                          isDirectPay: false,
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
                                        visible: BaseController
                                            .to
                                            .posMonerisTerminal,
                                        child: SizedBox(width: 16),
                                      ),
                                      // ! Elavon
                                      Visibility(
                                        visible:
                                            BaseController.to.posElavonTerminal,
                                        child: Expanded(
                                          child: PrimaryBtn(
                                            onPressed: () {
                                              Get.back();
                                              PopupDialog.customDialog(
                                                width: 600,
                                                child: MonerisCashAndCardDialog(
                                                  minPay: PosController
                                                      .to
                                                      .myOrder
                                                      .totalOrderAmount,
                                                  onPay: (paymentData) async {
                                                    // Handle pay action
                                                    if (paymentData == null) {
                                                      return;
                                                    }
                                                    Get.back();
                                                    elavonPurchaseDialog(
                                                      amountCents: paymentData
                                                          .cardPaidAmount
                                                          .toCentsInt(),
                                                      isCashAndCard: true,
                                                      isPlaceOrder: true,

                                                      cash: paymentData
                                                          .cashPaidAmount,
                                                      cashTip: paymentData
                                                          .cashTipAmount,
                                                      terminalIp: Preferences
                                                          .terminalIp,
                                                      terminalPort: Preferences
                                                          .terminalPort,
                                                    );
                                                  },
                                                  onPayAndPrint:
                                                      (paymentData) async {
                                                        if (paymentData ==
                                                            null) {
                                                          return;
                                                        }
                                                        Get.back();
                                                        elavonPurchaseDialog(
                                                          amountCents:
                                                              paymentData
                                                                  .cardPaidAmount
                                                                  .toCentsInt(),
                                                          isCashAndCard: true,
                                                          isPlaceOrder: true,

                                                          cash: paymentData
                                                              .cashPaidAmount,
                                                          cashTip: paymentData
                                                              .cashTipAmount,
                                                          terminalIp:
                                                              Preferences
                                                                  .terminalIp,
                                                          terminalPort:
                                                              Preferences
                                                                  .terminalPort,
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
                                        visible:
                                            BaseController.to.posElavonTerminal,
                                        child: SizedBox(width: 16),
                                      ),
                                      // ! standalone
                                      Expanded(
                                        child: PrimaryBtn(
                                          onPressed: () {
                                            Get.back();
                                            PopupDialog.customDialog(
                                              width: 600,
                                              child: PaymentDialog(
                                                paymentMethod: data,
                                                minPay: PosController
                                                    .to
                                                    .myOrder
                                                    .totalOrderAmount,
                                                onPay: (value) async {
                                                  if (value == null) {
                                                    return;
                                                  }
                                                  PosController
                                                          .to
                                                          .myOrder
                                                          .payment =
                                                      value;
                                                  PosController.to
                                                      .calculateTotalPrice();
                                                  PopupDialog.showLoadingDialog();
                                                  await PosController.to
                                                      .onPlaseOrder(
                                                        isPrint: false,
                                                        orderStatus:
                                                            "COMPLETED",
                                                        paymentStatus: "PAID",
                                                        isDirectPay: false,
                                                      );
                                                  PopupDialog.closeLoadingDialog();
                                                  Get.back();
                                                },
                                                onPayAndPrint: (value) async {
                                                  if (value == null) {
                                                    return;
                                                  }
                                                  PosController
                                                          .to
                                                          .myOrder
                                                          .payment =
                                                      value;
                                                  PosController.to
                                                      .calculateTotalPrice();
                                                  PopupDialog.showLoadingDialog();
                                                  await PosController.to
                                                      .onPlaseOrder(
                                                        orderStatus:
                                                            "COMPLETED",
                                                        paymentStatus: "PAID",
                                                        isPrint: true,
                                                        isDirectPay: true,
                                                      );
                                                  PopupDialog.closeLoadingDialog();
                                                  Get.back();
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
                            Get.back();
                            PopupDialog.customDialog(
                              width: 600,
                              child: PaymentDialog(
                                paymentMethod: data,
                                minPay:
                                    PosController.to.myOrder.totalOrderAmount,
                                onPay: (value) async {
                                  if (value == null) {
                                    return;
                                  }
                                  PosController.to.myOrder.payment = value;
                                  PosController.to.calculateTotalPrice();
                                  PopupDialog.showLoadingDialog();
                                  await PosController.to.onPlaseOrder(
                                    isPrint: false,
                                    orderStatus: "COMPLETED",
                                    paymentStatus: "PAID",
                                    isDirectPay: false,
                                  );
                                  PopupDialog.closeLoadingDialog();
                                  Get.back();
                                },
                                onPayAndPrint: (value) async {
                                  if (value == null) {
                                    return;
                                  }
                                  PosController.to.myOrder.payment = value;
                                  PosController.to.calculateTotalPrice();
                                  PopupDialog.showLoadingDialog();
                                  await PosController.to.onPlaseOrder(
                                    orderStatus: "COMPLETED",
                                    paymentStatus: "PAID",
                                    isDirectPay: true,
                                  );
                                  PopupDialog.closeLoadingDialog();
                                  Get.back();
                                },
                              ),
                            );
                          }
                        },
                        text: data.replaceAll('_', ' ').replaceAll('AND', '&'),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textMaxSize: 20,
                        textMinSize: 20,
                        borderColor: Colors.transparent,
                        isOutline: true,
                      );
                    }),
                  ),
                ],
              ),
              child: StaggeredGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: List.generate(context.paymentMathod.length, (index) {
                  var data = context.paymentMathod[index];
                  return PrimaryBtn(
                    color: StaticColors.blueColor,
                    textColor: Colors.white,
                    width: double.infinity,
                    height: 80,
                    onPressed: () {
                      Get.back();
                      if (data.isNotEmpty) {
                        PopupDialog.customDialog(
                          width: 600,
                          child: PaymentDialog(
                            paymentMethod: data,
                            minPay: PosController.to.myOrder.totalOrderAmount,
                            onPay: (value) async {
                              if (value == null) {
                                return;
                              }
                              PosController.to.myOrder.payment = value;
                              PosController.to.calculateTotalPrice();
                              PopupDialog.showLoadingDialog();
                              await PosController.to.onPlaseOrder(
                                isPrint: false,
                                orderStatus: "COMPLETED",
                                paymentStatus: "PAID",
                                isDirectPay: false,
                              );
                              PopupDialog.closeLoadingDialog();
                              Get.back();
                            },
                            onPayAndPrint: (value) async {
                              if (value == null) {
                                return;
                              }
                              PosController.to.myOrder.payment = value;
                              PosController.to.calculateTotalPrice();
                              PopupDialog.showLoadingDialog();
                              await PosController.to.onPlaseOrder(
                                orderStatus: "COMPLETED",
                                paymentStatus: "PAID",
                                isDirectPay: true,
                              );
                              PopupDialog.closeLoadingDialog();
                              Get.back();
                            },
                          ),
                        );
                      } else {
                        PopupDialog.showErrorMessage(
                          "Please select a payment method",
                        );
                      }
                    },
                    text: data.replaceAll("_", " ").replaceAll('AND', '&'),
                    textMaxSize: 20,
                    textMinSize: 20,
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DataCandyPaymentDialog
    extends GetView<DataCandyActiveAndReloadController> {
  final bool isReload;
  const DataCandyPaymentDialog({super.key, required this.isReload});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GetBuilder<DineInController>(
      builder: (context) {
        return Column(
          children: [
            Text('Select Payment', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 22),
            GetBuilder<DataCandyActiveAndReloadController>(
              builder: (controller) {
                return StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: List.generate(controller.cardList.length, (index) {
                    var data = context.paymentMathod[index];
                    return PrimaryBtn(
                      isOutline: true,
                      borderColor: data == controller.selectedCardType
                          ? StaticColors.orangeColor
                          : StaticColors.blueColor,
                      borderWidth: 2,
                      color: StaticColors.blueColor,
                      textColor: Colors.white,
                      width: double.infinity,
                      height: 80,
                      onPressed: () {
                        controller.selectedCardType = data;
                        // print(controller.selectedCardType);
                        controller.update();
                      },
                      text: data.replaceAll("_", " ").replaceAll('AND', '&'),
                      textMaxSize: 20,
                      textMinSize: 20,
                    );
                  }),
                );
              },
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Print Check
                PrimaryBtnWithChild(
                  onPressed: () async {
                    if (controller.selectedCardType != null) {
                      PaymentModel payment = PaymentModel(
                        cardPaidAmount: controller.selectedCardType == "CASH"
                            ? 0.00
                            : (num.tryParse(
                                    controller.amountController.text.trim(),
                                  ) ??
                                  0.00),
                        cashPaidAmount: controller.selectedCardType != "CASH"
                            ? 0.00
                            : (num.tryParse(
                                    controller.amountController.text.trim(),
                                  ) ??
                                  0.00),
                        methods: [controller.selectedCardType ?? ""],
                      );
                      if (isReload) {
                        bool isReload = await controller.reloadCard(
                          payment: payment,
                          isPrint: true,
                        );
                        if (isReload) {
                          DineInOrderController.to.getAllOrders();
                          DineInOrderController.to.getOrderStatus();
                        }
                      } else {
                        bool isReload = await controller.activeCard(
                          payment: payment,
                          isPrint: true,
                        );
                        if (!isReload) {
                          DineInOrderController.to.getAllOrders();
                          DineInOrderController.to.getOrderStatus();
                        }
                      }
                    } else {
                      showAnimatedErrorDialog(
                        Get.context!,
                        title: "Select Payment Type",
                      );
                      // PopupDialog.showErrorMessage("Select Payment Type");
                    }
                    // controller.cardController.clear();
                    // controller.amountController.clear();
                  },
                  height: 70,
                  width: 200,
                  color: StaticColors.blueColor,
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.print,
                        color: Colors.white,
                        size: 25,
                      ).marginOnly(right: 12),
                      const FittedBox(
                        child: MyCustomText(
                          'Print Check',
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ).marginOnly(right: 50),
                // No Print
                PrimaryBtnWithChild(
                  onPressed: () async {
                    if (controller.selectedCardType != null) {
                      PaymentModel payment = PaymentModel(
                        cardPaidAmount: controller.selectedCardType == "CASH"
                            ? 0.00
                            : (num.tryParse(
                                    controller.amountController.text.trim(),
                                  ) ??
                                  0.00),
                        cashPaidAmount: controller.selectedCardType != "CASH"
                            ? 0.00
                            : (num.tryParse(
                                    controller.amountController.text.trim(),
                                  ) ??
                                  0.00),
                        methods: [controller.selectedCardType ?? ""],
                      );
                      if (isReload) {
                        bool isReload = await controller.reloadCard(
                          payment: payment,
                          isPrint: false,
                        );
                        if (isReload) {
                          DineInOrderController.to.getAllOrders();
                          DineInOrderController.to.getOrderStatus();
                        }
                      } else {
                        bool isReload = await controller.activeCard(
                          payment: payment,
                          isPrint: false,
                        );
                        if (!isReload) {
                          DineInOrderController.to.getAllOrders();
                          DineInOrderController.to.getOrderStatus();
                        }
                      }
                    } else {
                      showAnimatedErrorDialog(
                        Get.context!,
                        title: "Error 404",
                        message: "Select Payment Type",
                      );
                      // PopupDialog.showErrorMessage("Select Payment Type");
                    }
                    // controller.cardController.clear();
                    // controller.amountController.clear();
                  },
                  height: 70,
                  width: 200,
                  textColor: Colors.white,
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.do_disturb_alt,
                        size: 25,
                        color: Colors.white,
                      ).marginOnly(right: 12),
                      const FittedBox(
                        child: MyCustomText(
                          color: Colors.white,
                          'No Print',
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
