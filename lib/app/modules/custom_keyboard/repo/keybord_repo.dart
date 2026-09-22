import 'package:yogo_pos/app/modules/custom_keyboard/controllers/custom_keyboard_controller.dart';

class KeybordRepo {
  static String addLetter(String keyboardValue, String letterToAdd) {
    // Optionally remove any trailing whitespace (if you don't want extra spaces)

    keyboardValue = keyboardValue.trimLeft();

    // Append the letter to the current value

    return '$keyboardValue${CustomKeyboardController.to.isCapsLock ? letterToAdd.toUpperCase() : letterToAdd}';
  }

  static String removeLastLetter(String keyboardValue) {
    // If the string is empty, just return an empty string.
    if (keyboardValue.isEmpty) return "";

    // Return the string without its last character.
    return keyboardValue.substring(0, keyboardValue.length - 1);
  }
}
