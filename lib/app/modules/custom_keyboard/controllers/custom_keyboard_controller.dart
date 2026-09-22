import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/utils/logger.dart';

import '../models/key_model.dart';
import '../repo/keybord_repo.dart';

class CustomKeyboardController extends GetxController {
  static CustomKeyboardController get to => Get.find();

  final PageController pageController = PageController();
  String keyboardValue = "";
  bool isCapsLock = false;
  bool hasSound = Preferences.keyboardSound;

  List<List<KeyModel>> keyboardKey = [
    [
      KeyModel(value: "q"),
      KeyModel(value: "w"),
      KeyModel(value: "e"),
      KeyModel(value: "r"),
      KeyModel(value: "t"),
      KeyModel(value: "y"),
      KeyModel(value: "u"),
      KeyModel(value: "i"),
      KeyModel(value: "o"),
      KeyModel(value: "p"),
    ],
    [
      KeyModel(value: "a"),
      KeyModel(value: "s"),
      KeyModel(value: "d"),
      KeyModel(value: "f"),
      KeyModel(value: "g"),
      KeyModel(value: "h"),
      KeyModel(value: "j"),
      KeyModel(value: "k"),
      KeyModel(value: "l"),
    ],
    [
      KeyModel(value: "cl"),
      KeyModel(value: "z"),
      KeyModel(value: "x"),
      KeyModel(value: "c"),
      KeyModel(value: "v"),
      KeyModel(value: "b"),
      KeyModel(value: "n"),
      KeyModel(value: "m"),
      KeyModel(
        value: "X",
      ),
    ],
    [
      KeyModel(
        value: "@",
      ),
      KeyModel(
        value: ",",
      ),
      KeyModel(
        value: "123",
      ),
      KeyModel(value: "space", width: 304),
      KeyModel(
        value: ".",
      ),
      KeyModel(
        value: "enter",
        width: 162,
      ),
    ]
  ];

  List<List<KeyModel>> keyboardNumberKey = [
    [
      KeyModel(
        value: "1",
      ),
      KeyModel(
        value: "2",
      ),
      KeyModel(
        value: "3",
      ),
      KeyModel(
        value: "4",
      ),
    ],
    [
      KeyModel(
        value: "5",
      ),
      KeyModel(
        value: "6",
      ),
      KeyModel(
        value: "7",
      ),
      KeyModel(
        value: "8",
      ),
    ],
    [
      KeyModel(
        value: "9",
      ),
      KeyModel(
        value: "0",
      ),
      // KeyModel(
      //   value: ".",
      // ),
      KeyModel(width: 174, value: "X"),
    ],
    [
      KeyModel(value: "abc", width: 172),
      KeyModel(value: "enter", width: 172),
    ],
  ];

  List<List<KeyModel>> numberKey = [
    [
      KeyModel(
        value: "1",
      ),
      KeyModel(
        value: "2",
      ),
      KeyModel(
        value: "3",
      ),
      KeyModel(
        value: "4",
      ),
    ],
    [
      KeyModel(
        value: "5",
      ),
      KeyModel(
        value: "6",
      ),
      KeyModel(
        value: "7",
      ),
      KeyModel(
        value: "8",
      ),
    ],
    [
      KeyModel(
        value: "9",
      ),
      KeyModel(
        value: "0",
      ),
      KeyModel(
        value: ".",
      ),
      KeyModel(value: "X"),
    ],
  ];

  void onRemoveLetter() {
    keyboardValue = KeybordRepo.removeLastLetter(keyboardValue);
  }

  void onAddLetter(String value, {RegExp? regExp}) {
    String myValue = KeybordRepo.addLetter(keyboardValue, value);

    if (regExp == null) {
      keyboardValue = myValue;
    } else {
      // Check if the provided value matches the allowed pattern.
      if (regExp.hasMatch(myValue)) {
        // If valid, add the letter.
        keyboardValue = myValue;
      } else {
        // Optionally handle invalid input.
        kLogger.e("Invalid letter: $value");
      }
    }
  }

  onChangeCapsLock() {
    isCapsLock = !isCapsLock;
    update();
  }
}
