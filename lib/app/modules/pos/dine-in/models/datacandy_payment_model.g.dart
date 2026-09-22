// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datacandy_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataCandyPaymentModel _$DataCandyPaymentModelFromJson(
  Map<String, dynamic> json,
) => DataCandyPaymentModel(
  balance: json['balance'] as num? ?? 0,
  cid: json['CID'] as String? ?? '',
  tcn: json['TCN'] as String? ?? '',
  amt: json['AMT'] as num? ?? 0,
  inv: json['INV'] as String? ?? '',
  wsn: json['WSN'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  v: (json['__v'] as num?)?.toInt() ?? 0,
  id: json['id'] as String? ?? '',
);

Map<String, dynamic> _$DataCandyPaymentModelToJson(
  DataCandyPaymentModel instance,
) => <String, dynamic>{
  'balance': instance.balance,
  'CID': instance.cid,
  'TCN': instance.tcn,
  'AMT': instance.amt,
  'INV': instance.inv,
  'WSN': instance.wsn,
  'createdAt': instance.createdAt.toIso8601String(),
  '__v': instance.v,
  'id': instance.id,
};
