import 'package:flutter/services.dart';

class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Ensure the new value has a decimal point
    if (newValue.text.contains('.')) {
      final parts = newValue.text.split('.');
      // Limit decimal places to 2
      if (parts.length > 1 && parts[1].length > 2) {
        final newText = '${parts[0]}.${parts[1].substring(0, 2)}';
        return TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }
    return newValue;
  }
}