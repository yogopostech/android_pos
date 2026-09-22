/// Bulk gift card activation: request inputs + payment selection + response.
///
/// API: POST {{base-url}}/giftcards/pos/activate/bulk
///
/// Request body shape:
///   {
///     "idempotencyKey": "...",          // controller adds
///     ...session,                        // controller adds (tenant/location/staff)
///     "cards": [ { cardNumber, initialAmount, owner{name,phone,email?},
///                  source, currency?, note? }, ... ],
///     "payments": [ { methods, paidAmount }, ... ]
///   }

/// One card in the bulk request.
class BulkCardInput {
  final String cardNumber; // digits only
  final num initialAmount;
  final String name;
  final String phone; // digits only
  final String source; // e.g. "Cash" / "Card"
  final String? email;
  final String? currency; // e.g. "CAD"
  final String? note;

  const BulkCardInput({
    required this.cardNumber,
    required this.initialAmount,
    required this.name,
    required this.phone,
    required this.source,
    this.email,
    this.currency,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'cardNumber': cardNumber,
        'initialAmount': initialAmount,
        'owner': {
          'name': name,
          'phone': phone,
          if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
        },
        'source': source,
        if (currency != null && currency!.isNotEmpty) 'currency': currency,
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}

/// One payment line in the bulk request.
class BulkPaymentInput {
  final String methods; // e.g. "CASH", "VISA", "MASTERCARD"
  final num paidAmount;

  const BulkPaymentInput({required this.methods, required this.paidAmount});

  Map<String, dynamic> toJson() => {
        'methods': methods,
        'paidAmount': paidAmount,
      };
}

/// What the payment flow returns to the caller (the dialog builds the request).
class PaymentSelection {
  final List<BulkPaymentInput> payments;
  final bool printCheck;

  const PaymentSelection({required this.payments, required this.printCheck});
}

/// ---------------------------------------------------------------------------
/// RESPONSE
/// ---------------------------------------------------------------------------
class BulkActivateResponse {
  final int statusCode;
  final bool success;
  final String message;
  final BulkActivateData? data;

  BulkActivateResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory BulkActivateResponse.fromJson(Map<String, dynamic> json) {
    return BulkActivateResponse(
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? BulkActivateData.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
    );
  }
}

class BulkActivateData {
  final String? batchId;
  final List<BulkActivatedCard> cards;
  final List<BulkActivatedPayment> payments;

  BulkActivateData({
    required this.batchId,
    required this.cards,
    required this.payments,
  });

  factory BulkActivateData.fromJson(Map<String, dynamic> json) {
    return BulkActivateData(
      batchId: json['batchId']?.toString(),
      cards: (json['cards'] is List)
          ? (json['cards'] as List)
              .whereType<Map>()
              .map((e) => BulkActivatedCard.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
          : const [],
      payments: (json['payments'] is List)
          ? (json['payments'] as List)
              .whereType<Map>()
              .map((e) => BulkActivatedPayment.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
          : const [],
    );
  }
}

class BulkActivatedCard {
  final String? cardNumber;
  final String? tcn;
  final String? invoiceNumber;
  final Map<String, dynamic>? card; // nested card object

  BulkActivatedCard({
    required this.cardNumber,
    required this.tcn,
    required this.invoiceNumber,
    required this.card,
  });

  factory BulkActivatedCard.fromJson(Map<String, dynamic> json) {
    return BulkActivatedCard(
      cardNumber: json['cardNumber']?.toString(),
      tcn: json['tcn']?.toString(),
      invoiceNumber: json['invoiceNumber']?.toString(),
      card: json['card'] is Map
          ? Map<String, dynamic>.from(json['card'] as Map)
          : null,
    );
  }
}

class BulkActivatedPayment {
  final String? methods;
  final num? paidAmount;
  final num? tipAmount;
  final num? change;
  final String? providerName;
  final String? transactionId;
  final num? extraAmount;
  final String? idempotencyKey;

  BulkActivatedPayment({
    required this.methods,
    required this.paidAmount,
    required this.tipAmount,
    required this.change,
    required this.providerName,
    required this.transactionId,
    required this.extraAmount,
    required this.idempotencyKey,
  });

  factory BulkActivatedPayment.fromJson(Map<String, dynamic> json) {
    return BulkActivatedPayment(
      methods: json['methods']?.toString(),
      paidAmount: json['paidAmount'] as num?,
      tipAmount: json['tipAmount'] as num?,
      change: json['change'] as num?,
      providerName: json['providerName']?.toString(),
      transactionId: json['transactionId']?.toString(),
      extraAmount: json['extraAmount'] as num?,
      idempotencyKey: json['idempotencyKey']?.toString(),
    );
  }
}
