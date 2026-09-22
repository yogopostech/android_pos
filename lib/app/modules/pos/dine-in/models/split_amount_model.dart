// To parse this JSON data, do
//
//     final splitAmountModel = splitAmountModelFromJson(jsonString);

import 'dart:convert';

import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';

SplitAmountModel splitAmountModelFromJson(String str) =>
    SplitAmountModel.fromJson(json.decode(str));

String splitAmountModelToJson(SplitAmountModel data) =>
    json.encode(data.toJson());

class SplitAmountModel {
  List<SplitAmount> splitAmounts;

  SplitAmountModel({
    required this.splitAmounts,
  });

  factory SplitAmountModel.fromJson(Map<String, dynamic> json) =>
      SplitAmountModel(
        splitAmounts: List<SplitAmount>.from(
            json["splitAmounts"].map((x) => SplitAmount.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "splitAmounts": List<dynamic>.from(splitAmounts.map((x) => x.toJson())),
      };
}

class SplitAmount {
  String orderId;
  String guestName;
  num splitAmount;
  num packagingCost;
  num extraAmount;
  num total;
  bool isVoid;
  bool refund;
  PaymentModel? payment;
  int declineAttempt;

  SplitAmount({
    required this.guestName,
    required this.splitAmount,
    this.orderId = "",
    this.packagingCost = 0,
    this.extraAmount = 0,
    this.total = 0,
    this.payment,
    this.isVoid =false,
    this.refund =false,
    this.declineAttempt = 0,
  });
  factory SplitAmount.fromJson(Map<String, dynamic> json) => SplitAmount(
        guestName: json["guestName"] ?? "",
        splitAmount: json["splitAmount"] ?? 0,
        extraAmount: json["extraAmount"] ?? 0,
        packagingCost: json["packagingCost"] ?? 0,
        isVoid: json["isVoid"] ?? false,
        refund: json["refund"] ?? false,
        total: json["total"] ?? 0,
        orderId: json["orderId"] ?? "",
        payment: json["payment"] == null
            ? null
            : PaymentModel.fromJson(json["payment"]),
        declineAttempt: json["declineAttempt"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "guestName": guestName,
        "splitAmount": splitAmount,
        "extraAmount": extraAmount,
        "orderId": orderId,
        "isVoid": isVoid,
        "refund": refund,
        "packagingCost": packagingCost,
        "total": total,
        if (payment != null) "payment": payment,
        "declineAttempt": declineAttempt,
      };
}
