import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/split_order_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/my_reg_exp.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import '../../../../../widgets/custom_textfield.dart';

class SplitDialogs {
  SplitDialogs._();

  static selectNumberOfGuest({
    required TextEditingController guestController,
    required TextEditingController amountController,
    required VoidCallback onTap,
  }) {
    PopupDialog.customDialog(
        width: 900,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: CustomTextField(
                    controller: guestController,
                    initOpenKeyboard: true,
                    keyboardType: KeyboardType.numeric,
                    extraLabel: 'Number of Guests:',
                    allowRegex: CommonRegexPatterns.digitsOnlyWithLength(2),
                    extraLabelFontSize: 22,
                    hintText: '',
                    autofocus: true,
                    style: const TextStyle(fontSize: 30),
                    padding: const EdgeInsets.symmetric(
                        vertical: 26, horizontal: 22),
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                      child: CustomTextField(
                    controller: amountController,
                    extraLabel:
                        SplitOrderController.to.order.orderType == "TAKEOUT"
                            ? "Total Amount(- Packaging Cost)"
                            : "Total Amount",
                    extraLabelFontSize: 22,
                    hintText: '',
                    readOnly: true,
                    style: const TextStyle(fontSize: 30),
                    padding: const EdgeInsets.symmetric(
                        vertical: 26, horizontal: 22),
                  )),
                  const SizedBox(width: 16),
                  PrimaryBtnWithChild(
                    onPressed: onTap,
                    height: 115,
                    width: 128,
                    padding: const EdgeInsets.all(4.0),
                    color: StaticColors.blueColor,
                    child: const FittedBox(
                      child: MyCustomText(
                        'Submit',
                        fontSize: 100,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  static guestName({
    required TextEditingController guestController,
    required VoidCallback onTap,
  }) {
    PopupDialog.customDialog(
        width: 700,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: CustomTextField(
                    controller: guestController,
                    initOpenKeyboard: true,
                    extraLabel: 'Guest Name:',
                    extraLabelFontSize: 32,
                    allowRegex:
                        CommonRegexPatterns.alphanumericWithSpaceAndLength(25),
                    hintText: '',
                    autofocus: true,
                    style: const TextStyle(fontSize: 48),
                    padding: const EdgeInsets.symmetric(
                        vertical: 26, horizontal: 22),
                  )),
                  const SizedBox(width: 16),
                  PrimaryBtnWithChild(
                    onPressed: onTap,
                    height: 115,
                    width: 128,
                    color: StaticColors.blueColor,
                    padding: const EdgeInsets.all(4.0),
                    child: const FittedBox(
                      child: MyCustomText(
                        'Submit',
                        fontSize: 100,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  static divideItem({
    required VoidCallback onTap1of2,
    required VoidCallback onTap1of3,
    required VoidCallback onTap1of4,
  }) {
    PopupDialog.customDialog(
      width: 550,
      child: _DevidedItemWidget(),
    );
  }
}

class _DevidedItemWidget extends StatefulWidget {
  const _DevidedItemWidget();

  @override
  State<_DevidedItemWidget> createState() => __DevidedItemWidgetState();
}

class __DevidedItemWidgetState extends State<_DevidedItemWidget> {
  final _textController = TextEditingController();
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MyCustomText(
          'Divide Item',
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 18),
        StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: List.generate(8, (index) {
            return PrimaryBtnWithChild(
              onPressed: () {
                SplitOrderController.to.divideItems(index + 2);
                Get.back();
              },
              height: 140,
              width: 140,
              color: ConfigController.to.isLightTheme
                  ? Colors.white
                  : const Color(0xff363636),
              padding: const EdgeInsets.all(4.0),
              child: MyCustomText(
                (index + 2).toString(),
                fontSize: 100,
                color: ConfigController.to.isLightTheme
                    ? const Color.fromARGB(255, 34, 34, 34)
                    : const Color(0xffBABABA),
              ),
            );
          }),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _textController,
                initOpenKeyboard: true,
                keyboardType: KeyboardType.numeric,
                allowRegex: CommonRegexPatterns.digitsOnlyWithLength(2),
                extraLabelFontSize: 22,
                style: const TextStyle(fontSize: 30),
                padding:
                    const EdgeInsets.symmetric(vertical: 26, horizontal: 22),
              ),
            ),
            const SizedBox(width: 8),
            PrimaryBtnWithChild(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  int number = int.parse(_textController.text);
                  if (number > 1 && number <= 99) {
                    SplitOrderController.to.divideItems(number);
                    Get.back();
                  } else {
                    PopupDialog.showErrorMessage(
                        "Please enter a valid number (2-99)");
                  }
                } else {
                  PopupDialog.showErrorMessage("Please enter a number");
                }
              },
              height: 92,
              width: 158,
              padding: const EdgeInsets.all(4.0),
              color: StaticColors.blueColor,
              child: const FittedBox(
                child: MyCustomText(
                  'Submit',
                  fontSize: 45,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
