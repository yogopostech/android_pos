import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/custom_keyboard/widgets/my_keyboard.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';

import '../controllers/custom_keyboard_controller.dart';
import '../custom_keyboard.dart';

class CustomKeyboardView extends StatefulWidget {
  final KeyboardType? keyboardType;
  final ValueChanged<String> onChange;
  final Function()? onSubmit;
  final bool changeKeybordType;
  final RegExp? regExp;
  final String initialValue;

  const CustomKeyboardView(
      {super.key,
      this.keyboardType,
      this.changeKeybordType = true,
      required this.onChange,
      this.onSubmit,
      this.regExp,
      required this.initialValue});

  @override
  State<CustomKeyboardView> createState() => _CustomKeyboardViewState();
}

class _CustomKeyboardViewState extends State<CustomKeyboardView> {
  late CustomKeyboardController controller;
  late bool isNumberKeyBoard;
  final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);
  Timer? _longPressTimer;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CustomKeyboardController());
    controller.keyboardValue = widget.initialValue;
    isNumberKeyBoard =
        widget.keyboardType == KeyboardType.number ? true : false;
  }

  @override
  void dispose() {
    Get.delete<CustomKeyboardController>();
    _longPressTimer?.cancel();
    super.dispose();
  }

  void _startLongPressTimer(String value) {
    _longPressTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (value == "X") {
        controller.onRemoveLetter();
        widget.onChange(controller.keyboardValue);
      }
    });
  }

  void _stopLongPressTimer() {
    _longPressTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 350,
          width: isNumberKeyBoard ? 390 : 895,
          margin: const EdgeInsets.only(bottom: 50),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: ConfigController.to.isLightTheme
                ? const Color(0xffBABABA)
                : const Color(0xff202020),
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
            border: Border.all(
              color: Colors.white,
            ),
          ),
          child: Visibility(
            visible: !isNumberKeyBoard,
            replacement: MyKeyboard(
              keyboardKey: CustomKeyboardController.to.keyboardNumberKey,
              gap: 6,
              onPressed: (value) {
                // function key
                if (value == "enter") {
                  widget.onChange(controller.keyboardValue);
                  if (widget.onSubmit != null) {
                    widget.onSubmit!();
                  } else {
                    Get.back();
                  }

                  // enter key
                  return;
                }
                if (value == "X") {
                  controller.onRemoveLetter();
                  widget.onChange(controller.keyboardValue);
                  // backspace key
                  return;
                }
                if (value == "cl") {
                  controller.onChangeCapsLock();
                  // backspace key
                  return;
                }
                if (value == "abc") {
                  // change to number keyboard
                  if (widget.changeKeybordType) {
                    isNumberKeyBoard = false;
                    setState(() {});
                  }

                  return;
                }
                // Normal key
                if (value == "space") {
                  controller.onAddLetter(" ");
                  widget.onChange(controller.keyboardValue);
                  return;
                }
                controller.onAddLetter(value, regExp: widget.regExp);
                widget.onChange(controller.keyboardValue);

                // kLogger.i(value);
              },
              onLongPressStart: (value) {
                if (value == "X") {
                  _startLongPressTimer(value);
                }
              },
              onLongPressEnd: (value) {
                if (value == "X") {
                  _stopLongPressTimer();
                }
              },
            ),
            child: // for alphabet keyboard
                MyKeyboard(
              keyboardKey: CustomKeyboardController.to.keyboardKey,
              gap: 6,
              onPressed: (value) {
                // function key
                if (value == "enter") {
                  // enter key
                  widget.onChange(controller.keyboardValue);
                  if (widget.onSubmit != null) {
                    widget.onSubmit!();
                  } else {
                    Get.back();
                  }
                  return;
                }
                if (value == "X") {
                  controller.onRemoveLetter();
                  widget.onChange(controller.keyboardValue);
                  // backspace key
                  return;
                }
                if (value == "cl") {
                  controller.onChangeCapsLock();
                  // backspace key
                  return;
                }
                if (value == "123") {
                  // change to number keyboard
                  if (widget.changeKeybordType) {
                    isNumberKeyBoard = true;
                    setState(() {});
                    // pageController.nextPage(
                    //   duration: const Duration(milliseconds: 300),
                    //   curve: Curves.easeInOut,
                    // );
                  }
                  return;
                }
                //normal key
                // add word
                if (value == "space") {
                  controller.onAddLetter(" ");
                  widget.onChange(controller.keyboardValue);
                  return;
                }
                controller.onAddLetter(value, regExp: widget.regExp);
                widget.onChange(controller.keyboardValue);
                // kLogger.i(value);
              },
              onLongPressStart: (value) {
                if (value == "X") {
                  _startLongPressTimer(value);
                }
              },
              onLongPressEnd: (value) {
                if (value == "X") {
                  _stopLongPressTimer();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
