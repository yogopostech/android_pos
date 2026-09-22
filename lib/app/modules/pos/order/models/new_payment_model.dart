import 'package:json_annotation/json_annotation.dart';

part 'new_payment_model.g.dart';

// ══════════════════════════════════════════════════════════════
// ENUMS
// ══════════════════════════════════════════════════════════════

@JsonEnum()
enum PaymentProvider {
  @JsonValue('CASH')
  cash,

  @JsonValue('STANDALONE')
  standalone,

  @JsonValue('STRIPE')
  stripe,

  @JsonValue('MONERIS')
  moneris,

  @JsonValue('ELAVON')
  elavon,

  @JsonValue('DATACANDY')
  datacandy,
}

@JsonEnum()
enum PaymentMethod {
  @JsonValue('CASH')
  cash,

  @JsonValue('CARD')
  card,

  @JsonValue('GIFT_CARD')
  giftCard,

  @JsonValue('WALLET')
  wallet,
}

@JsonEnum()
enum CardNetwork {
  @JsonValue('VISA')
  visa,

  @JsonValue('MASTERCARD')
  mastercard,

  @JsonValue('AMEX')
  amex,

  @JsonValue('DEBIT')
  debit,

  @JsonValue('DISCOVER')
  discover,

  @JsonValue('JCB')
  jcb,

  @JsonValue('UNIONPAY')
  unionpay,

  @JsonValue('DINERS')
  diners,

  @JsonValue('CARTES BANCAIRES')
  cartesBancaires,

  @JsonValue('OTHERS')
  others,
}

@JsonEnum()
enum WalletType {
  @JsonValue('APPLE_PAY')
  applePay,

  @JsonValue('GOOGLE_PAY')
  googlePay,

  @JsonValue('OTHERS')
  others,
}

@JsonEnum()
enum PaymentCurrency {
  @JsonValue('CAD')
  cad,

  @JsonValue('USD')
  usd,
}

@JsonEnum()
enum PaymentStatus {
  @JsonValue('PENDING')
  pending,

  @JsonValue('SUCCEEDED')
  succeeded,

  @JsonValue('FAILED')
  failed,

  @JsonValue('REFUNDED')
  refunded,

  @JsonValue('VOIDED')
  voided,
}

// ══════════════════════════════════════════════════════════════
// PAYMENT REFUND
// ══════════════════════════════════════════════════════════════

@JsonSerializable()
class PaymentRefund {
  final String? providerRefundId;
  final double amount;
  final PaymentCurrency currency;
  final String reason;
  final PaymentStatus status;
  final DateTime? createdAt;

  PaymentRefund({
    this.providerRefundId,
    this.amount = 0,
    this.currency = PaymentCurrency.cad,
    this.reason = '',
    this.status = PaymentStatus.pending,
    this.createdAt,
  });

  factory PaymentRefund.fromJson(Map<String, dynamic> json) =>
      _$PaymentRefundFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentRefundToJson(this);

  PaymentRefund copyWith({
    String? providerRefundId,
    double? amount,
    PaymentCurrency? currency,
    String? reason,
    PaymentStatus? status,
    DateTime? createdAt,
  }) {
    return PaymentRefund(
      providerRefundId: providerRefundId ?? this.providerRefundId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PAYMENT VOID
// ══════════════════════════════════════════════════════════════

@JsonSerializable()
class PaymentVoid {
  final String? providerVoidId;
  final String reason;
  final PaymentStatus status;
  final DateTime? createdAt;

  PaymentVoid({
    this.providerVoidId,
    this.reason = '',
    this.status = PaymentStatus.pending,
    this.createdAt,
  });

  factory PaymentVoid.fromJson(Map<String, dynamic> json) =>
      _$PaymentVoidFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentVoidToJson(this);

  PaymentVoid copyWith({
    String? providerVoidId,
    String? reason,
    PaymentStatus? status,
    DateTime? createdAt,
  }) {
    return PaymentVoid(
      providerVoidId: providerVoidId ?? this.providerVoidId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PAYMENT GIFT CARD
// ══════════════════════════════════════════════════════════════

@JsonSerializable()
class PaymentGiftCard {
  final String code;
  final double appliedAmount;
  final double remainingBalance;
  final DateTime? expiresAt;

  PaymentGiftCard({
    this.code = '',
    this.appliedAmount = 0,
    this.remainingBalance = 0,
    this.expiresAt,
  });

  factory PaymentGiftCard.fromJson(Map<String, dynamic> json) =>
      _$PaymentGiftCardFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentGiftCardToJson(this);

  PaymentGiftCard copyWith({
    String? code,
    double? appliedAmount,
    double? remainingBalance,
    DateTime? expiresAt,
  }) {
    return PaymentGiftCard(
      code: code ?? this.code,
      appliedAmount: appliedAmount ?? this.appliedAmount,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PAYMENT
// ══════════════════════════════════════════════════════════════

@JsonSerializable()
class Payment {
  @JsonKey(includeToJson: false)
  final String orderId;

  @JsonKey(includeToJson: false)
  final String userId;

  final PaymentProvider provider;
  final String? providerTxnId;
  final double amount;
  final double tipAmount;
  final double feeAmount;
  final double netAmount;
  final double cashChange;
  final double cashRounding;
  final PaymentCurrency currency;
  final PaymentMethod method;
  final CardNetwork? cardNetwork;
  final WalletType? walletType;
  final String last4;
  final PaymentStatus status;
  final String? errorCode;
  final String? errorMessage;
  final List<PaymentRefund> refunds;

  @JsonKey(defaultValue: 0)
  final double totalRefunded;

  @JsonKey(defaultValue: 0)
  final double refundable;

  final PaymentVoid? voidDetails;
  final Map<String, dynamic>? metadata;

  Payment({
    this.orderId = '',
    this.userId = '',
    this.provider = PaymentProvider.cash,
    this.providerTxnId,
    this.amount = 0,
    this.tipAmount = 0,
    this.feeAmount = 0,
    this.netAmount = 0,
    this.cashChange = 0,
    this.cashRounding = 0,
    this.currency = PaymentCurrency.cad,
    this.method = PaymentMethod.cash,
    this.cardNetwork,
    this.walletType,
    this.last4 = '',
    this.status = PaymentStatus.pending,
    this.errorCode,
    this.errorMessage,
    this.refunds = const [],
    this.totalRefunded = 0,
    this.refundable = 0,
    this.voidDetails,
    this.metadata,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  Payment copyWith({
    String? orderId,
    String? userId,
    PaymentProvider? provider,
    String? providerTxnId,
    double? amount,
    double? tipAmount,
    double? feeAmount,
    double? netAmount,
    double? cashChange,
    double? cashRounding,
    PaymentCurrency? currency,
    PaymentMethod? method,
    CardNetwork? cardNetwork,
    WalletType? walletType,
    String? last4,
    PaymentGiftCard? giftCardDetails,
    PaymentStatus? status,
    String? errorCode,
    String? errorMessage,
    List<PaymentRefund>? refunds,
    double? totalRefunded,
    double? refundable,
    PaymentVoid? voidDetails,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
      providerTxnId: providerTxnId ?? this.providerTxnId,
      amount: amount ?? this.amount,
      tipAmount: tipAmount ?? this.tipAmount,
      feeAmount: feeAmount ?? this.feeAmount,
      netAmount: netAmount ?? this.netAmount,
      cashChange: cashChange ?? this.cashChange,
      currency: currency ?? this.currency,
      method: method ?? this.method,
      cardNetwork: cardNetwork ?? this.cardNetwork,
      walletType: walletType ?? this.walletType,
      last4: last4 ?? this.last4,
      status: status ?? this.status,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
      refunds: refunds ?? this.refunds,
      totalRefunded: totalRefunded ?? this.totalRefunded,
      refundable: refundable ?? this.refundable,
      voidDetails: voidDetails ?? this.voidDetails,
      metadata: metadata ?? this.metadata,
    );
  }

  // ── Computed ──────────────────────────────────────────────

  bool get isVoidable =>
      (status == PaymentStatus.pending ||
          status == PaymentStatus.succeeded) &&
      status != PaymentStatus.refunded &&
      status != PaymentStatus.voided &&
      provider != PaymentProvider.cash;

  bool get isRefundable =>
      status == PaymentStatus.succeeded && refundable > 0;

  bool get isCash => provider == PaymentProvider.cash;

  bool get isGiftCard => method == PaymentMethod.giftCard;

  String get cardDisplayLabel {
    if (isCash) return 'Cash';
    // if (isGiftCard) {
    //   return 'Gift Card${giftCardDetails != null ? ' ${giftCardDetails!.code}' : ''}';
    // }
    final network = cardNetwork?.name ?? 'Card';
    final suffix = last4.isNotEmpty ? ' ····$last4' : '';
    return '$network$suffix';
  }

  String get providerLabel => switch (provider) {
        PaymentProvider.cash => 'Cash',
        PaymentProvider.standalone => 'Standalone',
        PaymentProvider.stripe => 'Stripe',
        PaymentProvider.moneris => 'Moneris',
        PaymentProvider.elavon => 'Elavon',
        PaymentProvider.datacandy => 'DataCandy',
      };

  double get totalWithTip => amount + tipAmount;

  double get totalAfterFee => amount + tipAmount - feeAmount;
}