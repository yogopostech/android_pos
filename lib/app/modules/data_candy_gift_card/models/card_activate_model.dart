class CardActivationResponse {
  final int statusCode;
  final bool success;
  final String message;
  final DataCandyActiveCardModel? data;

  CardActivationResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    this.data,
  });

  factory CardActivationResponse.fromJson(Map<String, dynamic> json) {
    return CardActivationResponse(
      statusCode: json['statusCode'] ?? 0,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? DataCandyActiveCardModel.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "statusCode": statusCode,
      "success": success,
      "message": message,
      "data": data?.toJson(),
    };
  }
}

class DataCandyActiveCardModel {
  final String cid;
  final String tcn;
  final String transactionType;
  final num amt;
  final String inv;
  final String wsn;
  final String user;
  final String employee;
  final String wan;
  final InitialResponse? initialResponse;
  final CommitResponse? commitResponse;
  final String id;
  final DateTime createdAt;
  final String employeeFirstName;
  final String employeeLastName;

  DataCandyActiveCardModel({
    required this.cid,
    required this.tcn,
    required this.transactionType,
    required this.amt,
    required this.inv,
    required this.wsn,
    required this.user,
    required this.employee,
    required this.wan,
    this.initialResponse,
    this.commitResponse,
    required this.id,
    required this.createdAt,
    required this.employeeFirstName,
    required this.employeeLastName,
  });

  factory DataCandyActiveCardModel.fromJson(Map<String, dynamic> json) {
    return DataCandyActiveCardModel(
      cid: json['CID'] ?? '',
      tcn: json['TCN'] ?? '',
      transactionType: json['transactionType'] ?? '',
      amt: num.tryParse(json['AMT']?.toString() ?? '0') ?? 0,
      inv: json['INV'] ?? '',
      wsn: json['WSN'] ?? '',
      user: json['user'] ?? '',
      employee: json['employee'] ?? '',
      wan: json['WAN'] ?? '',
      initialResponse: json['initialResponse'] != null
          ? InitialResponse.fromJson(json['initialResponse'])
          : null,
      commitResponse: json['commitResponse'] != null
          ? CommitResponse.fromJson(json['commitResponse'])
          : null,
      id: json['_id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      employeeFirstName: json['employeeFirstName'] ?? '',
      employeeLastName: json['employeeLastName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "CID": cid,
      "TCN": tcn,
      "transactionType": transactionType,
      "AMT": amt,
      "INV": inv,
      "WSN": wsn,
      "user": user,
      "employee": employee,
      "WAN": wan,
      "initialResponse": initialResponse?.toJson(),
      "commitResponse": commitResponse?.toJson(),
      "_id": id,
      "createdAt": createdAt,
      "employeeFirstName": employeeFirstName,
      "employeeLastName": employeeLastName,
    };
  }
}

class InitialResponse {
  final String mid;
  final String prg;
  final String trx;
  final String wsn;
  final String wan;
  final String ctm;
  final String tcn;
  final String cid;
  final String inv;
  final String aid;
  final num amt;
  final double bal;
  final String lng;
  final String res;
  final String msg;

  InitialResponse({
    required this.mid,
    required this.prg,
    required this.trx,
    required this.wsn,
    required this.wan,
    required this.ctm,
    required this.tcn,
    required this.cid,
    required this.inv,
    required this.aid,
    required this.amt,
    required this.bal,
    required this.lng,
    required this.res,
    required this.msg,
  });

  factory InitialResponse.fromJson(Map<String, dynamic> json) {
    return InitialResponse(
      mid: json['MID'] ?? '',
      prg: json['PRG'] ?? '',
      trx: json['TRX'] ?? '',
      wsn: json['WSN'] ?? '',
      wan: json['WAN'] ?? '',
      ctm: json['CTM'] ?? '',
      tcn: json['TCN'] ?? '',
      cid: json['CID'] ?? '',
      inv: json['INV'] ?? '',
      aid: json['AID'] ?? '',
      amt: num.tryParse(json['AMT']?.toString() ?? '0') ?? 0,
      bal: double.tryParse(json['BAL']?.toString() ?? '0') ?? 0,
      lng: json['LNG'] ?? '',
      res: json['RES'] ?? '',
      msg: json['MSG'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "MID": mid,
      "PRG": prg,
      "TRX": trx,
      "WSN": wsn,
      "WAN": wan,
      "CTM": ctm,
      "TCN": tcn,
      "CID": cid,
      "INV": inv,
      "AID": aid,
      "AMT": amt,
      "BAL": bal,
      "LNG": lng,
      "RES": res,
      "MSG": msg,
    };
  }
}

class CommitResponse {
  final String mid;
  final String prg;
  final String trx;
  final String wsn;
  final String wan;
  final String ctm;
  final String tcn;
  final String tcr;
  final String lng;
  final String res;
  final String msg;

  CommitResponse({
    required this.mid,
    required this.prg,
    required this.trx,
    required this.wsn,
    required this.wan,
    required this.ctm,
    required this.tcn,
    required this.tcr,
    required this.lng,
    required this.res,
    required this.msg,
  });

  factory CommitResponse.fromJson(Map<String, dynamic> json) {
    return CommitResponse(
      mid: json['MID'] ?? '',
      prg: json['PRG'] ?? '',
      trx: json['TRX'] ?? '',
      wsn: json['WSN'] ?? '',
      wan: json['WAN'] ?? '',
      ctm: json['CTM'] ?? '',
      tcn: json['TCN'] ?? '',
      tcr: json['TCR'] ?? '',
      lng: json['LNG'] ?? '',
      res: json['RES'] ?? '',
      msg: json['MSG'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "MID": mid,
      "PRG": prg,
      "TRX": trx,
      "WSN": wsn,
      "WAN": wan,
      "CTM": ctm,
      "TCN": tcn,
      "TCR": tcr,
      "LNG": lng,
      "RES": res,
      "MSG": msg,
    };
  }
}
