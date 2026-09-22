import 'package:flutter/services.dart';

class IpAddressInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // empty allow
    if (text.isEmpty) return newValue;

    // only digits and dots allow
    if (!RegExp(r'^[\d.]+$').hasMatch(text)) return oldValue;

    // max 4 dots allow  (192.168.1.88 = 3 dots)
    if ('.'.allMatches(text).length > 3) return oldValue;

    final parts = text.split('.');

    // max 4 parts
    if (parts.length > 4) return oldValue;

    for (final part in parts) {
      // each part max 3 digits
      if (part.length > 3) return oldValue;

      // 0 এর পর আর digit না (01, 001 invalid)
      if (part.length > 1 && part.startsWith('0')) return oldValue;

      // max value 255
      if (part.isNotEmpty && int.tryParse(part) != null) {
        if (int.parse(part) > 255) return oldValue;
      }
    }

    return newValue;
  }
}
