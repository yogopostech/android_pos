import 'package:flutter/services.dart';

class CardNumberFormatter extends TextInputFormatter {
  final int maxDigits;
  final int groupSize;
  final String separator;

  // ================================================================
  // Constructor with default values
  // ================================================================
  CardNumberFormatter({
    this.maxDigits = 19, // Default: 24 digits
    this.groupSize = 4, // Default: group in 4s
    this.separator = '-', // Default: dash separator
  });

  // ================================================================
  // Format card number with grouping
  // ================================================================
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extract only digits
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to max digits
    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }

    // Group digits with separator
    String formattedText = '';
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % groupSize == 0) {
        formattedText += separator;
      }
      formattedText += digits[i];
    }

    // Calculate cursor position
    int cursorPosition = formattedText.length;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

// class CardNumberFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

//     // limit to max 19 digits
//     if (digits.length > 19) {
//       digits = digits.substring(0, 19);
//     }

//     // group digits in 4s with dashes
//     String newText = '';
//     for (int i = 0; i < digits.length; i++) {
//       if (i > 0 && i % 4 == 0) newText += '-';
//       newText += digits[i];
//     }

//     return TextEditingValue(
//       text: newText,
//       selection: TextSelection.collapsed(offset: newText.length),
//     );
//   }
// }
