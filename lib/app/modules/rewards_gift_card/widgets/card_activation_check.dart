class ActivationCheckResponse {
  final int statusCode;
  final bool status;
  final String message;
  final ActivationCheckData? data;

  ActivationCheckResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    required this.data,
  });

  factory ActivationCheckResponse.fromJson(Map<String, dynamic> json) {
    return ActivationCheckResponse(
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
      status: json['status'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? ActivationCheckData.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
    );
  }
}

class ActivationCheckData {
  final String? code; // present on failure, e.g. CARD_ALREADY_ACTIVE
  final ActivationCheckCard? card; // present on success

  ActivationCheckData({required this.code, required this.card});

  factory ActivationCheckData.fromJson(Map<String, dynamic> json) {
    return ActivationCheckData(
      code: json['code']?.toString(),
      card: json['card'] is Map
          ? ActivationCheckCard.fromJson(
              Map<String, dynamic>.from(json['card'] as Map),
            )
          : null,
    );
  }
}

class ActivationCheckCard {
  final String? cardNumber;
  final String? status; // e.g. "Inactive"
  final String? currency; // e.g. "CAD"

  ActivationCheckCard({
    required this.cardNumber,
    required this.status,
    required this.currency,
  });

  factory ActivationCheckCard.fromJson(Map<String, dynamic> json) {
    return ActivationCheckCard(
      cardNumber: json['cardNumber']?.toString(),
      status: json['status']?.toString(),
      currency: json['currency']?.toString(),
    );
  }
}
