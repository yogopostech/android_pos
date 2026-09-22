// reload_card_response.dart
import 'package:yogo_pos/app/modules/rewards_gift_card/models/Acrivate_card_model.dart';

class ReloadCardResponse {
  final int? statusCode;
  final bool success;
  final String message;
  final ReloadData? data;

  const ReloadCardResponse({
    this.statusCode,
    required this.success,
    required this.message,
    this.data,
  });

  factory ReloadCardResponse.fromJson(Map<String, dynamic> json) {
    final bool success = json['success'] == true;
    final dynamic raw = json['data'];

    ReloadData? data;
    if (success && raw is Map && raw['card'] is Map) {
      data = ReloadData.fromJson(Map<String, dynamic>.from(raw));
    }

    return ReloadCardResponse(
      statusCode: json['statusCode'] is int ? json['statusCode'] as int : null,
      success: success,
      message: (json['message'] ?? '').toString(),
      data: data,
    );
  }
}

class ReloadData {
  final GiftCard card;
  final double addedAmount;
  final String tcn;
  final String invoiceNumber;
  final ReloadPayment? payments; // NEW

  const ReloadData({
    required this.card,
    required this.addedAmount,
    required this.tcn,
    required this.invoiceNumber,
    this.payments,
  });

  factory ReloadData.fromJson(Map<String, dynamic> json) => ReloadData(
    card: GiftCard.fromJson(Map<String, dynamic>.from(json['card'] as Map)),
    addedAmount: _toDouble(json['addedAmount']),
    tcn: (json['tcn'] ?? '').toString(),
    invoiceNumber: (json['invoiceNumber'] ?? '').toString(),
    payments: json['payments'] is Map
        ? ReloadPayment.fromJson(
            Map<String, dynamic>.from(json['payments'] as Map),
          )
        : null,
  );

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  String get addedAmountFormatted => '\$${addedAmount.toStringAsFixed(2)}';
}

/// NEW: payments object inside reload response data
class ReloadPayment {
  final String? id;
  final List<String> methods;
  final num cardPaidAmount;
  final num cardTipAmount;
  final num cashPaidAmount;
  final num cashTipAmount;
  final String? cardType;
  final num change;
  final String? providerName;
  final String? transactionId;
  final num extraAmount;
  final String? idempotencyKey;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReloadPayment({
    this.id,
    required this.methods,
    required this.cardPaidAmount,
    required this.cardTipAmount,
    required this.cashPaidAmount,
    required this.cashTipAmount,
    this.cardType,
    required this.change,
    this.providerName,
    this.transactionId,
    required this.extraAmount,
    this.idempotencyKey,
    this.createdAt,
    this.updatedAt,
  });

  factory ReloadPayment.fromJson(Map<String, dynamic> json) => ReloadPayment(
    id: json['_id']?.toString() ?? json['id']?.toString(),
    methods:
        (json['methods'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    cardPaidAmount: _toNum(json['cardPaidAmount']),
    cardTipAmount: _toNum(json['cardTipAmount']),
    cashPaidAmount: _toNum(json['cashPaidAmount']),
    cashTipAmount: _toNum(json['cashTipAmount']),
    cardType: json['cardType']?.toString(),
    change: _toNum(json['change']),
    providerName: json['providerName']?.toString(),
    transactionId: json['transactionId']?.toString(),
    extraAmount: _toNum(json['extraAmount']),
    idempotencyKey: json['idempotencyKey']?.toString(),
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
  );

  static num _toNum(dynamic v) {
    if (v is num) return v;
    return num.tryParse(v?.toString() ?? '') ?? 0;
  }

  static DateTime? _date(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());
}

class ReloadCard {
  final String? id;
  final String? tenantId;
  final String? locationId;
  final String cardNumber;
  final String status;
  final int balanceCents;
  final String currency;
  final String? batchId;
  final int? version;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? activatedAt;
  final String? activatedBy;
  final DateTime? lastActivityAt;
  final ReloadOwner? owner;

  const ReloadCard({
    this.id,
    this.tenantId,
    this.locationId,
    required this.cardNumber,
    required this.status,
    required this.balanceCents,
    required this.currency,
    this.batchId,
    this.version,
    this.createdAt,
    this.updatedAt,
    this.activatedAt,
    this.activatedBy,
    this.lastActivityAt,
    this.owner,
  });

  factory ReloadCard.fromJson(Map<String, dynamic> json) => ReloadCard(
    id: json['_id']?.toString(),
    tenantId: json['tenantId']?.toString(),
    locationId: json['locationId']?.toString(),
    cardNumber: (json['cardNumber'] ?? '').toString(),
    status: (json['status'] ?? '').toString(),
    balanceCents: json['balanceCents'] is int
        ? json['balanceCents'] as int
        : int.tryParse(json['balanceCents']?.toString() ?? '') ?? 0,
    currency: (json['currency'] ?? 'CAD').toString(),
    batchId: json['batchId']?.toString(),
    version: json['__v'] is int
        ? json['__v'] as int
        : int.tryParse(json['__v']?.toString() ?? ''),
    createdAt: _date(json['createdAt']),
    updatedAt: _date(json['updatedAt']),
    activatedAt: _date(json['activatedAt']),
    activatedBy: json['activatedBy']?.toString(),
    lastActivityAt: _date(json['lastActivityAt']),
    owner: json['owner'] is Map
        ? ReloadOwner.fromJson(Map<String, dynamic>.from(json['owner'] as Map))
        : null,
  );

  double get balanceDollars => balanceCents / 100.0;
  String get balanceFormatted => '\$${balanceDollars.toStringAsFixed(2)}';

  static DateTime? _date(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());
}

class ReloadOwner {
  final String name;
  final String phone;

  const ReloadOwner({required this.name, required this.phone});

  factory ReloadOwner.fromJson(Map<String, dynamic> json) => ReloadOwner(
    name: (json['name'] ?? '').toString(),
    phone: (json['phone'] ?? '').toString(),
  );
}
