class CheckBalanceModelDataCandy {
  int? statusCode;
  bool? success;
  String? message;
  Data? data;

  CheckBalanceModelDataCandy({
    this.statusCode,
    this.success,
    this.message,
    this.data,
  });

  CheckBalanceModelDataCandy.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['statusCode'] = statusCode;
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class Data {
  String? cID;
  double? balance;
  String? currency;
  String? message;
  String? employeeFirstName;
  String? employeeLastName;
  RawResponse? rawResponse;

  Data({
    this.cID,
    this.balance,
    this.currency,
    this.message,
    this.employeeFirstName,
    this.employeeLastName,
    this.rawResponse,
  });

  Data.fromJson(Map<String, dynamic> json) {
    cID = json['CID'];
    // Parse balance safely (can be int, double, or string)
    if (json['balance'] != null) {
      balance = json['balance'] is String
          ? double.tryParse(json['balance'])
          : (json['balance'] as num).toDouble();
    }
    currency = json['currency'];
    message = json['message'];
    employeeFirstName = json["employeeFirstName"];
    employeeLastName = json["employeeLastName"];
    rawResponse =
    json['rawResponse'] != null ? RawResponse.fromJson(json['rawResponse']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['CID'] = cID;
    map['balance'] = balance;
    map['currency'] = currency;
    map['message'] = message;
    if (rawResponse != null) {
      map['rawResponse'] = rawResponse!.toJson();
    }
    return map;
  }
}

class RawResponse {
  String? mID;
  String? pRG;
  String? tRX;
  String? wSN;
  String? wAN;
  String? cTM;
  String? tCN;
  String? cID;
  String? aID;
  String? bAL; // BAL is string in JSON
  double? bLT; // BLT should be numeric
  String? lNG;
  String? rES;
  String? mSG;

  RawResponse({
    this.mID,
    this.pRG,
    this.tRX,
    this.wSN,
    this.wAN,
    this.cTM,
    this.tCN,
    this.cID,
    this.aID,
    this.bAL,
    this.bLT,
    this.lNG,
    this.rES,
    this.mSG,
  });

  RawResponse.fromJson(Map<String, dynamic> json) {
    mID = json['MID'];
    pRG = json['PRG'];
    tRX = json['TRX'];
    wSN = json['WSN'];
    wAN = json['WAN'];
    cTM = json['CTM'];
    tCN = json['TCN'];
    cID = json['CID'];
    aID = json['AID'];
    bAL = json['BAL']; // stays string
    if (json['BLT'] != null) {
      bLT = json['BLT'] is String
          ? double.tryParse(json['BLT'])
          : (json['BLT'] as num).toDouble();
    }
    lNG = json['LNG'];
    rES = json['RES'];
    mSG = json['MSG'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['MID'] = mID;
    map['PRG'] = pRG;
    map['TRX'] = tRX;
    map['WSN'] = wSN;
    map['WAN'] = wAN;
    map['CTM'] = cTM;
    map['TCN'] = tCN;
    map['CID'] = cID;
    map['AID'] = aID;
    map['BAL'] = bAL;
    map['BLT'] = bLT;
    map['LNG'] = lNG;
    map['RES'] = rES;
    map['MSG'] = mSG;
    return map;
  }
}
