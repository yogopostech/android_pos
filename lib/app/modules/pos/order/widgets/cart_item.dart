import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/custom_keyboard/controllers/custom_keyboard_controller.dart';
import 'package:yogo_pos/app/modules/custom_keyboard/custom_keyboard.dart';
import 'package:yogo_pos/app/modules/custom_keyboard/views/custom_keyboard_view.dart';
import 'package:yogo_pos/app/modules/custom_keyboard/views/number_keyboard_view.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/discount_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/option_model.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/discount_extention.dart';
import 'package:yogo_pos/app/utils/extension/string_manipulation_extension.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:get/get.dart';
import '../../../../widgets/my_custom_text.dart';

class CartItem extends StatefulWidget {
  const CartItem({
    super.key,
    required this.title,
    required this.onTap,
    required this.itemIndex,
    required this.id,
    required this.note,
    required this.amount,
    required this.quantity,
    required this.isUpdated,
    required this.options,
    required this.weight,
    required this.onRemove,
    this.onDecrement,
    this.onIncrement,
    required this.discount,
    this.onLongPress,
    this.onDoubleTap,
    required this.modifiers,
  });
  final Function()? onTap;
  final String title;
  final List<OptionModel> options;
  final String note;
  final num amount;
  final num weight;
  final int itemIndex;
  final String id;
  final List<String> modifiers;
  final bool isUpdated;
  final num quantity;
  final Discount discount;
  final VoidCallback onRemove;
  final Function()? onLongPress;
  final Function()? onDoubleTap;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  final controller = Get.find<PosController>();
  late bool allowPriceChange;

  num myPrice = 0;
  bool showBorder = false;
  Timer? _holdTimer;
  void showNumberKeyboardDialog(int index) async {
    await Get.dialog(
      barrierColor: Colors.transparent,
      NumberKeyboardView(
        // initialValue: "$qty",
        regExp: RegExp(r'^(?:[0-9]{0,2})(?:\.(?:[0-9]|[0-9][05])?)?$'),
        onChange: (value) {
          num? quantity = num.tryParse(
            CustomKeyboardController.to.keyboardValue,
          );
          debugPrint("quantity is $quantity");
          if (quantity != null) {
            if (quantity < .1) {
              quantity = 1;
            }
            controller.quantityUpdateWithCartListIndex(index, quantity);
          } else {
            controller.quantityUpdateWithCartListIndex(index, 1);
          }
        },
      ),
    );
  }

  void _showCustomDialog() async {
    await Get.dialog(
      barrierColor: Colors.transparent,
      CustomKeyboardView(
        keyboardType: KeyboardType.number,
        changeKeybordType: true,
        onChange: (value) {
          myPrice = num.parse(value.toDecimalFormat());
          controller.myOrder.carts[widget.itemIndex].price = myPrice;
          controller.calculateTotalPrice();
          controller.update();
          // setState(() {});
        },
        regExp: RegExp(r'^\d{0,6}$'),
        initialValue: "${(myPrice * 100).toInt()}",
      ),
    );
    // Hide the border after the dialog is closed
    setState(() {
      showBorder = false;
    });
  }

  bool isQuantityButttonSelect = true;
  @override
  void initState() {
    myPrice = widget.amount;
    allowPriceChange =
        BaseController.to.restaurantDetails?.restaurant.allowPriceChange ??
        false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return InkWell(
      onLongPress: widget.onLongPress,
      onDoubleTap: widget.onDoubleTap,
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: controller.selectedItemList.contains(widget.id)
              ? const Color.fromARGB(80, 139, 139, 139).withAlpha(60)
              : widget.isUpdated
              ? const Color.fromARGB(80, 139, 139, 139)
              : Colors.transparent,
          borderRadius: controller.selectedItemList.contains(widget.id)
              ? BorderRadius.circular(6)
              : BorderRadius.circular(6),
          border: Border.all(
            width: 1,
            color: controller.selectedItemList.contains(widget.id)
                ? theme.hintColor
                : Colors.transparent,
          ),
        ),

        // margin: const EdgeInsets.only(bottom: 10),
        // color: widget.isUpdated
        //     ? const Color.fromARGB(80, 139, 139, 139)
        //     : Colors.transparent,

        // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.only(left: 12, right: 2, top: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 3),
                      MyCustomText(
                        widget.title.toUpperCase(),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        maxLines: 2,
                        height: 1.5,
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Visibility(
                  visible: !widget.isUpdated,
                  replacement: Container(
                    width: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    // decoration:
                    //     BoxDecoration(border: Border.all(color: theme.hintColor)),
                    child: Center(
                      child: MyCustomText(
                        widget.quantity.toString(),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Center(
                        child: Visibility(
                          visible: widget.weight > 0,
                          replacement: InkWell(
                            onTap: () {
                              showNumberKeyboardDialog(widget.itemIndex);
                            },
                            child: IntrinsicHeight(
                              child: Container(
                                color: Colors.transparent,

                                // height: double.infinity,
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  bottom: 20,
                                ),
                                child: Container(
                                  // width: isQuantityButttonSelect ? 50 : 70,
                                  width: 70,
                                  height: 30,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    // color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: theme.hintColor),
                                  ),
                                  child: Center(
                                    child: MyCustomText(
                                      widget.quantity.toString(),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text.rich(
                              style: theme.textTheme.labelLarge,
                              TextSpan(
                                text: widget.weight.toString(),
                                children: [
                                  TextSpan(
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    text: "LB",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // SizedBox(width: 8),
                GestureDetector(
                  onLongPressStart: (details) {
                    if (allowPriceChange) {
                      // Start a timer for 2 seconds
                      _holdTimer = Timer(const Duration(seconds: 1), () {
                        setState(() {
                          showBorder = true; // Show the border after 2 seconds
                        });
                        _showCustomDialog(); // Show the custom dialog
                      });
                    }
                  },
                  onLongPressEnd: (details) {
                    // Cancel the timer if the user releases early
                    _holdTimer?.cancel();
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(6),
                    //   border: Border.all(
                    //       color: showBorder
                    //           ? theme.hintColor
                    //           : Colors.transparent),
                    // ),
                    height: 40,
                    width: 90,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: MyCustomText(
                        widget.weight > 0
                            ? (widget.amount * widget.weight).toStringAsFixed(2)
                            : (widget.amount * widget.quantity).toStringAsFixed(
                                2,
                              ),
                        fontSize: showBorder ? 22 : 18,
                        fontWeight: showBorder
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                6.width,
              ],
            ).marginOnly(bottom: 2),
            Visibility(
              visible: widget.options.isNotEmpty,
              child: Column(
                children: List.generate(widget.options.length, (index) {
                  OptionModel optionData = widget.options[index];
                  // print("card id from cartSection ${PosController.to.cartId}");
                  // PosController.to.cartId;
                  return Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "${MyFunc.capitalizeEachWord(s: optionData.name)}: ",
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          "\$${optionData.price.toStringAsFixed(2)}x${optionData.quantity}",
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ).marginOnly(right: 10);
                }),
              ).marginOnly(bottom: 4),
            ),
            Visibility(
              visible: widget.modifiers.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(right: 150, bottom: 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: List.generate(widget.modifiers.length, (index) {
                    return Container(
                      // margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.only(
                        left: 3,
                        top: 2,
                        bottom: 2,
                        right: 0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: .5,
                          color: theme.colorScheme.surface,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        // color: StaticColors.purpleColor,
                      ),
                      child:
                          // MyCustomText(
                          //   widget.modifiers[index].trim().toUpperCase(),
                          //   color: StaticColors.greenColor,
                          //   fontSize: 11,
                          // ),
                          Text(
                            widget.modifiers[index].trim().toUpperCase(),
                            style: theme.textTheme.bodySmall,
                          ).marginOnly(right: 5),
                    );
                  }),
                ),
              ),
            ),
            Visibility(
              visible: widget.discount.value > 0,
              child: Text(
                "Discount: ${widget.discount.displayValue}",
                style: theme.textTheme.labelMedium,
              ),
            ),
            _modifiers(
              theme,
              widget.note,
              maxLines: 5,
              isItalic: true,
              title: "NOTE : ",
            ),
          ],
        ),
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
}
