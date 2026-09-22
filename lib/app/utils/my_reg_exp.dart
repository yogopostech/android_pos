class MyRegExp {
  static String email =
      r'^\s*[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\s*$';
  static String phone = r'^\+?[0-9]{10,13}$';
  static String guestNumber = r'^(?:[1-9]|1[0-9]|2[0-5])$';
}
// ====================================================================
// COMMON REGEX PATTERNS UTILITY CLASS
// Use this class for input validation with CustomTextField and AppKeyboard
// ====================================================================

class CommonRegexPatterns {
  // ====================================================================
  // DIGITS ONLY PATTERNS
  // ====================================================================

  /// Only digits with max length
  /// Example: digitsOnlyWithLength(6) -> "123456" ✓, "1234567" ✗
  static RegExp digitsOnlyWithLength(int maxLength) =>
      RegExp(r'^[0-9]{0,' + maxLength.toString() + r'}$');

  /// Alphanumeric with spaces and max length
  /// Example: alphanumericWithSpaceAndLength(15) -> "Hello World 123" ✓
  // static RegExp alphanumericWithSpaceAndLength(int maxLength) =>
  //     RegExp(r'^[a-zA-Z0-9 ]{0,' + maxLength.toString() + r'}$');
  static RegExp alphanumericWithSpaceAndLength(int maxLength) =>
      RegExp(r'^[a-zA-Z0-9 \-,.@#*]{0,' + maxLength.toString() + r'}$');

  static RegExp invoiceNumberWithAndLength(int maxLength) =>
      RegExp(r'^[a-zA-Z0-9\-]{0,' + maxLength.toString() + r'}$');

  // ====================================================================
  // EMAIL PATTERNS
  // ====================================================================
  /// Email characters with max length
  /// Example: emailCharsWithLength(30) -> "user@example.com" ✓
  static RegExp emailCharsWithLength(int maxLength) =>
      RegExp(r'^[a-zA-Z0-9@._-]{0,' + maxLength.toString() + r'}$');

  // ====================================================================
  // DECIMAL NUMBER PATTERNS
  // ====================================================================

  /// Decimal numbers with max length for integer part
  /// Example: decimalWithLength(5) -> "12345.67" ✓, "123456.7" ✗
  static RegExp decimalWithLength(int maxLength) =>
      RegExp(r'^\d{0,' + maxLength.toString() + r'}\.?\d*$');

  /// Decimal with specific precision (max integer digits, max decimal digits)
  /// Example: decimalWithPrecision(5, 2) -> "12345.67" ✓, "12345.678" ✗
  static RegExp decimalWithPrecision(int maxIntDigits, int maxDecimalDigits) =>
      RegExp(
        r'^\d{0,' +
            maxIntDigits.toString() +
            r'}(\.\d{0,' +
            maxDecimalDigits.toString() +
            r'})?$',
      );

  /// Username with max length
  /// Example: usernameWithLength(15) -> "test_user_123" ✓
  static RegExp usernameWithLength(int maxLength) =>
      RegExp(r'^[a-zA-Z0-9_]{0,' + maxLength.toString() + r'}$');

  /// Phone number with custom max length
  /// Example: phoneNumberWithLength(11) -> "01712345678" ✓
  static RegExp phoneNumberWithLength(int maxLength) =>
      RegExp(r'^[0-9]{0,' + maxLength.toString() + r'}$');

  /// PIN code with custom length
  /// Example: pinCodeWithLength(4) -> "1234" ✓, "12345" ✗
  static RegExp pinCodeWithLength(int length) =>
      RegExp(r'^[0-9]{0,' + length.toString() + r'}$');
}
