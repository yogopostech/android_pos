/// Redeem response model.
///
/// API: POST {{base-url}}/giftcards/pos/redeem
///
/// Sample:
/// {
///   "statusCode": 200,
///   "success": true,
///   "message": "Redeemed successfully",
///   "data": {
///     "appliedCents": 7500,           // actual amount deducted from card
///     "remainingBalanceCents": 0,
///     "tcn": "7971050825",
///     "txnId": "6a9a5e61ed6303ae498e3746",
///     "invoiceNumber": "260904-393098"
///   }
/// }
class RedeemResponse {
  final int statusCode;
  final bool success;
  final String message;
  final RedeemData? data;

  RedeemResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory RedeemResponse.fromJson(Map<String, dynamic> json) {
    return RedeemResponse(
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? RedeemData.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
    );
  }
}

class RedeemData {
  final int? appliedCents; // actual amount deducted from card
  final int? remainingBalanceCents;
  final String? tcn;
  final String? txnId;
  final String? invoiceNumber;

  RedeemData({
    required this.appliedCents,
    required this.remainingBalanceCents,
    required this.tcn,
    required this.txnId,
    required this.invoiceNumber,
  });

  factory RedeemData.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic v) => v is int ? v : (v is num ? v.toInt() : null);
    return RedeemData(
      appliedCents: asInt(json['appliedCents']),
      remainingBalanceCents: asInt(json['remainingBalanceCents']),
      tcn: json['tcn']?.toString(),
      txnId: json['txnId']?.toString(),
      invoiceNumber: json['invoiceNumber']?.toString(),
    );
  }

  /// Helpers for display.
  double get appliedDollars => (appliedCents ?? 0) / 100.0;
  double get remainingDollars => (remainingBalanceCents ?? 0) / 100.0;
}
