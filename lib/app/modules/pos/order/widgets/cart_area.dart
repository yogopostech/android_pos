// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
// import 'package:yogo_pos/app/helper/data_update_helper.dart';
// import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/kitchen_print.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in/widgets/table_body.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in/widgets/table_mapping_managment_view.dart';
// import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
// import 'package:yogo_pos/app/modules/pos/order/models/product_model.dart';
// import 'package:yogo_pos/app/modules/pos/order/widgets/cart_item.dart';
// import 'package:yogo_pos/app/modules/pos/order/widgets/dialogs/address_dialog.dart';
// import 'package:yogo_pos/app/modules/pos/order/widgets/variation.dart';
// import 'package:yogo_pos/app/services/base/preferences.dart';
// import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/services/controller/config_controller.dart';
// import 'package:yogo_pos/app/utils/extension/order_extention.dart';
// import 'package:yogo_pos/app/utils/logger.dart';
// import 'package:yogo_pos/app/utils/my_reg_exp.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';
// import 'package:yogo_pos/app/utils/urls.dart';
// import 'package:yogo_pos/app/widgets/app_keyboard.dart';
// import 'package:yogo_pos/app/widgets/custom_btn.dart';
// import 'package:yogo_pos/app/widgets/custom_textfield.dart';
// import 'package:yogo_pos/app/widgets/edit_delivery_fee.dart';
// import 'package:yogo_pos/app/widgets/edit_gratuity.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

// class CartArea extends GetView<PosController> {
//   final ThemeData theme;
//   const CartArea(this.theme, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AbsorbPointer(
//       absorbing: false,
//       child: Container(
//         width: 400,
//         decoration: BoxDecoration(
//           color: ConfigController.to.isLightTheme
//               ? theme.cardColor
//               : StaticColors.cartColor,
//           // border: Border.all(color: Colors.white),
//         ),
//         child: GetBuilder<PosController>(
//           builder: (controller) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(left: 12, top: 10),
//                   child: Wrap(
//                     crossAxisAlignment: WrapCrossAlignment.end,
//                     spacing: 26,
//                     // runSpacing: 4,
//                     children: List.generate(controller.orderTypeList.length, (
//                       index,
//                     ) {
//                       String orderType = controller.orderTypeList[index];
//                       // for item type
//                       return Visibility(
//                         child: PrimaryBtn(
//                           textColor: controller.orderType == orderType
//                               ? Colors.white
//                               : theme.textTheme.bodyLarge?.color,
//                           isOutline: true,
//                           borderColor: controller.orderType == orderType
//                               ? StaticColors.blueColor
//                               : theme.hintColor,
//                           color: controller.orderType == orderType
//                               ? StaticColors.blueColor
//                               : Colors.transparent,
//                           borderWidth: 1,
//                           onPressed: () async {
//                             if (controller.isUpdateView) return;
//                             controller.myOrder.numberOfPeople = 1;

//                             if (orderType != "DELIVERY") {
//                               controller.addressController.clear();
//                               controller.selectedLat = null;
//                               controller.selectedLon = null;
//                               controller.additionalDetailsController.clear();
//                               controller.myOrder.deliveryFee = 0;
//                             }

//                             controller.tableController.clear();
//                             controller.guestController.clear();
//                             controller.myOrder.table = "";
//                             controller.myOrder.tableName = "";
//                             controller.onChangeOrderType(orderType);
//                             // controller.orderType = orderType;
//                             // controller.update();
//                             controller.onFocusGuestName();

//                             if (orderType == "DINE_IN") {
//                               controller.onRemovePackagingCost();
//                             } else if (orderType == "DELIVERY") {
//                               controller.onAddPackagingCost();
//                               String phone =
//                                   controller.guestPhoneController.text;
//                               if (phone.isNotEmpty && phone.length == 10) {
//                                 var order = await _firstOrder(
//                                   phone,
//                                   isDelivery: true,
//                                 );
//                                 if (order != null) {
//                                   controller.addressController.text =
//                                       order.delivery?.address ?? "";
//                                   controller.additionalDetailsController.text =
//                                       order.delivery?.additionalDetails ?? "";
//                                   controller.selectedLat =
//                                       order.delivery?.latitude;
//                                   controller.selectedLon =
//                                       order.delivery?.longitude;

//                                   if (controller
//                                       .guestNameController
//                                       .text
//                                       .isEmpty) {
//                                     controller.guestNameController.text =
//                                         order.guestName;
//                                   }
//                                   controller.myOrder.deliveryFee =
//                                       order.deliveryFee;
//                                 }
//                               }
//                             } else {
//                               controller.onAddPackagingCost();
//                             }
//                             controller.calculateTotalPrice();
//                           },
//                           text: orderType.replaceAll("_", "-").toUpperCase(),
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//                 // for Dine in
//                 Padding(
//                   padding: const EdgeInsets.only(left: 12, right: 12, top: 10),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: CustomTextField(
//                           allowRegex:
//                               CommonRegexPatterns.alphanumericWithSpaceAndLength(
//                                 18,
//                               ),
//                           readOnly: controller.isGuestNameReadOnly,
//                           focusNode: controller.guestNameFocusNode,
//                           controller: controller.guestNameController,
//                           hintText: "Guest Name",
//                           onTap: () {
//                             // show keyboard
//                             // if (!controller.isUpdateView) {
//                             //   if (Preferences.customKeyboard) {
//                             //     CustomKeyboard.open(
//                             //         keyboardType: KeyboardType.alphabet,
//                             //         initialValue:
//                             //             controller.guestNameController.text,
//                             //         regExp: RegExp(r'^.{0,18}$'),
//                             //         onChange: (value) {
//                             //           controller.guestNameController.text = value;
//                             //         });
//                             //   }
//                             // }

//                             if (controller.isGuestNameReadOnly) {
//                               PopupDialog.permissionDialog(
//                                 theme,
//                                 onSubmit: () {
//                                   controller.isGuestNameReadOnly = false;
//                                   Get.back();
//                                   controller.update();
//                                   // show kewboard
//                                   if (Preferences.customKeyboard) {
//                                     AppKeyboard.open(
//                                       context,
//                                       keyboardType: KeyboardType.alphaNumeric,
//                                       controller:
//                                           controller.guestNameController,
//                                       allowRegex:
//                                           CommonRegexPatterns.alphanumericWithSpaceAndLength(
//                                             18,
//                                           ),
//                                     );
//                                   }
//                                 },
//                                 title: "Change Guest's Name?",
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: CustomTextField(
//                           keyboardType: KeyboardType.numeric,
//                           readOnly: controller.isGuestPhoneReadOnly,
//                           controller: controller.guestPhoneController,
//                           focusNode: controller.guestPhoneFocusNode,
//                           hintText: "Phone Number",
//                           allowRegex: CommonRegexPatterns.digitsOnlyWithLength(
//                             10,
//                           ),
//                           onChange: (value) async {
//                             if (value.length == 10 &&
//                                 controller.isUpdateView == false &&
//                                 controller.orderType == 'DELIVERY') {
//                               var order = await _firstOrder(
//                                 value,
//                                 isDelivery: true,
//                               );
//                               if (order != null) {
//                                 controller.addressController.text =
//                                     order.delivery?.address ?? "";
//                                 controller.additionalDetailsController.text =
//                                     order.delivery?.additionalDetails ?? "";
//                                 controller.selectedLat =
//                                     order.delivery?.latitude;
//                                 controller.selectedLon =
//                                     order.delivery?.longitude;
//                                 if (controller
//                                     .guestNameController
//                                     .text
//                                     .isEmpty) {
//                                   controller.guestNameController.text =
//                                       order.guestName;
//                                 }
//                                 controller.myOrder.deliveryFee =
//                                     order.deliveryFee;
//                                 controller.calculateTotalPrice();
//                               }
//                             }
//                           },
//                           onKeyboardChang: (value) async {
//                             if (value.length == 10 &&
//                                 controller.isUpdateView == false &&
//                                 controller.orderType == 'DELIVERY') {
//                               var order = await _firstOrder(
//                                 value,
//                                 isDelivery: true,
//                               );
//                               if (order != null) {
//                                 controller.addressController.text =
//                                     order.delivery?.address ?? "";
//                                 controller.additionalDetailsController.text =
//                                     order.delivery?.additionalDetails ?? "";
//                                 controller.selectedLat =
//                                     order.delivery?.latitude;
//                                 controller.selectedLon =
//                                     order.delivery?.longitude;
//                                 if (controller
//                                     .guestNameController
//                                     .text
//                                     .isEmpty) {
//                                   controller.guestNameController.text =
//                                       order.guestName;
//                                 }
//                                 controller.myOrder.deliveryFee =
//                                     order.deliveryFee;
//                                 controller.calculateTotalPrice();
//                               }
//                             }
//                           },
//                           // onKeyboardChang: (value) async {
//                           //   if (value.length == 10) {
//                           //     final hasUser = await _isUserAvailable(value);
//                           //     if (hasUser) {
//                           //       OrderModel? order = await showOrderSearchDialog(
//                           //         context,
//                           //         search: value,
//                           //       );
//                           //       if (order != null) {
//                           //         PosController.to.repeatOrder(order);
//                           //       }
//                           //     }
//                           //   }
//                           // },
//                           // onChange: (value) {
//                           //   print("ZZZ $value");
//                           // },
//                           // onKeyboardChang: (value) async {
//                           //   print("XXX $value");
//                           // },
//                           // keyboardType: TextInputType.number,
//                           // inputFormatters: [
//                           //   FilteringTextInputFormatter.digitsOnly,
//                           //   LengthLimitingTextInputFormatter(10),
//                           //   // NumberRangeInputFormatter(1, 25),
//                           // ],
//                           onTap: () {
//                             if (controller.isGuestPhoneReadOnly) {
//                               PopupDialog.permissionDialog(
//                                 theme,
//                                 onSubmit: () {
//                                   controller.isGuestPhoneReadOnly = false;
//                                   Get.back();
//                                   controller.update();
//                                   if (Preferences.customKeyboard) {
//                                     AppKeyboard.open(
//                                       context,
//                                       keyboardType: KeyboardType.numeric,
//                                       controller:
//                                           controller.guestPhoneController,
//                                       allowRegex:
//                                           CommonRegexPatterns.digitsOnlyWithLength(
//                                             10,
//                                           ),
//                                     );
//                                   }
//                                 },
//                                 title: "Change Phone Number?",
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 //for dine-in
//                 Visibility(
//                   visible: controller.orderType == "DINE_IN",
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 12, right: 12),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: CustomTextField(
//                             readOnly: true,
//                             focusNode: controller.tableFocusNode,
//                             controller: controller.tableController,
//                             hintText: "Table / Bar",
//                             prefixText:
//                                 controller.tableController.text.isNotEmpty
//                                 ? "Table: "
//                                 : null,
//                             onTap: () {
//                               // if (controller.isUpdateView) {
//                               //   PopupDialog.permissionDialog(
//                               //     theme,
//                               //     onSubmit: () {
//                               //       controller.isTableReadOnly = false;
//                               //       Get.back();
//                               //       _showTableDialog(isUpdateView: true);
//                               //     },
//                               //     title: "Change Table?",
//                               //   );
//                               // } else {
//                               //   _showTableDialog(isUpdateView: false);
//                               // }
//                               if (controller.isUpdateView) {
//                                 PopupDialog.permissionDialog(
//                                   theme,
//                                   onSubmit: () {
//                                     controller.isTableReadOnly = false;
//                                     Get.back();
//                                     DineInController.to.getTableCategories();
//                                     PopupDialog.customDialog(
//                                       width: Get.width * 0.8,
//                                       height: Get.height * .85,
//                                       child: const TableBody(
//                                         isScrollable: true,
//                                         isPOSPage: true,
//                                         isUpdateView: true,
//                                       ),
//                                     );
//                                   },
//                                   title: "Change Table?",
//                                 );
//                               } else {
//                                 DineInController.to.getTableCategories();
//                                 PopupDialog.customDialog(
//                                   width: Get.width * 0.8,
//                                   height: Get.height * .85,
//                                   child: const TableBody(
//                                     isScrollable: true,
//                                     isPOSPage: true,
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: CustomTextField(
//                             readOnly: controller.isGuestReadOnly,
//                             keyboardType: KeyboardType.numeric,
//                             // readOnly: true,
//                             controller: controller.guestController,
//                             allowRegex:
//                                 CommonRegexPatterns.digitsOnlyWithLength(2),
//                             focusNode: controller.guestFocusNode,

//                             hintText: "No. of Guests ",
//                             prefixText:
//                                 controller.guestController.text.isNotEmpty
//                                 ? "Guest: "
//                                 : null,

//                             // keyboardType: TextInputType.number,
//                             onTap: () {
//                               if (controller.isGuestReadOnly) {
//                                 PopupDialog.permissionDialog(
//                                   theme,
//                                   onSubmit: () {
//                                     controller.isGuestReadOnly = false;
//                                     Get.back();
//                                     // custom keyboard
//                                     if (Preferences.customKeyboard) {
//                                       AppKeyboard.open(
//                                         context,
//                                         keyboardType: KeyboardType.numeric,
//                                         controller: controller.guestController,
//                                         allowRegex:
//                                             CommonRegexPatterns.digitsOnlyWithLength(
//                                               2,
//                                             ),
//                                       );
//                                     }

//                                     // controller.update();
//                                   },
//                                   title: "Change no. of Guests?",
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 //for DELIVERY
//                 Visibility(
//                   visible: controller.orderType == "DELIVERY",
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                       left: 12,
//                       right: 12,
//                       bottom: 12,
//                     ),
//                     child: CustomTextField(
//                       controller: controller.addressController,
//                       hintText: "Delivery Address",
//                       focusNode: controller.addressFocusNode,
//                       readOnly: true,
//                       maxLines: 2,
//                       onTap: () => WoltModalSheet.show(
//                         context: context,
//                         modalTypeBuilder: (_) => LeftSideSheetType(),
//                         pageListBuilder: (context) => [
//                           addressDialog(
//                             context,
//                             theme,
//                             controller.addressController.text,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 Visibility(
//                   visible:
//                       controller.selectedLat != null &&
//                       controller.selectedLon != null &&
//                       controller.orderType == "DELIVERY",
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                       left: 12,
//                       right: 12,
//                       bottom: 12,
//                     ),
//                     child: CustomTextField(
//                       controller: controller.additionalDetailsController,
//                       focusNode: controller.additionalDetailsFocusNode,
//                       allowRegex:
//                           CommonRegexPatterns.alphanumericWithSpaceAndLength(
//                             200,
//                           ),
//                       hintText:
//                           "Additional Delivery Info. (e.g. Floor No., Unit No., Buzzer Code)",
//                       maxLines: 2,
//                     ),
//                   ),
//                 ),
//                 //for take out
//                 Visibility(
//                   visible:
//                       controller.orderType == "TAKEOUT" ||
//                       controller.orderType == "DELIVERY",
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 12, right: 12),
//                     child: CustomTextField(
//                       controller: controller.notesController,
//                       focusNode: controller.notesFocusNode,
//                       hintText: "Order Notes (Optional)",
//                       maxLines: 1,
//                       allowRegex:
//                           CommonRegexPatterns.alphanumericWithSpaceAndLength(
//                             200,
//                           ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     controller: controller.cartListScrollController,
//                     shrinkWrap: true,
//                     itemCount: controller.myOrder.carts.length,
//                     itemBuilder: (context, index) {
//                       var data = controller.myOrder.carts[index];
//                       return CartItem(
//                         itemIndex: index,
//                         id: data.id,
//                         weight: data.weight,
//                         isUpdated: data.isUpdated,
//                         title: data.isCustomProduct
//                             ? "${data.name} (CUSTOM)"
//                             : data.name,
//                         amount: data.price,
//                         quantity: data.quantity,
//                         options: data.variationOptions,
//                         modifiers: data.modifiers,
//                         discount: data.discount,
//                         note: data.kitchenNote,
//                         onRemove: () {
//                           controller.clearModifier();
//                           controller.onRemoveCartItemWithIndex(index);
//                         },
//                         onTap: () {
//                           controller.cartId = data.id;
//                           //eng

//                           controller.onChangeSelectedItemList(data.id);
//                           controller.update();
//                           if (controller.selectedItemList.isEmpty) {
//                             return;
//                           }
//                           String firstCartId =
//                               controller.selectedItemList.first;

//                           CartModel cart = controller.myOrder.carts.firstWhere(
//                             (c) => c.id == firstCartId,
//                             orElse: () => throw Exception(
//                               "Cart not found for ID: $firstCartId",
//                             ),
//                           );
//                           //  print("Selected Cart IDs: ${data.id}");
//                           controller.selectedModifiers.assignAll(
//                             cart.modifiers,
//                           );
//                         },
//                         onDoubleTap: () {
//                           // controller.toggleAllSelectedItem();
//                         },
//                         onLongPress: () {
//                           // for variation

//                           // controller.toggleAllSelectedItem();
//                           // if (controller.myOrder.carts.length ==
//                           //     controller.selectedItemList.length) {
//                           //   controller.toggleAllSelectedItem();
//                           //   Future.delayed(const Duration(milliseconds: 100), () {
//                           //     controller
//                           //         .onChangeSelectedItemList(index.toString());
//                           //   });
//                           // } else {
//                           //   controller.toggleAllSelectedItem();
//                           //   // controller.onChangeSelectedItemList(index.toString());
//                           // }

//                           // check option

//                           // if (data.variationOptions.isEmpty) {
//                           //   return;
//                           // }
//                           // if (controller.isUpdateView) {
//                           //   return;
//                           // }
//                           // if (data.variationOptions.isEmpty) {
//                           //   return;
//                           // }

//                           controller.cartId = data.id;
//                           controller.onChangeSelectedItemList(
//                             data.id,
//                             isLongPress: true,
//                           );
//                           controller.update();
//                           if (controller.selectedItemList.isEmpty) {
//                             return;
//                           }
//                           String firstCartId =
//                               controller.selectedItemList.first;

//                           CartModel cart = controller.myOrder.carts.firstWhere(
//                             (c) => c.id == firstCartId,
//                             orElse: () => throw Exception(
//                               "Cart not found for ID: $firstCartId",
//                             ),
//                           );
//                           controller.selectedModifiers.assignAll(
//                             cart.modifiers,
//                           );
//                           // new option
//                           ProductModel item = PosController.to.mainProductList
//                               .where((p) => p.id == data.itemId)
//                               .first;
//                           if (item.variations.isEmpty) {
//                             return;
//                           }

//                           try {
//                             PopupDialog.customDialog(
//                               hasScroll: false,
//                               width: MediaQuery.sizeOf(context).width * 0.8,
//                               height: MediaQuery.sizeOf(context).height * 0.85,
//                               child: Variation(
//                                 activeOptions: data.variationOptions,
//                                 initialQuantity: data.quantity,
//                                 item: item.copyWith(
//                                   variations: item.variations
//                                       .where((v) => v.posVariationOn == true)
//                                       .toList(),
//                                 ),
//                               ),
//                             );
//                           } catch (e, st) {
//                             if (kDebugMode) {
//                               kLogger.e(
//                                 "Error finding product for variation: $e",
//                               );
//                               kLogger.e(
//                                 "Error finding product for variation: $st",
//                               );
//                             }
//                           }
//                         },
//                       ).marginOnly(bottom: 12);
//                     },
//                   ),
//                 ),

//                 _modifiers(
//                   theme,
//                   PosController.to.myOrder.discountReason,
//                   title: "Discount Reason: ",
//                   isItalic: true,
//                   maxLines: 5,
//                 ),
//                 const Divider(thickness: .5, height: 1),
//                 SizedBox(height: 5),
//                 _row(
//                   theme,
//                   title: "Subtotal : ",
//                   value: "\$${controller.myOrder.subTotal.toStringAsFixed(2)}",
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.totalDiscount > 0,
//                   child: _row(
//                     theme,
//                     title: "Discount : ",
//                     value:
//                         "(-)  \$${controller.myOrder.totalDiscount.toStringAsFixed(2)}",
//                     child: controller.myOrder.payment != null
//                         ? const SizedBox()
//                         : InkWell(
//                             child: Container(
//                               margin: const EdgeInsets.only(left: 4),
//                               padding: const EdgeInsets.all(4.0),
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   width: 1,
//                                   color:
//                                       theme.textTheme.labelLarge?.color ??
//                                       Colors.white,
//                                 ),
//                               ),
//                               child: const Icon(
//                                 Icons.delete,
//                                 color: StaticColors.redColor,
//                                 size: 20,
//                               ),
//                             ),
//                             onTap: () {
//                               PosController.to.deleteDiscount();
//                             },
//                           ),
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.totalGst > 0,
//                   child: _row(
//                     theme,
//                     title:
//                         "GST ${BaseController.to.restaurantDetails?.businessProfile.gstNumber ?? 0}% : ",
//                     value:
//                         "\$${controller.myOrder.totalGst.toStringAsFixed(2)}",
//                   ),
//                 ),

//                 Visibility(
//                   visible: controller.myOrder.totalPst > 0,
//                   child: _row(
//                     theme,
//                     title:
//                         "PST ${BaseController.to.restaurantDetails?.businessProfile.pstNumber ?? 0}% : ",
//                     value:
//                         "\$${controller.myOrder.totalPst.toStringAsFixed(2)}",
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.totalPst2 > 0,
//                   child: _row(
//                     theme,
//                     title:
//                         "PST2 ${BaseController.to.restaurantDetails?.businessProfile.pstNumber2 ?? 0}% : ",
//                     value:
//                         "\$${controller.myOrder.totalPst2.toStringAsFixed(2)}",
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.orderType == "DINE_IN",
//                   child: _row(
//                     theme,
//                     title:
//                         "Gratuity ${controller.myOrder.gratuityPercentage ?? (BaseController.to.restaurantDetails?.businessProfile.gratuity ?? 0)}% : ",
//                     value:
//                         "\$${controller.myOrder.totalGratuity.toStringAsFixed(2)}",
//                     child: controller.myOrder.paymentStatus == "PAID"
//                         ? const SizedBox.shrink()
//                         : Row(
//                             children: [
//                               Container(
//                                 margin: const EdgeInsets.only(left: 4),
//                                 padding: const EdgeInsets.all(4.0),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     width: 1,
//                                     color:
//                                         theme.textTheme.labelLarge?.color ??
//                                         Colors.white,
//                                   ),
//                                 ),
//                                 child: InkWell(
//                                   child: const Icon(
//                                     Icons.edit_square,
//                                     color: StaticColors.greenColor,
//                                   ),
//                                   onTap: () {
//                                     PopupDialog.permissionDialog(
//                                       title: "Edit Gratuity?",
//                                       theme,
//                                       onSubmit: () async {
//                                         Get.back();
//                                         PopupDialog.customDialog(
//                                           width: 400,
//                                           child: EditGratuity(
//                                             isNewOrder:
//                                                 !controller.isUpdateView,
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ),
//                               SizedBox(width: 34),
//                               Visibility(
//                                 visible:
//                                     controller.myOrder.gratuityPercentage != 0,
//                                 child: Container(
//                                   margin: const EdgeInsets.only(left: 4),
//                                   padding: const EdgeInsets.all(4.0),
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       width: 1,
//                                       color:
//                                           theme.textTheme.labelLarge?.color ??
//                                           Colors.white,
//                                     ),
//                                   ),
//                                   child: InkWell(
//                                     child: const Icon(
//                                       Icons.delete,
//                                       color: StaticColors.redColor,
//                                     ),
//                                     onTap: () {
//                                       PopupDialog.permissionDialog(
//                                         title: "Delete Gratuity?",
//                                         theme,
//                                         onSubmit: () async {
//                                           controller.onDeleteGratuity();
//                                           Get.back();

//                                           if (controller.isUpdateView) {
//                                             PopupDialog.showLoadingDialog();
//                                             await PosController.to
//                                                 .onUpdateOrder(
//                                                   PosController.to.myOrder.id,
//                                                 );
//                                             PopupDialog.closeLoadingDialog();
//                                           }
//                                         },
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.tip > 0,
//                   child: _row(
//                     theme,
//                     title: "Tip : ",
//                     value: "\$${controller.myOrder.tip.toStringAsFixed(2)}",
//                   ),
//                 ),

//                 Visibility(
//                   visible:
//                       controller.myOrder.packagingCost > 0 &&
//                       controller.myOrder.carts.isNotEmpty,
//                   child: _row(
//                     theme,
//                     title:
//                         "${(BaseController.to.restaurantDetails?.restaurant.packagingCost.title) ?? ""}: ",
//                     value:
//                         "\$${controller.myOrder.packagingCost.toStringAsFixed(2)}",
//                     child: controller.myOrder.paymentStatus == "PAID"
//                         ? const SizedBox.shrink()
//                         : Container(
//                             margin: const EdgeInsets.only(left: 4),
//                             padding: const EdgeInsets.all(4.0),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 width: 1,
//                                 color:
//                                     theme.textTheme.labelLarge?.color ??
//                                     Colors.white,
//                               ),
//                             ),
//                             child: InkWell(
//                               child: const Icon(
//                                 Icons.delete,
//                                 color: StaticColors.redColor,
//                               ),
//                               onTap: () {
//                                 controller.onRemovePackagingCost();
//                               },
//                             ),
//                           ),
//                   ),
//                 ),
//                 // Visibility(
//                 //   visible: controller.orderType == "DELIVERY",
//                 //   child: DeliveryFeeRow(
//                 //     deliveryFee: controller.myOrder.deliveryFee,
//                 //   ),
//                 // ),
//                 Visibility(
//                   visible: controller.myOrder.orderType == "DELIVERY",
//                   child: _row(
//                     theme,
//                     title: "Delivery Fee: ",
//                     value:
//                         "\$${controller.myOrder.deliveryFee.toStringAsFixed(2)}",
//                     child: controller.myOrder.paymentStatus == "PAID"
//                         ? const SizedBox.shrink()
//                         : Row(
//                             children: [
//                               Container(
//                                 margin: const EdgeInsets.only(left: 4),
//                                 padding: const EdgeInsets.all(4.0),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     width: 1,
//                                     color:
//                                         theme.textTheme.labelLarge?.color ??
//                                         Colors.white,
//                                   ),
//                                 ),
//                                 child: InkWell(
//                                   child: const Icon(
//                                     Icons.edit_square,
//                                     color: StaticColors.greenColor,
//                                   ),
//                                   onTap: () {
//                                     PopupDialog.permissionDialog(
//                                       title: "Edit Delivery Fee?",
//                                       theme,
//                                       onSubmit: () async {
//                                         Get.back();
//                                         PopupDialog.customDialog(
//                                           width: 400,
//                                           child: EditDeliveryFee(
//                                             isNewOrder:
//                                                 !controller.isUpdateView,
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ),
//                               SizedBox(width: 34),
//                               Visibility(
//                                 visible: controller.myOrder.deliveryFee != 0,
//                                 child: Container(
//                                   margin: const EdgeInsets.only(left: 4),
//                                   padding: const EdgeInsets.all(4.0),
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       width: 1,
//                                       color:
//                                           theme.textTheme.labelLarge?.color ??
//                                           Colors.white,
//                                     ),
//                                   ),
//                                   child: InkWell(
//                                     child: const Icon(
//                                       Icons.delete,
//                                       color: StaticColors.redColor,
//                                     ),
//                                     onTap: () {
//                                       PopupDialog.permissionDialog(
//                                         title: "Delete Delivery Fee?",
//                                         theme,
//                                         onSubmit: () async {
//                                           PosController.to
//                                               .onDeleteDeliveryFee();

//                                           Get.back();

//                                           if (controller.isUpdateView) {
//                                             PopupDialog.showLoadingDialog();
//                                             await PosController.to
//                                                 .onUpdateOrder(
//                                                   PosController.to.myOrder.id,
//                                                 );
//                                             PopupDialog.closeLoadingDialog();
//                                           }
//                                         },
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),

//                 // const Divider(
//                 //   thickness: .5,
//                 // ),8
//                 Visibility(
//                   visible: controller.myOrder.maintenanceFee > 0,
//                   child: _row(
//                     theme,
//                     title: "Service Fee : ",
//                     value:
//                         "\$${controller.myOrder.maintenanceFee.toStringAsFixed(2)}",
//                   ),
//                 ),

//                 _row(
//                   theme,
//                   fontSize: 20,
//                   title: "Total : ",
//                   value:
//                       "\$ ${controller.myOrder.totalOrderAmount.toStringAsFixed(2)}",
//                 ),
//                 // order btn
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 12,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: GetBuilder<PosController>(
//                           builder: (controller) {
//                             return Tooltip(
//                               message: controller.myOrder.carts.isEmpty
//                                   ? 'No items to send order'
//                                   : "",
//                               child: PrimaryBtn(
//                                 onPressed: () async {
//                                   // print data
//                                   var myOrder = controller.myOrder
//                                       .toNonUpdate();

//                                   if (controller.isUpdateView) {
//                                     //
//                                     // if (controller.myOrder.carts.every(
//                                     //   (i) => i.isUpdated == true,
//                                     // )) {
//                                     //   PopupDialog.showErrorMessage(
//                                     //     duration: Duration(seconds: 2),
//                                     //     "Add Items before updating Order",
//                                     //   );
//                                     //   return;
//                                     // }

//                                     // update order
//                                     controller.myOrder.splitAmounts = [];
//                                     controller.myOrder.splitOrders = [];
//                                     controller.myOrder.splitOrderCarts = [];
//                                     PopupDialog.showLoadingDialog();
//                                     var isUpdated = await controller
//                                         .onUpdateOrder(
//                                           controller.myOrder.id,
//                                           isClearList: true,
//                                         );
//                                     PopupDialog.closeLoadingDialog();

//                                     if (isUpdated) {
//                                       PosController.to.isUpdateView = false;
//                                       controller.update();
//                                       //for printer
//                                       kitchenPrint(myOrder);

//                                       DataUpdateHelper.getDataByCheckType();
//                                       PosController.to.onFocusGuestName();
//                                     }
//                                   } else {
//                                     // for plaseOrder

//                                     await controller.onPlaseOrder();
//                                   }
//                                 },
//                                 textMaxSize: 26,
//                                 textMinSize: 24,
//                                 height: 70,
//                                 color: StaticColors.blueColor,
//                                 textColor: Colors.white,
//                                 text: controller.isUpdateView
//                                     ? "Update Order".toUpperCase()
//                                     : 'Send'.toUpperCase(),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // ignore: unused_element
// void _showTableDialog({required bool isUpdateView}) {
//   // DineInController.to.getTableCategories();
//   // TableMappingController.to.getMappingALlTables();

//   PopupDialog.customDialog(
//     width: Get.width * 0.80,
//     child: SizedBox(
//       width: Get.width * 0.80,
//       height: Get.height * 0.80,
//       child: TableManagmentView(
//         isScrollable: false,
//         isPOSPage: true,
//         isUpdateView: isUpdateView,
//       ),
//     ),
//   );
// }

// Widget _row(
//   ThemeData theme, {
//   double? fontSize,
//   FontWeight? fontWeight,
//   Widget? child,
//   required String title,
//   required String value,
// }) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Text(
//               title,
//               style: theme.textTheme.titleSmall?.copyWith(
//                 fontSize: fontSize ?? 16,
//                 fontWeight: fontWeight ?? FontWeight.w700,
//               ),
//             ),
//             SizedBox(child: child),
//           ],
//         ),
//         Text(
//           value,
//           style: theme.textTheme.titleSmall?.copyWith(
//             fontSize: fontSize ?? 16,
//             fontWeight: fontWeight ?? FontWeight.w700,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _modifiers(
//   ThemeData theme,
//   String value, {
//   int maxLines = 2,
//   bool isItalic = false,
//   String? title,
// }) {
//   return Visibility(
//     visible: value.contains(':') ? value.length > 6 : value != '',
//     child: Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
//       child: Text.rich(
//         maxLines: maxLines,
//         style: theme.textTheme.labelSmall?.copyWith(
//           fontWeight: FontWeight.bold,
//           fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
//         ),
//         TextSpan(
//           text: title,
//           children: [
//             TextSpan(
//               text: value.trim().toUpperCase(),
//               style: theme.textTheme.bodySmall?.copyWith(
//                 fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
// // import 'package:yogo_pos/app/helper/data_update_helper.dart';
// // import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
// // import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/kitchen_print.dart';
// // import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
// // import 'package:yogo_pos/app/modules/pos/dine-in/widgets/table_body.dart';
// // import 'package:yogo_pos/app/modules/pos/dine-in/widgets/table_mapping_managment_view.dart';
// // import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
// // import 'package:yogo_pos/app/modules/pos/order/models/product_model.dart';
// // import 'package:yogo_pos/app/modules/pos/order/widgets/cart_item.dart';
// // import 'package:yogo_pos/app/modules/pos/order/widgets/delivery_fee_row.dart';
// // import 'package:yogo_pos/app/modules/pos/order/widgets/dialogs/address_dialog.dart';
// // import 'package:yogo_pos/app/modules/pos/order/widgets/variation.dart';
// // import 'package:yogo_pos/app/services/base/preferences.dart';
// // import 'package:yogo_pos/app/services/controller/base_controller.dart';
// // import 'package:yogo_pos/app/services/controller/config_controller.dart';
// // import 'package:yogo_pos/app/utils/extension/order_extention.dart';
// // import 'package:yogo_pos/app/utils/logger.dart';
// // import 'package:yogo_pos/app/utils/my_reg_exp.dart';
// // import 'package:yogo_pos/app/utils/static_colors.dart';
// // import 'package:yogo_pos/app/widgets/app_keyboard.dart';
// // import 'package:yogo_pos/app/widgets/custom_btn.dart';
// // import 'package:yogo_pos/app/widgets/custom_textfield.dart';
// // import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

// // // ─── Swipeable Cart Item (reveals tappable buttons, 100px max) ───────────────

// // class _SwipeableCartItem extends StatefulWidget {
// //   final Widget child;
// //   final VoidCallback? onDelete;
// //   final VoidCallback? onRepeat;
// //   const _SwipeableCartItem({
// //     required this.child,
// //     this.onDelete,
// //     this.onRepeat,
// //   });

// //   @override
// //   State<_SwipeableCartItem> createState() => _SwipeableCartItemState();
// // }

// // class _SwipeableCartItemState extends State<_SwipeableCartItem>
// //     with SingleTickerProviderStateMixin {
// //   double _dragExtent = 0;
// //   late final AnimationController _animController = AnimationController(
// //       vsync: this, duration: const Duration(milliseconds: 200));
// //   late Animation<double> _snapAnimation;

// //   static const double _maxSlide = 100;
// //   // Snap open if dragged past this threshold
// //   static const double _snapThreshold = 40;

// //   @override
// //   void dispose() {
// //     _animController.dispose();
// //     super.dispose();
// //   }

// //   void _animateTo(double target) {
// //     _snapAnimation = Tween<double>(begin: _dragExtent, end: target).animate(
// //       CurvedAnimation(parent: _animController, curve: Curves.easeOut),
// //     )..addListener(() {
// //         setState(() => _dragExtent = _snapAnimation.value);
// //       });
// //     _animController.forward(from: 0);
// //   }

// //   void _onDragUpdate(DragUpdateDetails details) {
// //     setState(() {
// //       _dragExtent =
// //           (_dragExtent + details.delta.dx).clamp(-_maxSlide, _maxSlide);
// //     });
// //   }

// //   void _onDragEnd(DragEndDetails details) {
// //     if (_dragExtent > _snapThreshold) {
// //       // Snap open to right (show Repeat)
// //       _animateTo(_maxSlide);
// //     } else if (_dragExtent < -_snapThreshold) {
// //       // Snap open to left (show Delete)
// //       _animateTo(-_maxSlide);
// //     } else {
// //       // Snap closed
// //       _animateTo(0);
// //     }
// //   }

// //   void _close() => _animateTo(0);

// //   @override
// //   Widget build(BuildContext context) {
// //     return ClipRect(
// //       child: Stack(
// //         children: [
// //           // ── Background buttons ──
// //           Positioned.fill(
// //             child: Row(
// //               children: [
// //                 // Repeat button (right swipe reveals on left side)
// //                 if (_dragExtent > 0)
// //                   GestureDetector(
// //                     onTap: () {
// //                       _close();
// //                       widget.onRepeat?.call();
// //                     },
// //                     child: Container(
// //                       width: _dragExtent,
// //                       alignment: Alignment.center,
// //                       decoration: BoxDecoration(
// //                         color: Colors.green,
// //                         borderRadius: BorderRadius.circular(4),
// //                       ),
// //                       child: _dragExtent > 50
// //                           ? const Column(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Icon(Icons.repeat_rounded,
// //                                     color: Colors.white, size: 22),
// //                                 SizedBox(height: 4),
// //                                 Text("Repeat",
// //                                     style: TextStyle(
// //                                         color: Colors.white,
// //                                         fontSize: 12,
// //                                         fontWeight: FontWeight.w700)),
// //                               ],
// //                             )
// //                           : const Icon(Icons.repeat_rounded,
// //                               color: Colors.white, size: 20),
// //                     ),
// //                   ),
// //                 const Spacer(),
// //                 // Delete button (left swipe reveals on right side)
// //                 if (_dragExtent < 0)
// //                   GestureDetector(
// //                     onTap: () {
// //                       _close();
// //                       widget.onDelete?.call();
// //                     },
// //                     child: Container(
// //                       width: _dragExtent.abs(),
// //                       alignment: Alignment.center,
// //                       decoration: BoxDecoration(
// //                         color: StaticColors.redColor,
// //                         borderRadius: BorderRadius.circular(4),
// //                       ),
// //                       child: _dragExtent.abs() > 50
// //                           ? const Column(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Icon(Icons.delete_rounded,
// //                                     color: Colors.white, size: 22),
// //                                 SizedBox(height: 4),
// //                                 Text("Delete",
// //                                     style: TextStyle(
// //                                         color: Colors.white,
// //                                         fontSize: 12,
// //                                         fontWeight: FontWeight.w700)),
// //                               ],
// //                             )
// //                           : const Icon(Icons.delete_rounded,
// //                               color: Colors.white, size: 20),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //           // ── Foreground (CartItem) ──
// //           GestureDetector(
// //             onHorizontalDragUpdate: _onDragUpdate,
// //             onHorizontalDragEnd: _onDragEnd,
// //             child: Transform.translate(
// //               offset: Offset(_dragExtent, 0),
// //               child: widget.child,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ─── Cart Area ───────────────────────────────────────────────────────────────

// // class CartArea extends GetView<PosController> {
// //   final ThemeData theme;
// //   const CartArea(this.theme, {super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return AbsorbPointer(
// //       absorbing: false,
// //       child: Container(
// //         width: 350,
// //         decoration: BoxDecoration(
// //           color: ConfigController.to.isLightTheme
// //               ? theme.cardColor
// //               : StaticColors.cartColor,
// //         ),
// //         child: GetBuilder<PosController>(builder: (controller) {
// //           return Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Padding(
// //                 padding: const EdgeInsets.only(left: 12, top: 10),
// //                 child: Wrap(
// //                   crossAxisAlignment: WrapCrossAlignment.end,
// //                   spacing: 26,
// //                   children:
// //                       List.generate(controller.orderTypeList.length, (index) {
// //                     String orderType = controller.orderTypeList[index];
// //                     return Visibility(
// //                       child: PrimaryBtn(
// //                           textColor: controller.orderType == orderType
// //                               ? Colors.white
// //                               : theme.textTheme.bodyLarge?.color,
// //                           isOutline: true,
// //                           borderColor: controller.orderType == orderType
// //                               ? StaticColors.blueColor
// //                               : theme.hintColor,
// //                           color: controller.orderType == orderType
// //                               ? StaticColors.blueColor
// //                               : Colors.transparent,
// //                           borderWidth: 1,
// //                           onPressed: () {
// //                             controller.myOrder.numberOfPeople = 1;
// //                             if (!controller.isUpdateView) {
// //                               if (orderType != "DELIVERY") {
// //                                 controller.addressController.clear();
// //                                 controller.selectedLat = null;
// //                                 controller.selectedLon = null;
// //                                 controller.additionalDetailsController.clear();
// //                                 controller.myOrder.deliveryFee = 0;
// //                               }
// //                               controller.tableController.clear();
// //                               controller.guestController.clear();
// //                               controller.myOrder.table = "";
// //                               controller.myOrder.tableName = "";
// //                               controller.onChangeOrderType(orderType);
// //                               controller.onFocusGuestName();
// //                             }
// //                             if (orderType == "DINE_IN") {
// //                               controller.onRemovePackagingCost();
// //                             } else {
// //                               controller.onAddPackagingCost();
// //                             }
// //                           },
// //                           text: orderType.replaceAll("_", "-").toUpperCase()),
// //                     );
// //                   }),
// //                 ),
// //               ),
// //               Padding(
// //                 padding: const EdgeInsets.only(left: 12, right: 12, top: 10),
// //                 child: Row(
// //                   children: [
// //                     Expanded(
// //                         child: CustomTextField(
// //                       allowRegex:
// //                           CommonRegexPatterns.alphanumericWithSpaceAndLength(
// //                               18),
// //                       readOnly: controller.isGuestNameReadOnly,
// //                       focusNode: controller.guestNameFocusNode,
// //                       controller: controller.guestNameController,
// //                       hintText: "Guest Name",
// //                       onTap: () {
// //                         if (controller.isGuestNameReadOnly) {
// //                           PopupDialog.permissionDialog(theme, onSubmit: () {
// //                             controller.isGuestNameReadOnly = false;
// //                             Get.back();
// //                             controller.update();
// //                             if (Preferences.customKeyboard) {
// //                               AppKeyboard.open(
// //                                 context,
// //                                 keyboardType: KeyboardType.alphaNumeric,
// //                                 controller: controller.guestNameController,
// //                                 allowRegex: CommonRegexPatterns
// //                                     .alphanumericWithSpaceAndLength(18),
// //                               );
// //                             }
// //                           }, title: "Change Guest's Name?");
// //                         }
// //                       },
// //                     )),
// //                     const SizedBox(width: 12),
// //                     Expanded(
// //                       child: CustomTextField(
// //                         keyboardType: KeyboardType.numeric,
// //                         readOnly: controller.isGuestPhoneReadOnly,
// //                         controller: controller.guestPhoneController,
// //                         focusNode: controller.guestPhoneFocusNode,
// //                         hintText: "Phone Number",
// //                         allowRegex:
// //                             CommonRegexPatterns.digitsOnlyWithLength(10),
// //                         onTap: () {
// //                           if (controller.isGuestPhoneReadOnly) {
// //                             PopupDialog.permissionDialog(theme, onSubmit: () {
// //                               controller.isGuestPhoneReadOnly = false;
// //                               Get.back();
// //                               controller.update();
// //                               if (Preferences.customKeyboard) {
// //                                 AppKeyboard.open(
// //                                   context,
// //                                   keyboardType: KeyboardType.numeric,
// //                                   controller: controller.guestPhoneController,
// //                                   allowRegex:
// //                                       CommonRegexPatterns.digitsOnlyWithLength(
// //                                           10),
// //                                 );
// //                               }
// //                             }, title: "Change Phone Number?");
// //                           }
// //                         },
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const SizedBox(height: 10),
// //               Visibility(
// //                 visible: controller.orderType == "DINE_IN",
// //                 child: Padding(
// //                   padding: const EdgeInsets.only(left: 12, right: 12),
// //                   child: Row(
// //                     children: [
// //                       Expanded(
// //                           child: CustomTextField(
// //                         readOnly: true,
// //                         focusNode: controller.tableFocusNode,
// //                         controller: controller.tableController,
// //                         hintText: "Table / Bar",
// //                         prefixText: controller.tableController.text.isNotEmpty
// //                             ? "Table: "
// //                             : null,
// //                         onTap: () {
// //                           if (controller.isUpdateView) {
// //                             PopupDialog.permissionDialog(theme, onSubmit: () {
// //                               controller.isTableReadOnly = false;
// //                               Get.back();
// //                               DineInController.to.getTableCategories();
// //                               PopupDialog.customDialog(
// //                                   width: Get.width * 0.8,
// //                                   height: Get.height * .85,
// //                                   child: const TableBody(
// //                                     isScrollable: true,
// //                                     isPOSPage: true,
// //                                     isUpdateView: true,
// //                                   ));
// //                             }, title: "Change Table?");
// //                           } else {
// //                             DineInController.to.getTableCategories();
// //                             PopupDialog.customDialog(
// //                                 width: Get.width * 0.8,
// //                                 height: Get.height * .85,
// //                                 child: const TableBody(
// //                                   isScrollable: true,
// //                                   isPOSPage: true,
// //                                 ));
// //                           }
// //                         },
// //                       )),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: CustomTextField(
// //                           readOnly: controller.isGuestReadOnly,
// //                           keyboardType: KeyboardType.numeric,
// //                           controller: controller.guestController,
// //                           allowRegex:
// //                               CommonRegexPatterns.digitsOnlyWithLength(2),
// //                           focusNode: controller.guestFocusNode,
// //                           hintText: "No. of Guests ",
// //                           prefixText: controller.guestController.text.isNotEmpty
// //                               ? "Guest: "
// //                               : null,
// //                           onTap: () {
// //                             if (controller.isGuestReadOnly) {
// //                               PopupDialog.permissionDialog(theme, onSubmit: () {
// //                                 controller.isGuestReadOnly = false;
// //                                 Get.back();
// //                                 if (Preferences.customKeyboard) {
// //                                   AppKeyboard.open(
// //                                     context,
// //                                     keyboardType: KeyboardType.numeric,
// //                                     controller: controller.guestController,
// //                                     allowRegex: CommonRegexPatterns
// //                                         .digitsOnlyWithLength(2),
// //                                   );
// //                                 }
// //                               }, title: "Change no. of Guests?");
// //                             }
// //                           },
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //               Visibility(
// //                 visible: controller.orderType == "DELIVERY",
// //                 child: Padding(
// //                   padding:
// //                       const EdgeInsets.only(left: 12, right: 12, bottom: 12),
// //                   child: CustomTextField(
// //                     controller: controller.addressController,
// //                     hintText: "Delivery Address",
// //                     focusNode: controller.addressFocusNode,
// //                     readOnly: true,
// //                     maxLines: 2,
// //                     onTap: () => WoltModalSheet.show(
// //                       context: context,
// //                       modalTypeBuilder: (_) => LeftSideSheetType(),
// //                       pageListBuilder: (context) => [
// //                         addressDialog(
// //                             context, theme, controller.addressController.text),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               Visibility(
// //                 visible: controller.selectedLat != null &&
// //                     controller.selectedLon != null &&
// //                     controller.orderType == "DELIVERY",
// //                 child: Padding(
// //                   padding:
// //                       const EdgeInsets.only(left: 12, right: 12, bottom: 12),
// //                   child: CustomTextField(
// //                     controller: controller.additionalDetailsController,
// //                     focusNode: controller.additionalDetailsFocusNode,
// //                     allowRegex:
// //                         CommonRegexPatterns.alphanumericWithSpaceAndLength(200),
// //                     hintText:
// //                         "Additional Delivery Info. (e.g. Floor No., Unit No., Buzzer Code)",
// //                     maxLines: 2,
// //                   ),
// //                 ),
// //               ),
// //               Visibility(
// //                 visible: controller.orderType == "TAKEOUT" ||
// //                     controller.orderType == "DELIVERY",
// //                 child: Padding(
// //                   padding: const EdgeInsets.only(left: 12, right: 12),
// //                   child: CustomTextField(
// //                     controller: controller.notesController,
// //                     focusNode: controller.notesFocusNode,
// //                     hintText: "Order Notes (Optional)",
// //                     allowRegex:
// //                         CommonRegexPatterns.alphanumericWithSpaceAndLength(200),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 16),

// //               // ─── Cart List with Swipeable Actions ───
// //               Expanded(
// //                 child: ListView.separated(
// //                   controller: controller.cartListScrollController,
// //                   shrinkWrap: true,
// //                   itemCount: controller.myOrder.carts.length,
// //                   itemBuilder: (context, index) {
// //                     var data = controller.myOrder.carts[index];
// //                     return _SwipeableCartItem(
// //                       onDelete: () {
// //                         controller.clearModifier();
// //                         controller.onRemoveCartItemWithIndex(index);
// //                       },
// //                       onRepeat: () {
// //                         // controller.onRepeatCartItem(index);
// //                       },
// //                       child: CartItem(
// //                         itemIndex: index,
// //                         id: data.id,
// //                         weight: data.weight,
// //                         isUpdated: data.isUpdated,
// //                         title: data.isCustomProduct
// //                             ? "${data.name} (CUSTOM)"
// //                             : data.name,
// //                         amount: data.price,
// //                         quantity: data.quantity,
// //                         options: data.variationOptions,
// //                         modifiers: data.modifiers,
// //                         discount: data.discount,
// //                         note: data.kitchenNote,
// //                         onRemove: () {
// //                           controller.clearModifier();
// //                           controller.onRemoveCartItemWithIndex(index);
// //                         },
// //                         onTap: () {
// //                           controller.cartId = data.id;
// //                           controller.onChangeSelectedItemList(data.id);
// //                           controller.update();
// //                           if (controller.selectedItemList.isEmpty) return;
// //                           String firstCartId =
// //                               controller.selectedItemList.first;
// //                           CartModel cart = controller.myOrder.carts.firstWhere(
// //                             (c) => c.id == firstCartId,
// //                             orElse: () => throw Exception(
// //                                 "Cart not found for ID: $firstCartId"),
// //                           );
// //                           controller.selectedModifiers
// //                               .assignAll(cart.modifiers);
// //                         },
// //                         onDoubleTap: () {},
// //                         onLongPress: () {
// //                           controller.cartId = data.id;
// //                           controller.onChangeSelectedItemList(data.id,
// //                               isLongPress: true);
// //                           controller.update();
// //                           if (controller.selectedItemList.isEmpty) return;
// //                           String firstCartId =
// //                               controller.selectedItemList.first;
// //                           CartModel cart = controller.myOrder.carts.firstWhere(
// //                             (c) => c.id == firstCartId,
// //                             orElse: () => throw Exception(
// //                                 "Cart not found for ID: $firstCartId"),
// //                           );
// //                           controller.selectedModifiers
// //                               .assignAll(cart.modifiers);
// //                           ProductModel item = PosController.to.mainProductList
// //                               .where((p) => p.id == data.itemId)
// //                               .first;
// //                           if (item.variations.isEmpty) return;
// //                           try {
// //                             PopupDialog.customDialog(
// //                               hasScroll: false,
// //                               width: MediaQuery.sizeOf(context).width * 0.8,
// //                               height: MediaQuery.sizeOf(context).height * 0.85,
// //                               child: Variation(
// //                                 activeOptions: data.variationOptions,
// //                                 initialQuantity: data.quantity,
// //                                 item: item.copyWith(
// //                                   variations: item.variations
// //                                       .where((v) => v.posVariationOn == true)
// //                                       .toList(),
// //                                 ),
// //                               ),
// //                             );
// //                           } catch (e, st) {
// //                             if (kDebugMode) {
// //                               kLogger
// //                                   .e("Error finding product for variation: $e");
// //                               kLogger.e(
// //                                   "Error finding product for variation: $st");
// //                             }
// //                           }
// //                         },
// //                       ),
// //                     );
// //                   },
// //                   separatorBuilder: (context, index) =>
// //                       const SizedBox(height: 8),
// //                 ),
// //               ),

// //               _modifiers(
// //                 theme,
// //                 PosController.to.myOrder.discountReason,
// //                 title: "Discount Reason: ",
// //                 isItalic: true,
// //                 maxLines: 5,
// //               ),
// //               const Divider(thickness: .5, height: 1),
// //               const SizedBox(height: 5),
// //               _row(
// //                 theme,
// //                 title: "Subtotal : ",
// //                 value: "\$${controller.myOrder.subTotal.toStringAsFixed(2)}",
// //               ),
// //               Visibility(
// //                 visible: controller.myOrder.totalDiscount > 0,
// //                 child: _row(
// //                   theme,
// //                   title: "Discount : ",
// //                   value:
// //                       "(-)  \$${controller.myOrder.totalDiscount.toStringAsFixed(2)}",
// //                   child: controller.myOrder.payment != null
// //                       ? const SizedBox()
// //                       : InkWell(
// //                           child: Container(
// //                             margin: const EdgeInsets.only(left: 4),
// //                             padding: const EdgeInsets.all(4.0),
// //                             decoration: BoxDecoration(
// //                                 shape: BoxShape.circle,
// //                                 border: Border.all(
// //                                     width: 1,
// //                                     color: theme.textTheme.labelLarge?.color ??
// //                                         Colors.white)),
// //                             child: const Icon(Icons.delete,
// //                                 color: StaticColors.redColor, size: 20),
// //                           ),
// //                           onTap: () => PosController.to.deleteDiscount(),
// //                         ),
// //                 ),
// //               ),
// //               Visibility(
// //                 visible: controller.myOrder.totalGst > 0,
// //                 child: _row(
// //                   theme,
// //                   title:
// //                       "GST ${BaseController.to.restaurantDetails?.businessProfile.gstNumber ?? 0}% : ",
// //                   value: "\$${controller.myOrder.totalGst.toStringAsFixed(2)}",
// //                 ),
// //               ),
// //               Visibility(
// //                 visible: controller.myOrder.totalPst > 0,
// //                 child: _row(
// //                   theme,
// //                   title:
// //                       "PST ${BaseController.to.restaurantDetails?.businessProfile.pstNumber ?? 0}% : ",
// //                   value: "\$${controller.myOrder.totalPst.toStringAsFixed(2)}",
// //                 ),
// //               ),
// //               Visibility(
// //                 visible: controller.myOrder.totalPst2 > 0,
// //                 child: _row(
// //                   theme,
// //                   title:
// //                       "PST2 ${BaseController.to.restaurantDetails?.businessProfile.pstNumber2 ?? 0}% : ",
// //                   value: "\$${controller.myOrder.totalPst2.toStringAsFixed(2)}",
// //                 ),
// //               ),
// //               Visibility(
// //                 visible: controller.myOrder.totalGratuity > 0,
// //                 child: _row(
// //                   theme,
// //                   title:
// //                       "Gratuity ${BaseController.to.restaurantDetails?.businessProfile.gratuity ?? 0}% : ",
// //                   value:
// //                       "\$${controller.myOrder.totalGratuity.toStringAsFixed(2)}",
// //                 ),
// //               ),
// //               Visibility(
// //                 visible: controller.myOrder.tip > 0,
// //                 child: _row(
// //                   theme,
// //                   title: "Tip : ",
// //                   value: "\$${controller.myOrder.tip.toStringAsFixed(2)}",
// //                 ),
// //               ),
// //               Visibility(
// //                 visible: controller.myOrder.packagingCost > 0 &&
// //                     controller.myOrder.carts.isNotEmpty,
// //                 child: _row(theme,
// //                     title:
// //                         "${(BaseController.to.restaurantDetails?.restaurant.packagingCostModel.title) ?? ""}: ",
// //                     value:
// //                         "\$${controller.myOrder.packagingCost.toStringAsFixed(2)}",
// //                     child: controller.myOrder.paymentStatus == "PAID"
// //                         ? const SizedBox()
// //                         : Container(
// //                             margin: const EdgeInsets.only(left: 4),
// //                             padding: const EdgeInsets.all(4.0),
// //                             decoration: BoxDecoration(
// //                                 shape: BoxShape.circle,
// //                                 border: Border.all(
// //                                     width: 1,
// //                                     color: theme.textTheme.labelLarge?.color ??
// //                                         Colors.white)),
// //                             child: InkWell(
// //                               child: const Icon(Icons.delete,
// //                                   color: StaticColors.redColor),
// //                               onTap: () => controller.onRemovePackagingCost(),
// //                             ),
// //                           )),
// //               ),
// //               Visibility(
// //                 visible: controller.orderType == "DELIVERY",
// //                 child:
// //                     DeliveryFeeRow(deliveryFee: controller.myOrder.deliveryFee),
// //               ),
// //               Visibility(
// //                 visible: controller.myOrder.maintenanceFee > 0,
// //                 child: _row(
// //                   theme,
// //                   title: "Service Fee : ",
// //                   value:
// //                       "\$${controller.myOrder.maintenanceFee.toStringAsFixed(2)}",
// //                 ),
// //               ),
// //               _row(
// //                 theme,
// //                 fontSize: 20,
// //                 title: "Total : ",
// //                 value:
// //                     "\$ ${controller.myOrder.totalOrderAmount.toStringAsFixed(2)}",
// //               ),
// //               Padding(
// //                 padding:
// //                     const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
// //                 child: Row(
// //                   children: [
// //                     Expanded(
// //                       child: GetBuilder<PosController>(builder: (controller) {
// //                         return Tooltip(
// //                           message: controller.myOrder.carts.isEmpty
// //                               ? 'No items to send order'
// //                               : "",
// //                           child: PrimaryBtn(
// //                             onPressed: () async {
// //                               var myOrder = controller.myOrder.toNonUpdate();
// //                               if (controller.isUpdateView) {
// //                                 controller.myOrder.splitAmounts = [];
// //                                 controller.myOrder.splitOrders = [];
// //                                 controller.myOrder.splitOrderCarts = [];
// //                                 PopupDialog.showLoadingDialog();
// //                                 var isUpdated = await controller.onUpdateOrder(
// //                                     controller.myOrder.id,
// //                                     isClearList: true);
// //                                 PopupDialog.closeLoadingDialog();
// //                                 if (isUpdated) {
// //                                   PosController.to.isUpdateView = false;
// //                                   controller.update();
// //                                   kitchenPrint(myOrder);
// //                                   DataUpdateHelper.getDataByCheckType();
// //                                   PosController.to.onFocusGuestName();
// //                                 }
// //                               } else {
// //                                 PopupDialog.showLoadingDialog();
// //                                 await controller.onPlaseOrder();
// //                                 PopupDialog.closeLoadingDialog();
// //                               }
// //                             },
// //                             textMaxSize: 26,
// //                             textMinSize: 24,
// //                             height: 70,
// //                             color: StaticColors.blueColor,
// //                             textColor: Colors.white,
// //                             text: controller.isUpdateView
// //                                 ? "Update Order".toUpperCase()
// //                                 : 'Send'.toUpperCase(),
// //                           ),
// //                         );
// //                       }),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           );
// //         }),
// //       ),
// //     );
// //   }
// // }

// // // ─── Helper Widgets ──────────────────────────────────────────────────────────

// // // ignore: unused_element
// // void _showTableDialog({required bool isUpdateView}) {
// //   PopupDialog.customDialog(
// //     width: Get.width * 0.80,
// //     child: SizedBox(
// //       width: Get.width * 0.80,
// //       height: Get.height * 0.80,
// //       child: TableManagmentView(
// //         isScrollable: false,
// //         isPOSPage: true,
// //         isUpdateView: isUpdateView,
// //       ),
// //     ),
// //   );
// // }

// // Widget _row(
// //   ThemeData theme, {
// //   double? fontSize,
// //   FontWeight? fontWeight,
// //   Widget? child,
// //   required String title,
// //   required String value,
// // }) {
// //   return Padding(
// //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
// //     child: Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Row(
// //           children: [
// //             Text(
// //               title,
// //               style: theme.textTheme.titleSmall?.copyWith(
// //                   fontSize: fontSize ?? 16,
// //                   fontWeight: fontWeight ?? FontWeight.w700),
// //             ),
// //             SizedBox(child: child),
// //           ],
// //         ),
// //         Text(
// //           value,
// //           style: theme.textTheme.titleSmall?.copyWith(
// //               fontSize: fontSize ?? 16,
// //               fontWeight: fontWeight ?? FontWeight.w700),
// //         ),
// //       ],
// //     ),
// //   );
// // }

// // Widget _modifiers(ThemeData theme, String value,
// //     {int maxLines = 2, bool isItalic = false, String? title}) {
// //   return Visibility(
// //     visible: value.contains(':') ? value.length > 6 : value != '',
// //     child: Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
// //       child: Text.rich(
// //           maxLines: maxLines,
// //           style: theme.textTheme.labelSmall?.copyWith(
// //               fontWeight: FontWeight.bold,
// //               fontStyle: isItalic ? FontStyle.italic : FontStyle.normal),
// //           TextSpan(text: title, children: [
// //             TextSpan(
// //               text: value.trim().toUpperCase(),
// //               style: theme.textTheme.bodySmall?.copyWith(
// //                   fontStyle: isItalic ? FontStyle.italic : FontStyle.normal),
// //             ),
// //           ])),
// //     ),
// //   );
// // }

// Future<OrderModel?> _firstOrder(String query, {bool isDelivery = false}) async {
//   try {
//     final res = await BaseController.to.apiService.makeGetRequest(
//       URLS.orders,
//       queryParameters: {
//         'limit': 1,
//         'search': query.trim(),
//         if (isDelivery) 'orderType': 'DELIVERY',
//       },
//     );
//     if (res.statusCode == 200) {
//       final data = (res.data['data'] as List)
//           .map((e) => OrderModel.fromJson(e))
//           .toList();
//       return data.isNotEmpty ? data.first : null;
//     }
//     return null;
//   } catch (e) {
//     kLogger.e('Order search error => $e');
//     return null;
//   }
// }

//TODO:1st UI

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
// import 'package:yogo_pos/app/helper/data_update_helper.dart';
// import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/kitchen_print.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in/widgets/table_body.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in/widgets/table_mapping_managment_view.dart';
// import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
// import 'package:yogo_pos/app/modules/pos/order/models/product_model.dart';
// import 'package:yogo_pos/app/modules/pos/order/widgets/cart_item.dart';
// import 'package:yogo_pos/app/modules/pos/order/widgets/dialogs/address_dialog.dart';
// import 'package:yogo_pos/app/modules/pos/order/widgets/variation.dart';
// import 'package:yogo_pos/app/services/base/preferences.dart';
// import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/services/controller/config_controller.dart';
// import 'package:yogo_pos/app/utils/extension/order_extention.dart';
// import 'package:yogo_pos/app/utils/logger.dart';
// import 'package:yogo_pos/app/utils/my_reg_exp.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';
// import 'package:yogo_pos/app/utils/urls.dart';
// import 'package:yogo_pos/app/widgets/app_keyboard.dart';
// import 'package:yogo_pos/app/widgets/custom_btn.dart';
// import 'package:yogo_pos/app/widgets/custom_textfield.dart';
// import 'package:yogo_pos/app/widgets/edit_delivery_fee.dart';
// import 'package:yogo_pos/app/widgets/edit_gratuity.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

// // ─── Swipeable Cart Item ─────────────────────────────────────────────────────
// // Right swipe  -> reveals Repeat (green, left side)
// // Left  swipe  -> reveals Delete (red, right side)
// // Snaps fully open once dragged past 50% of the max slide.
// class _SwipeableCartItem extends StatefulWidget {
//   final Widget child;
//   final VoidCallback? onDelete;
//   final VoidCallback? onRepeat;
//   const _SwipeableCartItem({required this.child, this.onDelete, this.onRepeat});

//   @override
//   State<_SwipeableCartItem> createState() => _SwipeableCartItemState();
// }

// class _SwipeableCartItemState extends State<_SwipeableCartItem>
//     with SingleTickerProviderStateMixin {
//   double _dragExtent = 0;
//   late final AnimationController _animController = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 200),
//   );
//   late Animation<double> _snapAnimation;

//   static const double _maxSlide = 100;
//   // 50% of the max slide -> snap open threshold.
//   static const double _snapThreshold = _maxSlide / 2;

//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }

//   void _animateTo(double target) {
//     _snapAnimation =
//         Tween<double>(begin: _dragExtent, end: target).animate(
//           CurvedAnimation(parent: _animController, curve: Curves.easeOut),
//         )..addListener(() {
//           setState(() => _dragExtent = _snapAnimation.value);
//         });
//     _animController.forward(from: 0);
//   }

//   void _onDragUpdate(DragUpdateDetails details) {
//     setState(() {
//       _dragExtent = (_dragExtent + details.delta.dx).clamp(
//         -_maxSlide,
//         _maxSlide,
//       );
//     });
//   }

//   void _onDragEnd(DragEndDetails details) {
//     if (_dragExtent > _snapThreshold) {
//       _animateTo(_maxSlide); // right swipe -> Repeat
//     } else if (_dragExtent < -_snapThreshold) {
//       _animateTo(-_maxSlide); // left swipe -> Delete
//     } else {
//       _animateTo(0);
//     }
//   }

//   void _close() => _animateTo(0);

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(6),
//       child: Stack(
//         children: [
//           // ── Background action buttons ──
//           Positioned.fill(
//             child: Row(
//               children: [
//                 // Repeat (right swipe reveals on the left)
//                 if (_dragExtent > 0)
//                   GestureDetector(
//                     onTap: () {
//                       _close();
//                       widget.onRepeat?.call();
//                     },
//                     child: Container(
//                       width: _dragExtent,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color: StaticColors.greenColor,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: _dragExtent > _snapThreshold
//                           ? const Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.repeat_rounded,
//                                   color: Colors.white,
//                                   size: 22,
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   "Repeat",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ],
//                             )
//                           : const Icon(
//                               Icons.repeat_rounded,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                     ),
//                   ),
//                 const Spacer(),
//                 // Delete (left swipe reveals on the right)
//                 if (_dragExtent < 0)
//                   GestureDetector(
//                     onTap: () {
//                       _close();
//                       widget.onDelete?.call();
//                     },
//                     child: Container(
//                       width: _dragExtent.abs(),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color: StaticColors.redColor,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: _dragExtent.abs() > _snapThreshold
//                           ? const Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.delete_rounded,
//                                   color: Colors.white,
//                                   size: 22,
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   "Delete",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ],
//                             )
//                           : const Icon(
//                               Icons.delete_rounded,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           // ── Foreground (the actual CartItem) ──
//           GestureDetector(
//             onHorizontalDragUpdate: _onDragUpdate,
//             onHorizontalDragEnd: _onDragEnd,
//             child: Transform.translate(
//               offset: Offset(_dragExtent, 0),
//               child: widget.child,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CartArea extends GetView<PosController> {
//   final ThemeData theme;
//   const CartArea(this.theme, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AbsorbPointer(
//       absorbing: false,
//       child: Container(
//         width: 400,
//         decoration: BoxDecoration(
//           color: ConfigController.to.isLightTheme
//               ? theme.cardColor
//               : StaticColors.cartColor,
//           // border: Border.all(color: Colors.white),
//         ),
//         child: GetBuilder<PosController>(
//           builder: (controller) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(left: 12, top: 10),
//                   child: Wrap(
//                     crossAxisAlignment: WrapCrossAlignment.end,
//                     spacing: 26,
//                     // runSpacing: 4,
//                     children: List.generate(controller.orderTypeList.length, (
//                       index,
//                     ) {
//                       String orderType = controller.orderTypeList[index];
//                       // for item type
//                       return Visibility(
//                         child: PrimaryBtn(
//                           textColor: controller.orderType == orderType
//                               ? Colors.white
//                               : theme.textTheme.bodyLarge?.color,
//                           isOutline: true,
//                           borderColor: controller.orderType == orderType
//                               ? StaticColors.blueColor
//                               : theme.hintColor,
//                           color: controller.orderType == orderType
//                               ? StaticColors.blueColor
//                               : Colors.transparent,
//                           borderWidth: 1,
//                           onPressed: () async {
//                             if (controller.isUpdateView) return;
//                             controller.myOrder.numberOfPeople = 1;

//                             if (orderType != "DELIVERY") {
//                               controller.addressController.clear();
//                               controller.selectedLat = null;
//                               controller.selectedLon = null;
//                               controller.additionalDetailsController.clear();
//                               controller.myOrder.deliveryFee = 0;
//                             }

//                             controller.tableController.clear();
//                             controller.guestController.clear();
//                             controller.myOrder.table = "";
//                             controller.myOrder.tableName = "";
//                             controller.onChangeOrderType(orderType);
//                             // controller.orderType = orderType;
//                             // controller.update();
//                             controller.onFocusGuestName();

//                             if (orderType == "DINE_IN") {
//                               controller.onRemovePackagingCost();
//                             } else if (orderType == "DELIVERY") {
//                               controller.onAddPackagingCost();
//                               String phone =
//                                   controller.guestPhoneController.text;
//                               if (phone.isNotEmpty && phone.length == 10) {
//                                 var order = await _firstOrder(
//                                   phone,
//                                   isDelivery: true,
//                                 );
//                                 if (order != null) {
//                                   controller.addressController.text =
//                                       order.delivery?.address ?? "";
//                                   controller.additionalDetailsController.text =
//                                       order.delivery?.additionalDetails ?? "";
//                                   controller.selectedLat =
//                                       order.delivery?.latitude;
//                                   controller.selectedLon =
//                                       order.delivery?.longitude;

//                                   if (controller
//                                       .guestNameController
//                                       .text
//                                       .isEmpty) {
//                                     controller.guestNameController.text =
//                                         order.guestName;
//                                   }
//                                   controller.myOrder.deliveryFee =
//                                       order.deliveryFee;
//                                 }
//                               }
//                             } else {
//                               controller.onAddPackagingCost();
//                             }
//                             controller.calculateTotalPrice();
//                           },
//                           text: orderType.replaceAll("_", "-").toUpperCase(),
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//                 // for Dine in
//                 Padding(
//                   padding: const EdgeInsets.only(left: 12, right: 12, top: 10),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: CustomTextField(
//                           allowRegex:
//                               CommonRegexPatterns.alphanumericWithSpaceAndLength(
//                                 18,
//                               ),
//                           readOnly: controller.isGuestNameReadOnly,
//                           focusNode: controller.guestNameFocusNode,
//                           controller: controller.guestNameController,
//                           hintText: "Guest Name",
//                           onTap: () {
//                             if (controller.isGuestNameReadOnly) {
//                               PopupDialog.permissionDialog(
//                                 theme,
//                                 onSubmit: () {
//                                   controller.isGuestNameReadOnly = false;
//                                   Get.back();
//                                   controller.update();
//                                   // show kewboard
//                                   if (Preferences.customKeyboard) {
//                                     AppKeyboard.open(
//                                       context,
//                                       keyboardType: KeyboardType.alphaNumeric,
//                                       controller:
//                                           controller.guestNameController,
//                                       allowRegex:
//                                           CommonRegexPatterns.alphanumericWithSpaceAndLength(
//                                             18,
//                                           ),
//                                     );
//                                   }
//                                 },
//                                 title: "Change Guest's Name?",
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: CustomTextField(
//                           keyboardType: KeyboardType.numeric,
//                           readOnly: controller.isGuestPhoneReadOnly,
//                           controller: controller.guestPhoneController,
//                           focusNode: controller.guestPhoneFocusNode,
//                           hintText: "Phone Number",
//                           allowRegex: CommonRegexPatterns.digitsOnlyWithLength(
//                             10,
//                           ),
//                           onChange: (value) async {
//                             if (value.length == 10 &&
//                                 controller.isUpdateView == false &&
//                                 controller.orderType == 'DELIVERY') {
//                               var order = await _firstOrder(
//                                 value,
//                                 isDelivery: true,
//                               );
//                               if (order != null) {
//                                 controller.addressController.text =
//                                     order.delivery?.address ?? "";
//                                 controller.additionalDetailsController.text =
//                                     order.delivery?.additionalDetails ?? "";
//                                 controller.selectedLat =
//                                     order.delivery?.latitude;
//                                 controller.selectedLon =
//                                     order.delivery?.longitude;
//                                 if (controller
//                                     .guestNameController
//                                     .text
//                                     .isEmpty) {
//                                   controller.guestNameController.text =
//                                       order.guestName;
//                                 }
//                                 controller.myOrder.deliveryFee =
//                                     order.deliveryFee;
//                                 controller.calculateTotalPrice();
//                               }
//                             }
//                           },
//                           onKeyboardChang: (value) async {
//                             if (value.length == 10 &&
//                                 controller.isUpdateView == false &&
//                                 controller.orderType == 'DELIVERY') {
//                               var order = await _firstOrder(
//                                 value,
//                                 isDelivery: true,
//                               );
//                               if (order != null) {
//                                 controller.addressController.text =
//                                     order.delivery?.address ?? "";
//                                 controller.additionalDetailsController.text =
//                                     order.delivery?.additionalDetails ?? "";
//                                 controller.selectedLat =
//                                     order.delivery?.latitude;
//                                 controller.selectedLon =
//                                     order.delivery?.longitude;
//                                 if (controller
//                                     .guestNameController
//                                     .text
//                                     .isEmpty) {
//                                   controller.guestNameController.text =
//                                       order.guestName;
//                                 }
//                                 controller.myOrder.deliveryFee =
//                                     order.deliveryFee;
//                                 controller.calculateTotalPrice();
//                               }
//                             }
//                           },
//                           onTap: () {
//                             if (controller.isGuestPhoneReadOnly) {
//                               PopupDialog.permissionDialog(
//                                 theme,
//                                 onSubmit: () {
//                                   controller.isGuestPhoneReadOnly = false;
//                                   Get.back();
//                                   controller.update();
//                                   if (Preferences.customKeyboard) {
//                                     AppKeyboard.open(
//                                       context,
//                                       keyboardType: KeyboardType.numeric,
//                                       controller:
//                                           controller.guestPhoneController,
//                                       allowRegex:
//                                           CommonRegexPatterns.digitsOnlyWithLength(
//                                             10,
//                                           ),
//                                     );
//                                   }
//                                 },
//                                 title: "Change Phone Number?",
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 //for dine-in
//                 Visibility(
//                   visible: controller.orderType == "DINE_IN",
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 12, right: 12),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: CustomTextField(
//                             readOnly: true,
//                             focusNode: controller.tableFocusNode,
//                             controller: controller.tableController,
//                             hintText: "Table / Bar",
//                             prefixText:
//                                 controller.tableController.text.isNotEmpty
//                                 ? "Table: "
//                                 : null,
//                             onTap: () {
//                               if (controller.isUpdateView) {
//                                 PopupDialog.permissionDialog(
//                                   theme,
//                                   onSubmit: () {
//                                     controller.isTableReadOnly = false;
//                                     Get.back();
//                                     DineInController.to.getTableCategories();
//                                     PopupDialog.customDialog(
//                                       width: Get.width * 0.8,
//                                       height: Get.height * .85,
//                                       child: const TableBody(
//                                         isScrollable: true,
//                                         isPOSPage: true,
//                                         isUpdateView: true,
//                                       ),
//                                     );
//                                   },
//                                   title: "Change Table?",
//                                 );
//                               } else {
//                                 DineInController.to.getTableCategories();
//                                 PopupDialog.customDialog(
//                                   width: Get.width * 0.8,
//                                   height: Get.height * .85,
//                                   child: const TableBody(
//                                     isScrollable: true,
//                                     isPOSPage: true,
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: CustomTextField(
//                             readOnly: controller.isGuestReadOnly,
//                             keyboardType: KeyboardType.numeric,
//                             controller: controller.guestController,
//                             allowRegex:
//                                 CommonRegexPatterns.digitsOnlyWithLength(2),
//                             focusNode: controller.guestFocusNode,

//                             hintText: "No. of Guests ",
//                             prefixText:
//                                 controller.guestController.text.isNotEmpty
//                                 ? "Guest: "
//                                 : null,

//                             onTap: () {
//                               if (controller.isGuestReadOnly) {
//                                 PopupDialog.permissionDialog(
//                                   theme,
//                                   onSubmit: () {
//                                     controller.isGuestReadOnly = false;
//                                     Get.back();
//                                     // custom keyboard
//                                     if (Preferences.customKeyboard) {
//                                       AppKeyboard.open(
//                                         context,
//                                         keyboardType: KeyboardType.numeric,
//                                         controller: controller.guestController,
//                                         allowRegex:
//                                             CommonRegexPatterns.digitsOnlyWithLength(
//                                               2,
//                                             ),
//                                       );
//                                     }
//                                   },
//                                   title: "Change no. of Guests?",
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 //for DELIVERY
//                 Visibility(
//                   visible: controller.orderType == "DELIVERY",
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                       left: 12,
//                       right: 12,
//                       bottom: 12,
//                     ),
//                     child: CustomTextField(
//                       controller: controller.addressController,
//                       hintText: "Delivery Address",
//                       focusNode: controller.addressFocusNode,
//                       readOnly: true,
//                       maxLines: 2,
//                       onTap: () => WoltModalSheet.show(
//                         context: context,
//                         modalTypeBuilder: (_) => LeftSideSheetType(),
//                         pageListBuilder: (context) => [
//                           addressDialog(
//                             context,
//                             theme,
//                             controller.addressController.text,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 Visibility(
//                   visible:
//                       controller.selectedLat != null &&
//                       controller.selectedLon != null &&
//                       controller.orderType == "DELIVERY",
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                       left: 12,
//                       right: 12,
//                       bottom: 12,
//                     ),
//                     child: CustomTextField(
//                       controller: controller.additionalDetailsController,
//                       focusNode: controller.additionalDetailsFocusNode,
//                       allowRegex:
//                           CommonRegexPatterns.alphanumericWithSpaceAndLength(
//                             200,
//                           ),
//                       hintText:
//                           "Additional Delivery Info. (e.g. Floor No., Unit No., Buzzer Code)",
//                       maxLines: 2,
//                     ),
//                   ),
//                 ),
//                 //for take out
//                 Visibility(
//                   visible:
//                       controller.orderType == "TAKEOUT" ||
//                       controller.orderType == "DELIVERY",
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 12, right: 12),
//                     child: CustomTextField(
//                       controller: controller.notesController,
//                       focusNode: controller.notesFocusNode,
//                       hintText: "Order Notes (Optional)",
//                       maxLines: 1,
//                       allowRegex:
//                           CommonRegexPatterns.alphanumericWithSpaceAndLength(
//                             200,
//                           ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     controller: controller.cartListScrollController,
//                     shrinkWrap: true,
//                     itemCount: controller.myOrder.carts.length,
//                     itemBuilder: (context, index) {
//                       var data = controller.myOrder.carts[index];
//                       return _SwipeableCartItem(
//                         // left swipe -> remove item
//                         onDelete: () {
//                           controller.clearModifier();
//                           controller.onRemoveCartItemWithIndex(index);
//                         },
//                         // right swipe -> repeat item (adds one more of the same).
//                         // Replace with your own repeat method here if you have one.
//                         onRepeat: () {
//                           controller.quantityUpdateWithCartListIndex(
//                             index,
//                             data.quantity + 1,
//                           );
//                         },
//                         child: CartItem(
//                           itemIndex: index,
//                           id: data.id,
//                           weight: data.weight,
//                           isUpdated: data.isUpdated,
//                           title: data.isCustomProduct
//                               ? "${data.name} (CUSTOM)"
//                               : data.name,
//                           amount: data.price,
//                           quantity: data.quantity,
//                           options: data.variationOptions,
//                           modifiers: data.modifiers,
//                           discount: data.discount,
//                           note: data.kitchenNote,
//                           onRemove: () {
//                             controller.clearModifier();
//                             controller.onRemoveCartItemWithIndex(index);
//                           },
//                           onTap: () {
//                             controller.cartId = data.id;
//                             //eng

//                             controller.onChangeSelectedItemList(data.id);
//                             controller.update();
//                             if (controller.selectedItemList.isEmpty) {
//                               return;
//                             }
//                             String firstCartId =
//                                 controller.selectedItemList.first;

//                             CartModel cart = controller.myOrder.carts
//                                 .firstWhere(
//                                   (c) => c.id == firstCartId,
//                                   orElse: () => throw Exception(
//                                     "Cart not found for ID: $firstCartId",
//                                   ),
//                                 );
//                             controller.selectedModifiers.assignAll(
//                               cart.modifiers,
//                             );
//                           },
//                           onDoubleTap: () {
//                             // controller.toggleAllSelectedItem();
//                           },
//                           onLongPress: () {
//                             // for variation
//                             controller.cartId = data.id;
//                             controller.onChangeSelectedItemList(
//                               data.id,
//                               isLongPress: true,
//                             );
//                             controller.update();
//                             if (controller.selectedItemList.isEmpty) {
//                               return;
//                             }
//                             String firstCartId =
//                                 controller.selectedItemList.first;

//                             CartModel cart = controller.myOrder.carts
//                                 .firstWhere(
//                                   (c) => c.id == firstCartId,
//                                   orElse: () => throw Exception(
//                                     "Cart not found for ID: $firstCartId",
//                                   ),
//                                 );
//                             controller.selectedModifiers.assignAll(
//                               cart.modifiers,
//                             );
//                             // new option
//                             ProductModel item = PosController.to.mainProductList
//                                 .where((p) => p.id == data.itemId)
//                                 .first;
//                             if (item.variations.isEmpty) {
//                               return;
//                             }

//                             try {
//                               PopupDialog.customDialog(
//                                 hasScroll: false,
//                                 width: MediaQuery.sizeOf(context).width * 0.8,
//                                 height:
//                                     MediaQuery.sizeOf(context).height * 0.85,
//                                 child: Variation(
//                                   activeOptions: data.variationOptions,
//                                   initialQuantity: data.quantity,
//                                   item: item.copyWith(
//                                     variations: item.variations
//                                         .where((v) => v.posVariationOn == true)
//                                         .toList(),
//                                   ),
//                                 ),
//                               );
//                             } catch (e, st) {
//                               if (kDebugMode) {
//                                 kLogger.e(
//                                   "Error finding product for variation: $e",
//                                 );
//                                 kLogger.e(
//                                   "Error finding product for variation: $st",
//                                 );
//                               }
//                             }
//                           },
//                         ),
//                       ).marginOnly(bottom: 12);
//                     },
//                   ),
//                 ),

//                 _modifiers(
//                   theme,
//                   PosController.to.myOrder.discountReason,
//                   title: "Discount Reason: ",
//                   isItalic: true,
//                   maxLines: 5,
//                 ),
//                 const Divider(thickness: .5, height: 1),
//                 SizedBox(height: 5),
//                 _row(
//                   theme,
//                   title: "Subtotal : ",
//                   value: "\$${controller.myOrder.subTotal.toStringAsFixed(2)}",
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.totalDiscount > 0,
//                   child: _row(
//                     theme,
//                     title: "Discount : ",
//                     value:
//                         "(-)  \$${controller.myOrder.totalDiscount.toStringAsFixed(2)}",
//                     child: controller.myOrder.payment != null
//                         ? const SizedBox()
//                         : InkWell(
//                             child: Container(
//                               margin: const EdgeInsets.only(left: 4),
//                               padding: const EdgeInsets.all(4.0),
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   width: 1,
//                                   color:
//                                       theme.textTheme.labelLarge?.color ??
//                                       Colors.white,
//                                 ),
//                               ),
//                               child: const Icon(
//                                 Icons.delete,
//                                 color: StaticColors.redColor,
//                                 size: 20,
//                               ),
//                             ),
//                             onTap: () {
//                               PosController.to.deleteDiscount();
//                             },
//                           ),
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.totalGst > 0,
//                   child: _row(
//                     theme,
//                     title:
//                         "GST ${BaseController.to.restaurantDetails?.businessProfile.gstNumber ?? 0}% : ",
//                     value:
//                         "\$${controller.myOrder.totalGst.toStringAsFixed(2)}",
//                   ),
//                 ),

//                 Visibility(
//                   visible: controller.myOrder.totalPst > 0,
//                   child: _row(
//                     theme,
//                     title:
//                         "PST ${BaseController.to.restaurantDetails?.businessProfile.pstNumber ?? 0}% : ",
//                     value:
//                         "\$${controller.myOrder.totalPst.toStringAsFixed(2)}",
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.totalPst2 > 0,
//                   child: _row(
//                     theme,
//                     title:
//                         "PST2 ${BaseController.to.restaurantDetails?.businessProfile.pstNumber2 ?? 0}% : ",
//                     value:
//                         "\$${controller.myOrder.totalPst2.toStringAsFixed(2)}",
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.orderType == "DINE_IN",
//                   child: _row(
//                     theme,
//                     title:
//                         "Gratuity ${controller.myOrder.gratuityPercentage ?? (BaseController.to.restaurantDetails?.businessProfile.gratuity ?? 0)}% : ",
//                     value:
//                         "\$${controller.myOrder.totalGratuity.toStringAsFixed(2)}",
//                     child: controller.myOrder.paymentStatus == "PAID"
//                         ? const SizedBox.shrink()
//                         : Row(
//                             children: [
//                               Container(
//                                 margin: const EdgeInsets.only(left: 4),
//                                 padding: const EdgeInsets.all(4.0),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     width: 1,
//                                     color:
//                                         theme.textTheme.labelLarge?.color ??
//                                         Colors.white,
//                                   ),
//                                 ),
//                                 child: InkWell(
//                                   child: const Icon(
//                                     Icons.edit_square,
//                                     color: StaticColors.greenColor,
//                                   ),
//                                   onTap: () {
//                                     PopupDialog.permissionDialog(
//                                       title: "Edit Gratuity?",
//                                       theme,
//                                       onSubmit: () async {
//                                         Get.back();
//                                         PopupDialog.customDialog(
//                                           width: 400,
//                                           child: EditGratuity(
//                                             isNewOrder:
//                                                 !controller.isUpdateView,
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ),
//                               SizedBox(width: 34),
//                               Visibility(
//                                 visible:
//                                     controller.myOrder.gratuityPercentage != 0,
//                                 child: Container(
//                                   margin: const EdgeInsets.only(left: 4),
//                                   padding: const EdgeInsets.all(4.0),
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       width: 1,
//                                       color:
//                                           theme.textTheme.labelLarge?.color ??
//                                           Colors.white,
//                                     ),
//                                   ),
//                                   child: InkWell(
//                                     child: const Icon(
//                                       Icons.delete,
//                                       color: StaticColors.redColor,
//                                     ),
//                                     onTap: () {
//                                       PopupDialog.permissionDialog(
//                                         title: "Delete Gratuity?",
//                                         theme,
//                                         onSubmit: () async {
//                                           controller.onDeleteGratuity();
//                                           Get.back();

//                                           if (controller.isUpdateView) {
//                                             PopupDialog.showLoadingDialog();
//                                             await PosController.to
//                                                 .onUpdateOrder(
//                                                   PosController.to.myOrder.id,
//                                                 );
//                                             PopupDialog.closeLoadingDialog();
//                                           }
//                                         },
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.tip > 0,
//                   child: _row(
//                     theme,
//                     title: "Tip : ",
//                     value: "\$${controller.myOrder.tip.toStringAsFixed(2)}",
//                   ),
//                 ),

//                 Visibility(
//                   visible:
//                       controller.myOrder.packagingCost > 0 &&
//                       controller.myOrder.carts.isNotEmpty,
//                   child: _row(
//                     theme,
//                     title:
//                         "${(BaseController.to.restaurantDetails?.restaurant.packagingCost.title) ?? ""}: ",
//                     value:
//                         "\$${controller.myOrder.packagingCost.toStringAsFixed(2)}",
//                     child: controller.myOrder.paymentStatus == "PAID"
//                         ? const SizedBox.shrink()
//                         : Container(
//                             margin: const EdgeInsets.only(left: 4),
//                             padding: const EdgeInsets.all(4.0),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 width: 1,
//                                 color:
//                                     theme.textTheme.labelLarge?.color ??
//                                     Colors.white,
//                               ),
//                             ),
//                             child: InkWell(
//                               child: const Icon(
//                                 Icons.delete,
//                                 color: StaticColors.redColor,
//                               ),
//                               onTap: () {
//                                 controller.onRemovePackagingCost();
//                               },
//                             ),
//                           ),
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.orderType == "DELIVERY",
//                   child: _row(
//                     theme,
//                     title: "Delivery Fee: ",
//                     value:
//                         "\$${controller.myOrder.deliveryFee.toStringAsFixed(2)}",
//                     child: controller.myOrder.paymentStatus == "PAID"
//                         ? const SizedBox.shrink()
//                         : Row(
//                             children: [
//                               Container(
//                                 margin: const EdgeInsets.only(left: 4),
//                                 padding: const EdgeInsets.all(4.0),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     width: 1,
//                                     color:
//                                         theme.textTheme.labelLarge?.color ??
//                                         Colors.white,
//                                   ),
//                                 ),
//                                 child: InkWell(
//                                   child: const Icon(
//                                     Icons.edit_square,
//                                     color: StaticColors.greenColor,
//                                   ),
//                                   onTap: () {
//                                     PopupDialog.permissionDialog(
//                                       title: "Edit Delivery Fee?",
//                                       theme,
//                                       onSubmit: () async {
//                                         Get.back();
//                                         PopupDialog.customDialog(
//                                           width: 400,
//                                           child: EditDeliveryFee(
//                                             isNewOrder:
//                                                 !controller.isUpdateView,
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ),
//                               SizedBox(width: 34),
//                               Visibility(
//                                 visible: controller.myOrder.deliveryFee != 0,
//                                 child: Container(
//                                   margin: const EdgeInsets.only(left: 4),
//                                   padding: const EdgeInsets.all(4.0),
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       width: 1,
//                                       color:
//                                           theme.textTheme.labelLarge?.color ??
//                                           Colors.white,
//                                     ),
//                                   ),
//                                   child: InkWell(
//                                     child: const Icon(
//                                       Icons.delete,
//                                       color: StaticColors.redColor,
//                                     ),
//                                     onTap: () {
//                                       PopupDialog.permissionDialog(
//                                         title: "Delete Delivery Fee?",
//                                         theme,
//                                         onSubmit: () async {
//                                           PosController.to
//                                               .onDeleteDeliveryFee();

//                                           Get.back();

//                                           if (controller.isUpdateView) {
//                                             PopupDialog.showLoadingDialog();
//                                             await PosController.to
//                                                 .onUpdateOrder(
//                                                   PosController.to.myOrder.id,
//                                                 );
//                                             PopupDialog.closeLoadingDialog();
//                                           }
//                                         },
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),

//                 Visibility(
//                   visible: controller.myOrder.maintenanceFee > 0,
//                   child: _row(
//                     theme,
//                     title: "Service Fee : ",
//                     value:
//                         "\$${controller.myOrder.maintenanceFee.toStringAsFixed(2)}",
//                   ),
//                 ),

//                 _row(
//                   theme,
//                   fontSize: 20,
//                   title: "Total : ",
//                   value:
//                       "\$ ${controller.myOrder.totalOrderAmount.toStringAsFixed(2)}",
//                 ),
//                 // order btn
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 12,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: GetBuilder<PosController>(
//                           builder: (controller) {
//                             return Tooltip(
//                               message: controller.myOrder.carts.isEmpty
//                                   ? 'No items to send order'
//                                   : "",
//                               child: PrimaryBtn(
//                                 onPressed: () async {
//                                   // print data
//                                   var myOrder = controller.myOrder
//                                       .toNonUpdate();

//                                   if (controller.isUpdateView) {
//                                     // update order
//                                     controller.myOrder.splitAmounts = [];
//                                     controller.myOrder.splitOrders = [];
//                                     controller.myOrder.splitOrderCarts = [];
//                                     PopupDialog.showLoadingDialog();
//                                     var isUpdated = await controller
//                                         .onUpdateOrder(
//                                           controller.myOrder.id,
//                                           isClearList: true,
//                                         );
//                                     PopupDialog.closeLoadingDialog();

//                                     if (isUpdated) {
//                                       PosController.to.isUpdateView = false;
//                                       controller.update();
//                                       //for printer
//                                       kitchenPrint(myOrder);

//                                       DataUpdateHelper.getDataByCheckType();
//                                       PosController.to.onFocusGuestName();
//                                     }
//                                   } else {
//                                     // for plaseOrder
//                                     await controller.onPlaseOrder();
//                                   }
//                                 },
//                                 textMaxSize: 26,
//                                 textMinSize: 24,
//                                 height: 70,
//                                 color: StaticColors.blueColor,
//                                 textColor: Colors.white,
//                                 text: controller.isUpdateView
//                                     ? "Update Order".toUpperCase()
//                                     : 'Send'.toUpperCase(),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // ignore: unused_element
// void _showTableDialog({required bool isUpdateView}) {
//   PopupDialog.customDialog(
//     width: Get.width * 0.80,
//     child: SizedBox(
//       width: Get.width * 0.80,
//       height: Get.height * 0.80,
//       child: TableManagmentView(
//         isScrollable: false,
//         isPOSPage: true,
//         isUpdateView: isUpdateView,
//       ),
//     ),
//   );
// }

// Widget _row(
//   ThemeData theme, {
//   double? fontSize,
//   FontWeight? fontWeight,
//   Widget? child,
//   required String title,
//   required String value,
// }) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Text(
//               title,
//               style: theme.textTheme.titleSmall?.copyWith(
//                 fontSize: fontSize ?? 16,
//                 fontWeight: fontWeight ?? FontWeight.w700,
//               ),
//             ),
//             SizedBox(child: child),
//           ],
//         ),
//         Text(
//           value,
//           style: theme.textTheme.titleSmall?.copyWith(
//             fontSize: fontSize ?? 16,
//             fontWeight: fontWeight ?? FontWeight.w700,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _modifiers(
//   ThemeData theme,
//   String value, {
//   int maxLines = 2,
//   bool isItalic = false,
//   String? title,
// }) {
//   return Visibility(
//     visible: value.contains(':') ? value.length > 6 : value != '',
//     child: Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
//       child: Text.rich(
//         maxLines: maxLines,
//         style: theme.textTheme.labelSmall?.copyWith(
//           fontWeight: FontWeight.bold,
//           fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
//         ),
//         TextSpan(
//           text: title,
//           children: [
//             TextSpan(
//               text: value.trim().toUpperCase(),
//               style: theme.textTheme.bodySmall?.copyWith(
//                 fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

// Future<OrderModel?> _firstOrder(String query, {bool isDelivery = false}) async {
//   try {
//     final res = await BaseController.to.apiService.makeGetRequest(
//       URLS.orders,
//       queryParameters: {
//         'limit': 1,
//         'search': query.trim(),
//         if (isDelivery) 'orderType': 'DELIVERY',
//       },
//     );
//     if (res.statusCode == 200) {
//       final data = (res.data['data'] as List)
//           .map((e) => OrderModel.fromJson(e))
//           .toList();
//       return data.isNotEmpty ? data.first : null;
//     }
//     return null;
//   } catch (e) {
//     kLogger.e('Order search error => $e');
//     return null;
//   }
// }

//TODO:2nd UI

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:get/get.dart';
// import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
// import 'package:yogo_pos/app/helper/data_update_helper.dart';
// import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/kitchen_print.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in/widgets/table_body.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in/widgets/table_mapping_managment_view.dart';
// import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
// import 'package:yogo_pos/app/modules/pos/order/models/product_model.dart';
// import 'package:yogo_pos/app/modules/pos/order/widgets/cart_item.dart';
// import 'package:yogo_pos/app/modules/pos/order/widgets/dialogs/address_dialog.dart';
// import 'package:yogo_pos/app/modules/pos/order/widgets/variation.dart';
// import 'package:yogo_pos/app/services/base/preferences.dart';
// import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/services/controller/config_controller.dart';
// import 'package:yogo_pos/app/utils/extension/order_extention.dart';
// import 'package:yogo_pos/app/utils/logger.dart';
// import 'package:yogo_pos/app/utils/my_reg_exp.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';
// import 'package:yogo_pos/app/utils/urls.dart';
// import 'package:yogo_pos/app/widgets/app_keyboard.dart';
// import 'package:yogo_pos/app/widgets/custom_btn.dart';
// import 'package:yogo_pos/app/widgets/custom_textfield.dart';
// import 'package:yogo_pos/app/widgets/edit_delivery_fee.dart';
// import 'package:yogo_pos/app/widgets/edit_gratuity.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

// class CartArea extends GetView<PosController> {
//   final ThemeData theme;
//   const CartArea(this.theme, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AbsorbPointer(
//       absorbing: false,
//       child: Container(
//         width: 400,
//         decoration: BoxDecoration(
//           color: ConfigController.to.isLightTheme
//               ? theme.cardColor
//               : StaticColors.cartColor,
//         ),
//         child: GetBuilder<PosController>(
//           builder: (controller) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(left: 12, top: 10),
//                   child: Wrap(
//                     crossAxisAlignment: WrapCrossAlignment.end,
//                     spacing: 26,
//                     children: List.generate(controller.orderTypeList.length, (
//                       index,
//                     ) {
//                       String orderType = controller.orderTypeList[index];
//                       return Visibility(
//                         child: PrimaryBtn(
//                           textColor: controller.orderType == orderType
//                               ? Colors.white
//                               : theme.textTheme.bodyLarge?.color,
//                           isOutline: true,
//                           borderColor: controller.orderType == orderType
//                               ? StaticColors.blueColor
//                               : theme.hintColor,
//                           color: controller.orderType == orderType
//                               ? StaticColors.blueColor
//                               : Colors.transparent,
//                           borderWidth: 1,
//                           onPressed: () async {
//                             if (controller.isUpdateView) return;
//                             controller.myOrder.numberOfPeople = 1;

//                             if (orderType != "DELIVERY") {
//                               controller.addressController.clear();
//                               controller.selectedLat = null;
//                               controller.selectedLon = null;
//                               controller.additionalDetailsController.clear();
//                               controller.myOrder.deliveryFee = 0;
//                             }

//                             controller.tableController.clear();
//                             controller.guestController.clear();
//                             controller.myOrder.table = "";
//                             controller.myOrder.tableName = "";
//                             controller.onChangeOrderType(orderType);
//                             controller.onFocusGuestName();

//                             if (orderType == "DINE_IN") {
//                               controller.onRemovePackagingCost();
//                             } else if (orderType == "DELIVERY") {
//                               controller.onAddPackagingCost();
//                               String phone =
//                                   controller.guestPhoneController.text;
//                               if (phone.isNotEmpty && phone.length == 10) {
//                                 var order = await _firstOrder(
//                                   phone,
//                                   isDelivery: true,
//                                 );
//                                 if (order != null) {
//                                   controller.addressController.text =
//                                       order.delivery?.address ?? "";
//                                   controller.additionalDetailsController.text =
//                                       order.delivery?.additionalDetails ?? "";
//                                   controller.selectedLat =
//                                       order.delivery?.latitude;
//                                   controller.selectedLon =
//                                       order.delivery?.longitude;

//                                   if (controller
//                                       .guestNameController
//                                       .text
//                                       .isEmpty) {
//                                     controller.guestNameController.text =
//                                         order.guestName;
//                                   }
//                                   controller.myOrder.deliveryFee =
//                                       order.deliveryFee;
//                                 }
//                               }
//                             } else {
//                               controller.onAddPackagingCost();
//                             }
//                             controller.calculateTotalPrice();
//                           },
//                           text: orderType.replaceAll("_", "-").toUpperCase(),
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 12, right: 12, top: 10),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: CustomTextField(
//                           allowRegex:
//                               CommonRegexPatterns.alphanumericWithSpaceAndLength(
//                                 18,
//                               ),
//                           readOnly: controller.isGuestNameReadOnly,
//                           focusNode: controller.guestNameFocusNode,
//                           controller: controller.guestNameController,
//                           hintText: "Guest Name",
//                           onTap: () {
//                             if (controller.isGuestNameReadOnly) {
//                               PopupDialog.permissionDialog(
//                                 theme,
//                                 onSubmit: () {
//                                   controller.isGuestNameReadOnly = false;
//                                   Get.back();
//                                   controller.update();
//                                   if (Preferences.customKeyboard) {
//                                     AppKeyboard.open(
//                                       context,
//                                       keyboardType: KeyboardType.alphaNumeric,
//                                       controller:
//                                           controller.guestNameController,
//                                       allowRegex:
//                                           CommonRegexPatterns.alphanumericWithSpaceAndLength(
//                                             18,
//                                           ),
//                                     );
//                                   }
//                                 },
//                                 title: "Change Guest's Name?",
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: CustomTextField(
//                           keyboardType: KeyboardType.numeric,
//                           readOnly: controller.isGuestPhoneReadOnly,
//                           controller: controller.guestPhoneController,
//                           focusNode: controller.guestPhoneFocusNode,
//                           hintText: "Phone Number",
//                           allowRegex: CommonRegexPatterns.digitsOnlyWithLength(
//                             10,
//                           ),
//                           onChange: (value) async {
//                             if (value.length == 10 &&
//                                 controller.isUpdateView == false &&
//                                 controller.orderType == 'DELIVERY') {
//                               var order = await _firstOrder(
//                                 value,
//                                 isDelivery: true,
//                               );
//                               if (order != null) {
//                                 controller.addressController.text =
//                                     order.delivery?.address ?? "";
//                                 controller.additionalDetailsController.text =
//                                     order.delivery?.additionalDetails ?? "";
//                                 controller.selectedLat =
//                                     order.delivery?.latitude;
//                                 controller.selectedLon =
//                                     order.delivery?.longitude;
//                                 if (controller
//                                     .guestNameController
//                                     .text
//                                     .isEmpty) {
//                                   controller.guestNameController.text =
//                                       order.guestName;
//                                 }
//                                 controller.myOrder.deliveryFee =
//                                     order.deliveryFee;
//                                 controller.calculateTotalPrice();
//                               }
//                             }
//                           },
//                           onKeyboardChang: (value) async {
//                             if (value.length == 10 &&
//                                 controller.isUpdateView == false &&
//                                 controller.orderType == 'DELIVERY') {
//                               var order = await _firstOrder(
//                                 value,
//                                 isDelivery: true,
//                               );
//                               if (order != null) {
//                                 controller.addressController.text =
//                                     order.delivery?.address ?? "";
//                                 controller.additionalDetailsController.text =
//                                     order.delivery?.additionalDetails ?? "";
//                                 controller.selectedLat =
//                                     order.delivery?.latitude;
//                                 controller.selectedLon =
//                                     order.delivery?.longitude;
//                                 if (controller
//                                     .guestNameController
//                                     .text
//                                     .isEmpty) {
//                                   controller.guestNameController.text =
//                                       order.guestName;
//                                 }
//                                 controller.myOrder.deliveryFee =
//                                     order.deliveryFee;
//                                 controller.calculateTotalPrice();
//                               }
//                             }
//                           },
//                           onTap: () {
//                             if (controller.isGuestPhoneReadOnly) {
//                               PopupDialog.permissionDialog(
//                                 theme,
//                                 onSubmit: () {
//                                   controller.isGuestPhoneReadOnly = false;
//                                   Get.back();
//                                   controller.update();
//                                   if (Preferences.customKeyboard) {
//                                     AppKeyboard.open(
//                                       context,
//                                       keyboardType: KeyboardType.numeric,
//                                       controller:
//                                           controller.guestPhoneController,
//                                       allowRegex:
//                                           CommonRegexPatterns.digitsOnlyWithLength(
//                                             10,
//                                           ),
//                                     );
//                                   }
//                                 },
//                                 title: "Change Phone Number?",
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Visibility(
//                   visible: controller.orderType == "DINE_IN",
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 12, right: 12),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: CustomTextField(
//                             readOnly: true,
//                             focusNode: controller.tableFocusNode,
//                             controller: controller.tableController,
//                             hintText: "Table / Bar",
//                             prefixText:
//                                 controller.tableController.text.isNotEmpty
//                                 ? "Table: "
//                                 : null,
//                             onTap: () {
//                               if (controller.isUpdateView) {
//                                 PopupDialog.permissionDialog(
//                                   theme,
//                                   onSubmit: () {
//                                     controller.isTableReadOnly = false;
//                                     Get.back();
//                                     DineInController.to.getTableCategories();
//                                     PopupDialog.customDialog(
//                                       width: Get.width * 0.8,
//                                       height: Get.height * .85,
//                                       child: const TableBody(
//                                         isScrollable: true,
//                                         isPOSPage: true,
//                                         isUpdateView: true,
//                                       ),
//                                     );
//                                   },
//                                   title: "Change Table?",
//                                 );
//                               } else {
//                                 DineInController.to.getTableCategories();
//                                 PopupDialog.customDialog(
//                                   width: Get.width * 0.8,
//                                   height: Get.height * .85,
//                                   child: const TableBody(
//                                     isScrollable: true,
//                                     isPOSPage: true,
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: CustomTextField(
//                             readOnly: controller.isGuestReadOnly,
//                             keyboardType: KeyboardType.numeric,
//                             controller: controller.guestController,
//                             allowRegex:
//                                 CommonRegexPatterns.digitsOnlyWithLength(2),
//                             focusNode: controller.guestFocusNode,
//                             hintText: "No. of Guests ",
//                             prefixText:
//                                 controller.guestController.text.isNotEmpty
//                                 ? "Guest: "
//                                 : null,
//                             onTap: () {
//                               if (controller.isGuestReadOnly) {
//                                 PopupDialog.permissionDialog(
//                                   theme,
//                                   onSubmit: () {
//                                     controller.isGuestReadOnly = false;
//                                     Get.back();
//                                     if (Preferences.customKeyboard) {
//                                       AppKeyboard.open(
//                                         context,
//                                         keyboardType: KeyboardType.numeric,
//                                         controller: controller.guestController,
//                                         allowRegex:
//                                             CommonRegexPatterns.digitsOnlyWithLength(
//                                               2,
//                                             ),
//                                       );
//                                     }
//                                   },
//                                   title: "Change no. of Guests?",
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.orderType == "DELIVERY",
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                       left: 12,
//                       right: 12,
//                       bottom: 12,
//                     ),
//                     child: CustomTextField(
//                       controller: controller.addressController,
//                       hintText: "Delivery Address",
//                       focusNode: controller.addressFocusNode,
//                       readOnly: true,
//                       maxLines: 2,
//                       onTap: () => WoltModalSheet.show(
//                         context: context,
//                         modalTypeBuilder: (_) => LeftSideSheetType(),
//                         pageListBuilder: (context) => [
//                           addressDialog(
//                             context,
//                             theme,
//                             controller.addressController.text,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Visibility(
//                   visible:
//                       controller.selectedLat != null &&
//                       controller.selectedLon != null &&
//                       controller.orderType == "DELIVERY",
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                       left: 12,
//                       right: 12,
//                       bottom: 12,
//                     ),
//                     child: CustomTextField(
//                       controller: controller.additionalDetailsController,
//                       focusNode: controller.additionalDetailsFocusNode,
//                       allowRegex:
//                           CommonRegexPatterns.alphanumericWithSpaceAndLength(
//                             200,
//                           ),
//                       hintText:
//                           "Additional Delivery Info. (e.g. Floor No., Unit No., Buzzer Code)",
//                       maxLines: 2,
//                     ),
//                   ),
//                 ),
//                 Visibility(
//                   visible:
//                       controller.orderType == "TAKEOUT" ||
//                       controller.orderType == "DELIVERY",
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 12, right: 12),
//                     child: CustomTextField(
//                       controller: controller.notesController,
//                       focusNode: controller.notesFocusNode,
//                       hintText: "Order Notes (Optional)",
//                       maxLines: 1,
//                       allowRegex:
//                           CommonRegexPatterns.alphanumericWithSpaceAndLength(
//                             200,
//                           ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Expanded(
//                   child: SlidableAutoCloseBehavior(
//                     child: ListView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       controller: controller.cartListScrollController,
//                       shrinkWrap: true,
//                       itemCount: controller.myOrder.carts.length,
//                       itemBuilder: (context, index) {
//                         var data = controller.myOrder.carts[index];
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 12),
//                           child: Slidable(
//                             key: ValueKey(data.id),
//                             // Right swipe -> Repeat (left side)
//                             startActionPane: ActionPane(
//                               motion: const DrawerMotion(),
//                               extentRatio: 0.28,
//                               children: [
//                                 CustomSlidableAction(
//                                   onPressed: (_) {
//                                     controller.quantityUpdateWithCartListIndex(
//                                       index,
//                                       data.quantity + 1,
//                                     );
//                                   },
//                                   backgroundColor: StaticColors.greenColor
//                                       .withAlpha(10),
//                                   foregroundColor: Colors.white,
//                                   padding: EdgeInsets.zero,
//                                   child: Center(
//                                     child: Container(
//                                       width: 90,
//                                       // margin: const EdgeInsets.only(left: 4),
//                                       padding: const EdgeInsets.only(
//                                         left: 8,
//                                         right: 8,
//                                         top: 4,
//                                         bottom: 4,
//                                       ),

//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(6),
//                                         color: StaticColors.greenColor,
//                                       ),
//                                       child: const Text(
//                                         "Repeat",
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.w800,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             // Left swipe -> Remove (right side)
//                             endActionPane: ActionPane(
//                               motion: const DrawerMotion(),
//                               extentRatio: 0.28,
//                               children: [
//                                 CustomSlidableAction(
//                                   onPressed: (_) {
//                                     controller.clearModifier();
//                                     controller.onRemoveCartItemWithIndex(index);
//                                   },
//                                   backgroundColor: StaticColors.redColor
//                                       .withAlpha(10),
//                                   foregroundColor: Colors.white,
//                                   padding: EdgeInsets.zero,
//                                   child: Center(
//                                     child: Container(
//                                       width: 90,
//                                       // margin: const EdgeInsets.only(left: 4),
//                                       padding: const EdgeInsets.only(
//                                         left: 8,
//                                         right: 8,
//                                         top: 4,
//                                         bottom: 4,
//                                       ),

//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(6),
//                                         color: StaticColors.redColor,
//                                       ),
//                                       child: const Text(
//                                         "Remove",
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.w800,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             child: CartItem(
//                               itemIndex: index,
//                               id: data.id,
//                               weight: data.weight,
//                               isUpdated: data.isUpdated,
//                               title: data.isCustomProduct
//                                   ? "${data.name} (CUSTOM)"
//                                   : data.name,
//                               amount: data.price,
//                               quantity: data.quantity,
//                               options: data.variationOptions,
//                               modifiers: data.modifiers,
//                               discount: data.discount,
//                               note: data.kitchenNote,
//                               onRemove: () {
//                                 controller.clearModifier();
//                                 controller.onRemoveCartItemWithIndex(index);
//                               },
//                               onTap: () {
//                                 controller.cartId = data.id;
//                                 controller.onChangeSelectedItemList(data.id);
//                                 controller.update();
//                                 if (controller.selectedItemList.isEmpty) {
//                                   return;
//                                 }
//                                 String firstCartId =
//                                     controller.selectedItemList.first;

//                                 CartModel cart = controller.myOrder.carts
//                                     .firstWhere(
//                                       (c) => c.id == firstCartId,
//                                       orElse: () => throw Exception(
//                                         "Cart not found for ID: $firstCartId",
//                                       ),
//                                     );
//                                 controller.selectedModifiers.assignAll(
//                                   cart.modifiers,
//                                 );
//                               },
//                               onDoubleTap: () {},
//                               onLongPress: () {
//                                 controller.cartId = data.id;
//                                 controller.onChangeSelectedItemList(
//                                   data.id,
//                                   isLongPress: true,
//                                 );
//                                 controller.update();
//                                 if (controller.selectedItemList.isEmpty) {
//                                   return;
//                                 }
//                                 String firstCartId =
//                                     controller.selectedItemList.first;

//                                 CartModel cart = controller.myOrder.carts
//                                     .firstWhere(
//                                       (c) => c.id == firstCartId,
//                                       orElse: () => throw Exception(
//                                         "Cart not found for ID: $firstCartId",
//                                       ),
//                                     );
//                                 controller.selectedModifiers.assignAll(
//                                   cart.modifiers,
//                                 );
//                                 ProductModel item = PosController
//                                     .to
//                                     .mainProductList
//                                     .where((p) => p.id == data.itemId)
//                                     .first;
//                                 if (item.variations.isEmpty) {
//                                   return;
//                                 }

//                                 try {
//                                   PopupDialog.customDialog(
//                                     hasScroll: false,
//                                     width:
//                                         MediaQuery.sizeOf(context).width * 0.8,
//                                     height:
//                                         MediaQuery.sizeOf(context).height *
//                                         0.85,
//                                     child: Variation(
//                                       activeOptions: data.variationOptions,
//                                       initialQuantity: data.quantity,
//                                       item: item.copyWith(
//                                         variations: item.variations
//                                             .where(
//                                               (v) => v.posVariationOn == true,
//                                             )
//                                             .toList(),
//                                       ),
//                                     ),
//                                   );
//                                 } catch (e, st) {
//                                   if (kDebugMode) {
//                                     kLogger.e(
//                                       "Error finding product for variation: $e",
//                                     );
//                                     kLogger.e(
//                                       "Error finding product for variation: $st",
//                                     );
//                                   }
//                                 }
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),

//                 _modifiers(
//                   theme,
//                   PosController.to.myOrder.discountReason,
//                   title: "Discount Reason: ",
//                   isItalic: true,
//                   maxLines: 5,
//                 ),
//                 const Divider(thickness: .5, height: 1),
//                 SizedBox(height: 5),
//                 _row(
//                   theme,
//                   title: "Subtotal : ",
//                   value: "\$${controller.myOrder.subTotal.toStringAsFixed(2)}",
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.totalDiscount > 0,
//                   child: _row(
//                     theme,
//                     title: "Discount : ",
//                     value:
//                         "(-)  \$${controller.myOrder.totalDiscount.toStringAsFixed(2)}",
//                     child: controller.myOrder.payment != null
//                         ? const SizedBox()
//                         : InkWell(
//                             child: Container(
//                               margin: const EdgeInsets.only(left: 4),
//                               padding: const EdgeInsets.all(4.0),
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   width: 1,
//                                   color:
//                                       theme.textTheme.labelLarge?.color ??
//                                       Colors.white,
//                                 ),
//                               ),
//                               child: const Icon(
//                                 Icons.delete,
//                                 color: StaticColors.redColor,
//                                 size: 20,
//                               ),
//                             ),
//                             onTap: () {
//                               PosController.to.deleteDiscount();
//                             },
//                           ),
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.totalGst > 0,
//                   child: _row(
//                     theme,
//                     title:
//                         "GST ${BaseController.to.restaurantDetails?.businessProfile.gstNumber ?? 0}% : ",
//                     value:
//                         "\$${controller.myOrder.totalGst.toStringAsFixed(2)}",
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.totalPst > 0,
//                   child: _row(
//                     theme,
//                     title:
//                         "PST ${BaseController.to.restaurantDetails?.businessProfile.pstNumber ?? 0}% : ",
//                     value:
//                         "\$${controller.myOrder.totalPst.toStringAsFixed(2)}",
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.totalPst2 > 0,
//                   child: _row(
//                     theme,
//                     title:
//                         "PST2 ${BaseController.to.restaurantDetails?.businessProfile.pstNumber2 ?? 0}% : ",
//                     value:
//                         "\$${controller.myOrder.totalPst2.toStringAsFixed(2)}",
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.orderType == "DINE_IN",
//                   child: _row(
//                     theme,
//                     title:
//                         "Gratuity ${controller.myOrder.gratuityPercentage ?? (BaseController.to.restaurantDetails?.businessProfile.gratuity ?? 0)}% : ",
//                     value:
//                         "\$${controller.myOrder.totalGratuity.toStringAsFixed(2)}",
//                     child: controller.myOrder.paymentStatus == "PAID"
//                         ? const SizedBox.shrink()
//                         : Row(
//                             children: [
//                               Container(
//                                 margin: const EdgeInsets.only(left: 4),
//                                 padding: const EdgeInsets.all(4.0),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     width: 1,
//                                     color:
//                                         theme.textTheme.labelLarge?.color ??
//                                         Colors.white,
//                                   ),
//                                 ),
//                                 child: InkWell(
//                                   child: const Icon(
//                                     Icons.edit_square,
//                                     color: StaticColors.greenColor,
//                                   ),
//                                   onTap: () {
//                                     PopupDialog.permissionDialog(
//                                       title: "Edit Gratuity?",
//                                       theme,
//                                       onSubmit: () async {
//                                         Get.back();
//                                         PopupDialog.customDialog(
//                                           width: 400,
//                                           child: EditGratuity(
//                                             isNewOrder:
//                                                 !controller.isUpdateView,
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ),
//                               SizedBox(width: 34),
//                               Visibility(
//                                 visible:
//                                     controller.myOrder.gratuityPercentage != 0,
//                                 child: Container(
//                                   margin: const EdgeInsets.only(left: 4),
//                                   padding: const EdgeInsets.all(4.0),
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       width: 1,
//                                       color:
//                                           theme.textTheme.labelLarge?.color ??
//                                           Colors.white,
//                                     ),
//                                   ),
//                                   child: InkWell(
//                                     child: const Icon(
//                                       Icons.delete,
//                                       color: StaticColors.redColor,
//                                     ),
//                                     onTap: () {
//                                       PopupDialog.permissionDialog(
//                                         title: "Delete Gratuity?",
//                                         theme,
//                                         onSubmit: () async {
//                                           controller.onDeleteGratuity();
//                                           Get.back();

//                                           if (controller.isUpdateView) {
//                                             PopupDialog.showLoadingDialog();
//                                             await PosController.to
//                                                 .onUpdateOrder(
//                                                   PosController.to.myOrder.id,
//                                                 );
//                                             PopupDialog.closeLoadingDialog();
//                                           }
//                                         },
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.tip > 0,
//                   child: _row(
//                     theme,
//                     title: "Tip : ",
//                     value: "\$${controller.myOrder.tip.toStringAsFixed(2)}",
//                   ),
//                 ),
//                 Visibility(
//                   visible:
//                       controller.myOrder.packagingCost > 0 &&
//                       controller.myOrder.carts.isNotEmpty,
//                   child: _row(
//                     theme,
//                     title:
//                         "${(BaseController.to.restaurantDetails?.restaurant.packagingCost.title) ?? ""}: ",
//                     value:
//                         "\$${controller.myOrder.packagingCost.toStringAsFixed(2)}",
//                     child: controller.myOrder.paymentStatus == "PAID"
//                         ? const SizedBox.shrink()
//                         : Container(
//                             margin: const EdgeInsets.only(left: 4),
//                             padding: const EdgeInsets.all(4.0),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 width: 1,
//                                 color:
//                                     theme.textTheme.labelLarge?.color ??
//                                     Colors.white,
//                               ),
//                             ),
//                             child: InkWell(
//                               child: const Icon(
//                                 Icons.delete,
//                                 color: StaticColors.redColor,
//                               ),
//                               onTap: () {
//                                 controller.onRemovePackagingCost();
//                               },
//                             ),
//                           ),
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.orderType == "DELIVERY",
//                   child: _row(
//                     theme,
//                     title: "Delivery Fee: ",
//                     value:
//                         "\$${controller.myOrder.deliveryFee.toStringAsFixed(2)}",
//                     child: controller.myOrder.paymentStatus == "PAID"
//                         ? const SizedBox.shrink()
//                         : Row(
//                             children: [
//                               Container(
//                                 margin: const EdgeInsets.only(left: 4),
//                                 padding: const EdgeInsets.all(4.0),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     width: 1,
//                                     color:
//                                         theme.textTheme.labelLarge?.color ??
//                                         Colors.white,
//                                   ),
//                                 ),
//                                 child: InkWell(
//                                   child: const Icon(
//                                     Icons.edit_square,
//                                     color: StaticColors.greenColor,
//                                   ),
//                                   onTap: () {
//                                     PopupDialog.permissionDialog(
//                                       title: "Edit Delivery Fee?",
//                                       theme,
//                                       onSubmit: () async {
//                                         Get.back();
//                                         PopupDialog.customDialog(
//                                           width: 400,
//                                           child: EditDeliveryFee(
//                                             isNewOrder:
//                                                 !controller.isUpdateView,
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ),
//                               SizedBox(width: 34),
//                               Visibility(
//                                 visible: controller.myOrder.deliveryFee != 0,
//                                 child: Container(
//                                   margin: const EdgeInsets.only(left: 4),
//                                   padding: const EdgeInsets.all(4.0),
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       width: 1,
//                                       color:
//                                           theme.textTheme.labelLarge?.color ??
//                                           Colors.white,
//                                     ),
//                                   ),
//                                   child: InkWell(
//                                     child: const Icon(
//                                       Icons.delete,
//                                       color: StaticColors.redColor,
//                                     ),
//                                     onTap: () {
//                                       PopupDialog.permissionDialog(
//                                         title: "Delete Delivery Fee?",
//                                         theme,
//                                         onSubmit: () async {
//                                           PosController.to
//                                               .onDeleteDeliveryFee();

//                                           Get.back();

//                                           if (controller.isUpdateView) {
//                                             PopupDialog.showLoadingDialog();
//                                             await PosController.to
//                                                 .onUpdateOrder(
//                                                   PosController.to.myOrder.id,
//                                                 );
//                                             PopupDialog.closeLoadingDialog();
//                                           }
//                                         },
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),
//                 Visibility(
//                   visible: controller.myOrder.maintenanceFee > 0,
//                   child: _row(
//                     theme,
//                     title: "Service Fee : ",
//                     value:
//                         "\$${controller.myOrder.maintenanceFee.toStringAsFixed(2)}",
//                   ),
//                 ),
//                 _row(
//                   theme,
//                   fontSize: 20,
//                   title: "Total : ",
//                   value:
//                       "\$ ${controller.myOrder.totalOrderAmount.toStringAsFixed(2)}",
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 12,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: GetBuilder<PosController>(
//                           builder: (controller) {
//                             return Tooltip(
//                               message: controller.myOrder.carts.isEmpty
//                                   ? 'No items to send order'
//                                   : "",
//                               child: PrimaryBtn(
//                                 onPressed: () async {
//                                   var myOrder = controller.myOrder
//                                       .toNonUpdate();

//                                   if (controller.isUpdateView) {
//                                     controller.myOrder.splitAmounts = [];
//                                     controller.myOrder.splitOrders = [];
//                                     controller.myOrder.splitOrderCarts = [];
//                                     PopupDialog.showLoadingDialog();
//                                     var isUpdated = await controller
//                                         .onUpdateOrder(
//                                           controller.myOrder.id,
//                                           isClearList: true,
//                                         );
//                                     PopupDialog.closeLoadingDialog();

//                                     if (isUpdated) {
//                                       PosController.to.isUpdateView = false;
//                                       controller.update();
//                                       kitchenPrint(myOrder);

//                                       DataUpdateHelper.getDataByCheckType();
//                                       PosController.to.onFocusGuestName();
//                                     }
//                                   } else {
//                                     await controller.onPlaseOrder();
//                                   }
//                                 },
//                                 textMaxSize: 26,
//                                 textMinSize: 24,
//                                 height: 70,
//                                 color: StaticColors.blueColor,
//                                 textColor: Colors.white,
//                                 text: controller.isUpdateView
//                                     ? "Update Order".toUpperCase()
//                                     : 'Send'.toUpperCase(),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // ignore: unused_element
// void _showTableDialog({required bool isUpdateView}) {
//   PopupDialog.customDialog(
//     width: Get.width * 0.80,
//     child: SizedBox(
//       width: Get.width * 0.80,
//       height: Get.height * 0.80,
//       child: TableManagmentView(
//         isScrollable: false,
//         isPOSPage: true,
//         isUpdateView: isUpdateView,
//       ),
//     ),
//   );
// }

// Widget _row(
//   ThemeData theme, {
//   double? fontSize,
//   FontWeight? fontWeight,
//   Widget? child,
//   required String title,
//   required String value,
// }) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Text(
//               title,
//               style: theme.textTheme.titleSmall?.copyWith(
//                 fontSize: fontSize ?? 16,
//                 fontWeight: fontWeight ?? FontWeight.w700,
//               ),
//             ),
//             SizedBox(child: child),
//           ],
//         ),
//         Text(
//           value,
//           style: theme.textTheme.titleSmall?.copyWith(
//             fontSize: fontSize ?? 16,
//             fontWeight: fontWeight ?? FontWeight.w700,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _modifiers(
//   ThemeData theme,
//   String value, {
//   int maxLines = 2,
//   bool isItalic = false,
//   String? title,
// }) {
//   return Visibility(
//     visible: value.contains(':') ? value.length > 6 : value != '',
//     child: Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
//       child: Text.rich(
//         maxLines: maxLines,
//         style: theme.textTheme.labelSmall?.copyWith(
//           fontWeight: FontWeight.bold,
//           fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
//         ),
//         TextSpan(
//           text: title,
//           children: [
//             TextSpan(
//               text: value.trim().toUpperCase(),
//               style: theme.textTheme.bodySmall?.copyWith(
//                 fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

// Future<OrderModel?> _firstOrder(String query, {bool isDelivery = false}) async {
//   try {
//     final res = await BaseController.to.apiService.makeGetRequest(
//       URLS.orders,
//       queryParameters: {
//         'limit': 1,
//         'search': query.trim(),
//         if (isDelivery) 'orderType': 'DELIVERY',
//       },
//     );
//     if (res.statusCode == 200) {
//       final data = (res.data['data'] as List)
//           .map((e) => OrderModel.fromJson(e))
//           .toList();
//       return data.isNotEmpty ? data.first : null;
//     }
//     return null;
//   } catch (e) {
//     kLogger.e('Order search error => $e');
//     return null;
//   }
// }

//TODO:3rd UI

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/kitchen_print.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/widgets/table_body.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/widgets/table_mapping_managment_view.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/product_model.dart';
import 'package:yogo_pos/app/modules/pos/order/widgets/cart_item.dart';
import 'package:yogo_pos/app/modules/pos/order/widgets/dialogs/address_dialog.dart';
import 'package:yogo_pos/app/modules/pos/order/widgets/variation.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/extension/order_extention.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/my_reg_exp.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/edit_delivery_fee.dart';
import 'package:yogo_pos/app/widgets/edit_gratuity.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class CartArea extends GetView<PosController> {
  final ThemeData theme;
  const CartArea(this.theme, {super.key});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: false,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: ConfigController.to.isLightTheme
              ? theme.cardColor
              : StaticColors.cartColor,
        ),
        child: GetBuilder<PosController>(
          builder: (controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 10),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 26,
                    children: List.generate(controller.orderTypeList.length, (
                      index,
                    ) {
                      String orderType = controller.orderTypeList[index];
                      return Visibility(
                        child: PrimaryBtn(
                          textColor: controller.orderType == orderType
                              ? Colors.white
                              : theme.textTheme.bodyLarge?.color,
                          isOutline: true,
                          borderColor: controller.orderType == orderType
                              ? StaticColors.blueColor
                              : theme.hintColor,
                          color: controller.orderType == orderType
                              ? StaticColors.blueColor
                              : Colors.transparent,
                          borderWidth: 1,
                          onPressed: () async {
                            if (controller.isUpdateView) return;
                            controller.myOrder.numberOfPeople = 1;

                            if (orderType != "DELIVERY") {
                              controller.addressController.clear();
                              controller.selectedLat = null;
                              controller.selectedLon = null;
                              controller.additionalDetailsController.clear();
                              controller.myOrder.deliveryFee = 0;
                            }

                            controller.tableController.clear();
                            controller.guestController.clear();
                            controller.myOrder.table = "";
                            controller.myOrder.tableName = "";
                            controller.onChangeOrderType(orderType);
                            controller.onFocusGuestName();

                            if (orderType == "DINE_IN") {
                              controller.onRemovePackagingCost();
                            } else if (orderType == "DELIVERY") {
                              controller.onAddPackagingCost();
                              String phone =
                                  controller.guestPhoneController.text;
                              if (phone.isNotEmpty && phone.length == 10) {
                                var order = await _firstOrder(
                                  phone,
                                  isDelivery: true,
                                );
                                if (order != null) {
                                  controller.addressController.text =
                                      order.delivery?.address ?? "";
                                  controller.additionalDetailsController.text =
                                      order.delivery?.additionalDetails ?? "";
                                  controller.selectedLat =
                                      order.delivery?.latitude;
                                  controller.selectedLon =
                                      order.delivery?.longitude;

                                  if (controller
                                      .guestNameController
                                      .text
                                      .isEmpty) {
                                    controller.guestNameController.text =
                                        order.guestName;
                                  }
                                  controller.myOrder.deliveryFee =
                                      order.deliveryFee;
                                }
                              }
                            } else {
                              controller.onAddPackagingCost();
                            }
                            controller.calculateTotalPrice();
                          },
                          text: orderType.replaceAll("_", "-").toUpperCase(),
                        ),
                      );
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          allowRegex:
                              CommonRegexPatterns.alphanumericWithSpaceAndLength(
                                18,
                              ),
                          readOnly: controller.isGuestNameReadOnly,
                          focusNode: controller.guestNameFocusNode,
                          controller: controller.guestNameController,
                          hintText: "Guest Name",
                          onTap: () {
                            if (controller.isGuestNameReadOnly) {
                              PopupDialog.permissionDialog(
                                theme,
                                onSubmit: () {
                                  controller.isGuestNameReadOnly = false;
                                  Get.back();
                                  controller.update();
                                  if (Preferences.customKeyboard) {
                                    AppKeyboard.open(
                                      context,
                                      keyboardType: KeyboardType.alphaNumeric,
                                      controller:
                                          controller.guestNameController,
                                      allowRegex:
                                          CommonRegexPatterns.alphanumericWithSpaceAndLength(
                                            18,
                                          ),
                                    );
                                  }
                                },
                                title: "Change Guest's Name?",
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          keyboardType: KeyboardType.numeric,
                          readOnly: controller.isGuestPhoneReadOnly,
                          controller: controller.guestPhoneController,
                          focusNode: controller.guestPhoneFocusNode,
                          hintText: "Phone Number",
                          allowRegex: CommonRegexPatterns.digitsOnlyWithLength(
                            10,
                          ),
                          onChange: (value) async {
                            if (value.length == 10 &&
                                controller.isUpdateView == false &&
                                controller.orderType == 'DELIVERY') {
                              var order = await _firstOrder(
                                value,
                                isDelivery: true,
                              );
                              if (order != null) {
                                controller.addressController.text =
                                    order.delivery?.address ?? "";
                                controller.additionalDetailsController.text =
                                    order.delivery?.additionalDetails ?? "";
                                controller.selectedLat =
                                    order.delivery?.latitude;
                                controller.selectedLon =
                                    order.delivery?.longitude;
                                if (controller
                                    .guestNameController
                                    .text
                                    .isEmpty) {
                                  controller.guestNameController.text =
                                      order.guestName;
                                }
                                controller.myOrder.deliveryFee =
                                    order.deliveryFee;
                                controller.calculateTotalPrice();
                              }
                            }
                          },
                          onKeyboardChang: (value) async {
                            if (value.length == 10 &&
                                controller.isUpdateView == false &&
                                controller.orderType == 'DELIVERY') {
                              var order = await _firstOrder(
                                value,
                                isDelivery: true,
                              );
                              if (order != null) {
                                controller.addressController.text =
                                    order.delivery?.address ?? "";
                                controller.additionalDetailsController.text =
                                    order.delivery?.additionalDetails ?? "";
                                controller.selectedLat =
                                    order.delivery?.latitude;
                                controller.selectedLon =
                                    order.delivery?.longitude;
                                if (controller
                                    .guestNameController
                                    .text
                                    .isEmpty) {
                                  controller.guestNameController.text =
                                      order.guestName;
                                }
                                controller.myOrder.deliveryFee =
                                    order.deliveryFee;
                                controller.calculateTotalPrice();
                              }
                            }
                          },
                          onTap: () {
                            if (controller.isGuestPhoneReadOnly) {
                              PopupDialog.permissionDialog(
                                theme,
                                onSubmit: () {
                                  controller.isGuestPhoneReadOnly = false;
                                  Get.back();
                                  controller.update();
                                  if (Preferences.customKeyboard) {
                                    AppKeyboard.open(
                                      context,
                                      keyboardType: KeyboardType.numeric,
                                      controller:
                                          controller.guestPhoneController,
                                      allowRegex:
                                          CommonRegexPatterns.digitsOnlyWithLength(
                                            10,
                                          ),
                                    );
                                  }
                                },
                                title: "Change Phone Number?",
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Visibility(
                  visible: controller.orderType == "DINE_IN",
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            readOnly: true,
                            focusNode: controller.tableFocusNode,
                            controller: controller.tableController,
                            hintText: "Table / Bar",
                            prefixText:
                                controller.tableController.text.isNotEmpty
                                ? "Table: "
                                : null,
                            onTap: () {
                              if (controller.isUpdateView) {
                                PopupDialog.permissionDialog(
                                  theme,
                                  onSubmit: () {
                                    controller.isTableReadOnly = false;
                                    Get.back();
                                    DineInController.to.getTableCategories();
                                    PopupDialog.customDialog(
                                      width: Get.width * 0.8,
                                      height: Get.height * .85,
                                      child: const TableBody(
                                        isScrollable: true,
                                        isPOSPage: true,
                                        isUpdateView: true,
                                      ),
                                    );
                                  },
                                  title: "Change Table?",
                                );
                              } else {
                                DineInController.to.getTableCategories();
                                PopupDialog.customDialog(
                                  width: Get.width * 0.8,
                                  height: Get.height * .85,
                                  child: const TableBody(
                                    isScrollable: true,
                                    isPOSPage: true,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            readOnly: controller.isGuestReadOnly,
                            keyboardType: KeyboardType.numeric,
                            controller: controller.guestController,
                            allowRegex:
                                CommonRegexPatterns.digitsOnlyWithLength(2),
                            focusNode: controller.guestFocusNode,
                            hintText: "No. of Guests ",
                            prefixText:
                                controller.guestController.text.isNotEmpty
                                ? "Guest: "
                                : null,
                            onTap: () {
                              if (controller.isGuestReadOnly) {
                                PopupDialog.permissionDialog(
                                  theme,
                                  onSubmit: () {
                                    controller.isGuestReadOnly = false;
                                    Get.back();
                                    if (Preferences.customKeyboard) {
                                      AppKeyboard.open(
                                        context,
                                        keyboardType: KeyboardType.numeric,
                                        controller: controller.guestController,
                                        allowRegex:
                                            CommonRegexPatterns.digitsOnlyWithLength(
                                              2,
                                            ),
                                      );
                                    }
                                  },
                                  title: "Change no. of Guests?",
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: controller.orderType == "DELIVERY",
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 12,
                    ),
                    child: CustomTextField(
                      controller: controller.addressController,
                      hintText: "Delivery Address",
                      focusNode: controller.addressFocusNode,
                      readOnly: true,
                      maxLines: 2,
                      onTap: () => WoltModalSheet.show(
                        context: context,
                        modalTypeBuilder: (_) => LeftSideSheetType(),
                        pageListBuilder: (context) => [
                          addressDialog(
                            context,
                            theme,
                            controller.addressController.text,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible:
                      controller.selectedLat != null &&
                      controller.selectedLon != null &&
                      controller.orderType == "DELIVERY",
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 12,
                    ),
                    child: CustomTextField(
                      controller: controller.additionalDetailsController,
                      focusNode: controller.additionalDetailsFocusNode,
                      allowRegex:
                          CommonRegexPatterns.alphanumericWithSpaceAndLength(
                            200,
                          ),
                      hintText:
                          "Additional Delivery Info. (e.g. Floor No., Unit No., Buzzer Code)",
                      maxLines: 2,
                    ),
                  ),
                ),
                Visibility(
                  visible:
                      controller.orderType == "TAKEOUT" ||
                      controller.orderType == "DELIVERY",
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: CustomTextField(
                      controller: controller.notesController,
                      focusNode: controller.notesFocusNode,
                      hintText: "Order Notes (Optional)",
                      maxLines: 1,
                      allowRegex:
                          CommonRegexPatterns.alphanumericWithSpaceAndLength(
                            200,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SlidableAutoCloseBehavior(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      controller: controller.cartListScrollController,
                      shrinkWrap: true,
                      itemCount: controller.myOrder.carts.length,
                      itemBuilder: (context, index) {
                        var data = controller.myOrder.carts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          // ClipRRect stops the item content from overflowing
                          // outside its bounds while it is being swiped.
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Slidable(
                              enabled: !controller.isUpdateView,
                              key: ValueKey(data.id),
                              // Right swipe -> Repeat (left side)
                              startActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                extentRatio: 0.28,
                                children: [
                                  CustomSlidableAction(
                                    onPressed: (_) {
                                      controller.onRepeatCartItemWithIndex(
                                        index,
                                      );
                                    },
                                    backgroundColor: StaticColors.greenColor
                                        .withAlpha(10),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    child: Center(
                                      child: Container(
                                        width: 90,
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                          top: 4,
                                          bottom: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          color: StaticColors.greenColor,
                                        ),
                                        child: const Text(
                                          "Repeat",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Left swipe -> Remove (right side)
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                extentRatio: 0.28,
                                children: [
                                  CustomSlidableAction(
                                    onPressed: (_) {
                                      controller.clearModifier();
                                      controller.selectedItemList.clear();
                                      controller.onRemoveCartItemWithIndex(
                                        index,
                                      );
                                    },
                                    backgroundColor: StaticColors.greenColor
                                        .withAlpha(10),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    child: Center(
                                      child: Container(
                                        width: 90,
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                          top: 4,
                                          bottom: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          color: StaticColors.redColor,
                                        ),
                                        child: const Text(
                                          "Remove",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Builder so we can read the Slidable's animation
                              // and highlight the item while it is being swiped.
                              child: Builder(
                                builder: (slidableContext) {
                                  final slidable = Slidable.of(slidableContext);
                                  final anim =
                                      slidable?.animation ??
                                      const AlwaysStoppedAnimation<double>(0);
                                  return AnimatedBuilder(
                                    animation: anim,
                                    builder: (context, child) {
                                      final isSwiping =
                                          anim.value.abs() > 0.001;
                                      return DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: isSwiping
                                              ? const Color.fromARGB(
                                                  80,
                                                  139,
                                                  139,
                                                  139,
                                                ).withAlpha(60)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: child,
                                      );
                                    },
                                    child: CartItem(
                                      itemIndex: index,
                                      id: data.id,
                                      weight: data.weight,
                                      isUpdated: data.isUpdated,
                                      title: data.isCustomProduct
                                          ? "${data.name} (CUSTOM)"
                                          : data.name,
                                      amount: data.price,
                                      quantity: data.quantity,
                                      options: data.variationOptions,
                                      modifiers: data.modifiers,
                                      discount: data.discount,
                                      note: data.kitchenNote,
                                      onRemove: () {
                                        controller.clearModifier();
                                        controller.onRemoveCartItemWithIndex(
                                          index,
                                        );
                                      },
                                      onTap: () {
                                        controller.cartId = data.id;
                                        controller.onChangeSelectedItemList(
                                          data.id,
                                        );
                                        controller.update();
                                        if (controller
                                            .selectedItemList
                                            .isEmpty) {
                                          return;
                                        }
                                        String firstCartId =
                                            controller.selectedItemList.first;

                                        CartModel
                                        cart = controller.myOrder.carts.firstWhere(
                                          (c) => c.id == firstCartId,
                                          orElse: () => throw Exception(
                                            "Cart not found for ID: $firstCartId",
                                          ),
                                        );
                                        controller.selectedModifiers.assignAll(
                                          cart.modifiers,
                                        );
                                      },
                                      onDoubleTap: () {},
                                      onLongPress: () {
                                        controller.cartId = data.id;
                                        controller.onChangeSelectedItemList(
                                          data.id,
                                          isLongPress: true,
                                        );
                                        controller.update();
                                        if (controller
                                            .selectedItemList
                                            .isEmpty) {
                                          return;
                                        }
                                        String firstCartId =
                                            controller.selectedItemList.first;

                                        CartModel
                                        cart = controller.myOrder.carts.firstWhere(
                                          (c) => c.id == firstCartId,
                                          orElse: () => throw Exception(
                                            "Cart not found for ID: $firstCartId",
                                          ),
                                        );
                                        controller.selectedModifiers.assignAll(
                                          cart.modifiers,
                                        );
                                        ProductModel item = PosController
                                            .to
                                            .mainProductList
                                            .where((p) => p.id == data.itemId)
                                            .first;
                                        if (item.variations.isEmpty) {
                                          return;
                                        }

                                        try {
                                          PopupDialog.customDialog(
                                            hasScroll: false,
                                            width:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).width *
                                                0.8,
                                            height:
                                                MediaQuery.sizeOf(
                                                  context,
                                                ).height *
                                                0.85,
                                            child: Variation(
                                              activeOptions:
                                                  data.variationOptions,
                                              initialQuantity: data.quantity,
                                              item: item.copyWith(
                                                variations: item.variations
                                                    .where(
                                                      (v) =>
                                                          v.posVariationOn ==
                                                          true,
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                          );
                                        } catch (e, st) {
                                          if (kDebugMode) {
                                            kLogger.e(
                                              "Error finding product for variation: $e",
                                            );
                                            kLogger.e(
                                              "Error finding product for variation: $st",
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                _modifiers(
                  theme,
                  PosController.to.myOrder.discountReason,
                  title: "Discount Reason: ",
                  isItalic: true,
                  maxLines: 5,
                ),
                const Divider(thickness: .5, height: 1),
                SizedBox(height: 5),
                _row(
                  theme,
                  title: "Subtotal : ",
                  value: "\$${controller.myOrder.subTotal.toStringAsFixed(2)}",
                ),
                Visibility(
                  visible: controller.myOrder.totalDiscount > 0,
                  child: _row(
                    theme,
                    title: "Discount : ",
                    value:
                        "(-)  \$${controller.myOrder.totalDiscount.toStringAsFixed(2)}",
                    child: controller.myOrder.payment != null
                        ? const SizedBox()
                        : InkWell(
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
                              child: const Icon(
                                Icons.delete,
                                color: StaticColors.redColor,
                                size: 20,
                              ),
                            ),
                            onTap: () {
                              PosController.to.deleteDiscount();
                            },
                          ),
                  ),
                ),
                Visibility(
                  visible: controller.myOrder.totalGst > 0,
                  child: _row(
                    theme,
                    title:
                        "GST ${BaseController.to.restaurantDetails?.businessProfile.gstNumber ?? 0}% : ",
                    value:
                        "\$${controller.myOrder.totalGst.toStringAsFixed(2)}",
                  ),
                ),
                Visibility(
                  visible: controller.myOrder.totalPst > 0,
                  child: _row(
                    theme,
                    title:
                        "PST ${BaseController.to.restaurantDetails?.businessProfile.pstNumber ?? 0}% : ",
                    value:
                        "\$${controller.myOrder.totalPst.toStringAsFixed(2)}",
                  ),
                ),
                Visibility(
                  visible: controller.myOrder.totalPst2 > 0,
                  child: _row(
                    theme,
                    title:
                        "PST2 ${BaseController.to.restaurantDetails?.businessProfile.pstNumber2 ?? 0}% : ",
                    value:
                        "\$${controller.myOrder.totalPst2.toStringAsFixed(2)}",
                  ),
                ),
                Visibility(
                  visible: controller.myOrder.orderType == "DINE_IN",
                  child: _row(
                    theme,
                    title:
                        "Gratuity ${controller.myOrder.gratuityPercentage ?? (BaseController.to.restaurantDetails?.businessProfile.gratuity ?? 0)}% : ",
                    value:
                        "\$${controller.myOrder.totalGratuity.toStringAsFixed(2)}",
                    child: controller.myOrder.paymentStatus == "PAID"
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
                                            isNewOrder:
                                                !controller.isUpdateView,
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
                                    controller.myOrder.gratuityPercentage != 0,
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
                                          controller.onDeleteGratuity();
                                          Get.back();

                                          if (controller.isUpdateView) {
                                            PopupDialog.showLoadingDialog();
                                            await PosController.to
                                                .onUpdateOrder(
                                                  PosController.to.myOrder.id,
                                                );
                                            PopupDialog.closeLoadingDialog();
                                          }
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
                  visible: controller.myOrder.tip > 0,
                  child: _row(
                    theme,
                    title: "Tip : ",
                    value: "\$${controller.myOrder.tip.toStringAsFixed(2)}",
                  ),
                ),
                Visibility(
                  visible:
                      controller.myOrder.packagingCost > 0 &&
                      controller.myOrder.carts.isNotEmpty,
                  child: _row(
                    theme,
                    title:
                        "${(BaseController.to.restaurantDetails?.restaurant.packagingCost.title) ?? ""}: ",
                    value:
                        "\$${controller.myOrder.packagingCost.toStringAsFixed(2)}",
                    child: controller.myOrder.paymentStatus == "PAID"
                        ? const SizedBox.shrink()
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
                            child: InkWell(
                              child: const Icon(
                                Icons.delete,
                                color: StaticColors.redColor,
                              ),
                              onTap: () {
                                controller.onRemovePackagingCost();
                              },
                            ),
                          ),
                  ),
                ),
                Visibility(
                  visible: controller.myOrder.orderType == "DELIVERY",
                  child: _row(
                    theme,
                    title: "Delivery Fee: ",
                    value:
                        "\$${controller.myOrder.deliveryFee.toStringAsFixed(2)}",
                    child: controller.myOrder.paymentStatus == "PAID"
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
                                            isNewOrder:
                                                !controller.isUpdateView,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 34),
                              Visibility(
                                visible: controller.myOrder.deliveryFee != 0,
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

                                          Get.back();

                                          if (controller.isUpdateView) {
                                            PopupDialog.showLoadingDialog();
                                            await PosController.to
                                                .onUpdateOrder(
                                                  PosController.to.myOrder.id,
                                                );
                                            PopupDialog.closeLoadingDialog();
                                          }
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
                  visible: controller.myOrder.maintenanceFee > 0,
                  child: _row(
                    theme,
                    title: "Service Fee : ",
                    value:
                        "\$${controller.myOrder.maintenanceFee.toStringAsFixed(2)}",
                  ),
                ),
                _row(
                  theme,
                  fontSize: 20,
                  title: "Total : ",
                  value:
                      "\$ ${controller.myOrder.totalOrderAmount.toStringAsFixed(2)}",
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GetBuilder<PosController>(
                          builder: (controller) {
                            return Tooltip(
                              message: controller.myOrder.carts.isEmpty
                                  ? 'No items to send order'
                                  : "",
                              child: PrimaryBtn(
                                onPressed: () async {
                                  var myOrder = controller.myOrder
                                      .toNonUpdate();

                                  if (controller.isUpdateView) {
                                    controller.myOrder.splitAmounts = [];
                                    controller.myOrder.splitOrders = [];
                                    controller.myOrder.splitOrderCarts = [];
                                    PopupDialog.showLoadingDialog();
                                    var isUpdated = await controller
                                        .onUpdateOrder(
                                          controller.myOrder.id,
                                          isClearList: true,
                                        );
                                    PopupDialog.closeLoadingDialog();

                                    if (isUpdated) {
                                      PosController.to.isUpdateView = false;
                                      controller.update();
                                      kitchenPrint(myOrder);

                                      DataUpdateHelper.getDataByCheckType();
                                      PosController.to.onFocusGuestName();
                                    }
                                  } else {
                                    await controller.onPlaseOrder(
                                      isDirectPay: false,
                                      isSendOrder: true,
                                    );
                                  }
                                },
                                textMaxSize: 26,
                                textMinSize: 24,
                                height: 70,
                                color: StaticColors.blueColor,
                                textColor: Colors.white,
                                text: controller.isUpdateView
                                    ? "Update Order".toUpperCase()
                                    : 'Send'.toUpperCase(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ignore: unused_element
void _showTableDialog({required bool isUpdateView}) {
  PopupDialog.customDialog(
    width: Get.width * 0.80,
    child: SizedBox(
      width: Get.width * 0.80,
      height: Get.height * 0.80,
      child: TableManagmentView(
        isScrollable: false,
        isPOSPage: true,
        isUpdateView: isUpdateView,
      ),
    ),
  );
}

Widget _row(
  ThemeData theme, {
  double? fontSize,
  FontWeight? fontWeight,
  Widget? child,
  required String title,
  required String value,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: fontSize ?? 16,
                fontWeight: fontWeight ?? FontWeight.w700,
              ),
            ),
            SizedBox(child: child),
          ],
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontSize: fontSize ?? 16,
            fontWeight: fontWeight ?? FontWeight.w700,
          ),
        ),
      ],
    ),
  );
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

Future<OrderModel?> _firstOrder(String query, {bool isDelivery = false}) async {
  try {
    final res = await BaseController.to.apiService.makeGetRequest(
      URLS.orders,
      queryParameters: {
        'limit': 1,
        'search': query.trim(),
        if (isDelivery) 'orderType': 'DELIVERY',
      },
    );
    if (res.statusCode == 200) {
      final data = (res.data['data'] as List)
          .map((e) => OrderModel.fromJson(e))
          .toList();
      return data.isNotEmpty ? data.first : null;
    }
    return null;
  } catch (e) {
    kLogger.e('Order search error => $e');
    return null;
  }
}
