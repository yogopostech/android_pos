import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'views/custom_keyboard_view.dart';

enum KeyboardType { alphabet, number }

class CustomKeyboard {
  static open(
      {KeyboardType? keyboardType,
      bool? changeKeybordType,
      RegExp? regExp,
      String initialValue = '',
      Function()? onSubmit,
      required ValueChanged<String> onChange}) async {
    FocusNode? previousFocusNode;
    await Future.delayed(const Duration(milliseconds: 30), () {
      previousFocusNode = FocusManager.instance.primaryFocus;
    });
    if (previousFocusNode != null) {
      Future.delayed(const Duration(milliseconds: 50), () {
        FocusScope.of(Get.context!).requestFocus(previousFocusNode);
      });
    }
    Get.dialog(
      barrierColor: Colors.transparent,
      CustomKeyboardView(
        keyboardType: keyboardType,
        changeKeybordType: changeKeybordType ?? true,
        onChange: onChange,
        onSubmit: onSubmit,
        regExp: regExp,
        initialValue: initialValue,
      ),
    );
  }
}
