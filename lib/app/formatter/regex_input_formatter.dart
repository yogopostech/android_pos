import 'package:flutter/services.dart';

class RegexInputFormatter extends TextInputFormatter {
  final RegExp allowRegex;

  RegexInputFormatter(this.allowRegex);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If empty, allow it
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // If new value doesn't match regex, keep the old value
    if (!allowRegex.hasMatch(newValue.text)) {
      return oldValue; // Don't clear, just reject the new input
    }

    return newValue;
  }
}