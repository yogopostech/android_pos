class GiftCardTransaction {
  final String date;
  final String time;
  final String name;
  final String phone;
  final String server;
  final String cardNo;
  final String transactionType;
  final String tcnNo;
  final String invoiceNo;

  const GiftCardTransaction({
    required this.date,
    required this.time,
    required this.name,
    required this.phone,
    required this.server,
    required this.cardNo,
    required this.transactionType,
    required this.tcnNo,
    required this.invoiceNo,
  });

  factory GiftCardTransaction.fromJson(Map<String, dynamic> json) {
    final created = DateTime.tryParse('${json['createdAt'] ?? ''}')?.toLocal();
    return GiftCardTransaction(
      date: _fmtDate(created),
      time: _fmtTime(created),
      name: _orDash(json['customerName']),
      phone: _fmtPhone('${json['customerPhone'] ?? ''}'),
      server: _orDash(json['staffId']),
      cardNo: _fmtCard('${json['cardNumber'] ?? ''}'),
      transactionType: _typeLabel('${json['type'] ?? ''}'),
      tcnNo: _orDash(json['tcn']),
      invoiceNo: _orDash(json['invoiceNumber']),
    );
  }

  // ---- formatters ----
  static String _orDash(dynamic v) {
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? '-' : s;
  }

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static String _ordinal(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  static String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return '${_months[d.month - 1]} ${d.day}${_ordinal(d.day)} ${d.year}';
  }

  static String _fmtTime(DateTime? d) {
    if (d == null) return '-';
    var h = d.hour % 12;
    if (h == 0) h = 12;
    final hh = h.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '$hh:$mm $ampm';
  }

  static String _fmtCard(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '-';
    final b = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) b.write('-');
      b.write(digits[i]);
    }
    return b.toString();
  }

  static String _fmtPhone(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.length == 10) {
      return '(${d.substring(0, 3)}) ${d.substring(3, 6)}-${d.substring(6)}';
    }
    if (d.length == 11 && d.startsWith('1')) {
      final n = d.substring(1);
      return '(${n.substring(0, 3)}) ${n.substring(3, 6)}-${n.substring(6)}';
    }
    return d.isEmpty ? '-' : raw;
  }

  static String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'ACTIVATE':
      case 'ACTIVATION':
        return 'Activate';
      case 'ADD_FUNDS':
      case 'RELOAD':
        return 'Reload';
      case 'REDEEM':
        return 'Redeem';
      case 'REVERSE':
      case 'CANCEL':
      case 'CANCELLATION':
        return 'Cancell';
      case 'BALANCE_CHECK':
        return 'Check Balance';
      default:
        return type
            .split('_')
            .where((w) => w.isNotEmpty)
            .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
            .join(' ');
    }
  }
}