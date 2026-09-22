import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/custom_keyboard/widgets/my_keyboard.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import '../controllers/custom_keyboard_controller.dart';

class NumberKeyboardView extends StatefulWidget {
  final ValueChanged<String> onChange;
  final bool changeKeybordType;
  final RegExp? regExp;
  final String initialValue;

  const NumberKeyboardView(
      {super.key,
      // this.keyboardType,
      this.changeKeybordType = true,
      required this.onChange,
      this.regExp,
      this.initialValue = ""});

  @override
  State<NumberKeyboardView> createState() => _NumberKeyboardViewState();
}

class _NumberKeyboardViewState extends State<NumberKeyboardView> {
  late CustomKeyboardController controller;
  late bool isNumberKeyBoard;
  final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);
  Timer? _longPressTimer;
  final _numberKey = TextEditingController();
  final FocusNode _numberKeyFocusNode = FocusNode();

  void _focusOnTextField() {
    Future.delayed(Duration(milliseconds: 50), () {
      // ignore: use_build_context_synchronously
      FocusScope.of(context).requestFocus(_numberKeyFocusNode);
    });
  }

  @override
  void initState() {
    super.initState();
    controller = Get.put(CustomKeyboardController());
    controller.keyboardValue = widget.initialValue;
    _focusOnTextField();
  }

  @override
  void dispose() {
    Get.delete<CustomKeyboardController>();
    _numberKeyFocusNode.dispose();
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
          width: 390,
          margin: const EdgeInsets.only(bottom: 100),
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
          child: Column(
            children: [
              // display value
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(
                    left: 25, right: 25, bottom: 7, top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                // alignment: Alignment.centerRight,
                height: 70,
                decoration: BoxDecoration(
                  color: ConfigController.to.isLightTheme
                      ? Colors.white
                      : const Color(0xff363636),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: GetBuilder<CustomKeyboardController>(builder: (c) {
                  return Material(
                    child: TextField(
                      readOnly: true,
                        controller: _numberKey,
                        focusNode: _numberKeyFocusNode,
                        selectionControls: MaterialTextSelectionControls(),
                        cursorColor: StaticColors.orangeColor,
                        enableInteractiveSelection: false,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: ConfigController.to.isLightTheme
                                ? Colors.white
                                : const Color(0xff363636),
                            border: InputBorder.none)),
                  );
                }),
              ),
              MyKeyboard(
                keyboardKey: CustomKeyboardController.to.numberKey,
                gap: 6,
                onPressed: (value) async {
                  // function key
                  if (value == "enter") {
                    widget.onChange(controller.keyboardValue);

                    controller.update();
                    Get.back();
                    // enter key
                    return;
                  }
                  if (value == "X") {
                    controller.onRemoveLetter();
                    widget.onChange(controller.keyboardValue);
                    _numberKey.text = controller.keyboardValue;
                    _focusOnTextField();
                    controller.update();
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
                  _numberKey.text = controller.keyboardValue;
                  _focusOnTextField();

                  controller.update();

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
            ],
          ),
        ),
      ),
    );
  }
}
