import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/custom_keyboard/custom_keyboard.dart';
import 'package:yogo_pos/app/modules/custom_keyboard/views/custom_keyboard_view.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/utils/extension/string_manipulation_extension.dart';

class DeliveryFeeRow extends StatefulWidget {
  final num deliveryFee;

  const DeliveryFeeRow({super.key, required this.deliveryFee});

  @override
  State<DeliveryFeeRow> createState() => _DeliveryFeeRowState();
}

class _DeliveryFeeRowState extends State<DeliveryFeeRow> {
  bool allowDeliveryFeeChange = false;

  num myDeliveryFeeChange = 0;
  bool showBorder = false;
  Timer? _holdTimer;

  void _showCustomDialog() async {
    await Get.dialog(
      barrierColor: Colors.transparent,
      CustomKeyboardView(
        keyboardType: KeyboardType.number,
        changeKeybordType: true,
        onChange: (value) {
          myDeliveryFeeChange = num.parse(value.toDecimalFormat());
          PosController.to.myOrder.deliveryFee = myDeliveryFeeChange;
          PosController.to.calculateTotalPrice();
          PosController.to.update();
          setState(() {});
        },
        regExp: RegExp(r'^\d{0,6}$'),
        initialValue: "${(myDeliveryFeeChange * 100).toInt()}",
      ),
    );
    // Hide the border after the dialog is closed
    setState(() {
      showBorder = false;
    });
  }

  @override
  void initState() {
    myDeliveryFeeChange = widget.deliveryFee;
    // allowDeliveryFeeChange =
    //     BaseController.to.restaurantDetails?.restaurant.deliveryAudited ??
    //         false;
    allowDeliveryFeeChange = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Delivery Fee:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onLongPressStart: (details) {
              if (allowDeliveryFeeChange) {
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
            child: Text(
              '\$${widget.deliveryFee.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 16,
                fontWeight: showBorder ? FontWeight.w900 : FontWeight.w700,
                decoration: showBorder
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: theme.primaryColor,
                decorationThickness: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
