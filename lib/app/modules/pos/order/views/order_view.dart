import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/modules/pos/order/widgets/bottom_bar.dart';
import 'package:yogo_pos/app/modules/pos/order/widgets/cart_area.dart';
import 'package:yogo_pos/app/modules/pos/order/widgets/search_custom_item_row.dart';
import 'package:yogo_pos/app/modules/pos/order/widgets/category_body.dart';
import 'package:yogo_pos/app/modules/pos/order/widgets/product_body.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/models/restaurant_model.dart';
import 'package:yogo_pos/app/utils/my_reg_exp.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/app_indecator.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:get/get.dart';

import '../../views/widgets/top_menu.dart';

import '../widgets/modifiers.dart';

class OrderView extends GetView<PosController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    // PosController.to.onFocusGuestName();
    PosController.to.categoryTypeActiveIndex = 0;

    return GetBuilder<BaseController>(
      builder: (bc) {
        final bool isCategoryWithItems =
            bc.posDisplayMode == PosDisplayMode.categoryWithItems;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // cart area (left side)
            CartArea(theme),
            // right side
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TopMenu(paddingLeft: 16),
                  const SizedBox(height: 16),
                  //search row
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SearchAndCustomItemRow(),
                  ),
                  const SizedBox(height: 12),
                  // sub category and product
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // item 1 (Category)
                        const SizedBox(width: 16),

                        Visibility(
                          visible: isCategoryWithItems,
                          child: Container(
                            margin: EdgeInsets.only(right: 6),
                            width: 200,
                            child: CategoryBody(
                              padding: EdgeInsets.only(right: 14),
                              crossAxisCount: 1,
                            ),
                          ),
                        ),
                        Expanded(
                          child: GetBuilder<PosController>(
                            builder: (controller) {
                              return Visibility(
                                visible: isCategoryWithItems
                                    ? true
                                    : controller.isItemsShow,

                                replacement: CategoryBody(
                                  crossAxisCount: 5,
                                  padding: EdgeInsets.only(right: 14),
                                ),
                                child: GetBuilder<PosController>(
                                  builder: (controller) {
                                    if (controller.isLoadingProduct) {
                                      return const AppIndecator();
                                    } else {
                                      return ProductBody(
                                        crossAxisCount: isCategoryWithItems
                                            ? 3
                                            : 4,
                                        padding: EdgeInsets.only(right: 14),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        GetBuilder<PosController>(
                          builder: (controller) {
                            return Visibility(
                              visible: isCategoryWithItems
                                  ? true
                                  : controller.isItemsShow,
                              child: SizedBox(
                                width: 180,
                                child: ModifiersRow(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),

                  //bottom bar
                  BottomBar(theme),
                ],
              ),
            ),

            // cart area
          ],
        );
      },
    );
  }

  //** Modifiers **
  // Widget _modifiersRow(BuildContext context) {
  //   return GetBuilder<PosController>(
  //     builder: (c) {
  //       return Column(
  //         children: [
  //           Expanded(
  //             child: SingleChildScrollView(
  //               child: Column(
  //                 children: [
  //                   ...List.generate(c.modifiers.length, (index) {
  //                     var modifier = c.modifiers[index];
  //                     return Modifiers(modifier: modifier);
  //                   }),
  //                   const SizedBox(height: 16),
  //                   const SizedBox(height: 16),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           _popupPrimaryBtn(
  //             backgroundColor: StaticColors.greenColor,
  //             onPressed: () {
  //               // ckeck cart is empty
  //               if (PosController.to.myOrder.carts.isEmpty) {
  //                 PopupDialog.showErrorMessage("No item selected");
  //                 return;
  //               }
  //               if (c.selectedItemList.length > 1) {
  //                 PopupDialog.showErrorMessage("Select 1 item");
  //                 return;
  //               }

  //               CartModel? cart;
  //               if (c.selectedItemList.isEmpty) {
  //                 cart = PosController.to.myOrder.carts.last;
  //               } else {
  //                 cart = PosController.to.myOrder.carts.firstWhereOrNull(
  //                   (c) => c.id == PosController.to.selectedItemList.first,
  //                 );
  //               }
  //               if (cart == null) {
  //                 PopupDialog.showErrorMessage("Item not found");
  //                 return;
  //               }

  //               if (cart.isUpdated) {
  //                 PopupDialog.showErrorMessage("Can't update kitchen note");
  //                 return;
  //               }
  //               if (controller.selectedItemList.length == 1) {
  //                 // Find the index of the selected cart
  //                 int cartIndex = controller.myOrder.carts.indexWhere(
  //                   (c) => c.id == controller.selectedItemList.first,
  //                 );

  //                 if (cartIndex != -1) {
  //                   // Update the found cart's kitchen note
  //                   controller.kitchenNoteTEC.text =
  //                       controller.myOrder.carts[cartIndex].kitchenNote;
  //                 } else {
  //                   // Handle error: cart not found
  //                   debugPrint(
  //                     "Cart not found for ID: ${controller.selectedItemList.first}",
  //                   );
  //                 }
  //               } else if (controller.selectedItemList.isEmpty) {
  //                 controller.kitchenNoteTEC.text =
  //                     controller.myOrder.carts.last.kitchenNote;
  //               }

  //               PopupDialog.customDialog(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     const Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         MyCustomText(
  //                           'Add  Notes',
  //                           fontSize: 24,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 14),
  //                     CustomTextField(
  //                       controller: controller.kitchenNoteTEC,
  //                       allowRegex:
  //                           CommonRegexPatterns.alphanumericWithSpaceAndLength(
  //                             200,
  //                           ),
  //                       hintText: '',
  //                       maxLines: 10,
  //                       padding: const EdgeInsets.symmetric(
  //                         vertical: 16,
  //                         horizontal: 16,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 20),
  //                     PrimaryBtn(
  //                       width: 200,
  //                       height: 70,
  //                       style: const TextStyle(
  //                         fontSize: 22,
  //                         fontWeight: FontWeight.w600,
  //                         color: Colors.white,
  //                       ),
  //                       onPressed: () {
  //                         controller.addKitchenNote();
  //                         CustomerWindowServices.updateCustomerWindow(
  //                           controller.myOrder,
  //                         );
  //                         Get.back();
  //                       },
  //                       color: StaticColors.blueColor,
  //                       text: 'Submit',
  //                       textColor: Colors.white,
  //                     ),
  //                   ],
  //                 ),
  //               );
  //               c.update();
  //             },
  //             text: 'NOTE',
  //             isSelected: false,
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}

class ModifiersRow extends StatefulWidget {
  const ModifiersRow({super.key});

  @override
  State<ModifiersRow> createState() => _ModifiersRowState();
}

class _ModifiersRowState extends State<ModifiersRow> {
  final PosController controller = Get.find<PosController>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetBuilder<PosController>(
      builder: (c) {
        return Column(
          children: [
            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(
                    theme.textTheme.bodyLarge?.color!.withAlpha(100),
                  ),
                  trackColor: WidgetStateProperty.all(theme.cardColor),
                  trackBorderColor: WidgetStateProperty.all(Colors.transparent),
                  thickness: WidgetStateProperty.all(6),
                  radius: const Radius.circular(8),
                  thumbVisibility: WidgetStateProperty.all(true),
                  trackVisibility: WidgetStateProperty.all(true),
                ),
                child: Scrollbar(
                  controller: controller.modifierScrollController,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(right: 14),
                    controller: controller.modifierScrollController,
                    child: Column(
                      children: [
                        ...List.generate(c.modifiers.length, (index) {
                          var modifier = c.modifiers[index];
                          return Modifiers(modifier: modifier);
                        }),
                        const SizedBox(height: 16),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _popupPrimaryBtn(
              backgroundColor: StaticColors.greenColor,
              onPressed: () {
                // ckeck cart is empty
                if (PosController.to.myOrder.carts.isEmpty) {
                  PopupDialog.showErrorMessage("No item selected");
                  return;
                }
                if (c.selectedItemList.length > 1) {
                  PopupDialog.showErrorMessage("Select 1 item");
                  return;
                }

                CartModel? cart;
                if (c.selectedItemList.isEmpty) {
                  cart = PosController.to.myOrder.carts.last;
                } else {
                  cart = PosController.to.myOrder.carts.firstWhereOrNull(
                    (c) => c.id == PosController.to.selectedItemList.first,
                  );
                }
                if (cart == null) {
                  PopupDialog.showErrorMessage("Item not found");
                  return;
                }

                if (cart.isUpdated) {
                  PopupDialog.showErrorMessage("Can't update kitchen note");
                  return;
                }
                if (controller.selectedItemList.length == 1) {
                  // Find the index of the selected cart
                  int cartIndex = controller.myOrder.carts.indexWhere(
                    (c) => c.id == controller.selectedItemList.first,
                  );

                  if (cartIndex != -1) {
                    // Update the found cart's kitchen note
                    controller.kitchenNoteTEC.text =
                        controller.myOrder.carts[cartIndex].kitchenNote;
                  } else {
                    // Handle error: cart not found
                    debugPrint(
                      "Cart not found for ID: ${controller.selectedItemList.first}",
                    );
                  }
                } else if (controller.selectedItemList.isEmpty) {
                  controller.kitchenNoteTEC.text =
                      controller.myOrder.carts.last.kitchenNote;
                }

                PopupDialog.customDialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyCustomText(
                            'Add  Notes',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: controller.kitchenNoteTEC,
                        allowRegex:
                            CommonRegexPatterns.alphanumericWithSpaceAndLength(
                              200,
                            ),
                        hintText: '',
                        maxLines: 10,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryBtn(
                        width: 200,
                        height: 70,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          controller.addKitchenNote();
                         
                          Get.back();
                        },
                        color: StaticColors.blueColor,
                        text: 'Submit',
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                );
                c.update();
              },
              text: 'NOTE',
              isSelected: false,
            ).marginOnly(right: 14),
          ],
        );
      },
    );
  }

  PrimaryBtn _popupPrimaryBtn({
    required VoidCallback onPressed,
    required String text,
    Color? backgroundColor,
    required bool isSelected,
  }) {
    return PrimaryBtn(
      onPressed: onPressed,
      width: double.infinity,
      text: text,
      isOutline: true,
      textColor: Colors.white,
      color:
          backgroundColor ??
          (isSelected
              ? StaticColors.blueColor
              : Theme.of(Get.context!).scaffoldBackgroundColor),
      borderColor: isSelected
          ? StaticColors.blueColor
          : StaticColors.greenColor,
    );
  }
}
