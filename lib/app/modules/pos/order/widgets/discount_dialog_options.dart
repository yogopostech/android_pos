import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:get/get.dart';

class DiscountDialogOptions extends StatefulWidget {
  const DiscountDialogOptions({super.key});

  @override
  State<DiscountDialogOptions> createState() => _DiscountDialogOptionsState();
}

class _DiscountDialogOptionsState extends State<DiscountDialogOptions> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int quantity = 1;
  num orderTotalPrice = 0;

  //** Calculate Price **
  void onCalculatTotalPrice(String value) {
    if (value.isNotEmpty) {
      orderTotalPrice = num.parse(value) * quantity;
    } else {
      orderTotalPrice = 0;
    }
    setState(() {});
  }

  //** Update quantity **
  void updateOrderQuantity(bool isIncrease) {
    if (_priceController.text.isNotEmpty) {
      if (isIncrease && quantity < 10) {
        quantity++;
        orderTotalPrice = num.parse(_priceController.text) * quantity;
      } else if (!isIncrease && quantity > 1) {
        quantity--;
        orderTotalPrice = num.parse(_priceController.text) * quantity;
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyCustomText(
                    'Discount Type',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyCustomText(
                    'Discount',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(height: 4),
                  CustomTextField(
                    controller: _priceController,
                    maxLines: 1,
                    isFilled: true,
                    onChange: (value) {
                      onCalculatTotalPrice(value);
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(4),
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]'))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        //description
        MyCustomText(
          'Reason',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        const SizedBox(height: 4),
        CustomTextField(
          controller: _descriptionController,
          maxLines: 5,
          isFilled: true,
        ),
        const SizedBox(height: 14),
        //quantity row
        MyCustomText(
          'Access Pin',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
        const SizedBox(height: 4),
        const CustomTextField(
          // controller: _descriptionController,
          maxLines: 1, obscureText: true,
          isFilled: true,
        ),
        const SizedBox(height: 28),
        //order button
        Center(
          child: PrimaryBtn(
            onPressed: () {
              Get.back();
            },
            text: 'Apply',
            textColor: Colors.white,
            textMaxSize: 20,
            textMinSize: 16,
          ),
        ),
      ],
    );
  }
}
