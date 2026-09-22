// gift_card_models.dart

/// Owner: { name, phone }
class Owner {
  final String name;
  final String phone;

  const Owner({required this.name, required this.phone});

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
        name: (json['name'] ?? '').toString(),
        phone: (json['phone'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone};
}

/// Activate request body.
class ActivateCardRequest {
  final String cardNumber; // pure digits, no dash
  final num initialAmount;
  final Owner owner;
  final String source; // CASH / CARD etc.

  const ActivateCardRequest({
    required this.cardNumber,
    required this.initialAmount,
    required this.owner,
    this.source = 'Cash',
  });

  Map<String, dynamic> toJson() => {
        'cardNumber': cardNumber,
        'initialAmount': initialAmount,
        'owner': owner.toJson(),
        'source': source,
      };
}

/// Card object.
class GiftCard {
  final String id;
  final String? tenantId;
  final String? locationId;
  final String cardNumber;
  final String status;
  final int balanceCents;
  final String currency;
  final String? batchId;
  final Owner? owner;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? activatedAt;
  final String? activatedBy;
  final DateTime? lastActivityAt;

  const GiftCard({
    required this.id,
    this.tenantId,
    this.locationId,
    required this.cardNumber,
    required this.status,
    required this.balanceCents,
    required this.currency,
    this.batchId,
    this.owner,
    this.createdAt,
    this.updatedAt,
    this.activatedAt,
    this.activatedBy,
    this.lastActivityAt,
  });

  /// UI te dekhanor jonno: 5000 -> 50.00
  double get balanceDollars => balanceCents / 100.0;

  factory GiftCard.fromJson(Map<String, dynamic> json) => GiftCard(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        tenantId: json['tenantId']?.toString(),
        locationId: json['locationId']?.toString(),
        cardNumber: (json['cardNumber'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        balanceCents: (json['balanceCents'] ?? 0) as int,
        currency: (json['currency'] ?? 'CAD').toString(),
        batchId: json['batchId']?.toString(),
        owner: json['owner'] is Map
            ? Owner.fromJson(Map<String, dynamic>.from(json['owner']))
            : null,
        createdAt: _date(json['createdAt']),
        updatedAt: _date(json['updatedAt']),
        activatedAt: _date(json['activatedAt']),
        activatedBy: json['activatedBy']?.toString(),
        lastActivityAt: _date(json['lastActivityAt']),
      );

  static DateTime? _date(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());
}

/// Inner data block: { card, tcn }
class ActivateData {
  final GiftCard card;
  final String tcn;

  const ActivateData({required this.card, required this.tcn});

  factory ActivateData.fromJson(Map<String, dynamic> json) => ActivateData(
        card: GiftCard.fromJson(Map<String, dynamic>.from(json['card'])),
        tcn: (json['tcn'] ?? '').toString(),
      );
}

/// Full envelope: { statusCode, success, message, data: { card, tcn } }
class ActivateCardResponse {
  final int? statusCode;
  final bool success;
  final String message;
  final ActivateData? data;

  const ActivateCardResponse({
    this.statusCode,
    required this.success,
    required this.message,
    this.data,
  });

  factory ActivateCardResponse.fromJson(Map<String, dynamic> json) =>
      ActivateCardResponse(
        statusCode: json['statusCode'] is int ? json['statusCode'] as int : null,
        success: json['success'] == true,
        message: (json['message'] ?? '').toString(),
        data: json['data'] is Map
            ? ActivateData.fromJson(Map<String, dynamic>.from(json['data']))
            : null,
      );
}