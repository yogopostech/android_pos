import 'package:flutter/services.dart';

class DecimalFormatter extends TextInputFormatter {
  final int maxDigits;

  DecimalFormatter({this.maxDigits = 6});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Get only digits
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // If empty, show 0.00
    if (digits.isEmpty) {
      return TextEditingValue(
        text: '0.00',
        selection: TextSelection.collapsed(offset: 4),
      );
    }

    // Limit max digits
    if (digits.length > maxDigits) {
      return oldValue; // Return old value if exceeds max
    }

    // Remove leading zeros but keep at least one digit
    digits = digits.replaceFirst(RegExp(r'^0+'), '');
    if (digits.isEmpty) digits = '0';

    // Convert to double and divide by 100 to get decimal
    double value = double.parse(digits) / 100;

    // Format to 2 decimal places
    String formatted = value.toStringAsFixed(2);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
