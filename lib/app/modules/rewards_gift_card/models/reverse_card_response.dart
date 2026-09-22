/// ---------------------------------------------------------------------------
/// REVERSE / CANCEL TRANSACTION — RESPONSE MODEL
/// ---------------------------------------------------------------------------

class ReverseCardResponse {
  final int statusCode;
  final bool success;
  final String message;
  final ReverseCardData? data;

  const ReverseCardResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    this.data,
  });

  factory ReverseCardResponse.fromJson(Map<String, dynamic> json) {
    return ReverseCardResponse(
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: json['data'] is Map<String, dynamic>
          ? ReverseCardData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ReverseCardData {
  /// Card object — backend je structure pathay seta raw hisebe rakhlam.
  /// Apnader existing card model thakle sheta diye replace korte paren.
  final Map<String, dynamic>? card;
  final String tcn;
  final String invoiceNumber;
  final ReversePayments? payments;

  const ReverseCardData({
    this.card,
    required this.tcn,
    required this.invoiceNumber,
    this.payments,
  });

  factory ReverseCardData.fromJson(Map<String, dynamic> json) {
    return ReverseCardData(
      card: json['card'] is Map<String, dynamic>
          ? json['card'] as Map<String, dynamic>
          : null,
      tcn: (json['tcn'] ?? '').toString(),
      invoiceNumber: (json['invoiceNumber'] ?? '').toString(),
      payments: json['payments'] is Map<String, dynamic>
          ? ReversePayments.fromJson(json['payments'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convenience getters — card balance access korar jonno
  int get balanceCents => (card?['balanceCents'] as num?)?.toInt() ?? 0;
  double get balanceDollars => balanceCents / 100.0;
}

class ReversePayments {
  final String id;
  final List<String> methods;
  final num cardPaidAmount;
  final num cardTipAmount;
  final num cashPaidAmount;
  final num cashTipAmount;
  final num change;
  final String providerName;
  final String transactionId;
  final num extraAmount;
  final String idempotencyKey;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReversePayments({
    required this.id,
    required this.methods,
    required this.cardPaidAmount,
    required this.cardTipAmount,
    required this.cashPaidAmount,
    required this.cashTipAmount,
    required this.change,
    required this.providerName,
    required this.transactionId,
    required this.extraAmount,
    required this.idempotencyKey,
    this.createdAt,
    this.updatedAt,
  });

  factory ReversePayments.fromJson(Map<String, dynamic> json) {
    return ReversePayments(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      methods: json['methods'] is List
          ? (json['methods'] as List).map((e) => e.toString()).toList()
          : const [],
      cardPaidAmount: (json['cardPaidAmount'] as num?) ?? 0,
      cardTipAmount: (json['cardTipAmount'] as num?) ?? 0,
      cashPaidAmount: (json['cashPaidAmount'] as num?) ?? 0,
      cashTipAmount: (json['cashTipAmount'] as num?) ?? 0,
      change: (json['change'] as num?) ?? 0,
      providerName: (json['providerName'] ?? '').toString(),
      transactionId: (json['transactionId'] ?? '').toString(),
      extraAmount: (json['extraAmount'] as num?) ?? 0,
      idempotencyKey: (json['idempotencyKey'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString(),
      ),
    );
  }
}