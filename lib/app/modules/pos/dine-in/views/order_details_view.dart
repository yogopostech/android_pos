import 'dart:ui';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/delivery/controllers/delivery_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/controllers/dine_in_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_order_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/kitchen_print.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/repo/datacandy_payment_repo.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/views/split_order_view.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/widgets/dialogs/discount_dialog.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/widgets/dialogs/edit_notes.dart';
import 'package:yogo_pos/app/modules/pos/onlineOrder/controllers/online_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/onlineOrder/widgets/online_order_details.dart';

import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/modules/setting/controllers/payments_controller.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/elavon-terminal/views/elavon_purchase_dialog.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/moneris/dialogs/moneris_purchase_dialog.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/num_extensions.dart';
import 'package:yogo_pos/app/utils/extension/order_extention.dart';
import 'package:yogo_pos/app/utils/extension/string_manipulation_extension.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/cash_and_gift_card_dialog.dart';
import 'package:yogo_pos/app/widgets/change_takeout_to_delivery.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/edit_delivery_fee.dart';
import 'package:yogo_pos/app/widgets/edit_gratuity.dart';
import 'package:yogo_pos/app/widgets/moneris_cash_and_card_dialog.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:yogo_pos/app/widgets/payment_dialog.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/widgets/title_bar.dart';
import '../widgets/custom_table_item.dart';

class OrderDetailsView extends GetView<DineInController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    PosController.to.orderDetailItemsScrollToBottom();
    PosController.to.selectedItemList.clear();

    const double btnSize = 140;
    const double height = 90;

    const double textMaxSize = 25;
    const double textMinSize = 20;
    return Scaffold(
      body: Column(
        children: [
          const TitleBar(),
          Expanded(
            child: GetBuilder<PosController>(
              builder: (controller) {
                var data = controller.myOrder;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        // height: 120,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind
                                  .mouse, // mouse drag scroll enable
                              PointerDeviceKind.trackpad,
                            },
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                PrimaryBtnWithChild(
                                  width: height,
                                  height: height,
                                  onPressed: () {
                                    PosController.to.onchangePage(0);
                                    PosController.to.isUpdateView = false;

                                    kLogger.e(
                                      "Order Type: ${controller.myOrder.orderType}",
                                    );
                                    // PosController.to.setOrderTypeIndex(
                                    //     PosController.to.orderTypeList.first);
                                    PosController.to
                                        .setTakeOutTypeIndexAndValue(
                                          PosController
                                              .to
                                              .takeOutTypeList
                                              .first,
                                        );
                                    PosController.to
                                        .onEditableAllCartTextField();
                                    PosController.to.clearCartList();
                                    if (controller.orderType == "DINE_IN") {
                                      controller.onRemovePackagingCost();
                                    } else {
                                      controller.onAddPackagingCost();
                                    }
                                    Get.back();
                                  },
                                  color: StaticColors.greenColor,
                                  textColor: Colors.white,
                                  child: const Icon(
                                    Icons.home,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                  // text: 'pos'.toUpperCase(),
                                  // textMaxSize: txtMaxSize,
                                  // textMinSize: txtMinSize,
                                ).marginOnly(right: 16),

                                Visibility(
                                  visible:
                                      BaseController
                                          .to
                                          .restaurantDetails
                                          ?.restaurant
                                          .takeout ??
                                      false,
                                  child: PrimaryBtn(
                                    width: btnSize,
                                    height: height,
                                    onPressed: () {
                                      PosController.to.onchangePage(3);
                                      PosController.to.isUpdateView = false;
                                      // PosController.to.setOrderTypeIndex(
                                      //     PosController.to.orderTypeList.first);
                                      PosController.to
                                          .setTakeOutTypeIndexAndValue(
                                            PosController
                                                .to
                                                .takeOutTypeList
                                                .first,
                                          );
                                      PosController.to
                                          .onEditableAllCartTextField();
                                      PosController.to.clearCartList();
                                      Get.back();
                                    },
                                    color: StaticColors.greenColor,
                                    textColor: Colors.white,
                                    text: 'TakeOut'.toUpperCase(),
                                    textMaxSize: textMaxSize,
                                    textMinSize: textMinSize,
                                  ).marginOnly(right: 10),
                                ),
                                Visibility(
                                  visible:
                                      BaseController
                                          .to
                                          .restaurantDetails
                                          ?.restaurant
                                          .dineIn ??
                                      false,
                                  child: PrimaryBtn(
                                    width: btnSize,
                                    height: height,
                                    onPressed: () {
                                      PosController.to.onchangePage(2);
                                      PosController.to.isUpdateView = false;
                                      // PosController.to.setOrderTypeIndex(
                                      //     PosController.to.orderTypeList.first);
                                      PosController.to
                                          .setTakeOutTypeIndexAndValue(
                                            PosController
                                                .to
                                                .takeOutTypeList
                                                .first,
                                          );
                                      PosController.to
                                          .onEditableAllCartTextField();
                                      PosController.to.clearCartList();
                                      Get.back();
                                    },
                                    color: StaticColors.greenColor,
                                    textColor: Colors.white,
                                    text: 'Dine-in'.toUpperCase(),
                                    textMaxSize: textMaxSize,
                                    textMinSize: textMinSize,
                                  ).marginOnly(right: 12),
                                ),
                                Visibility(
                                  visible:
                                      BaseController
                                          .to
                                          .restaurantDetails
                                          ?.restaurant
                                          .pickup ??
                                      false,
                                  child: GetBuilder<OnlineOrderController>(
                                    builder: (c) {
                                      return Badge(
                                        isLabelVisible: c.unseenOrders == 0
                                            ? false
                                            : true,
                                        label: Text(c.unseenOrders.toString()),
                                        child: PrimaryBtn(
                                          width: btnSize,
                                          height: height,
                                          onPressed: () {
                                            PosController.to.onchangePage(4);
                                            PosController.to.isUpdateView =
                                                false;
                                            // PosController.to.setOrderTypeIndex(
                                            //     PosController.to.orderTypeList.first);
                                            PosController.to
                                                .setTakeOutTypeIndexAndValue(
                                                  PosController
                                                      .to
                                                      .takeOutTypeList
                                                      .first,
                                                );
                                            PosController.to
                                                .onEditableAllCartTextField();
                                            PosController.to.clearCartList();
                                            Get.back();
                                          },
                                          color: StaticColors.greenColor,
                                          textColor: Colors.white,
                                          text: 'OLO'.toUpperCase(),
                                          textMaxSize: textMaxSize,
                                          textMinSize: textMinSize,
                                        ).marginOnly(right: 10),
                                      );
                                    },
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      BaseController
                                          .to
                                          .restaurantDetails
                                          ?.restaurant
                                          .posDelivery ??
                                      false,
                                  child: GetBuilder<DeliveryController>(
                                    builder: (c) {
                                      return Badge(
                                        isLabelVisible: c.unseenOrders == 0
                                            ? false
                                            : true,
                                        label: Text(c.unseenOrders.toString()),
                                        child: PrimaryBtn(
                                          width: btnSize,
                                          height: height,
                                          onPressed: () {
                                            PosController.to.onchangePage(5);
                                            PosController.to.isUpdateView =
                                                false;
                                            // PosController.to.setOrderTypeIndex(
                                            //     PosController.to.orderTypeList.first);
                                            PosController.to
                                                .setTakeOutTypeIndexAndValue(
                                                  PosController
                                                      .to
                                                      .takeOutTypeList
                                                      .first,
                                                );
                                            PosController.to
                                                .onEditableAllCartTextField();
                                            PosController.to.clearCartList();
                                            Get.back();
                                          },
                                          color: StaticColors.greenColor,
                                          textColor: Colors.white,
                                          text: 'DELIVERY'.toUpperCase(),
                                          textMaxSize: textMaxSize,
                                          textMinSize: textMinSize,
                                        ).marginOnly(right: 10),
                                      );
                                    },
                                  ),
                                ),

                                // const SizedBox(width: 8),
                                PrimaryBtn(
                                  width: btnSize,
                                  height: height,
                                  onPressed: () {
                                    PosController.to.onchangePage(1);
                                    PosController.to.isUpdateView = false;
                                    // PosController.to.setOrderTypeIndex(
                                    //     PosController.to.orderTypeList.first);
                                    PosController.to
                                        .setTakeOutTypeIndexAndValue(
                                          PosController
                                              .to
                                              .takeOutTypeList
                                              .first,
                                        );
                                    PosController.to
                                        .onEditableAllCartTextField();
                                    PosController.to.clearCartList();
                                    Get.back();
                                  },
                                  color: StaticColors.greenColor,
                                  textColor: Colors.white,
                                  text: 'Checks'.toUpperCase(),
                                  textMaxSize: textMaxSize,
                                  textMinSize: textMinSize,
                                ).marginOnly(right: 40),

                                GetBuilder<PosController>(
                                  builder: (context) {
                                    return Tooltip(
                                      message: context.selectedItemList.isEmpty
                                          ? 'Select item first'
                                          : '',
                                      child: PrimaryBtn(
                                        width: btnSize,
                                        height: height,
                                        onPressed: () async {
                                          if (context
                                              .selectedItemList
                                              .isNotEmpty) {
                                            var myOrder = context.myOrder
                                                .filterCartsByIds(
                                                  context.selectedItemList,
                                                );
                                            kitchenPrint(
                                              myOrder,
                                              showSuccessMSG: true,
                                            );
                                          }
                                        },
                                        textColor: Colors.white,
                                        color: context.selectedItemList.isEmpty
                                            ? StaticColors.blueColor
                                            : StaticColors.blueColor,
                                        textMaxSize: textMaxSize,
                                        textMinSize: textMinSize,
                                        // width: double.infinity,
                                        text: "Print\nKitchen".toUpperCase(),
                                      ),
                                    );
                                  },
                                ).marginOnly(right: 10),

                                GetBuilder<PosController>(
                                  builder: (context) {
                                    return PrimaryBtn(
                                      width: btnSize,
                                      height: height,
                                      onPressed: () async {
                                        bool isPrint = await PrintUtils()
                                            .directPrint(
                                              data: escOrderPrintReceipt(
                                                order: PosController.to.myOrder,
                                              ),
                                              printer:
                                                  Preferences.counterPrinter,
                                            );
                                        if (isPrint) {
                                          PopupDialog.showSuccessDialog(
                                            "Print Sent",
                                          );
                                        }
                                      },
                                      // maxLines: 3,
                                      textColor: Colors.white,
                                      color: StaticColors.blueColor,
                                      textMaxSize: textMaxSize,
                                      textMinSize: textMinSize,
                                      text: "Print\nCheck".toUpperCase(),
                                    );
                                  },
                                ).marginOnly(right: 40),
                                Visibility(
                                  visible:
                                      PosController
                                          .to
                                          .myOrder
                                          .carts
                                          .isNotEmpty &&
                                      (PosController.to.myOrder.paymentStatus !=
                                              "PAID" ||
                                          PosController
                                              .to
                                              .myOrder
                                              .splitAmounts
                                              .isNotEmpty ||
                                          PosController
                                              .to
                                              .myOrder
                                              .splitOrders
                                              .isNotEmpty),
                                  // visible: MyFunc.canGoSplitPage(
                                  //     PosController.to.myOrder),
                                  child: PrimaryBtn(
                                    onPressed: () {
                                      Get.to(() => const SplitOrderView());
                                    },
                                    width: btnSize,
                                    height: height,
                                    textMaxSize: textMaxSize,
                                    textMinSize: textMinSize,
                                    text: 'Split Check'.toUpperCase(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 10,
                                    ),
                                    textColor: Colors.white,
                                    color: StaticColors.blueColor,
                                    isdisabled:
                                        PosController.to.myOrder.orderStatus ==
                                            "CANCELED"
                                        ? true
                                        : false,
                                  ).marginOnly(right: 10),
                                ),
                                GetBuilder<PosController>(
                                  builder: (context) {
                                    return Visibility(
                                      visible:
                                          PosController
                                              .to
                                              .myOrder
                                              .orderStatus ==
                                          "CONFIRMED",
                                      child: Tooltip(
                                        message:
                                            context.selectedItemList.isEmpty
                                            ? 'Select item first'
                                            : '',
                                        child: PrimaryBtn(
                                          width: btnSize,
                                          height: height,
                                          isdisabled:
                                              PosController
                                                      .to
                                                      .myOrder
                                                      .orderStatus ==
                                                  "CANCELED"
                                              ? true
                                              : false,
                                          textMaxSize: textMaxSize,
                                          textMinSize: textMinSize,
                                          onPressed: () {
                                            if (context
                                                .selectedItemList
                                                .isEmpty) {
                                              PopupDialog.showErrorMessage(
                                                "Select an Item to apply Discount",
                                              );
                                              return;
                                            }
                                            PopupDialog.customDialog(
                                              width: 700,
                                              hasScroll: true,
                                              child: const DiscountDialog(),
                                            );
                                          },
                                          // width: double.infinity,
                                          text: 'Discount'.toUpperCase(),
                                          textColor: Colors.white,
                                          color: StaticColors.blueColor,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // title area
                      GetBuilder<PosController>(
                        builder: (c) {
                          return _titleRow(theme, c.myOrder, context);
                        },
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // for order details
                            Expanded(child: _itemDetails(theme, data)),
                            // order setup
                            SizedBox(
                              width: 400,
                              child: _orderSetup(theme, data),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // title row widgets
  Widget _titleRow(ThemeData theme, OrderModel data, BuildContext context) {
    return SizedBox(
      height: 45,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse, // mouse drag scroll enable
            PointerDeviceKind.trackpad,
          },
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Visibility(
                visible: data.guestName.isNotEmpty,
                child: Text(
                  "Guest: ${data.guestName.toUpperCase()}",
                  // 'Order: #${data.orderId}',
                  style: theme.textTheme.titleMedium,
                ).marginOnly(right: 16),
              ),
              Visibility(
                visible: data.guestPhoneNumber.isNotEmpty,
                child: Text(
                  "Number: ${data.guestPhoneNumber}",
                  // 'Order: #${data.orderId}',
                  style: theme.textTheme.titleMedium,
                ).marginOnly(right: 16),
              ),
              Text(
                "Check: #${data.orderId}${(data.splitAmounts.isNotEmpty || data.splitOrders.isNotEmpty) ? "-SC" : ""}",
                // 'Order: #${data.orderId}',
                style: theme.textTheme.titleMedium,
              ).marginOnly(right: 16),
              Text(
                "Token: ${data.tokenId}",
                // 'Order: #${data.orderId}',
                style: theme.textTheme.titleMedium,
              ).marginOnly(right: 16),
              Text(
                'Items: ${data.carts.length}',
                style: theme.textTheme.titleMedium,
              ).marginOnly(right: 16),
              GetBuilder<PosController>(
                builder: (context) {
                  return Visibility(
                    visible: context.myOrder.orderType == "DINE_IN",
                    child: Text(
                      'Table: ${data.tableName}',
                      style: theme.textTheme.titleMedium,
                    ).marginOnly(right: 16),
                  );
                },
              ),
              GetBuilder<PosController>(
                builder: (context) {
                  return Visibility(
                    visible: context.myOrder.orderType == "DINE_IN",
                    child: Text(
                      'Guests: ${data.numberOfPeople}',
                      style: theme.textTheme.titleMedium,
                    ).marginOnly(right: 16),
                  );
                },
              ),
              InkWell(
                onTap:
                    data.orderStatus == "COMPLETED" ||
                        data.orderStatus == "CANCELED"
                    ? null
                    : () {
                        PopupDialog.customDialog(
                          width: 500,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Change Server',
                                style: theme.textTheme.displaySmall,
                              ),
                              const SizedBox(height: 22),
                              Text(
                                'Select Server',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              GetBuilder<DineInOrderController>(
                                builder: (context) {
                                  return CustomSearchTextField(
                                    dropDownItemCount:
                                        context.orderStatusList.length,
                                    hintText: data.employee?.firstName,
                                    dropDownList: List.generate(
                                      PosController.to.employeeList.length,
                                      (index) {
                                        var data = PosController
                                            .to
                                            .employeeList[index];
                                        return DropDownValueModel(
                                          name: data.firstName,
                                          value: data.id,
                                        );
                                      },
                                    ),
                                    onChanged: (value) async {
                                      PopupDialog.showLoadingDialog();
                                      bool isLoaded = await PosController.to
                                          .onUpdateOrderItems(
                                            PosController.to.myOrder.id,
                                            employeeId: "${value.value}",
                                          );
                                      PopupDialog.closeLoadingDialog();
                                      if (isLoaded) {
                                        Get.back();
                                        DataUpdateHelper.getDataByCheckType();
                                      }
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 35),
                            ],
                          ),
                        );
                      },
                child: Row(
                  children: [
                    Text(
                      'Server: ${MyFunc.capitalizeEachWord(s: data.employee?.firstName)}',
                      style: theme.textTheme.titleMedium,
                    ),
                    Visibility(
                      visible: data.paymentStatus == "UNPAID",
                      child: const Icon(
                        Icons.edit_square,
                        color: StaticColors.orangeColor,
                      ),
                    ),
                  ],
                ).marginOnly(right: 16),
              ),
              Text(
                'Order Type: ${data.orderType}'.replaceAll("_", " "),
                style: theme.textTheme.titleMedium,
              ).marginOnly(right: 16),
              Visibility(
                visible: data.orderType == 'TAKEOUT',
                child: Text(
                  'Takeout Type: ${data.takeOutType}'.replaceAll("_", " "),
                  style: theme.textTheme.titleMedium,
                ).marginOnly(right: 16),
              ),
              Visibility(
                visible: data.orderType == 'TAKEOUT',
                child: InkWell(
                  onTap:
                      data.orderStatus == "COMPLETED" ||
                          data.orderStatus == "CANCELED"
                      ? null
                      : () {
                          PopupDialog.customDialog(
                            width: 700,
                            child: EditNotes(
                              order: data,
                              onPressed: (notes) async {
                                PopupDialog.showLoadingDialog();
                                var isUpdated = await PosController.to
                                    .onUpdateOrderItems(data.id, notes: notes);
                                PopupDialog.closeLoadingDialog();
                                if (isUpdated) {
                                  Get.back();
                                  DataUpdateHelper.getDataByCheckType();
                                }
                              },
                            ),
                          );
                        },
                  child: const Row(
                    children: [
                      Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.visibility, color: StaticColors.blueColor),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible:
                    data.orderType == "TAKEOUT" && data.takeOutType == "ONLINE",
                child: PrimaryBtn(
                  onPressed: () {
                    OnlineOrderController.to.changeTabIndex(0);
                    PopupDialog.customDialog(
                      width: 550,
                      hasScroll: true,
                      child: OnlineOrderDetails(data),
                    );
                  },
                  text: "Details",
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  color: StaticColors.greenColor,
                  textColor: Colors.white,
                  // textMaxSize: 10,
                  // textMinSize: 10,
                  height: 30,
                ).marginOnly(left: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // order setup
  Widget _orderSetup(ThemeData theme, OrderModel data) {
    // OrderModel order = PosController.to.myOrder;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // cal 1
                Container(
                  margin: const EdgeInsets.only(left: 16),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Status',
                        style: theme.textTheme.headlineMedium,
                      ),
                      // const SizedBox(height: 16),
                      // Text(
                      //   'Change Order Status',
                      //   style: theme.textTheme.titleLarge,
                      // ),
                      const SizedBox(height: 12),
                      GetBuilder<DineInOrderController>(
                        builder: (context) {
                          return CustomSearchTextField(
                            dropDownItemCount: context.orderStatusList.length,
                            hintText: data.orderStatus,
                            dropDownList:
                                data.orderStatus == "COMPLETED" ||
                                    data.orderStatus == "CANCELED"
                                ? []
                                : [
                                    // const DropDownValueModel(
                                    //     name: "COMPLETED", value: "COMPLETED"),
                                    const DropDownValueModel(
                                      name: "CANCELLED",
                                      value: "CANCELED",
                                    ),
                                  ],
                            onChanged: (value) async {
                              PopupDialog.permissionDialogWithAccessPin(
                                title: "Change Order Status",
                                onSubmit: () async {
                                  // PopupDialog.showLoadingDialog();
                                  var isUpdated = await PosController.to
                                      .onUpdateOrderItems(
                                        data.id,
                                        orderStatus: "${value.value}"
                                            .toUpperCase(),
                                      );
                                  // PopupDialog.closeLoadingDialog();
                                  // print for CANCELED

                                  if (isUpdated) {
                                    // await Future.delayed(
                                    //     const Duration(seconds: 1));
                                    if (PosController.to.myOrder.orderStatus ==
                                        "CANCELED") {
                                      //new print for canceled order
                                      kitchenPrint(
                                        PosController.to.myOrder,
                                        isCheckCanceled: true,
                                        isShowItems: true,
                                        receipt: 1,
                                      );
                                    }

                                    DataUpdateHelper.getDataByCheckType();
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // payment Method
                Visibility(
                  visible: data.orderStatus == "CANCELED",
                  replacement: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 16, top: 16),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                    ),
                    child: Visibility(
                      visible: data.paymentStatus == "UNPAID",
                      replacement: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Visibility(
                          //     child: Text(
                          //   'Transaction Status : Voided',
                          //   style: theme.textTheme.titleLarge,
                          // )),
                          _row(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            theme,
                            title: "Pay. Mode: ",
                            value:
                                "${data.payment?.providerName.toUpperCase()}",
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Payment Method: ",
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.end,
                                  data.payment?.methods
                                          .join(', ')
                                          .replaceAll('_', ' ') ??
                                      "",
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (data.payment?.cardType != '')
                            _row(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              theme,
                              title: "Card: ",
                              value:
                                  "${data.payment?.cardType.replaceAll('_', ' ')}",
                            ),
                          // card number
                          Visibility(
                            visible:
                                data.payment?.maskedPan.isNotEmpty ?? false,
                            child: _row(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              theme,
                              title: "Card Number: ",
                              value: "${data.payment?.maskedPan}",
                            ),
                          ),
                          //entryMode
                          Visibility(
                            visible:
                                data.payment?.entryMode.isNotEmpty ?? false,
                            child: _row(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              theme,
                              title: "Payment Method: ",
                              value: "${data.payment?.entryMode}",
                            ),
                          ),
                          Visibility(
                            visible:
                                data.payment?.transactionId.isNotEmpty ?? false,
                            child: _row(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              theme,
                              title: "Approval Code:",
                              value: "${data.payment?.transactionId}",
                            ),
                          ),
                          if ((data.payment?.cardPaidAmount ?? 0) > 0)
                            _row(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              theme,
                              title: "Card Amount: ",
                              value:
                                  "\$${data.payment?.cardPaidAmount.toStringAsFixed(2)}",
                            ),
                          if ((data.payment?.cardTipAmount ?? 0) > 0)
                            _row(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              theme,
                              title: "Card Tip Amount: ",
                              value:
                                  "\$${data.payment?.cardTipAmount.toStringAsFixed(2)}",
                            ),
                          if ((data.payment?.cashPaidAmount ?? 0) > 0)
                            _row(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              theme,
                              title: "Cash Amount: ",
                              value:
                                  "\$${data.payment?.cashPaidAmount.toStringAsFixed(2)}",
                            ),
                          if ((data.payment?.cashTipAmount ?? 0) > 0)
                            _row(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              theme,
                              title: "Cash Tip Amount: ",
                              value:
                                  "\$${data.payment?.cashTipAmount.toStringAsFixed(2)}",
                            ),
                          if ((data.payment?.change ?? 0) > 0)
                            _row(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              theme,
                              title: "Cash Change: ",
                              value:
                                  "\$${data.payment?.change.toStringAsFixed(2)}",
                            ),
                          const SizedBox(height: 14),
                          _row(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            theme,
                            title: "Total ${MyFunc.orderCondition(data)}: ",
                            value:
                                '\$${data.totalOrderAmount.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                      child: Visibility(
                        visible:
                            data.splitAmounts.isEmpty &&
                            data.splitOrders.isEmpty &&
                            data.splitOrderCarts.isEmpty,
                        replacement: Text(
                          'Split Check in Progress...',
                          style: theme.textTheme.titleMedium,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Payment Method :',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            GetBuilder<PaymentsController>(
                              builder: (paymentsController) {
                                return Column(
                                  children: [
                                    Visibility(
                                      visible:
                                          BaseController.to.hybridPaymen &&
                                          BaseController.to.posMonerisTerminal,
                                      child: PrimaryBtn(
                                        onPressed: () {
                                          if (PosController.to.terminals !=
                                              null) {
                                            String terminalId =
                                                Preferences.terminalId;

                                            if (terminalId.isEmpty == true) {
                                              PopupDialog.showErrorMessage(
                                                "There is no terminal active",
                                              );
                                              return;
                                            }
                                            monerisPurchaseDialog(
                                              orderId: PosController
                                                  .to
                                                  .myOrder
                                                  .orderId,
                                              terminalId: terminalId,
                                              totalAmount: PosController
                                                  .to
                                                  .myOrder
                                                  .totalOrderAmount
                                                  .toCents(),
                                              // declineAttempt: PosController
                                              //     .to.myOrder.declineAttempt
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
                                      ).marginOnly(bottom: 12),
                                    ),

                                    Visibility(
                                      visible:
                                          BaseController.to.hybridPaymen &&
                                          BaseController.to.posElavonTerminal,
                                      child: PrimaryBtn(
                                        onPressed: () {
                                          elavonPurchaseDialog(
                                            amountCents: PosController
                                                .to
                                                .myOrder
                                                .totalOrderAmount
                                                .toCentsInt(),
                                            terminalIp: Preferences.terminalIp,
                                            terminalPort:
                                                Preferences.terminalPort,
                                          );
                                        },
                                        text: "Elavon Pay".toUpperCase(),
                                        height: 103,
                                        width: double.infinity,
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
                                      ).marginOnly(bottom: 12),
                                    ),
                                    StaggeredGrid.count(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      children: List.generate(controller.paymentMathod.length, (
                                        index,
                                      ) {
                                        var data =
                                            controller.paymentMathod[index];

                                        return PrimaryBtn(
                                          height: 103,
                                          color: StaticColors.blueColor,
                                          onPressed: () {
                                            kLogger.e(data);
                                            if (data == "CASH_AND_CARD" &&
                                                BaseController
                                                    .to
                                                    .hybridPaymen) {
                                              PopupDialog.customDialog(
                                                width:
                                                    (BaseController
                                                            .to
                                                            .posMonerisTerminal &&
                                                        BaseController
                                                            .to
                                                            .posElavonTerminal)
                                                    ? 550
                                                    : 400,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "Select Payment Processor",
                                                      style: theme
                                                          .textTheme
                                                          .headlineMedium,
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
                                                                    onPay:
                                                                        (
                                                                          paymentData,
                                                                        ) {
                                                                          // Handle pay action
                                                                          if (paymentData ==
                                                                              null) {
                                                                            return;
                                                                          }
                                                                          Get.back();
                                                                          String
                                                                          terminalId =
                                                                              Preferences.terminalId;
                                                                          if (terminalId.isEmpty ==
                                                                              true) {
                                                                            PopupDialog.showErrorMessage(
                                                                              "There is no terminal active",
                                                                            );
                                                                            return;
                                                                          }
                                                                          monerisPurchaseDialog(
                                                                            orderId:
                                                                                PosController.to.myOrder.orderId,
                                                                            terminalId:
                                                                                terminalId,
                                                                            totalAmount:
                                                                                paymentData.cardPaidAmount.toCents(),
                                                                            isCashAndCard:
                                                                                true,
                                                                            isKitchenPrint:
                                                                                false,
                                                                            cash:
                                                                                paymentData.cashPaidAmount,
                                                                            cashTip:
                                                                                paymentData.cashTipAmount,
                                                                            // declineAttempt: PosController
                                                                            //     .to
                                                                            //     .myOrder
                                                                            //     .declineAttempt
                                                                          );
                                                                        },
                                                                    onPayAndPrint:
                                                                        (
                                                                          paymentData,
                                                                        ) {
                                                                          if (paymentData ==
                                                                              null) {
                                                                            return;
                                                                          }
                                                                          Get.back();
                                                                          String
                                                                          terminalId =
                                                                              Preferences.terminalId;
                                                                          if (terminalId.isEmpty ==
                                                                              true) {
                                                                            PopupDialog.showErrorMessage(
                                                                              "There is no terminal active",
                                                                            );
                                                                            return;
                                                                          }
                                                                          monerisPurchaseDialog(
                                                                            orderId:
                                                                                PosController.to.myOrder.orderId,
                                                                            terminalId:
                                                                                terminalId,
                                                                            totalAmount:
                                                                                paymentData.cardPaidAmount.toCents(),
                                                                            isCashAndCard:
                                                                                true,
                                                                            isKitchenPrint:
                                                                                false,
                                                                            cash:
                                                                                paymentData.cashPaidAmount,
                                                                            cashTip:
                                                                                paymentData.cashTipAmount,
                                                                            //                              declineAttempt: PosController
                                                                            // .to.myOrder.declineAttempt
                                                                          );
                                                                          //Todo: Need to test Moneris
                                                                          // PrintUtils().directPrint(
                                                                          //   data: escOrderPrintReceipt(
                                                                          //     order: PosController.to.myOrder,
                                                                          //   ),
                                                                          //   printer:
                                                                          //       Preferences.counterPrinter,
                                                                          // );
                                                                        },
                                                                  ),
                                                                );
                                                              },
                                                              text: 'Moneris'
                                                                  .toUpperCase(),
                                                              height: 103,
                                                              color: StaticColors
                                                                  .blueColor,
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                  ),
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              textMaxSize: 20,
                                                              textMinSize: 20,
                                                              borderColor: Colors
                                                                  .transparent,
                                                              isOutline: true,
                                                            ),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: BaseController
                                                              .to
                                                              .posMonerisTerminal,
                                                          child: SizedBox(
                                                            width: 16,
                                                          ),
                                                        ),
                                                        // !elavon
                                                        Visibility(
                                                          visible: BaseController
                                                              .to
                                                              .posElavonTerminal,
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
                                                                    onPay:
                                                                        (
                                                                          paymentData,
                                                                        ) {
                                                                          // Handle pay action
                                                                          if (paymentData ==
                                                                              null) {
                                                                            return;
                                                                          }
                                                                          Get.back();

                                                                          elavonPurchaseDialog(
                                                                            amountCents:
                                                                                paymentData.cardPaidAmount.toCentsInt(),
                                                                            isCashAndCard:
                                                                                true,

                                                                            cash:
                                                                                paymentData.cashPaidAmount,
                                                                            cashTip:
                                                                                paymentData.cashTipAmount,
                                                                            terminalIp:
                                                                                Preferences.terminalIp,
                                                                            terminalPort:
                                                                                Preferences.terminalPort,
                                                                          );
                                                                        },
                                                                    onPayAndPrint:
                                                                        (
                                                                          paymentData,
                                                                        ) {
                                                                          if (paymentData ==
                                                                              null) {
                                                                            return;
                                                                          }
                                                                          Get.back();

                                                                          elavonPurchaseDialog(
                                                                            amountCents:
                                                                                paymentData.cardPaidAmount.toCentsInt(),

                                                                            isCashAndCard:
                                                                                true,

                                                                            cash:
                                                                                paymentData.cashPaidAmount,
                                                                            cashTip:
                                                                                paymentData.cashTipAmount,
                                                                            terminalIp:
                                                                                Preferences.terminalIp,
                                                                            terminalPort:
                                                                                Preferences.terminalPort,
                                                                          );
                                                                          PrintUtils().directPrint(
                                                                            data: escOrderPrintReceipt(
                                                                              order: PosController.to.myOrder,
                                                                            ),
                                                                            printer:
                                                                                Preferences.counterPrinter,
                                                                          );
                                                                        },
                                                                  ),
                                                                );
                                                              },
                                                              text: 'Elavon'
                                                                  .toUpperCase(),
                                                              height: 103,
                                                              color: StaticColors
                                                                  .blueColor,
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                  ),
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              textMaxSize: 20,
                                                              textMinSize: 20,
                                                              borderColor: Colors
                                                                  .transparent,
                                                              isOutline: true,
                                                            ),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: BaseController
                                                              .to
                                                              .posElavonTerminal,
                                                          child: SizedBox(
                                                            width: 16,
                                                          ),
                                                        ),
                                                        //! standalone
                                                        Expanded(
                                                          child: PrimaryBtn(
                                                            onPressed: () {
                                                              Get.back();
                                                              PopupDialog.customDialog(
                                                                width: 600,
                                                                child: PaymentDialog(
                                                                  paymentMethod:
                                                                      data,
                                                                  minPay: PosController
                                                                      .to
                                                                      .myOrder
                                                                      .totalOrderAmount,
                                                                  onPay: (value) async {
                                                                    if (value ==
                                                                        null) {
                                                                      return;
                                                                    }
                                                                    PosController
                                                                            .to
                                                                            .myOrder
                                                                            .payment =
                                                                        value;
                                                                    PosController
                                                                            .to
                                                                            .myOrder
                                                                            .orderStatus =
                                                                        "COMPLETED";
                                                                    PosController
                                                                            .to
                                                                            .myOrder
                                                                            .paymentStatus =
                                                                        "PAID";
                                                                    PosController
                                                                        .to
                                                                        .calculateTotalPrice();
                                                                    PopupDialog.showLoadingDialog();
                                                                    bool
                                                                    isUpdated = await PosController.to.onUpdateOrder(
                                                                      PosController
                                                                          .to
                                                                          .myOrder
                                                                          .id,
                                                                    );
                                                                    PopupDialog.closeLoadingDialog();
                                                                    if (isUpdated) {
                                                                      Get.back();
                                                                      DataUpdateHelper.getDataByCheckType();
                                                                    }
                                                                  },
                                                                  onPayAndPrint: (value) async {
                                                                    if (value ==
                                                                        null) {
                                                                      return;
                                                                    }
                                                                    PosController
                                                                            .to
                                                                            .myOrder
                                                                            .payment =
                                                                        value;
                                                                    PosController
                                                                            .to
                                                                            .myOrder
                                                                            .orderStatus =
                                                                        "COMPLETED";
                                                                    PosController
                                                                            .to
                                                                            .myOrder
                                                                            .paymentStatus =
                                                                        "PAID";
                                                                    PosController
                                                                        .to
                                                                        .calculateTotalPrice();
                                                                    PopupDialog.showLoadingDialog();
                                                                    bool
                                                                    isUpdated = await PosController.to.onUpdateOrder(
                                                                      PosController
                                                                          .to
                                                                          .myOrder
                                                                          .id,
                                                                    );
                                                                    PopupDialog.closeLoadingDialog();
                                                                    if (isUpdated) {
                                                                      Get.back();

                                                                      PosController
                                                                          .to
                                                                          .calculateTotalPrice();
                                                                      await PrintUtils().directPrint(
                                                                        data: escOrderPrintReceipt(
                                                                          order: PosController
                                                                              .to
                                                                              .myOrder,
                                                                        ),
                                                                        printer:
                                                                            Preferences.counterPrinter,
                                                                      );
                                                                      DataUpdateHelper.getDataByCheckType();
                                                                    }
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                            text: 'standalone'
                                                                .toUpperCase(),
                                                            height: 103,
                                                            color: StaticColors
                                                                .blueColor,
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                ),
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                            textMaxSize: 20,
                                                            textMinSize: 20,
                                                            borderColor: Colors
                                                                .transparent,
                                                            isOutline: true,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else if (data == "GIFT_CARD") {
                                              DataCandyPaymentRepo.showDialogPay(
                                                PosController
                                                    .to
                                                    .myOrder
                                                    .totalOrderAmount,
                                              );
                                            } else if (data ==
                                                "CASH_AND_GIFT_CARD") {
                                              PopupDialog.customDialog(
                                                width: 650,
                                                child: CashAndGiftCardDialog(
                                                  minPay: PosController
                                                      .to
                                                      .myOrder
                                                      .totalOrderAmount,
                                                ),
                                              );
                                            } else {
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
                                                    PosController
                                                            .to
                                                            .myOrder
                                                            .orderStatus =
                                                        "COMPLETED";
                                                    PosController
                                                            .to
                                                            .myOrder
                                                            .paymentStatus =
                                                        "PAID";
                                                    PosController.to
                                                        .calculateTotalPrice();
                                                    PopupDialog.showLoadingDialog();
                                                    bool isUpdated =
                                                        await PosController.to
                                                            .onUpdateOrder(
                                                              PosController
                                                                  .to
                                                                  .myOrder
                                                                  .id,
                                                            );
                                                    PopupDialog.closeLoadingDialog();
                                                    if (isUpdated) {
                                                      Get.back();
                                                      DataUpdateHelper.getDataByCheckType();
                                                    }
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
                                                    PosController
                                                            .to
                                                            .myOrder
                                                            .orderStatus =
                                                        "COMPLETED";
                                                    PosController
                                                            .to
                                                            .myOrder
                                                            .paymentStatus =
                                                        "PAID";
                                                    PosController.to
                                                        .calculateTotalPrice();
                                                    PopupDialog.showLoadingDialog();
                                                    bool isUpdated =
                                                        await PosController.to
                                                            .onUpdateOrder(
                                                              PosController
                                                                  .to
                                                                  .myOrder
                                                                  .id,
                                                            );
                                                    PopupDialog.closeLoadingDialog();
                                                    if (isUpdated) {
                                                      Get.back();

                                                      PosController.to
                                                          .calculateTotalPrice();
                                                      await PrintUtils().directPrint(
                                                        data:
                                                            escOrderPrintReceipt(
                                                              order:
                                                                  PosController
                                                                      .to
                                                                      .myOrder,
                                                            ),
                                                        printer: Preferences
                                                            .counterPrinter,
                                                      );
                                                      DataUpdateHelper.getDataByCheckType();
                                                    }
                                                  },
                                                ),
                                              );
                                            }
                                          },
                                          text: data
                                              .replaceAll('_', ' ')
                                              .replaceAll('AND', '&'),
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
                                        );
                                      }),
                                    ),
                                    SizedBox(height: 12),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: const SizedBox(),
                ),

                // Visibility(
                //   visible: data.splitAmounts.isEmpty &&
                //       data.splitOrders.isEmpty &&
                //       data.splitOrderCarts.isEmpty,
                //   child: Visibility(
                //     visible: (data.isVoid == false && data.refund == false) &&
                //         data.paymentStatus == "PAID",
                //     child: Padding(
                //       padding:
                //           const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                //       child: Row(
                //         children: [
                //           Expanded(
                //             child: PrimaryBtn(
                //               onPressed: () async {
                //                 PopupDialog.permissionDialog(theme,
                //                     onSubmit: () async {
                //                   if (PosController
                //                           .to.myOrder.payment?.providerName ==
                //                       "Moneris") {
                //                     String terminalId = PosController.to.terminals
                //                             ?.terminalIds.first.terminalId ??
                //                         "";

                // String transactionId = Preferences.terminalId;

                //                     if (terminalId.isEmpty == true) {
                //                       PopupDialog.showErrorMessage(
                //                           "There is no terminal active");
                //                       return;
                //                     }
                //                     if (transactionId.isEmpty == true) {
                //                       PopupDialog.showErrorMessage(
                //                           "TransactionId is empty");
                //                       return;
                //                     }
                //                     monerisVoidDialog(
                //                       orderId: PosController.to.myOrder.orderId,
                //                       terminalId: terminalId,
                //                       transactionId: transactionId,
                //                     );
                //                     Get.back();
                //                   } else if (PosController
                //                           .to.myOrder.payment?.providerName ==
                //                       "standalone") {
                //                     PopupDialog.showLoadingDialog();
                //                     bool isUpdated = await PosController.to
                //                         .onUpdateOrderItems(
                //                             PosController.to.myOrder.id,
                //                             isVoid: true);

                //                     PopupDialog.closeLoadingDialog();
                //                     Get.back();
                //                     if (isUpdated) {
                //                       DataUpdateHelper.getDataByCheckType();
                //                     }
                //                   } else {
                //                     PopupDialog.showErrorMessage(
                //                         "Payment is not valid");
                //                   }
                //                 }, title: "Want to Void the Transaction?");
                //               },
                //               textMaxSize: 30,
                //               textMinSize: 11,
                //               padding: const EdgeInsets.symmetric(
                //                   horizontal: 6, vertical: 10),
                //               text: 'VOID',
                //               textColor: Colors.white,
                //               color: StaticColors.blueColor,
                //             ),
                //           ),
                //           const SizedBox(width: 12),
                //           Expanded(
                //             child: PrimaryBtn(
                //               onPressed: () async {
                //                 PopupDialog.permissionDialog(theme,
                //                     onSubmit: () async {
                //                   if (PosController
                //                           .to.myOrder.payment?.providerName ==
                //                       "Moneris") {
                //                    String transactionId = Preferences.terminalId;
                //                     String transactionId = PosController
                //                             .to.myOrder.payment?.transactionId ??
                //                         "";
                //                     if (terminalId.isEmpty == true) {
                //                       PopupDialog.showErrorMessage(
                //                           "There is no terminal active");
                //                       return;
                //                     }
                //                     if (transactionId.isEmpty == true) {
                //                       PopupDialog.showErrorMessage(
                //                           "TransactionId is empty");
                //                       return;
                //                     }
                //                     if (PosController.to.myOrder.payment?.methods
                //                             .contains("CASH_AND_CARD") ==
                //                         true) {
                //                       monerisRefundDialog(
                //                         orderId: PosController.to.myOrder.orderId,
                //                         totalAmount:
                //                             "${((PosController.to.myOrder.payment?.cardPaidAmount ?? 0) + (PosController.to.myOrder.payment?.cardTipAmount ?? 0) * 100).toInt()}",
                //                         terminalId: terminalId,
                //                         transactionId: transactionId,
                //                       );
                //                       Get.back();
                //                     } else {
                //                       monerisRefundDialog(
                //                         orderId: PosController.to.myOrder.orderId,
                //                         totalAmount:
                //                             "${(PosController.to.myOrder.totalOrderAmount * 100).toInt()}",
                //                         terminalId: terminalId,
                //                         transactionId: transactionId,
                //                       );
                //                     }
                //                   } else if (PosController
                //                           .to.myOrder.payment?.providerName ==
                //                       "standalone") {
                //                     PopupDialog.showLoadingDialog();
                //                     bool isUpdated = await PosController.to
                //                         .onUpdateOrderItems(
                //                             PosController.to.myOrder.id,
                //                             refund: true);

                //                     PopupDialog.closeLoadingDialog();
                //                     Get.back();
                //                     if (isUpdated) {
                //                       DataUpdateHelper.getDataByCheckType();
                //                     }
                //                   } else {
                //                     PopupDialog.showErrorMessage(
                //                         "Payment method is not valid");
                //                   }
                //                 }, title: "Want to Refund the Transaction?");
                //               },
                //               textMaxSize: 30,
                //               textMinSize: 11,
                //               padding: const EdgeInsets.symmetric(
                //                   horizontal: 6, vertical: 10),
                //               text: 'REFUND',
                //               textColor: Colors.white,
                //               color: StaticColors.orangeColor,
                //             ),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // item details
  Widget _itemDetails(ThemeData theme, OrderModel data) {
    // print("ZZZ ${data.discountReason}");
    const double btnSize = 180;
    const double height = 60;
    const double textMaxSize = 30;
    const double textMinSize = 11;
    return Container(
      // width: double.infinity,
      // padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(border: Border.all(color: Colors.white)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          // const SizedBox(height: 16),
          // header
          GetBuilder<PosController>(
            builder: (c) {
              return CustomTableItem(
                isSelected: c.myOrder.carts.length == c.selectedItemList.length,
                isHeader: true,
                onChanged: (value) {
                  c.toggleAllSelectedItem();
                },
              );
            },
          ),
          Expanded(
            child: GetBuilder<PosController>(
              builder: (c) {
                return SingleChildScrollView(
                  controller: c.orderDetailItemsScrollController,
                  child: Column(
                    children: [
                      Column(
                        children: List.generate(data.carts.length, (index) {
                          var item = data.carts[index];

                          var discount = item.discountAmount;
                          var itemName = item.isCustomProduct
                              ? "${item.name}(CUSTOM)"
                              : item.name;
                          var totalDiscount =
                              item.discountAmount * item.quantity;
                          var totalPrice =
                              (item.price - item.discountAmount) *
                              item.quantity;
                          return CustomTableItem(
                            onTap: () {
                              c.onChangeSelectedItemList(item.id);
                            },
                            isSelected: c.selectedItemList.contains(item.id),
                            onChanged: (value) {
                              c.onChangeSelectedItemList(item.id);
                              kLogger.e(c.selectedItemList);
                            },
                            sl: "${index + 1}",
                            name: item.itemType == "weighing scale"
                                ? "$itemName(${item.weight}LB)".toCapitalize()
                                : itemName.toCapitalize(),
                            qty: "${item.quantity}",
                            discount: item.discount,
                            discountAmount: "\$ ${discount.toStringAsFixed(2)}",
                            totalDiscount:
                                "\$ ${totalDiscount.toStringAsFixed(2)}",
                            totalPrice: "\$ ${totalPrice.toStringAsFixed(2)}",
                            price: "\$ ${item.price.toStringAsFixed(2)}",
                            isUpdated: item.isUpdated,
                            modifiers: item.modifiers,
                            note: item.kitchenNote,
                            options: item.variationOptions,
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _modifiers(
            theme,
            data.discountReason,
            title: "Discount Reason: ",
            isItalic: true,
            maxLines: 5,
          ),

          const Divider(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                _row(
                  theme,
                  title: "Subtotal :",
                  fontSize: 15,
                  value: "\$ ${data.subTotal.toStringAsFixed(2)}",
                  fontWeight: FontWeight.w800,
                ),
                const SizedBox(height: 4),
                if (data.totalDiscount > 0)
                  _row(
                    child: Visibility(
                      visible: data.paymentStatus == "UNPAID",
                      child: InkWell(
                        onTap: () {
                          PopupDialog.permissionDialog(
                            theme,
                            onSubmit: () async {
                              PosController.to.deleteDiscount();
                              Get.back();
                              var isUpdated = await PosController.to
                                  .onUpdateOrder(
                                    PosController.to.myOrder.id,
                                    isClearList: false,
                                  );

                              if (isUpdated) {
                                DataUpdateHelper.getDataByCheckType();
                              }
                            },
                            title: "Delete Discount?",
                          );
                        },
                        child: data.paymentStatus == "PAID"
                            ? const SizedBox()
                            : Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 1,
                                    color:
                                        theme.textTheme.labelLarge?.color ??
                                        Colors.white,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: StaticColors.redColor,
                                  size: 20,
                                ),
                              ),
                      ),
                    ),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    theme,
                    title: "Discount : ",
                    value: "(-)  \$${data.totalDiscount.toStringAsFixed(2)}",
                  ),
                Visibility(
                  visible: data.totalGst > 0,
                  child: _row(
                    theme,
                    title:
                        "GST ${BaseController.to.restaurantDetails?.businessProfile.gstNumber ?? 0}% :",
                    fontSize: 13,
                    value: "\$ ${data.totalGst.toStringAsFixed(2)}",
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (data.totalPst > 0)
                  _row(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    theme,
                    title:
                        "PST ${BaseController.to.restaurantDetails?.businessProfile.pstNumber ?? 0}% : ",
                    value: "\$${data.totalPst.toStringAsFixed(2)}",
                  ),
                if (data.totalPst2 > 0)
                  _row(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    theme,
                    title:
                        "PST2 ${BaseController.to.restaurantDetails?.businessProfile.pstNumber2 ?? 0}% : ",
                    value: "\$${data.totalPst2.toStringAsFixed(2)}",
                  ),
                // if (data.totalGratuity > 0)
                //   _row(
                //     fontWeight: FontWeight.w800,
                //     fontSize: 13,
                //     theme,
                //     title:
                //         "Gratuity ${BaseController.to.restaurantDetails?.businessProfile.gratuity ?? 0}% : ",
                //     value: "\$${data.totalGratuity.toStringAsFixed(2)}",
                //   ),
                Visibility(
                  visible: data.orderType == "DINE_IN",
                  child: _row(
                    theme,
                    title:
                        "Gratuity ${data.gratuityPercentage ?? (BaseController.to.restaurantDetails?.businessProfile.gratuity ?? 0)}% : ",
                    value: "\$${data.totalGratuity.toStringAsFixed(2)}",
                    child: data.paymentStatus == "PAID"
                        ? const SizedBox.shrink()
                        : Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 1,
                                    color:
                                        theme.textTheme.labelLarge?.color ??
                                        Colors.white,
                                  ),
                                ),
                                child: InkWell(
                                  child: const Icon(
                                    Icons.edit_square,
                                    color: StaticColors.greenColor,
                                  ),
                                  onTap: () {
                                    PopupDialog.permissionDialog(
                                      title: "Edit Gratuity?",
                                      theme,
                                      onSubmit: () async {
                                        Get.back();
                                        PopupDialog.customDialog(
                                          width: 400,
                                          child: EditGratuity(
                                            isNewOrder: false,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 34),
                              Visibility(
                                visible:
                                    (data.gratuityPercentage ??
                                        (BaseController
                                                .to
                                                .restaurantDetails
                                                ?.businessProfile
                                                .gratuity ??
                                            0)) !=
                                    0,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 1,
                                      color:
                                          theme.textTheme.labelLarge?.color ??
                                          Colors.white,
                                    ),
                                  ),
                                  child: InkWell(
                                    child: const Icon(
                                      Icons.delete,
                                      color: StaticColors.redColor,
                                    ),
                                    onTap: () {
                                      PopupDialog.permissionDialog(
                                        title: "Delete Gratuity?",
                                        theme,
                                        onSubmit: () async {
                                          PosController.to.onDeleteGratuity();
                                          // PosController.to.onUpdateOrder(id)
                                          Get.back();

                                          PopupDialog.showLoadingDialog();
                                          await PosController.to.onUpdateOrder(
                                            PosController.to.myOrder.id,
                                          );
                                          PopupDialog.closeLoadingDialog();
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (data.tip > 0)
                  _row(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    theme,
                    title: "Tip : ",
                    value: "\$${data.tip.toStringAsFixed(2)}",
                  ),
                Visibility(
                  visible: data.orderType == "DELIVERY",
                  child: _row(
                    theme,
                    title: "Delivery Fee: ",
                    value: "\$${data.deliveryFee.toStringAsFixed(2)}",
                    child: data.paymentStatus == "PAID"
                        ? const SizedBox.shrink()
                        : Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 1,
                                    color:
                                        theme.textTheme.labelLarge?.color ??
                                        Colors.white,
                                  ),
                                ),
                                child: InkWell(
                                  child: const Icon(
                                    Icons.edit_square,
                                    color: StaticColors.greenColor,
                                  ),
                                  onTap: () {
                                    PopupDialog.permissionDialog(
                                      title: "Edit Delivery Fee?",
                                      theme,
                                      onSubmit: () async {
                                        Get.back();
                                        PopupDialog.customDialog(
                                          width: 400,
                                          child: EditDeliveryFee(
                                            isNewOrder: false,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 34),
                              Visibility(
                                visible: data.deliveryFee != 0,

                                child: Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 1,
                                      color:
                                          theme.textTheme.labelLarge?.color ??
                                          Colors.white,
                                    ),
                                  ),
                                  child: InkWell(
                                    child: const Icon(
                                      Icons.delete,
                                      color: StaticColors.redColor,
                                    ),
                                    onTap: () {
                                      PopupDialog.permissionDialog(
                                        title: "Delete Delivery Fee?",
                                        theme,
                                        onSubmit: () async {
                                          PosController.to
                                              .onDeleteDeliveryFee();
                                          // PosController.to.onUpdateOrder(id)
                                          Get.back();

                                          PopupDialog.showLoadingDialog();
                                          await PosController.to.onUpdateOrder(
                                            PosController.to.myOrder.id,
                                          );
                                          PopupDialog.closeLoadingDialog();
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                Visibility(
                  visible: data.maintenanceFee > 0,
                  child: _row(
                    theme,
                    title: "Service Fee",
                    value: "\$${data.maintenanceFee.toStringAsFixed(2)}",
                  ),
                ),
                Visibility(
                  visible: data.packagingCost > 0,
                  child: _row(
                    theme,
                    title:
                        "${(BaseController.to.restaurantDetails?.restaurant.packagingCost.title) ?? ""}: ",
                    value: "\$${data.packagingCost.toStringAsFixed(2)}",
                  ),
                ),
                const SizedBox(height: 8),
                _row(
                  theme,
                  title: "Total ${MyFunc.orderCondition(data)}: ",
                  value: "\$ ${data.totalOrderAmount.toStringAsFixed(2)}",
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: GetBuilder<PosController>(
              builder: (pc) {
                return Visibility(
                  visible:
                      pc.checkSplitChecksAllPaid() ||
                      data.paymentStatus == "PAID" ||
                      data.orderStatus == "CANCELED",
                  replacement: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: height,
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(Get.context!)
                                .copyWith(
                                  dragDevices: {
                                    PointerDeviceKind.touch,
                                    PointerDeviceKind
                                        .mouse, // mouse drag scroll
                                    PointerDeviceKind.trackpad,
                                  },
                                ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,

                              child: Row(
                                children: [
                                  PrimaryBtn(
                                    width: 200,
                                    height: height,
                                    textMaxSize: textMaxSize,
                                    textMinSize: textMinSize,
                                    onPressed: () {
                                      PosController.to.isUpdateView = true;
                                      PosController.to.onChangeOrderType(
                                        data.orderType,
                                      );
                                      PosController.to
                                          .setTakeOutTypeIndexAndValue(
                                            data.takeOutType ?? "",
                                          );
                                      PosController.to.guestController.text =
                                          data.numberOfPeople.toString();
                                      PosController.to.tableController.text =
                                          data.tableName;
                                      PosController
                                              .to
                                              .guestNameController
                                              .text =
                                          data.guestName;
                                      PosController
                                              .to
                                              .guestPhoneController
                                              .text =
                                          data.guestPhoneNumber;
                                      PosController.to.notesController.text =
                                          data.notes;

                                      PosController.to.selectedLat =
                                          data.delivery?.latitude;
                                      PosController.to.selectedLon =
                                          data.delivery?.longitude;
                                      PosController.to.addressController.text =
                                          data.delivery?.address ?? "";
                                      PosController
                                              .to
                                              .additionalDetailsController
                                              .text =
                                          data.delivery?.additionalDetails ??
                                          "";

                                      // delivery
                                      // PosController.to.deliveryAddress =AddressModel(
                                      //   placeId: 0, licence: , osmType: osmType, osmId: osmId, lat: lat, lon: lon, addrassClass: addrassClass, type: type, placeRank: placeRank, importance: importance, addresstype: addresstype, name: name, displayName: displayName, boundingbox: boundingbox)
                                      //     ;
                                      // unable to edit
                                      PosController.to
                                          .onReadOnlyAllCartTextField();
                                      PosController.to.onchangePage(0);
                                      Get.back();
                                    },
                                    // Add Items,Change Table,Guests
                                    text: 'Add Items ,\nChange Table, Guests'
                                        .toUpperCase(),
                                    textColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 10,
                                    ),
                                    color: theme.primaryColor,
                                  ),
                                  GetBuilder<PosController>(
                                    builder: (context) {
                                      return Tooltip(
                                        message:
                                            context.selectedItemList.isEmpty
                                            ? 'Select item first'
                                            : '',
                                        child: PrimaryBtn(
                                          onPressed: () async {
                                            if (context
                                                .selectedItemList
                                                .isEmpty) {
                                              PopupDialog.showErrorMessage(
                                                "Select item first",
                                              );
                                              return;
                                            }

                                            await context
                                                .repeatAllSelectedItems();
                                            DataUpdateHelper.getDataByCheckType();
                                          },
                                          width: btnSize,
                                          height: height,
                                          isdisabled:
                                              context.selectedItemList.isEmpty
                                              ? true
                                              : false,
                                          textMaxSize: textMaxSize,
                                          textMinSize: textMinSize,
                                          text: 'Repeat Items'.toUpperCase(),
                                          textColor: Colors.white,
                                          color: StaticColors.greenColor,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 10,
                                          ),
                                        ).marginOnly(left: 12),
                                      );
                                    },
                                  ),
                                  GetBuilder<PosController>(
                                    builder: (context) {
                                      return Tooltip(
                                        message:
                                            context.selectedItemList.isEmpty
                                            ? 'Select item first'
                                            : '',
                                        child: PrimaryBtn(
                                          width: btnSize,
                                          height: height,
                                          isdisabled:
                                              context.selectedItemList.isEmpty
                                              ? true
                                              : false,
                                          textMaxSize: textMaxSize,
                                          textMinSize: textMinSize,
                                          onPressed: () {
                                            if (context.myOrder.carts.length ==
                                                1) {
                                              PopupDialog.showErrorMessage(
                                                "Remove items does not allow, Select cancel the check",
                                              );
                                              return;
                                            }
                                            if (context.myOrder.carts.length ==
                                                    context
                                                        .selectedItemList
                                                        .length ||
                                                context
                                                    .selectedItemList
                                                    .isEmpty) {
                                              PopupDialog.showErrorMessage(
                                                "To Remove All Items, select Order Status ''Canceled'' on the right. To remove Specific Items, choose Individual Items and then select ",
                                                duration: Duration(seconds: 3),
                                                maxLines: 5,
                                              );
                                              return;
                                            }

                                            PopupDialog.permissionDialogWithAccessPin(
                                              onSubmit: () {
                                                context
                                                    .removeAllSelectedItems();
                                                DataUpdateHelper.getDataByCheckType();
                                                // Get.back();
                                              },
                                              title:
                                                  context
                                                          .selectedItemList
                                                          .length ==
                                                      1
                                                  ? "Remove Item?"
                                                  : "Remove Items?",
                                            );
                                          },
                                          // width: double.infinity,
                                          text: 'Remove Items'.toUpperCase(),
                                          textColor: Colors.white,
                                          color: StaticColors.orangeColor,
                                        ).marginOnly(left: 12),
                                      );
                                    },
                                  ),
                                  // order status change button
                                  GetBuilder<PosController>(
                                    builder: (c) {
                                      return Visibility(
                                        // need to set ,when user can see the btn
                                        visible:
                                            c.myOrder.orderType != "DINE_IN" &&
                                            c.myOrder.orderStatus ==
                                                "CONFIRMED",
                                        child: PrimaryBtn(
                                          width: btnSize,
                                          height: height,
                                          textMaxSize: textMaxSize,
                                          textMinSize: textMinSize,
                                          onPressed: () {
                                            if (c.myOrder.orderType ==
                                                "DELIVERY") {
                                              // change delivery to takeout

                                              PopupDialog.permissionDialog(
                                                theme,
                                                onSubmit: () {
                                                  Get.back();
                                                  c.onChangeDeliveryToTakeout();
                                                },
                                                title: "Switch to Takeout?"
                                                    .toUpperCase(),
                                              );
                                            } else {
                                              // change takeout to delivery
                                              PopupDialog.permissionDialog(
                                                theme,
                                                title: "Switch to Delivery?"
                                                    .toUpperCase(),
                                                onSubmit: () {
                                                  Get.back();
                                                  PopupDialog.customDialog(
                                                    width: 900,
                                                    child:
                                                        ChangeTakeoutToDelivery(),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          // width: double.infinity,
                                          text:
                                              c.myOrder.orderType == "DELIVERY"
                                              ? 'Switch to Takeout'
                                                    .toUpperCase()
                                              : 'Switch to Delivery'
                                                    .toUpperCase(),
                                          textColor: Colors.white,
                                          color: StaticColors.blueColor,
                                        ).marginOnly(left: 12),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),

                      InkWell(
                        onTap: () {
                          PosController.to.myOrder = OrderModel();
                          Get.back();
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: theme.cardColor,
                            border: Border.all(
                              width: 2,
                              color:
                                  theme.textTheme.labelLarge?.color ??
                                  Colors.white,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Spacer(),
                      InkWell(
                        onTap: () {
                          PosController.to.myOrder = OrderModel();
                          Get.back();
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: theme.cardColor,
                            border: Border.all(
                              width: 2,
                              color:
                                  theme.textTheme.labelLarge?.color ??
                                  Colors.white,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// row
Widget _row(
  ThemeData theme, {
  double? fontSize,
  FontWeight? fontWeight,
  Widget? child,
  required String title,
  required String value,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: fontSize ?? 14,
                fontWeight: fontWeight ?? FontWeight.w700,
              ),
            ),
            SizedBox(child: child),
          ],
        ),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: fontSize ?? 14,
              fontWeight: fontWeight ?? FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.name,
    required this.qnty,
    required this.price,
    this.onTap,
    this.bgColor,
  });

  final String name;
  final int qnty;
  final double price;
  final VoidCallback? onTap;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: Theme.of(context).focusColor, width: 0.15),
        ),
        child: Row(
          children: [
            Expanded(flex: 4, child: MyCustomText(name)),
            Expanded(flex: 1, child: MyCustomText('x$qnty')),
            Expanded(
              flex: 2,
              child: MyCustomText('\$${price.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _modifiers(
  ThemeData theme,
  String value, {
  int maxLines = 2,
  bool isItalic = false,
  String? title,
}) {
  return Visibility(
    visible: value.contains(':') ? value.length > 6 : value != '',
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
      child: Text.rich(
        maxLines: maxLines,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        ),
        TextSpan(
          text: title,
          children: [
            TextSpan(
              text: value.trim().toUpperCase(),
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
