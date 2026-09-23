import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/widgets/dialogs/discount_dialog.dart';
import 'package:yogo_pos/app/modules/pos/order/widgets/dialogs/order_payment_dialog.dart';
import 'package:yogo_pos/app/modules/setting/controllers/caller_id_controller.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/elavon-cws/services/cws_gratuity.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/elavon-cws/views/cws_purchase_dialog.dart';
import 'package:yogo_pos/app/routes/app_pages.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/services/models/restaurant_model.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';

import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:yogo_pos/app/widgets/show_caller_order_split_dialog.dart';

class BottomBar extends GetView<PosController> {
  final ThemeData theme;
  const BottomBar(this.theme, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PosController>(
      builder: (c) {
        final bool isCategoryWithItems =
            BaseController.to.posDisplayMode ==
            PosDisplayMode.categoryWithItems;
        return Container(
          height: 100,
          padding: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
          decoration: BoxDecoration(
            color: ConfigController.to.isLightTheme
                ? theme.cardColor
                : StaticColors.cartColor,
            // border: Border.all(color: Colors.white),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Visibility(
                      //   visible: kDebugMode,
                      //   child: PrimaryBtn(
                      //     width: 90,
                      //     height: 80,
                      //     textColor: Colors.white,
                      //     color: StaticColors.blueColor,
                      //     onPressed: () async {
                      //       // cwsPurchaseDialog(amountCents: 5050);
                      //       // print(Preferences.user);
                      //       // Get.toNamed(Routes.CALLER_ID_PAGE);
                      //     },
                      //     text: "No Tips".toUpperCase(),
                      //   ).marginOnly(right: 10),
                      // ),
                      // Visibility(
                      //   // visible: kDebugMode,
                      //   child: PrimaryBtn(
                      //     width: 90,
                      //     height: 80,
                      //     textColor: Colors.white,
                      //     color: StaticColors.blueColor,
                      //     onPressed: () async {
                      //       cwsPurchaseDialog(
                      //         amountCents: 5050,
                      //         gratuity: const CwsGratuity.prompt(),
                      //       );
                      //     },
                      //     text: "Tips 15/18/20%".toUpperCase(),
                      //   ).marginOnly(right: 10),
                      // ),
                      // Visibility(
                      //   // visible: kDebugMode,
                      //   child: PrimaryBtn(
                      //     width: 90,
                      //     height: 80,
                      //     textColor: Colors.white,
                      //     color: StaticColors.blueColor,
                      //     onPressed: () async {
                      //       cwsPurchaseDialog(
                      //         amountCents: 5050,
                      //         gratuity: CwsGratuity.prompt(
                      //           quickSelections: const [
                      //             CwsTipOption.percent(15),
                      //             CwsTipOption.percent(20),
                      //             CwsTipOption.amount(300), // $3.00
                      //           ],
                      //         ),
                      //       );
                      //     },
                      //     text: "custom quick tips".toUpperCase(),
                      //   ).marginOnly(right: 10),
                      // ),
                      // Visibility(
                      //   // visible: kDebugMode,
                      //   child: PrimaryBtn(
                      //     width: 90,
                      //     height: 80,
                      //     textColor: Colors.white,
                      //     color: StaticColors.blueColor,
                      //     onPressed: () async {
                      //       cwsPurchaseDialog(
                      //         amountCents: 5050,
                      //         gratuity: const CwsGratuity.fixed(500),
                      //       );
                      //     },
                      //     text: "tips fixed".toUpperCase(),
                      //   ).marginOnly(right: 10),
                      // ),

                      PrimaryBtn(
                        width: 90,
                        height: 80,
                        textColor: Colors.white,
                        color: StaticColors.blueColor,
                        onPressed: () async {
                          if (controller.selectedItemList.isEmpty) {
                            PopupDialog.showErrorMessage(
                              "Select an Item to Delete",
                            );
                            return;
                          }
                          var isHasUpdatedData =
                              MyFunc.hasMatchingUpdatedCartId(
                                controller.myOrder,
                                controller.selectedItemList,
                              );

                          if (isHasUpdatedData) {
                            PopupDialog.showErrorMessage(
                              "Updated Item is selected ,unselect it first",
                            );
                            return;
                          }
                          controller.removeAllSelectedItems(
                            isUpdateView: false,
                          );
                        },
                        text: "Delete".toUpperCase(),
                      ).marginOnly(right: 10),
                      Visibility(
                        visible: !controller.isUpdateView,
                        child: PrimaryBtn(
                          width: 90,
                          height: 80,
                          textColor: Colors.white,
                          color: StaticColors.blueColor,
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          onPressed: () async {
                            if (controller.myOrder.carts.isEmpty) {
                              PopupDialog.showErrorMessage(
                                "No Items to Cancell",
                              );
                              return;
                            }
                            PopupDialog.permissionDialog(
                              theme,
                              onSubmit: () async {
                                Get.back();
                                controller.clearCartList();
                                if (controller.orderType == "DINE_IN") {
                                  controller.onRemovePackagingCost();
                                } else {
                                  controller.onAddPackagingCost();
                                }
                              },
                              title: "Cancell Items & Order Details?",
                            );
                          },
                          text: "CANCELL".toUpperCase(),
                        ).marginOnly(right: 10),
                      ),

                      // SizedBox(width: 10),
                      Visibility(
                        visible: !controller.isUpdateView,
                        child: PrimaryBtn(
                          width: 90,
                          height: 80,
                          textMaxSize: 25,
                          textMinSize: 20,
                          textColor: Colors.white,
                          color: StaticColors.blueColor,
                          onPressed: () {
                            // for dine in
                            if (controller.myOrder.carts.isNotEmpty) {
                              // for takeout
                              if (controller.myOrder.orderType == "TAKEOUT") {
                                // payment dialog
                                PopupDialog.customDialog(
                                  width: 500,
                                  hasScroll: true,
                                  child: const OrderPaymentDialog(),
                                );
                              } else if (controller.myOrder.orderType ==
                                  "DINE_IN") {
                                // payment dialog for dine in
                                if (controller.tableController.text.isEmpty) {
                                  PopupDialog.showErrorMessage(
                                    "Table is required.",
                                  );
                                } else if (controller
                                    .guestController
                                    .text
                                    .isEmpty) {
                                  PopupDialog.showErrorMessage(
                                    "Number of guest is required.",
                                  );
                                } else {
                                  // payment dialog
                                  PopupDialog.customDialog(
                                    width: 500,
                                    hasScroll: true,
                                    child: const OrderPaymentDialog(),
                                  );
                                }
                              } else if (controller.myOrder.orderType ==
                                  "DELIVERY") {
                                // for delivery
                                if (controller.addressController.text.isEmpty) {
                                  PopupDialog.showErrorMessage(
                                    "Delivery address is required.",
                                  );
                                } else if (controller
                                    .guestNameController
                                    .text
                                    .isEmpty) {
                                  PopupDialog.showErrorMessage(
                                    "Guest name is required.",
                                  );
                                } else if (controller
                                    .guestPhoneController
                                    .text
                                    .isEmpty) {
                                  PopupDialog.showErrorMessage(
                                    "Guest phone is required.",
                                  );
                                } else {
                                  // payment dialog
                                  PopupDialog.customDialog(
                                    width: 500,
                                    hasScroll: true,
                                    child: const OrderPaymentDialog(),
                                  );
                                }
                              } else {
                                PopupDialog.showErrorMessage(
                                  "Order type is not valid.",
                                );
                              }
                            } else {
                              PopupDialog.showErrorMessage(
                                "No Items for Payment.",
                              );
                            }
                          },
                          text: "Pay".toUpperCase(),
                        ).marginOnly(right: 10),
                      ),
                      // PrimaryBtn(
                      //   width: 90,
                      //   height: 80,
                      //   textColor: Colors.white,
                      //   color: StaticColors.blueColor,
                      //   onPressed: () async {
                      //     // final List<int> values = List.generate(20, (index) => (index + 1) * 5);
                      //     Get.toNamed(Routes.Gift_Card_page);
                      //     // BaseController.to.getRestaurantsDetailsFromAPI();
                      //   },
                      //   text: "Gift Card".toUpperCase(),
                      // ).marginOnly(right: 10),

                      PrimaryBtn(
                        height: 80,

                        textColor: Colors.white,
                        color: StaticColors.blueColor,
                        onPressed: () {
                          if (controller.selectedItemList.isEmpty) {
                            PopupDialog.showErrorMessage(
                              "Select an Item First",
                            );
                            return;
                          }
                          PopupDialog.customDialog(
                            hasScroll: true,
                            width: 600,
                            child: DiscountDialog(isUpdateView: false),
                          );
                        },
                        text: "Discount".toUpperCase(),
                      ).marginOnly(right: 10),
                      // ElevatedButton(
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: StaticColors.blueColor,
                      //     foregroundColor: Colors.white,
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     padding: EdgeInsets.zero,
                      //     fixedSize: Size(90, 80),
                      //     alignment: Alignment.center,
                      //     textStyle: TextStyle(
                      //       fontSize: 15,
                      //       fontWeight: FontWeight.bold,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      //   onPressed: () async {
                      //     PopupDialog.permissionDialogWithAccessPin(
                      //       title: "Open Drawer",
                      //       onSubmit: () async {
                      //         await PrintUtils().openDrawer1();
                      //         if (Get.isDialogOpen == true) {
                      //           Get.back();
                      //         }
                      //         Get.back();
                      //       },
                      //     );
                      //   },
                      //   onLongPress: () {
                      //     PopupDialog.permissionDialogWithAccessPin(
                      //       title: "Open Drawer".toUpperCase(),
                      //       onSubmit: () async {
                      //         await PrintUtils().openDrawer2();
                      //         if (Get.isDialogOpen == true) {
                      //           Get.back();
                      //         }
                      //         Get.back();
                      //       },
                      //     );
                      //   },
                      //   child: Text(
                      //     "Open\nDrawer".toUpperCase(),
                      //     textAlign: TextAlign.center,
                      //   ),
                      // ).marginOnly(right: 10),

                      // GetBuilder<BaseController>(
                      //   builder: (bc) {
                      //     return Visibility(
                      //       visible:
                      //           bc.allowCallerIdTypeChange &&
                      //           bc.callerIdType == CallerIdType.typeTwo,
                      //       child: Obx(() {
                      //         return Visibility(
                      //           visible: BaseController.to.hasCallerId.value,
                      //           child: ElevatedButton(
                      //             style: ElevatedButton.styleFrom(
                      //               backgroundColor: StaticColors.blueColor,
                      //               foregroundColor: Colors.white,
                      //               shape: RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.circular(8),
                      //               ),
                      //               padding: EdgeInsets.zero,
                      //               fixedSize: Size(90, 80),
                      //               alignment: Alignment.center,
                      //               textStyle: TextStyle(
                      //                 fontSize: 15,
                      //                 fontWeight: FontWeight.bold,
                      //                 color: Colors.white,
                      //               ),
                      //             ),
                      //             onPressed: () async {
                      //               showCallerOrderSplitDialog(context);
                      //             },
                      //             child: Text(
                      //               "call\nhistory".toUpperCase(),
                      //               textAlign: TextAlign.center,
                      //             ),
                      //           ),
                      //         );
                      //       }),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),

              // toggle btn
              Visibility(
                visible: isCategoryWithItems,
                replacement: SizedBox(
                  width: 180,
                  height: 70,
                  // color: theme.cardColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          BaseController.to.playTapSound();
                          PosController.to.changeItemsView();
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              width: 2,
                              color:
                                  theme.textTheme.labelLarge?.color ??
                                  Colors.white,
                            ),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 40),
                        ),
                      ),
                      // const Icon(Icons.arrow_back_ios_new),
                      // const SizedBox(width: 70),
                      InkWell(
                        onTap: () {
                          BaseController.to.playTapSound();
                          PosController.to.changeItemsView();
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
                            Icons.arrow_forward_ios_rounded,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).marginOnly(left: 10),
                child: SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}
