import 'package:flutter/material.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

/// Validity status of a gift card, derived from its expiry date.
enum GiftCardStatus { active, expiringSoon, expired }

/// Immutable model representing a single gift card record.
class GiftCardModel {
  final String cardNumber;
  final String customerName;
  final double balance;
  final DateTime openDate;
  final DateTime expiryDate;
  final bool isActive;

  const GiftCardModel({
    required this.cardNumber,
    required this.customerName,
    required this.balance,
    required this.openDate,
    required this.expiryDate,
    this.isActive = true,
  });

  static const int _expiringWindowDays = 30;

  GiftCardStatus get status {
    final now = DateTime.now();
    final endOfExpiry = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
      23,
      59,
      59,
    );

    if (endOfExpiry.isBefore(now)) return GiftCardStatus.expired;
    if (endOfExpiry.difference(now).inDays <= _expiringWindowDays) {
      return GiftCardStatus.expiringSoon;
    }
    return GiftCardStatus.active;
  }

  String get statusLabel {
    switch (status) {
      case GiftCardStatus.active:
        return 'Active';
      case GiftCardStatus.expiringSoon:
        return 'Expiring Soon';
      case GiftCardStatus.expired:
        return 'Expired';
    }
  }

  Color get statusColor {
    switch (status) {
      case GiftCardStatus.active:
        return StaticColors.greenColor;
      case GiftCardStatus.expiringSoon:
        return StaticColors.orangeColor;
      case GiftCardStatus.expired:
        return StaticColors.redColor;
    }
  }

  bool get hasBalance => balance > 0;

  String get openDateText => _formatDate(openDate);

  String get expiryDateText => _formatDate(expiryDate);

  String get balanceText => '\$${balance.toStringAsFixed(2)}';

  String get displayName =>
      customerName.trim().isEmpty ? 'Unassigned' : customerName.trim();

  /// `9950000163` -> `9950 0001 63`
  String get formattedCardNumber {
    final raw = cardNumber.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }

  static String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$mm/$dd/${d.year}';
  }

  GiftCardModel copyWith({
    String? cardNumber,
    String? customerName,
    double? balance,
    DateTime? openDate,
    DateTime? expiryDate,
    bool? isActive,
  }) {
    return GiftCardModel(
      cardNumber: cardNumber ?? this.cardNumber,
      customerName: customerName ?? this.customerName,
      balance: balance ?? this.balance,
      openDate: openDate ?? this.openDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
