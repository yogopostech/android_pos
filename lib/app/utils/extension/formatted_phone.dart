extension PhoneNumberFormatter on String? {
  String toFormattedPhone() {
    if (this == null || this!.trim().isEmpty) return '';

    final digits = this!.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return '';

    final last10 = digits.substring(digits.length - 10);

    final area = last10.substring(0, 3);
    final prefix = last10.substring(3, 6);
    final line = last10.substring(6, 10);

    return '($area) $prefix-$line';
  }
}
