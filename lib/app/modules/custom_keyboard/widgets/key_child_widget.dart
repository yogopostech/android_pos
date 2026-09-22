import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';

import '../controllers/custom_keyboard_controller.dart';
import '../models/key_model.dart';

class KeyChildWidget extends StatelessWidget {
  final KeyModel keyData;

  const KeyChildWidget(
    this.keyData, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the app is using a light theme
    final isLightTheme = ConfigController.to.isLightTheme;
    final iconColor = isLightTheme ? keyData.textColor : keyData.textDarkColor;

    switch (keyData.value) {
      case "X":
        return Icon(
          Icons.backspace,
          color: iconColor,
          size: 30,
          weight: 900,
        );
      case "space":
        return const Icon(
          Icons.space_bar,
          color: Colors.transparent,
        );
      case "cl":
        return GetBuilder<CustomKeyboardController>(builder: (context) {
          return Icon(
            size: 30,
            context.isCapsLock
                ? Icons.arrow_circle_down
                : Icons.arrow_circle_up,
            color: iconColor,
          );
        });
      default:
        return GetBuilder<CustomKeyboardController>(builder: (context) {
          return Text(
            // context.isCapsLock ? keyData.value.toUpperCase() : keyData.value,
            keyData.value.toUpperCase(),
            style: TextStyle(
              color: iconColor,
              fontSize: 35,
              fontWeight: FontWeight.w700,
            ),
          );
        });
    }
  }
}
