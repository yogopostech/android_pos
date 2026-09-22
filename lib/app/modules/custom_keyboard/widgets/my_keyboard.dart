import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/custom_keyboard/models/key_model.dart';
import 'package:yogo_pos/app/modules/custom_keyboard/widgets/key_child_widget.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';

import '../controllers/custom_keyboard_controller.dart';

class MyKeyboard extends StatelessWidget {
  final List<List<KeyModel>> keyboardKey;
  final ValueChanged<String> onPressed;
  final ValueChanged<String>? onLongPressStart;
  final ValueChanged<String>? onLongPressEnd;
  final double? gap;
  final TextStyle? textStyle;
  const MyKeyboard({
    super.key,
    required this.keyboardKey,
    required this.onPressed,
    this.gap,
    this.textStyle,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(keyboardKey.length, (index) {
        var rowData = keyboardKey[index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(rowData.length, (index) {
            return SizedBox(
              width: rowData[index].width,
              height: rowData[index].height,
              child: GestureDetector(
                onTap: () {
                  if (CustomKeyboardController.to.hasSound) {
                    BaseController.to.playKeybordSound();
                  }
                  onPressed(rowData[index].value);
                },
                onLongPressStart: (_) {
                  if (onLongPressStart != null) {
                    onLongPressStart!(rowData[index].value);
                  }
                },
                onLongPressEnd: (_) {
                  if (onLongPressEnd != null) {
                    onLongPressEnd!(rowData[index].value);
                  }
                },
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    textStyle: textStyle ??
                        TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: ConfigController.to.isLightTheme
                              ? rowData[index].textColor
                              : rowData[index].textDarkColor,
                        ),
                    backgroundColor: ConfigController.to.isLightTheme
                        ? rowData[index].bgColor
                        : rowData[index].bgDarkColor,
                    foregroundColor: ConfigController.to.isLightTheme
                        ? rowData[index].textColor
                        : rowData[index].textDarkColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: KeyChildWidget(rowData[index]),
                ).marginAll(gap ?? 3),
              ),
            );
          }),
        );
      }),
    );
  }
}
