import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/utils/extension/string_manipulation_extension.dart';
import '../../../../utils/logger.dart';
import '../../../../utils/static_colors.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/my_custom_text.dart';
import '../../../../widgets/custom_Btn.dart';
import '../../../custom_keyboard/custom_keyboard.dart';
import '../../controller/gift_card_controller.dart';

class UpdateDatCandyGiftCardView extends StatefulWidget {
  const UpdateDatCandyGiftCardView({super.key});

  @override
  State<UpdateDatCandyGiftCardView> createState() =>
      _UpdateDatCandyGiftCardViewState();
}

class _UpdateDatCandyGiftCardViewState
    extends State<UpdateDatCandyGiftCardView> {
  GiftCardController controller = Get.find<GiftCardController>();

  @override
  Widget build(BuildContext context) {
    final List<int> values = List.generate(20, (index) => (index + 1) * 5);

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/datacandy.png",
                  height: 70, width: 70),
              const SizedBox(width: 10),
              MyCustomText(
                "DataCandy",
                fontSize: 43,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          const SizedBox(height: 35),

          // Custom button
          Padding(
            padding: const EdgeInsets.only(left: 100),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.center, // horizontally center
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: SizedBox(
                    height: 180,
                    width: 300,
                    child:CustomTextField(
                      extralabeldownpadding:28,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$')),
                        LengthLimitingTextInputFormatter(6),
                      ],
                      padding: EdgeInsets.all(26),
                      errorStyle: const TextStyle(
                        fontSize: 16,
                        height: 1,
                        overflow: TextOverflow.fade,
                      ),
                      // readOnly: true,
                      controller: controller.amountController,
                      extraLabelFontSize: 40,
                      hintStyle: TextStyle(fontSize: 30,color: Theme.of(context).hintColor),
                      hintText: "Amount",
                      extraLabel: "Amount",
                      style: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Amount is required";
                        }

                        final numberRegExp = RegExp(r'^\d+(\.\d+)?$');
                        if (!numberRegExp.hasMatch(value)) {
                          return "Only numeric values are allowed";
                        }

                        final numValue = num.tryParse(value);
                        if (numValue == null) {
                          return "Invalid number";
                        }

                        if (numValue < 5 || numValue > 500) {
                          return "Amount must be between 5 and 500";
                        }

                        return null;
                      },
                      onTap: () {
                        int initValue =
                        ((num.tryParse(controller.amountController.text) ?? 0) * 100)
                            .toInt();

                        CustomKeyboard.open(
                            keyboardType: KeyboardType.number,
                            changeKeybordType: false,
                            initialValue: initValue.toString(),
                            // regExp: RegExp(r'^\d{0,5}(\.\d{0,2})?$'),
                            // regExp: RegExp(r'^\d{0,7}$'),
                            regExp: RegExp(r'^\d{0,6}$'),
                            // regExp: RegExp(r'^(?:[0-9]{1,4}|[1-4][0-9]{4}|50000)$'),
                            onChange: (value) {
                              controller.amountController.text = value.toDecimalFormat();
                              kLogger.e(value);
                            });
                        // int initValue =
                        // ((num.tryParse(controller.amountController.text) ?? 0) * 100).toInt();
                        //
                        // CustomKeyboard.open(
                        //   keyboardType: KeyboardType.number,
                        //   changeKeybordType: false,
                        //   initialValue: initValue.toString(),
                        //   // ✅ 1 থেকে 3 digit + optional decimal
                        //   regExp: RegExp(r'^\d{0,3}(\.\d{0,500})?$'),
                        //   onChange: (value) {
                        //     controller.amountController.text = value.toDecimalFormat();
                        //   },
                        // );
                      },
                    ),

                  ),
                ),
                SizedBox(width: 20,),
                Padding(
                  padding: const EdgeInsets.only(top: 75),
                  child: PrimaryBtn(
                    onPressed: () {},
                    text: "Custom",
                    textMinSize: 30,
                    textMaxSize: 30,
                    height: 90,
                    width: 200,
                    color: StaticColors.greenColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Generated buttons (5,10,...,50)

          SizedBox(
            height: 450,
            child: StaggeredGrid.count(
              crossAxisCount: 4, // 4 ta column
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,

              children:  List.generate(values.length,(index) {

                final value = values[index];
                final formattedValue = value.toStringAsFixed(2);

                return PrimaryBtn(
                  textMinSize: 30,
                  textMaxSize: 30,
                  onPressed: () {
                    controller.amountController.text = formattedValue;
                    debugPrint('Selected: $formattedValue');
                  },
                  text: "\$$formattedValue",
                  height: 100,
                  width: 200,
                  color: StaticColors.blueColor,
                );
              },
            ),
          ),
          )

        ],
      ),
    );
  }
}





class DataCandyBtn extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final Color? color;
  final Color? borderColor;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;
  final AlignmentGeometry? alignment;

  const DataCandyBtn({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.color,
    this.textStyle,
    this.borderRadius, this.borderColor, this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 250,
      height: height ?? 100,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color ?? Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(0),
          ),
          side: BorderSide(
            color: borderColor ?? Colors.black38, //
            width: 1.5,
          ),
          padding: EdgeInsets.zero, //
        ),
        child: Align(
          alignment: alignment ?? Alignment.bottomLeft, //
          child: Padding(
            padding: const EdgeInsets.all(8.0), //
            child: Text(
              text,
              style: textStyle ??
                  const TextStyle(
                    fontSize: 22,
                    // color: Colors.b,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
