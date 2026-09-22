// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRefund _$PaymentRefundFromJson(Map<String, dynamic> json) =>
    PaymentRefund(
      providerRefundId: json['providerRefundId'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency:
          $enumDecodeNullable(_$PaymentCurrencyEnumMap, json['currency']) ??
          PaymentCurrency.cad,
      reason: json['reason'] as String? ?? '',
      status:
          $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']) ??
          PaymentStatus.pending,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PaymentRefundToJson(PaymentRefund instance) =>
    <String, dynamic>{
      'providerRefundId': instance.providerRefundId,
      'amount': instance.amount,
      'currency': _$PaymentCurrencyEnumMap[instance.currency]!,
      'reason': instance.reason,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$PaymentCurrencyEnumMap = {
  PaymentCurrency.cad: 'CAD',
  PaymentCurrency.usd: 'USD',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'PENDING',
  PaymentStatus.succeeded: 'SUCCEEDED',
  PaymentStatus.failed: 'FAILED',
  PaymentStatus.refunded: 'REFUNDED',
  PaymentStatus.voided: 'VOIDED',
};

PaymentVoid _$PaymentVoidFromJson(Map<String, dynamic> json) => PaymentVoid(
  providerVoidId: json['providerVoidId'] as String?,
  reason: json['reason'] as String? ?? '',
  status:
      $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']) ??
      PaymentStatus.pending,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PaymentVoidToJson(PaymentVoid instance) =>
    <String, dynamic>{
      'providerVoidId': instance.providerVoidId,
      'reason': instance.reason,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

PaymentGiftCard _$PaymentGiftCardFromJson(Map<String, dynamic> json) =>
    PaymentGiftCard(
      code: json['code'] as String? ?? '',
      appliedAmount: (json['appliedAmount'] as num?)?.toDouble() ?? 0,
      remainingBalance: (json['remainingBalance'] as num?)?.toDouble() ?? 0,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$PaymentGiftCardToJson(PaymentGiftCard instance) =>
    <String, dynamic>{
      'code': instance.code,
      'appliedAmount': instance.appliedAmount,
      'remainingBalance': instance.remainingBalance,
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  orderId: json['orderId'] as String? ?? '',
  userId: json['userId'] as String? ?? '',
  provider:
      $enumDecodeNullable(_$PaymentProviderEnumMap, json['provider']) ??
      PaymentProvider.cash,
  providerTxnId: json['providerTxnId'] as String?,
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
  tipAmount: (json['tipAmount'] as num?)?.toDouble() ?? 0,
  feeAmount: (json['feeAmount'] as num?)?.toDouble() ?? 0,
  netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0,
  cashChange: (json['cashChange'] as num?)?.toDouble() ?? 0,
  cashRounding: (json['cashRounding'] as num?)?.toDouble() ?? 0,
  currency:
      $enumDecodeNullable(_$PaymentCurrencyEnumMap, json['currency']) ??
      PaymentCurrency.cad,
  method:
      $enumDecodeNullable(_$PaymentMethodEnumMap, json['method']) ??
      PaymentMethod.cash,
  cardNetwork: $enumDecodeNullable(_$CardNetworkEnumMap, json['cardNetwork']),
  walletType: $enumDecodeNullable(_$WalletTypeEnumMap, json['walletType']),
  last4: json['last4'] as String? ?? '',
  status:
      $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']) ??
      PaymentStatus.pending,
  errorCode: json['errorCode'] as String?,
  errorMessage: json['errorMessage'] as String?,
  refunds:
      (json['refunds'] as List<dynamic>?)
          ?.map((e) => PaymentRefund.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalRefunded: (json['totalRefunded'] as num?)?.toDouble() ?? 0,
  refundable: (json['refundable'] as num?)?.toDouble() ?? 0,
  voidDetails: json['voidDetails'] == null
      ? null
      : PaymentVoid.fromJson(json['voidDetails'] as Map<String, dynamic>),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'provider': _$PaymentProviderEnumMap[instance.provider]!,
  'providerTxnId': instance.providerTxnId,
  'amount': instance.amount,
  'tipAmount': instance.tipAmount,
  'feeAmount': instance.feeAmount,
  'netAmount': instance.netAmount,
  'cashChange': instance.cashChange,
  'cashRounding': instance.cashRounding,
  'currency': _$PaymentCurrencyEnumMap[instance.currency]!,
  'method': _$PaymentMethodEnumMap[instance.method]!,
  'cardNetwork': _$CardNetworkEnumMap[instance.cardNetwork],
  'walletType': _$WalletTypeEnumMap[instance.walletType],
  'last4': instance.last4,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'errorCode': instance.errorCode,
  'errorMessage': instance.errorMessage,
  'refunds': instance.refunds,
  'totalRefunded': instance.totalRefunded,
  'refundable': instance.refundable,
  'voidDetails': instance.voidDetails,
  'metadata': instance.metadata,
};

const _$PaymentProviderEnumMap = {
  PaymentProvider.cash: 'CASH',
  PaymentProvider.standalone: 'STANDALONE',
  PaymentProvider.stripe: 'STRIPE',
  PaymentProvider.moneris: 'MONERIS',
  PaymentProvider.elavon: 'ELAVON',
  PaymentProvider.datacandy: 'DATACANDY',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'CASH',
  PaymentMethod.card: 'CARD',
  PaymentMethod.giftCard: 'GIFT_CARD',
  PaymentMethod.wallet: 'WALLET',
};

const _$CardNetworkEnumMap = {
  CardNetwork.visa: 'VISA',
  CardNetwork.mastercard: 'MASTERCARD',
  CardNetwork.amex: 'AMEX',
  CardNetwork.debit: 'DEBIT',
  CardNetwork.discover: 'DISCOVER',
  CardNetwork.jcb: 'JCB',
  CardNetwork.unionpay: 'UNIONPAY',
  CardNetwork.diners: 'DINERS',
  CardNetwork.cartesBancaires: 'CARTES BANCAIRES',
  CardNetwork.others: 'OTHERS',
};

const _$WalletTypeEnumMap = {
  WalletType.applePay: 'APPLE_PAY',
  WalletType.googlePay: 'GOOGLE_PAY',
  WalletType.others: 'OTHERS',
};
