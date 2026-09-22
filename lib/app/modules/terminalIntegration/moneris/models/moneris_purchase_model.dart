class MonerisPurchaseModel {
  MonerisPurchaseModel({
    required this.receipt,
  });

  final Receipt receipt;

  factory MonerisPurchaseModel.fromJson(Map<String, dynamic> json) {
    return MonerisPurchaseModel(
      receipt: Receipt.fromJson(json["receipt"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "receipt": receipt.toJson(),
      };
}

class Receipt {
  Receipt({
    required this.apiVersion,
    required this.statusCode,
    // required this.status,
    required this.dataId,
    // required this.dataTimestamp,
    required this.data,
  });

  final String apiVersion;
  final String statusCode;
  // final String status;
  final String dataId;
  // final DateTime? dataTimestamp;
  final Data data;

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      apiVersion: json["apiVersion"] ?? "",
      statusCode: json["statusCode"] ?? "",
      // status: json["status"] ?? "",
      dataId: json["dataId"] ?? "",
      // dataTimestamp: DateTime.tryParse(json["dataTimestamp"] ?? ""),
      data: Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "apiVersion": apiVersion,
        "statusCode": statusCode,
        "dataId": dataId,
        "data": data.toJson(),
      };
}

class Data {
  Data({
    required this.response,
  });

  final List<Response> response;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      response: json["response"] == null
          ? []
          : List<Response>.from(
              json["response"]!.map((x) => Response.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "response": response.map((x) => x.toJson()).toList(),
      };
}

class Response {
  Response({
    required this.orderId,
    required this.transactionId,
    required this.linkId,
    required this.statusCode,
    required this.status,
    required this.idempotencyKey,
    required this.cloudTicket,
    required this.completed,
    required this.responseCode,
    required this.iso,
    required this.tipAmount,
    required this.cashback,
    required this.surcharge,
    required this.approvedAmount,
    required this.tenderType,
    required this.cardType,
    required this.cardName,
    required this.sequenceNum,
    required this.realTimeUniqueId,
    required this.authCode,
    required this.formFactor,
    required this.maskedPan,
    required this.action,
    required this.terminalId,
    required this.receipt,
    required this.totalAmount,
  });

  final String orderId;
  final String transactionId;
  final String linkId;
  final String statusCode;
  final String status;
  final String idempotencyKey;
  final String cloudTicket;
  final String completed;
  final String responseCode;
  final String iso;
  final String tipAmount;
  final String cashback;
  final String surcharge;
  final String approvedAmount;
  final String tenderType;
  final String cardType;
  final String cardName;
  final String sequenceNum;
  final String realTimeUniqueId;
  final String authCode;
  final String formFactor;
  final String maskedPan;
  final String action;
  final String terminalId;
  final String receipt;
  final String totalAmount;

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      orderId: json["orderId"] ?? "",
      transactionId: json["transactionId"] ?? "",
      linkId: json["linkId"] ?? "",
      statusCode: json["statusCode"] ?? "",
      status: json["status"] ?? "",
      idempotencyKey: json["idempotencyKey"] ?? "",
      cloudTicket: json["cloudTicket"] ?? "",
      completed: json["completed"] ?? "",
      responseCode: json["responseCode"] ?? "",
      iso: json["iso"] ?? "",
      tipAmount: json["tipAmount"] ?? "",
      cashback: json["cashback"] ?? "",
      surcharge: json["surcharge"] ?? "",
      approvedAmount: json["approvedAmount"] ?? "",
      tenderType: json["tenderType"] ?? "",
      cardType: json["cardType"] ?? "",
      cardName: json["cardName"] ?? "",
      sequenceNum: json["sequenceNum"] ?? "",
      realTimeUniqueId: json["realTimeUniqueId"] ?? "",
      authCode: json["authCode"] ?? "",
      formFactor: json["formFactor"] ?? "",
      maskedPan: json["maskedPan"] ?? "",
      action: json["action"] ?? "",
      terminalId: json["terminalId"] ?? "",
      receipt: json["receipt"] ?? "",
      totalAmount: json["totalAmount"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "orderId": orderId,
        "transactionId": transactionId,
        "linkId": linkId,
        "statusCode": statusCode,
        "status": status,
        "idempotencyKey": idempotencyKey,
        "cloudTicket": cloudTicket,
        "completed": completed,
        "responseCode": responseCode,
        "iso": iso,
        "tipAmount": tipAmount,
        "cashback": cashback,
        "surcharge": surcharge,
        "approvedAmount": approvedAmount,
        "tenderType": tenderType,
        "cardType": cardType,
        "cardName": cardName,
        "sequenceNum": sequenceNum,
        "realTimeUniqueId": realTimeUniqueId,
        "authCode": authCode,
        "formFactor": formFactor,
        "maskedPan": maskedPan,
        "action": action,
        "terminalId": terminalId,
        "receipt": receipt,
        "totalAmount": totalAmount,
      };
}
