import 'package:flutter/material.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/controllers/dine_in_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_order_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/widgets/dialogs/split_print/split_amount/esc_split_amount_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/discount_extention.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/widgets/payment_method_dialog.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fraction/fraction.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:yogo_pos/app/widgets/title_bar.dart';
import '../../../../widgets/popup_dialogs.dart';
import '../../order/models/discount_model.dart';
import '../../order/models/order_model.dart';
import '../controllers/dine_in_controller.dart';
import '../controllers/split_order_controller.dart';
import '../widgets/dialogs/split_dialog.dart';

class SplitOrderView extends GetView<DineInController> {
  const SplitOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut<SplitOrderController>(() => SplitOrderController());
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const TitleBar(),
          Expanded(
            child: SizedBox(
              // onPopInvokedWithResult: (_, value) async {
              // await SplitOrderController.to.saveSplitChecksToMainOrder();
              // DataUpdateHelper.getDataByCheckType();
              // DineInOrderController.to.getAllOrders(
              //   orderStatus:
              //       DineInOrderController.to.selectedOrderStatus.isEmpty
              //           ? null
              //           : DineInOrderController.to.selectedOrderStatus,
              // );
              // DineInOrderController.to.getOrderStatus();
              // },
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      // header
                      _header(theme, SplitOrderController.to.mainOrder),
                      const SizedBox(height: 16),
                      Expanded(child: _splitBody(theme)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme, OrderModel order) {
    return Row(
      children: [
        InkWell(
          onTap: () async {
            PopupDialog.showLoadingDialog();
            await SplitOrderController.to.saveSplitChecksToMainOrder();
            DataUpdateHelper.getDataByCheckType();
            DineInOrderController.to.getAllOrders(
              orderStatus: DineInOrderController.to.selectedOrderStatus.isEmpty
                  ? null
                  : DineInOrderController.to.selectedOrderStatus,
            );
            DineInOrderController.to.getOrderStatus();
            PopupDialog.closeLoadingDialog();

            Get.back();
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border.all(
                width: 2,
                color: theme.textTheme.labelLarge?.color ?? Colors.white,
              ),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded, size: 40),
          ),
        ),
        const SizedBox(width: 24),
        PrimaryBtn(
          onPressed: () {
            //if has paid split amount or split by items(not possible)
            if (SplitOrderController.to.listOfSpitChecksByItems.any(
                  (item) => item.payment is PaymentModel,
                ) ||
                SplitOrderController.to.splitAmountChecks.splitAmounts.any(
                  (item) => item.payment is PaymentModel,
                )) {
              PopupDialog.showErrorMessage(
                'One or more Split Checks already settled',
              );
              return;
            }
            //if has not paid split amount (possible if )
            if ((SplitOrderController.to.listOfSpitChecksByItems.isNotEmpty &&
                    SplitOrderController.to.listOfSpitChecksByItems.every(
                      (item) => item.payment == null,
                    )) ||
                (SplitOrderController
                        .to
                        .splitAmountChecks
                        .splitAmounts
                        .isNotEmpty &&
                    SplitOrderController.to.splitAmountChecks.splitAmounts
                        .every((item) => item.payment == null))) {
              PopupDialog.customDialog(
                width: 600,
                child: PopupDialog.permissionDialog(
                  titleStyle: theme.textTheme.headlineSmall,
                  Get.theme,
                  onSubmit: () async {
                    PopupDialog.showLoadingDialog();
                    bool isReset = await SplitOrderController.to
                        .resetSplitChecks();
                    PopupDialog.closeLoadingDialog();
                    if (isReset) {
                      Get.back();
                    }
                  },
                  title: "Split Check is in progress.\nConfirm Reset?",
                ),
              );

              return;
            }
            SplitDialogs.selectNumberOfGuest(
              guestController: SplitOrderController.to.noOfGuestTEC,
              amountController: TextEditingController(
                text:
                    (SplitOrderController.to.mainOrder.totalOrderAmount -
                            SplitOrderController.to.mainOrder.packagingCost)
                        .toStringAsFixed(2),
              ),
              onTap: () {
                SplitOrderController.to.isSplitByAmount = true;
                SplitOrderController.to.calculateSplitReceipts();
                Get.back();
              },
            );
          },
          text: "Split Amount",
          color: StaticColors.greenColor,
          textColor: Colors.white,
        ),
        const SizedBox(width: 12),
        PrimaryBtn(
          onPressed: () {
            if (SplitOrderController.to.pickedItem == null) {
              PopupDialog.showErrorMessage('Select an item to proceed');
              return;
            }
            SplitOrderController.to.breakdownItems();
          },
          text: "Breakdown Items",
          color: StaticColors.greenColor,
          textColor: Colors.white,
        ),
        const SizedBox(width: 12),
        PrimaryBtn(
          onPressed: () {
            if (SplitOrderController.to.pickedItem == null) {
              PopupDialog.showErrorMessage('Select an item to proceed');
              return;
            }
            SplitDialogs.divideItem(
              onTap1of2: () {
                SplitOrderController.to.divideItems(2);
                Get.back();
              },
              onTap1of3: () {
                SplitOrderController.to.divideItems(3);
                Get.back();
              },
              onTap1of4: () {
                SplitOrderController.to.divideItems(4);
                Get.back();
              },
            );
          },
          text: "Divide Items",
          color: StaticColors.greenColor,
          textColor: Colors.white,
        ),
        // const SizedBox(width: 12),
        const Spacer(),
        PrimaryBtn(
          onPressed: () async {
            if (SplitOrderController.to.listOfSpitChecksByItems.isEmpty &&
                SplitOrderController
                    .to
                    .splitAmountChecks
                    .splitAmounts
                    .isEmpty) {
              PopupDialog.showErrorMessage("No split is available.");
            } else {
              if (SplitOrderController.to.listOfSpitChecksByItems.isNotEmpty) {
                final printerName = Preferences.counterPrinter;
                //Print For Spit Checks
                for (
                  int i = 0;
                  i < SplitOrderController.to.listOfSpitChecksByItems.length;
                  i++
                ) {
                  if (printerName.isNotEmpty) {
                    await PrintUtils().directPrint(
                      data: escOrderPrintReceipt(
                        isCustomerCopy: true,
                        order:
                            SplitOrderController.to.listOfSpitChecksByItems[i],
                      ),
                      printer: printerName,
                    );
                  } else {
                    PopupDialog.showErrorMessage(
                      "You need to select printer first",
                    );
                  }
                }
                // PopupDialog.showErrorMessage("Spit Checks");
              } else {
                final printerName = Preferences.counterPrinter;
                //Print For Split Amounts
                for (
                  int i = 0;
                  i <
                      SplitOrderController
                          .to
                          .splitAmountChecks
                          .splitAmounts
                          .length;
                  i++
                ) {
                  if (printerName.isNotEmpty) {
                    await PrintUtils().directPrint(
                      data: escSplitAmountPrintReceipt(
                        isCustomerCopy: true,
                        order: SplitOrderController
                            .to
                            .splitAmountChecks
                            .splitAmounts[i],
                      ),
                      printer: printerName,
                    );
                  } else {
                    PopupDialog.showErrorMessage(
                      "You need to select printer first",
                    );
                  }
                }
                // PopupDialog.showErrorMessage("Spit Amounts");
              }
              PopupDialog.showSuccessDialog(
                "All checks have been printed successfully.",
              );
            }
          },
          text: "Print All Checks",
          color: StaticColors.blueColor,
          textColor: Colors.white,
        ),
        const SizedBox(width: 12),

        PrimaryBtn(
          onPressed: () {
            SplitOrderController.to.resetSplitChecks();
          },
          width: 100,
          text: "Reset",
          color: StaticColors.orangeColor,
          textColor: Colors.white,
        ),
      ],
    );
  }

  Widget _splitBody(ThemeData theme) {
    return GetBuilder<SplitOrderController>(
      builder: (c) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.white)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // *** Left area MAIN RECEIPT */
              GestureDetector(
                onTap: () {
                  c.moveItemToReceipt(c.order);
                },
                child: Container(
                  color: theme.cardColor,
                  padding: const EdgeInsets.all(16),
                  width: 400,
                  child: Column(
                    children: [
                      // header
                      ColoredBox(
                        color: Colors.grey.shade700,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MyCustomText('Order: #${c.order.orderId}'),
                              Visibility(
                                visible: c.order.orderType == "DINE_IN",
                                child: MyCustomText(
                                  'Table: ${c.order.tableName}',
                                ),
                              ),
                              MyCustomText('Token: ${c.order.tokenId}'),
                            ],
                          ),
                        ),
                      ),
                      Divider(color: theme.dividerColor, height: 24),
                      // items area
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                controller: c.itemListScrollController,
                                shrinkWrap: true,
                                itemCount: c.order.carts.length,
                                itemBuilder: (_, i) {
                                  var item = c.order.carts[i];
                                  return _itemRow(
                                    theme,
                                    onTap: () {
                                      // c.updateSelectedItems(item);
                                      c.onItemSelect(item, c.order);
                                    },
                                    isSelected: c.pickedItem == item,
                                    // isSelected:
                                    //     c.selectedItems.carts.contains(item),
                                    discountModel: item.discount,
                                    name: item.name,
                                    quantity: item.quantity.toString(),
                                    discount: item.discountAmount,
                                    price:
                                        " \$ ${num.parse(((item.price - item.discountAmount) * item.quantity).toString()).toStringAsFixed(2)}",
                                  );
                                },
                                separatorBuilder: (_, __) => Divider(
                                  height: 6,
                                  color: theme.dividerColor.withAlpha(153),
                                ),
                              ),
                            ),
                            Divider(
                              height: 16,
                              color: theme.dividerColor.withAlpha(153),
                            ),
                            // price area
                            _priceRow(
                              theme,
                              title: "Subtotal : ",
                              value: "\$${c.order.subTotal.toStringAsFixed(2)}",
                            ),
                            Visibility(
                              visible: c.order.totalDiscount > 0,
                              child: _priceRow(
                                theme,
                                title: "Discount : ",
                                value:
                                    "(-)  \$${c.order.totalDiscount.toStringAsFixed(2)}",
                              ),
                            ),
                            Visibility(
                              visible: c.order.totalGst > 0,
                              child: _priceRow(
                                theme,
                                title:
                                    "GST ${BaseController.to.restaurantDetails?.businessProfile.gstNumber ?? 0}% : ",
                                value:
                                    "\$${c.order.totalGst.toStringAsFixed(2)}",
                              ),
                            ),
                            Visibility(
                              visible: c.order.totalGratuity > 0,
                              child: _priceRow(
                                theme,
                                title:
                                    "Gratuity ${c.mainOrder.gratuityPercentage ?? (BaseController.to.restaurantDetails?.businessProfile.gratuity ?? 0)}% : ",

                                value:
                                    "\$${c.order.totalGratuity.toStringAsFixed(2)}",
                              ),
                            ),
                            Visibility(
                              visible: c.order.totalPst > 0,
                              child: _priceRow(
                                theme,
                                title:
                                    "PST ${BaseController.to.restaurantDetails?.businessProfile.pstNumber ?? 0}% : ",
                                value:
                                    "\$${c.order.totalPst.toStringAsFixed(2)}",
                              ),
                            ),
                            Visibility(
                              visible: c.order.totalPst2 > 0,
                              child: _priceRow(
                                theme,
                                title:
                                    "PST2 ${BaseController.to.restaurantDetails?.businessProfile.pstNumber2 ?? 0}% : ",
                                value:
                                    "\$${c.order.totalPst2.toStringAsFixed(2)}",
                              ),
                            ),
                            Visibility(
                              visible: c.order.tip > 0,
                              child: _priceRow(
                                theme,
                                title: "Tip : ",
                                value: "\$${c.order.tip.toStringAsFixed(2)}",
                              ),
                            ),

                            //deliveryFee
                            Visibility(
                              visible: c.order.deliveryFee > 0,
                              child: _priceRow(
                                theme,
                                title: "Delivery Fee : ",
                                value:
                                    "\$${c.order.deliveryFee.toStringAsFixed(2)}",
                              ),
                            ),
                            Visibility(
                              visible: c.order.maintenanceFee > 0,
                              child: _priceRow(
                                theme,
                                title: "Service Fee : ",
                                value:
                                    "\$${c.order.maintenanceFee.toStringAsFixed(2)}",
                              ),
                            ),
                            Visibility(
                              visible:
                                  c.order.packagingCost > 0 &&
                                  c.order.carts.isNotEmpty,
                              child: _priceRow(
                                theme,
                                title:
                                    "${(BaseController.to.restaurantDetails?.restaurant.packagingCost.title) ?? ""}: ",
                                value:
                                    "\$${c.order.packagingCost.toStringAsFixed(2)}",
                              ),
                            ),
                            const Divider(thickness: .5),
                            _priceRow(
                              theme,
                              title: "Total : ",
                              value:
                                  "\$${c.order.totalOrderAmount.toStringAsFixed(2)}",
                            ),
                          ],
                        ),
                      ),
                      // btn area
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryBtn(
                              onPressed: () {
                                if (c.order.carts.isNotEmpty) {
                                  c.createNewReceipt();
                                } else {
                                  PopupDialog.showErrorMessage(
                                    'Check is empty!',
                                  );
                                }
                              },
                              color: StaticColors.greenColor,
                              text: 'CREATE NEW\nORDER',
                              textColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // *** Right area SPLIT RECEIPTS */
              const SizedBox(width: 22),
              Expanded(
                child: GetBuilder<SplitOrderController>(
                  builder: (c) {
                    return Visibility(
                      visible: c.isSplitByAmount,
                      //split by items
                      replacement: SingleChildScrollView(
                        controller: c.splitChecksScrollController,
                        child: StaggeredGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: List.generate(c.listOfSpitChecksByItems.length, (
                            index,
                          ) {
                            // var check = c.listOfSpitChecksByItems[index];
                            return GestureDetector(
                              onTap:
                                  c.listOfSpitChecksByItems[index].payment !=
                                      null
                                  ? null
                                  : () {
                                      c.moveItemToReceipt(
                                        c.listOfSpitChecksByItems[index],
                                      );
                                    },
                              child: Container(
                                color: theme.cardColor,
                                height: 600,
                                // width: 450,
                                width: Get.width * 0.23,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // header
                                    Row(
                                      children: [
                                        Text(
                                          'Order: #${c.listOfSpitChecksByItems[index].orderId}',
                                          style: theme.textTheme.titleSmall,
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () {
                                            if (SplitOrderController
                                                    .to
                                                    .listOfSpitChecksByItems
                                                    .any(
                                                      (item) =>
                                                          item.payment
                                                              is PaymentModel,
                                                    ) ||
                                                SplitOrderController
                                                    .to
                                                    .splitAmountChecks
                                                    .splitAmounts
                                                    .any(
                                                      (item) =>
                                                          item.payment
                                                              is PaymentModel,
                                                    )) {
                                              PopupDialog.showErrorMessage(
                                                'One or more Split Checks already settled',
                                              );
                                              return;
                                            }
                                            c.removeToListOfSelectedItems(
                                              c.listOfSpitChecksByItems[index],
                                            );
                                          },
                                          child: const Icon(Icons.close),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: theme.dividerColor.withAlpha(102),
                                      height: 16,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              child: MyCustomText(
                                                '${c.order.orderType.replaceAll('_', '-')}:  ${c.listOfSpitChecksByItems[index].guestName}',
                                                fontSize: 18,
                                                maxLines: 2,
                                              ),
                                            ),
                                            if (c
                                                    .listOfSpitChecksByItems[index]
                                                    .payment ==
                                                null)
                                              InkWell(
                                                onTap: () {
                                                  SplitDialogs.guestName(
                                                    guestController:
                                                        c.guestNameTEC,
                                                    onTap: () => c
                                                        .updateGuestName(index),
                                                  );
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                  ),
                                                  child: FaIcon(
                                                    FontAwesomeIcons
                                                        .penToSquare,
                                                    color: StaticColors
                                                        .orangeColor,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: theme.dividerColor.withAlpha(102),
                                      height: 16,
                                    ),

                                    //items row
                                    Expanded(
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: c
                                            .listOfSpitChecksByItems[index]
                                            .carts
                                            .length,
                                        itemBuilder: (_, i) {
                                          var item = c
                                              .listOfSpitChecksByItems[index]
                                              .carts[i];
                                          return _itemRow(
                                            theme,
                                            onTap:
                                                c
                                                        .listOfSpitChecksByItems[index]
                                                        .payment !=
                                                    null
                                                ? null
                                                : () {
                                                    c.onItemSelect(
                                                      item,
                                                      c.listOfSpitChecksByItems[index],
                                                    );
                                                  },
                                            isSelected: c.pickedItem == item,
                                            // isSelected:
                                            //     c.selectedItems.carts.contains(item),
                                            name: item.name,
                                            quantity: item.quantity.toString(),
                                            discount: item.discountAmount,
                                            discountModel: item.discount,
                                            price:
                                                "\$ ${num.parse(((item.price - item.discountAmount) * item.quantity).toString()).toStringAsFixed(2)}",
                                          );
                                        },
                                        separatorBuilder: (_, __) => Divider(
                                          height: 6,
                                          color: theme.dividerColor.withAlpha(
                                            153,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // ...List.generate(
                                    //     c.listOfSpitChecksByItems[index].carts
                                    //         .length, (j) {
                                    //   var item =
                                    //       c.listOfSpitChecksByItems[index].carts[j];
                                    //   return _itemRow(
                                    //     theme,
                                    //     onTap: c.listOfSpitChecksByItems[index]
                                    //                 .payment !=
                                    //             null
                                    //         ? null
                                    //         : () {
                                    //             c.onItemSelect(
                                    //                 item,
                                    //                 c.listOfSpitChecksByItems[
                                    //                     index]);
                                    //           },
                                    //     isSelected: c.pickedItem == item,
                                    //     // isSelected:
                                    //     //     c.selectedItems.carts.contains(item),
                                    //     name: item.name,
                                    //     quantity: item.quantity.toString(),
                                    //     discount: item.discountAmount,
                                    //     discountModel: item.discount,
                                    //     price:
                                    //         "\$ ${num.parse(((item.price - item.discountAmount) * item.quantity).toString()).toStringAsFixed(2)}",
                                    //   );
                                    // }),
                                    Divider(
                                      color: theme.dividerColor.withAlpha(102),
                                      height: 16,
                                    ),
                                    SizedBox(height: 8),
                                    //price area
                                    _priceRow(
                                      theme,
                                      title: "Sub Total",
                                      value:
                                          "\$${c.listOfSpitChecksByItems[index].subTotal.toStringAsFixed(2)}",
                                    ),
                                    if (c
                                            .listOfSpitChecksByItems[index]
                                            .totalDiscount >
                                        0.0)
                                      _priceRow(
                                        theme,
                                        title: "Discount",
                                        value:
                                            "(-)  \$${c.listOfSpitChecksByItems[index].totalDiscount.toStringAsFixed(2)}",
                                      ),
                                    Visibility(
                                      visible:
                                          c
                                              .listOfSpitChecksByItems[index]
                                              .totalGst >
                                          0.0,
                                      child: _priceRow(
                                        theme,
                                        title:
                                            "GST ${BaseController.to.restaurantDetails?.businessProfile.gstNumber ?? 0}% :",
                                        value:
                                            "\$${c.listOfSpitChecksByItems[index].totalGst.toStringAsFixed(2)}",
                                      ),
                                    ),
                                    if (c
                                            .listOfSpitChecksByItems[index]
                                            .totalPst >
                                        0.0)
                                      _priceRow(
                                        theme,
                                        title:
                                            "PST ${BaseController.to.restaurantDetails?.businessProfile.pstNumber ?? 0}% :",
                                        value:
                                            "\$${c.listOfSpitChecksByItems[index].totalPst.toStringAsFixed(2)}",
                                      ),
                                    if (c
                                            .listOfSpitChecksByItems[index]
                                            .totalPst2 >
                                        0.0)
                                      _priceRow(
                                        theme,
                                        title:
                                            "PST2 ${BaseController.to.restaurantDetails?.businessProfile.pstNumber2 ?? 0}% :",
                                        value:
                                            "\$${c.listOfSpitChecksByItems[index].totalPst2.toStringAsFixed(2)}",
                                      ),
                                    if (c
                                            .listOfSpitChecksByItems[index]
                                            .totalGratuity >
                                        0.0)
                                      _priceRow(
                                        theme,
                                        title:
                                            "Gratuity ${c.listOfSpitChecksByItems[index].gratuityPercentage ?? (BaseController.to.restaurantDetails?.businessProfile.gratuity ?? 0)}% : ",

                                        value:
                                            "\$${c.listOfSpitChecksByItems[index].totalGratuity.toStringAsFixed(2)}",
                                      ),

                                    Visibility(
                                      visible:
                                          c
                                                  .listOfSpitChecksByItems[index]
                                                  .packagingCost >
                                              0 &&
                                          c
                                              .listOfSpitChecksByItems[index]
                                              .carts
                                              .isNotEmpty,
                                      child: _priceRow(
                                        theme,
                                        title:
                                            "${(BaseController.to.restaurantDetails?.restaurant.packagingCost.title) ?? ""}: ",
                                        value:
                                            "\$${c.listOfSpitChecksByItems[index].packagingCost.toStringAsFixed(2)}",
                                        child:
                                            c
                                                    .listOfSpitChecksByItems[index]
                                                    .payment !=
                                                null
                                            ? const SizedBox()
                                            : Container(
                                                margin: const EdgeInsets.only(
                                                  left: 4,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  4.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    width: 1,
                                                    color:
                                                        theme
                                                            .textTheme
                                                            .labelLarge
                                                            ?.color ??
                                                        Colors.white,
                                                  ),
                                                ),
                                                child: InkWell(
                                                  child: const Icon(
                                                    Icons.delete,
                                                    color:
                                                        StaticColors.redColor,
                                                  ),
                                                  onTap: () {
                                                    c.splitOrderRemovePackagingCost(
                                                      index,
                                                    );
                                                  },
                                                ),
                                              ),
                                      ),
                                    ),
                                    //maintenanceFee
                                    Visibility(
                                      visible:
                                          c
                                              .listOfSpitChecksByItems[index]
                                              .deliveryFee >
                                          0.0,
                                      child: _priceRow(
                                        theme,
                                        title: "Delivery Fee",
                                        value:
                                            "\$${c.listOfSpitChecksByItems[index].deliveryFee.toStringAsFixed(2)}",
                                      ),
                                    ),
                                    //maintenanceFee
                                    Visibility(
                                      visible:
                                          c
                                              .listOfSpitChecksByItems[index]
                                              .maintenanceFee >
                                          0.0,
                                      child: _priceRow(
                                        theme,
                                        title: "Service Fee",
                                        value:
                                            "\$${c.listOfSpitChecksByItems[index].maintenanceFee.toStringAsFixed(2)}",
                                      ),
                                    ),
                                    if ((c
                                                .listOfSpitChecksByItems[index]
                                                .payment
                                                ?.cardTipAmount ??
                                            0) >
                                        0.0)
                                      _priceRow(
                                        theme,
                                        title: "Card Tip",
                                        value:
                                            "\$${c.listOfSpitChecksByItems[index].payment?.cardTipAmount.toStringAsFixed(2)}",
                                      ),
                                    if ((c
                                                .listOfSpitChecksByItems[index]
                                                .payment
                                                ?.cashTipAmount ??
                                            0) >
                                        0.0)
                                      _priceRow(
                                        theme,
                                        title: "Cash Tip",
                                        value:
                                            "\$${c.listOfSpitChecksByItems[index].payment?.cashTipAmount.toStringAsFixed(2)}",
                                      ),

                                    //toal payment
                                    if ((c
                                                .listOfSpitChecksByItems[index]
                                                .payment
                                                ?.cardPaidAmount ??
                                            0) >
                                        0) ...[
                                      _priceRow(
                                        theme,
                                        title:
                                            "Paid by ${MyFunc.getSplitCardType(c.listOfSpitChecksByItems[index].payment)}",
                                        value:
                                            '\$${((c.listOfSpitChecksByItems[index].payment?.cardPaidAmount ?? 0) + (c.listOfSpitChecksByItems[index].payment?.cardTipAmount ?? 0)).toStringAsFixed(2)}',
                                      ),
                                    ],

                                    if ((c
                                                .listOfSpitChecksByItems[index]
                                                .payment
                                                ?.cashPaidAmount ??
                                            0) >
                                        0) ...[
                                      _priceRow(
                                        theme,
                                        title: "Paid by Cash",
                                        value:
                                            '\$${((c.listOfSpitChecksByItems[index].payment?.cashPaidAmount ?? 0) + (c.listOfSpitChecksByItems[index].payment?.change ?? 0) + (c.listOfSpitChecksByItems[index].payment?.cashTipAmount ?? 0)).toStringAsFixed(2)}',
                                      ),
                                    ],
                                    if ((c
                                                .listOfSpitChecksByItems[index]
                                                .payment
                                                ?.change ??
                                            0) >
                                        0.0)
                                      _priceRow(
                                        theme,
                                        title: "Cash Change",
                                        value:
                                            "\$${c.listOfSpitChecksByItems[index].payment?.change.toStringAsFixed(2)}",
                                      ),
                                    _priceRow(
                                      theme,
                                      title:
                                          "Total${MyFunc.orderCondition(c.listOfSpitChecksByItems[index])}",
                                      fontSize: 20,
                                      spacing: 8,
                                      value:
                                          "\$${(c.listOfSpitChecksByItems[index].totalOrderAmount).toStringAsFixed(2)}",
                                    ),
                                    SizedBox(height: 8),
                                    Divider(
                                      color: theme.dividerColor.withAlpha(102),
                                      height: 16,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: PrimaryBtn(
                                            onPressed:
                                                c
                                                    .listOfSpitChecksByItems[index]
                                                    .carts
                                                    .isEmpty
                                                ? () {
                                                    PopupDialog.showErrorMessage(
                                                      'Check is empty!',
                                                    );
                                                  }
                                                : () async {
                                                    // PopupDialog.customDialog(
                                                    //   width: 435,
                                                    //   color: Colors.white,
                                                    //   iconColor: Colors.black,
                                                    //   child: PrintOrderDialog(
                                                    //     order: SplitOrderController
                                                    //             .to
                                                    //             .listOfSpitChecksByItems[
                                                    //         index],
                                                    //   ),
                                                    // );
                                                    final printerName =
                                                        Preferences
                                                            .counterPrinter;
                                                    if (printerName
                                                        .isNotEmpty) {
                                                      await PrintUtils().directPrint(
                                                        data: escOrderPrintReceipt(
                                                          order: SplitOrderController
                                                              .to
                                                              .listOfSpitChecksByItems[index],
                                                        ),
                                                        printer:
                                                            printerName,
                                                      );
                                                    } else {
                                                      PopupDialog.showErrorMessage(
                                                        "You need to select printer first",
                                                      );
                                                    }

                                                    // kLogger.e(SplitOrderController
                                                    //     .to
                                                    //     .listOfSpitChecksByItems[
                                                    //         index]
                                                    //     .paymentStatus);
                                                    // kLogger.e(SplitOrderController
                                                    //     .to
                                                    //     .listOfSpitChecksByItems[
                                                    //         index]
                                                    //     .payment!
                                                    //     .cardTipAmount);
                                                  },
                                            text: 'PRINT CHECK',
                                            textColor: Colors.white,
                                            color: StaticColors.blueColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: PrimaryBtn(
                                            onPressed:
                                                c
                                                    .listOfSpitChecksByItems[index]
                                                    .carts
                                                    .isEmpty
                                                ? () {
                                                    PopupDialog.showErrorMessage(
                                                      'Add item first!',
                                                    );
                                                  }
                                                : c
                                                          .listOfSpitChecksByItems[index]
                                                          .payment !=
                                                      null
                                                ? () {
                                                    //paid already
                                                  }
                                                : () {
                                                    PopupDialog.customDialog(
                                                      width: 450,
                                                      child: Visibility(
                                                        // visible: true,
                                                        // replacement:
                                                        //     MonerisSplitDialog(
                                                        //   index: index,
                                                        //   isSplitOrder: true,
                                                        // ),
                                                        child:
                                                            PaymentMethodDialog(
                                                              orderIndex: index,
                                                              isSplitOrder:
                                                                  true,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                            text:
                                                c
                                                        .listOfSpitChecksByItems[index]
                                                        .payment ==
                                                    null
                                                ? 'PAY'
                                                : 'PAID (${c.listOfSpitChecksByItems[index].payment?.methods.join(', ').replaceAll('_', ' ') ?? ""})',
                                            textColor: Colors.white,
                                            color:
                                                c
                                                        .listOfSpitChecksByItems[index]
                                                        .payment ==
                                                    null
                                                ? StaticColors.greenColor
                                                : StaticColors.blueColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      //Split by amount
                      child: SingleChildScrollView(
                        child: StaggeredGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: List.generate(c.splitAmountChecks.splitAmounts.length, (
                            index,
                          ) {
                            var check = c.splitAmountChecks.splitAmounts[index];
                            return Container(
                              color: theme.cardColor,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // header
                                  Text(
                                    'Order: #${c.splitAmountChecks.splitAmounts[index].orderId}',
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  Divider(
                                    color: theme.dividerColor.withAlpha(102),
                                    height: 16,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: MyCustomText(
                                              '${c.order.orderType.replaceAll('_', '-')}:  ${check.guestName}',
                                              fontSize: 18,
                                              maxLines: 2,
                                            ),
                                          ),
                                          if (c
                                                  .splitAmountChecks
                                                  .splitAmounts[index]
                                                  .payment ==
                                              null)
                                            InkWell(
                                              onTap: () {
                                                SplitDialogs.guestName(
                                                  guestController:
                                                      c.guestNameTEC,
                                                  onTap: () =>
                                                      c.updateGuestName(index),
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.0,
                                                ),
                                                child: FaIcon(
                                                  FontAwesomeIcons.penToSquare,
                                                  color:
                                                      StaticColors.orangeColor,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: theme.dividerColor.withAlpha(102),
                                    height: 16,
                                  ),
                                  _priceRow(
                                    theme,
                                    title: c.order.orderType == "TAKEOUT"
                                        ? "Total Amount (- Packaging Cost)"
                                        : "Total Amount",
                                    value:
                                        "\$${(c.order.totalOrderAmount - c.order.packagingCost).toStringAsFixed(2)}",
                                  ),
                                  Divider(
                                    color: theme.dividerColor.withAlpha(102),
                                    height: 16,
                                  ),

                                  _priceRow(
                                    theme,
                                    title: "Split Amount",
                                    value:
                                        "\$${(check.splitAmount).toStringAsFixed(2)}",
                                  ),
                                  Divider(
                                    color: theme.dividerColor.withAlpha(102),
                                    height: 16,
                                  ),
                                  if (check.packagingCost > 0.0) ...[
                                    _priceRow(
                                      theme,
                                      title: "Packaging Cost",
                                      value:
                                          "\$${(check.packagingCost).toStringAsFixed(2)}",
                                      child: check.payment != null
                                          ? const SizedBox()
                                          : Container(
                                              margin: const EdgeInsets.only(
                                                left: 4,
                                              ),
                                              padding: const EdgeInsets.all(
                                                4.0,
                                              ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  width: 1,
                                                  color:
                                                      theme
                                                          .textTheme
                                                          .labelLarge
                                                          ?.color ??
                                                      Colors.white,
                                                ),
                                              ),
                                              child: InkWell(
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: StaticColors.redColor,
                                                ),
                                                onTap: () {
                                                  c.splitAmountRemovePackagingCost(
                                                    index,
                                                  );
                                                },
                                              ),
                                            ),
                                    ),
                                    Divider(
                                      color: theme.dividerColor.withAlpha(102),
                                      height: 16,
                                    ),
                                  ],

                                  if ((check.payment?.cardTipAmount ?? 0) >
                                      0) ...[
                                    _priceRow(
                                      theme,
                                      title: "Card Tip",
                                      value:
                                          "\$${check.payment?.cardTipAmount.toStringAsFixed(2)}",
                                    ),
                                    Divider(
                                      color: theme.dividerColor.withAlpha(102),
                                      height: 16,
                                    ),
                                  ],

                                  if ((check.payment?.cashTipAmount ?? 0) >
                                      0) ...[
                                    _priceRow(
                                      theme,
                                      title: "Cash Tip",
                                      value:
                                          "\$${check.payment?.cashTipAmount.toStringAsFixed(2)}",
                                    ),
                                    Divider(
                                      color: theme.dividerColor.withAlpha(102),
                                      height: 16,
                                    ),
                                  ],

                                  //toal payment
                                  if ((check.payment?.cardPaidAmount ?? 0) >
                                      0) ...[
                                    _priceRow(
                                      theme,
                                      title:
                                          "Paid by ${MyFunc.getSplitCardType(check.payment)}",
                                      value:
                                          '\$${((check.payment?.cardPaidAmount ?? 0) + (check.payment?.cardTipAmount ?? 0)).toStringAsFixed(2)}',
                                    ),
                                    Divider(
                                      color: theme.dividerColor.withAlpha(102),
                                      height: 16,
                                    ),
                                  ],

                                  if ((check.payment?.cashPaidAmount ?? 0) >
                                      0) ...[
                                    _priceRow(
                                      theme,
                                      title: "Paid by Cash",
                                      value:
                                          '\$${((check.payment?.cashPaidAmount ?? 0) + (check.payment?.change ?? 0) + (check.payment?.cashTipAmount ?? 0)).toStringAsFixed(2)}',
                                    ),
                                    Divider(
                                      color: theme.dividerColor.withAlpha(102),
                                      height: 16,
                                    ),
                                  ],
                                  //change
                                  if ((check.payment?.change ?? 0) > 0) ...[
                                    _priceRow(
                                      theme,
                                      title: "Change",
                                      value:
                                          '\$${check.payment?.change.toStringAsFixed(2)}',
                                    ),
                                    Divider(
                                      color: theme.dividerColor.withAlpha(102),
                                      height: 16,
                                    ),
                                  ],

                                  _priceRow(
                                    theme,
                                    title:
                                        "Total ${MyFunc.orderCondition(check)}",
                                    fontSize: 20,
                                    spacing: 8,
                                    value:
                                        "\$${(check.total + (check.payment?.cardTipAmount ?? 0) + (check.payment?.cashTipAmount ?? 0)).toStringAsFixed(2)}",
                                  ),
                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: PrimaryBtn(
                                          onPressed: () async {
                                            final printerName =
                                                Preferences.counterPrinter;
                                            if (printerName.isNotEmpty) {
                                              await PrintUtils().directPrint(
                                                data:
                                                    escSplitAmountPrintReceipt(
                                                      order: check,
                                                    ),
                                                printer: printerName,
                                              );
                                            } else {
                                              PopupDialog.showErrorMessage(
                                                "You need to select printer first",
                                              );
                                            }
                                          },
                                          text: 'PRINT CHECK',
                                          width: double.infinity,
                                          textColor: Colors.white,
                                          color: StaticColors.blueColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: PrimaryBtn(
                                          onPressed: check.payment != null
                                              ? () {
                                                  //paid already
                                                }
                                              : () {
                                                  PopupDialog.customDialog(
                                                    width: 450,
                                                    child: Visibility(
                                                      // visible: true,
                                                      // replacement:
                                                      //     MonerisSplitDialog(
                                                      //         index: index,
                                                      //         isSplitOrder:
                                                      //             false),
                                                      child:
                                                          PaymentMethodDialog(
                                                            orderIndex: index,
                                                            isSplitOrder: false,
                                                          ),
                                                    ),
                                                  );
                                                },
                                          text:
                                              c
                                                      .splitAmountChecks
                                                      .splitAmounts[index]
                                                      .payment !=
                                                  null
                                              ? 'PAID (${c.splitAmountChecks.splitAmounts[index].payment?.methods.join(', ').replaceAll('_', ' ') ?? ""})'
                                              : 'PAY',
                                          textColor: Colors.white,
                                          color:
                                              c
                                                      .splitAmountChecks
                                                      .splitAmounts[index]
                                                      .payment !=
                                                  null
                                              ? StaticColors.blueColor
                                              : StaticColors.greenColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // todo:need to added
                                  // Visibility(
                                  //   visible: (c.splitAmountChecks
                                  //                   .splitAmounts[index].isVoid ==
                                  //               false &&
                                  //           c.splitAmountChecks.splitAmounts[index]
                                  //                   .refund ==
                                  //               false) &&
                                  //       c.splitAmountChecks.splitAmounts[index]
                                  //               .payment !=
                                  //           null,
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.only(
                                  //         top: 12, bottom: 12),
                                  //     child: Row(
                                  //       children: [
                                  //         Expanded(
                                  //           child: PrimaryBtn(
                                  //             onPressed: () async {
                                  //               PopupDialog.permissionDialog(theme,
                                  //                   onSubmit: () async {
                                  //                 if (c
                                  //                         .splitAmountChecks
                                  //                         .splitAmounts[index]
                                  //                         .payment
                                  //                         ?.providerName ==
                                  //                     "Moneris") {
                                  //                   String terminalId =
                                  //                       PosController
                                  //                               .to
                                  //                               .terminals
                                  //                               ?.terminalIds
                                  //                               .first
                                  //                               .terminalId ??
                                  //                           "";

                                  //                   String transactionId = c
                                  //                           .splitAmountChecks
                                  //                           .splitAmounts[index]
                                  //                           .payment
                                  //                           ?.transactionId ??
                                  //                       "";

                                  //                   if (terminalId.isEmpty ==
                                  //                       true) {
                                  //                     PopupDialog.showErrorMessage(
                                  //                         "There is no terminal active");
                                  //                     return;
                                  //                   }
                                  //                   if (transactionId.isEmpty ==
                                  //                       true) {
                                  //                     PopupDialog.showErrorMessage(
                                  //                         "TransactionId is empty");
                                  //                     return;
                                  //                   }
                                  //                   //todo:Nedd to work
                                  //                   monerisVoidDialog(
                                  //                       orderId: c
                                  //                           .splitAmountChecks
                                  //                           .splitAmounts[index]
                                  //                           .orderId,
                                  //                       terminalId: terminalId,
                                  //                       transactionId:
                                  //                           transactionId,
                                  //                       isSplitOrder: false,
                                  //                       splitIndex: index);
                                  //                 } else if (c
                                  //                         .splitAmountChecks
                                  //                         .splitAmounts[index]
                                  //                         .payment
                                  //                         ?.providerName ==
                                  //                     "standalone") {
                                  //                   c
                                  //                       .splitAmountChecks
                                  //                       .splitAmounts[index]
                                  //                       .isVoid = true;
                                  //                   c.update();
                                  //                   Get.back();
                                  //                 } else {
                                  //                   PopupDialog.showErrorMessage(
                                  //                       "Payment is not valid");
                                  //                 }
                                  //               },
                                  //                   title:
                                  //                       "Want to Void the Transaction?");
                                  //             },
                                  //             textMaxSize: 30,
                                  //             textMinSize: 11,
                                  //             padding: const EdgeInsets.symmetric(
                                  //                 horizontal: 6, vertical: 10),
                                  //             text: 'VOID',
                                  //             textColor: Colors.white,
                                  //             color: StaticColors.blueColor,
                                  //           ),
                                  //         ),
                                  //         const SizedBox(width: 12),
                                  //         Expanded(
                                  //           child: PrimaryBtn(
                                  //             onPressed: () async {
                                  //               PopupDialog.permissionDialog(theme,
                                  //                   onSubmit: () async {
                                  //                 if (c
                                  //                         .splitAmountChecks
                                  //                         .splitAmounts[index]
                                  //                         .payment
                                  //                         ?.providerName ==
                                  //                     "Moneris") {
                                  //                   String terminalId =
                                  //                       PosController
                                  //                               .to
                                  //                               .terminals
                                  //                               ?.terminalIds
                                  //                               .first
                                  //                               .terminalId ??
                                  //                           "";
                                  //                   String transactionId = c
                                  //                           .splitAmountChecks
                                  //                           .splitAmounts[index]
                                  //                           .payment
                                  //                           ?.transactionId ??
                                  //                       "";
                                  //                   if (terminalId.isEmpty ==
                                  //                       true) {
                                  //                     PopupDialog.showErrorMessage(
                                  //                         "There is no terminal active");
                                  //                     return;
                                  //                   }
                                  //                   if (transactionId.isEmpty ==
                                  //                       true) {
                                  //                     PopupDialog.showErrorMessage(
                                  //                         "TransactionId is empty");
                                  //                     return;
                                  //                   }
                                  //                   if (c
                                  //                           .splitAmountChecks
                                  //                           .splitAmounts[index]
                                  //                           .payment
                                  //                           ?.methods
                                  //                           .contains(
                                  //                               "CASH_AND_CARD") ==
                                  //                       true) {
                                  //                     //todo:Nedd to work
                                  //                     monerisRefundDialog(
                                  //                         orderId: c
                                  //                             .splitAmountChecks
                                  //                             .splitAmounts[index]
                                  //                             .orderId,
                                  //                         totalAmount:
                                  //                             "${((c.splitAmountChecks.splitAmounts[index].payment?.cardPaidAmount ?? 0) + (c.splitAmountChecks.splitAmounts[index].payment?.cardTipAmount ?? 0) * 100).toInt()}",
                                  //                         terminalId: terminalId,
                                  //                         transactionId:
                                  //                             transactionId,
                                  //                         isSplitOrder: false,
                                  //                         splitIndex: index);
                                  //                   } else {
                                  //                     //todo:Nedd to work
                                  //                     monerisRefundDialog(
                                  //                         orderId: c
                                  //                             .splitAmountChecks
                                  //                             .splitAmounts[index]
                                  //                             .orderId,
                                  //                         totalAmount:
                                  //                             "${(c.splitAmountChecks.splitAmounts[index].total * 100).toInt()}",
                                  //                         terminalId: terminalId,
                                  //                         transactionId:
                                  //                             transactionId,
                                  //                         isSplitOrder: false,
                                  //                         splitIndex: index);
                                  //                     Get.back();
                                  //                     Get.back();
                                  //                   }
                                  //                 } else if (c
                                  //                         .splitAmountChecks
                                  //                         .splitAmounts[index]
                                  //                         .payment
                                  //                         ?.providerName ==
                                  //                     "standalone") {
                                  //                   c
                                  //                       .splitAmountChecks
                                  //                       .splitAmounts[index]
                                  //                       .refund = true;
                                  //                   c.update();
                                  //                   Get.back();
                                  //                 } else {
                                  //                   PopupDialog.showErrorMessage(
                                  //                       "Payment method is not valid");
                                  //                 }
                                  //               },
                                  //                   title:
                                  //                       "Want to Refund the Transaction?");
                                  //             },
                                  //             textMaxSize: 30,
                                  //             textMinSize: 11,
                                  //             padding: const EdgeInsets.symmetric(
                                  //                 horizontal: 6, vertical: 10),
                                  //             text: 'REFUND',
                                  //             textColor: Colors.white,
                                  //             color: StaticColors.orangeColor,
                                  //           ),
                                  //         )
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // row
  Widget _priceRow(
    ThemeData theme, {
    double fontSize = 16,
    required String title,
    required String value,
    Widget? child,
    double spacing = 3,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                MyCustomText(title, fontSize: fontSize),
                SizedBox(child: child),
              ],
            ),
          ),
          MyCustomText(value, fontSize: fontSize),
        ],
      ),
    );
  }

  // row 2
  Widget _itemRow(
    ThemeData theme, {
    required String name,
    required num discount,
    required String quantity,
    required String price,
    required Discount discountModel,
    required VoidCallback? onTap,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      child: ColoredBox(
        color: isSelected
            ? StaticColors.blueColor.withAlpha(45)
            : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Expanded(
                          child: MyCustomText(
                            '${name.capitalize}${discount > 0 ? '  (D \$${discount.toStringAsFixed(2)})' : ''}',
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const MyCustomText('x ', fontSize: 14),
                        Expanded(
                          child: MyCustomText(
                            double.parse(quantity).toFraction().toString(),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MyCustomText(price, textAlign: TextAlign.right),
                ],
              ),
              const SizedBox(height: 4),
              Visibility(
                visible: discountModel.value > 0,
                child: Text(
                  "Discount: ${discountModel.displayValue}",
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
