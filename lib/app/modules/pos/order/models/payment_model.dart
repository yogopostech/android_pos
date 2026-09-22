class PaymentModel {
  PaymentModel({
    this.methods = const [],
    this.cardPaidAmount = 0,
    this.cardTipAmount = 0,
    this.cashPaidAmount = 0,
    this.cashTipAmount = 0,
    this.cardType = "",
    this.change = 0,
    this.method = "",
    this.maskedPan = "",
    this.entryMode = "",
    this.extraAmount = 0,
    this.transactionId = "",
    this.paymentIntent,
    this.providerName = "standalone",
  });
  String method;
  List<String> methods;
  num cardPaidAmount;
  num cardTipAmount;
  num cashPaidAmount;
  num cashTipAmount;
  String cardType;
  String entryMode;
  String maskedPan;

  num change;
  num extraAmount;
  String transactionId;
  String? paymentIntent;
  String providerName;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      methods: List<String>.from(json["methods"] ?? []),
      method: json["method"] ?? "",
      cardPaidAmount: json["cardPaidAmount"] ?? 0,
      cardTipAmount: json["cardTipAmount"] ?? 0,
      cashPaidAmount: json["cashPaidAmount"] ?? 0,
      cashTipAmount: json["cashTipAmount"] ?? 0,
      cardType: json["cardType"] ?? "",
      entryMode: json["entryMode"] ?? "",
      maskedPan: json["maskedPan"] ?? "",
      change: json["change"] ?? 0,

      extraAmount: json["extraAmount"] ?? 0,
      transactionId: json["transactionId"] ?? "",
      paymentIntent: json["paymentIntent"],
      providerName: json["providerName"] ?? "standalone",
    );
  }

  Map<String, dynamic> toJson() => {
    "methods": methods,
    "method": method,
    "cardPaidAmount": cardPaidAmount,
    "cardTipAmount": cardTipAmount,
    "cashPaidAmount": cashPaidAmount,
    "cashTipAmount": cashTipAmount,
    "cardType": cardType,
    "entryMode": entryMode,
    "maskedPan": maskedPan,
    "change": change,
    "extraAmount": extraAmount,
    "transactionId": transactionId,
    if (paymentIntent != null) "paymentIntent": paymentIntent,
    "providerName": providerName,
  };
}
