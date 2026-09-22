class ReloadModelDataCandy {
  DataCandyCardReloadModel? data;

  ReloadModelDataCandy({this.data});

  ReloadModelDataCandy.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? DataCandyCardReloadModel.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class DataCandyCardReloadModel {
  String? cID;
  String? tCN;
  String? transactionType;
  double? aMT;          // ✅ double
  String? iNV;
  String? wSN;
  String? user;
  num? balance;
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

  DataCandyCardReloadModel(
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
        this.employeeLastName,this.balance});

  DataCandyCardReloadModel.fromJson(Map<String, dynamic> json) {
    cID = json['CID'];
    tCN = json['TCN'];
    transactionType = json['transactionType'];
    aMT = (json['AMT'] as num?)?.toDouble(); // ✅ parse double
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
    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null;
    iV = json['__v'];
    id = json['id'];
    employeeFirstName = json['employeeFirstName'];
    employeeLastName = json['employeeLastName'];
    balance = json["balance"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
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
    data['createdAt'] = createdAt?.toIso8601String();
    data['__v'] = iV;
    data['id'] = id;
    data['employeeFirstName'] = employeeFirstName;
    data['employeeLastName'] = employeeLastName;
    data['balance'] = balance;
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
  String? aID;
  String? aMT;          // ✅ double
  String? bAL;          // ✅ double
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
        this.aID,
        this.aMT,
        this.bAL,
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
    aID = json['AID'];
    aMT = json['AMT'];
    bAL = json['BAL'];
    lNG = json['LNG'];
    rES = json['RES'];
    mSG = json['MSG'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['MID'] = mID;
    data['PRG'] = pRG;
    data['TRX'] = tRX;
    data['WSN'] = wSN;
    data['WAN'] = wAN;
    data['CTM'] = cTM;
    data['TCN'] = tCN;
    data['CID'] = cID;
    data['INV'] = iNV;
    data['AID'] = aID;
    data['AMT'] = aMT;
    data['BAL'] = bAL;
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
    final Map<String, dynamic> data = {};
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
