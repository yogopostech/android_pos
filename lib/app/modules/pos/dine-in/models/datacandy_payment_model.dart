// class DataCandyPaymentModel {
//   final num balance;
//   final String cid;
//   final String tcn;
//   final num amt;
//   final String inv;
//   final String wsn;
//   final DateTime createdAt;
//   final int v;
//   final String id;

//   DataCandyPaymentModel({
//     required this.balance,
//     required this.cid,
//     required this.tcn,
//     required this.amt,
//     required this.inv,
//     required this.wsn,
//     required this.createdAt,
//     required this.v,
//     required this.id,
//   });

//   factory DataCandyPaymentModel.fromJson(Map<String, dynamic> json) {
//     return DataCandyPaymentModel(
//       balance: json['balance'] ?? 0,
//       cid: json['CID'] ?? '',
//       tcn: json['TCN'] ?? '',
//       amt: json['AMT'] ?? 0,
//       inv: json['INV'] ?? '',
//       wsn: json['WSN'] ?? '',
//       createdAt: DateTime.parse(json['createdAt']),
//       v: json['__v'] ?? 0,
//       id: json['id'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'balance': balance,
//       'CID': cid,
//       'TCN': tcn,
//       'AMT': amt,
//       'INV': inv,
//       'WSN': wsn,
//       'createdAt': createdAt.toIso8601String(),
//       '__v': v,
//       'id': id,
//     };
//   }
// }


import 'package:json_annotation/json_annotation.dart';

part 'datacandy_payment_model.g.dart';

@JsonSerializable()
class DataCandyPaymentModel {
  @JsonKey(defaultValue: 0)
  final num balance;

  @JsonKey(name: 'CID', defaultValue: '')
  final String cid;

  @JsonKey(name: 'TCN', defaultValue: '')
  final String tcn;

  @JsonKey(name: 'AMT', defaultValue: 0)
  final num amt;

  @JsonKey(name: 'INV', defaultValue: '')
  final String inv;

  @JsonKey(name: 'WSN', defaultValue: '')
  final String wsn;

  final DateTime createdAt;

  @JsonKey(name: '__v', defaultValue: 0)
  final int v;

  @JsonKey(defaultValue: '')
  final String id;

  DataCandyPaymentModel({
    required this.balance,
    required this.cid,
    required this.tcn,
    required this.amt,
    required this.inv,
    required this.wsn,
    required this.createdAt,
    required this.v,
    required this.id,
  });

  factory DataCandyPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$DataCandyPaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$DataCandyPaymentModelToJson(this);
}