class CancelTransactionModelDataCandy {
  int? statusCode;
  bool? success;
  String? message;
  Data? data;

  CancelTransactionModelDataCandy(
      {this.statusCode, this.success, this.message, this.data});

  CancelTransactionModelDataCandy.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? cID;
  String? tCN;
  String? transactionType;
  double? aMT;
  String? iNV;
  String? wSN;
  String? user;
  String? employee;
  String? wAN;
  InitialResponse? initialResponse;
  CommitResponse? commitResponse;
  String? sId;
  DateTime? createdAt;
  int? iV;
  String? id;
  String? employeeFirstName;
  String? employeeLastName;

  Data(
      {this.cID,
      this.tCN,
      this.transactionType,
      this.aMT,
      this.iNV,
      this.wSN,
      this.user,
      this.employee,
      this.wAN,
      this.initialResponse,
      this.commitResponse,
      this.sId,
      this.createdAt,
      this.iV,
      this.id,
      this.employeeFirstName,
      this.employeeLastName});

  Data.fromJson(Map<String, dynamic> json) {
    cID = json['CID'];
    tCN = json['TCN'];
    transactionType = json['transactionType'];
    aMT = (json['AMT'] as num?)?.toDouble();
    iNV = json['INV'];
    wSN = json['WSN'];
    user = json['user'];
    employee = json['employee'];
    wAN = json['WAN'];
    initialResponse = json['initialResponse'] != null
        ? InitialResponse.fromJson(json['initialResponse'])
        : null;
    commitResponse = json['commitResponse'] != null
        ? CommitResponse.fromJson(json['commitResponse'])
        : null;
    sId = json['_id'];
    createdAt =
        json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
    iV = json['__v'];
    id = json['id'];
    employeeFirstName = json['employeeFirstName'];
    employeeLastName = json['employeeLastName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CID'] = cID;
    data['TCN'] = tCN;
    data['transactionType'] = transactionType;
    data['AMT'] = aMT;
    data['INV'] = iNV;
    data['WSN'] = wSN;
    data['user'] = user;
    data['employee'] = employee;
    data['WAN'] = wAN;
    if (initialResponse != null) {
      data['initialResponse'] = initialResponse!.toJson();
    }
    if (commitResponse != null) {
      data['commitResponse'] = commitResponse!.toJson();
    }
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    data['id'] = id;
    data['employeeFirstName'] = employeeFirstName;
    data['employeeLastName'] = employeeLastName;
    return data;
  }
}

class InitialResponse {
  String? mID;
  String? pRG;
  String? tRX;
  String? wSN;
  String? wAN;
  String? cTM;
  String? tCN;
  String? cID;
  String? iNV;
  String? aMT;
  String? bAL;
  String? tCR;
  String? lNG;
  String? rES;
  String? mSG;

  InitialResponse(
      {this.mID,
      this.pRG,
      this.tRX,
      this.wSN,
      this.wAN,
      this.cTM,
      this.tCN,
      this.cID,
      this.iNV,
      this.aMT,
      this.bAL,
      this.tCR,
      this.lNG,
      this.rES,
      this.mSG});

  InitialResponse.fromJson(Map<String, dynamic> json) {
    mID = json['MID'];
    pRG = json['PRG'];
    tRX = json['TRX'];
    wSN = json['WSN'];
    wAN = json['WAN'];
    cTM = json['CTM'];
    tCN = json['TCN'];
    cID = json['CID'];
    iNV = json['INV'];
    aMT = json['AMT'];
    bAL = json['BAL'];
    tCR = json['TCR'];
    lNG = json['LNG'];
    rES = json['RES'];
    mSG = json['MSG'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['MID'] = mID;
    data['PRG'] = pRG;
    data['TRX'] = tRX;
    data['WSN'] = wSN;
    data['WAN'] = wAN;
    data['CTM'] = cTM;
    data['TCN'] = tCN;
    data['CID'] = cID;
    data['INV'] = iNV;
    data['AMT'] = aMT;
    data['BAL'] = bAL;
    data['TCR'] = tCR;
    data['LNG'] = lNG;
    data['RES'] = rES;
    data['MSG'] = mSG;
    return data;
  }
}

class CommitResponse {
  String? mID;
  String? pRG;
  String? tRX;
  String? wSN;
  String? wAN;
  String? cTM;
  String? tCN;
  String? tCR;
  String? lNG;
  String? rES;
  String? mSG;

  CommitResponse(
      {this.mID,
      this.pRG,
      this.tRX,
      this.wSN,
      this.wAN,
      this.cTM,
      this.tCN,
      this.tCR,
      this.lNG,
      this.rES,
      this.mSG});

  CommitResponse.fromJson(Map<String, dynamic> json) {
    mID = json['MID'];
    pRG = json['PRG'];
    tRX = json['TRX'];
    wSN = json['WSN'];
    wAN = json['WAN'];
    cTM = json['CTM'];
    tCN = json['TCN'];
    tCR = json['TCR'];
    lNG = json['LNG'];
    rES = json['RES'];
    mSG = json['MSG'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['MID'] = mID;
    data['PRG'] = pRG;
    data['TRX'] = tRX;
    data['WSN'] = wSN;
    data['WAN'] = wAN;
    data['CTM'] = cTM;
    data['TCN'] = tCN;
    data['TCR'] = tCR;
    data['LNG'] = lNG;
    data['RES'] = rES;
    data['MSG'] = mSG;
    return data;
  }
}
