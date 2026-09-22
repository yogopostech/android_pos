//
// import 'package:yogo_pos/app/modules/pos/dine-in-orders/models/meta_model.dart';
//
// class TransactionResponse {
//   final int statusCode;
//   final bool success;
//   final String message;
//   final List<Transaction> data;
//   final MetaModel meta;
//
//   TransactionResponse({
//     required this.statusCode,
//     required this.success,
//     required this.message,
//     required this.data,
//     required this.meta,
//   });
//
//   factory TransactionResponse.fromJson(Map<String, dynamic> json) {
//     return TransactionResponse(
//       statusCode: json['statusCode'] ?? 0,
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       data: (json['data'] as List<dynamic>?)
//           ?.map((e) => Transaction.fromJson(e))
//           .toList() ??
//           [],
//       meta: MetaModel.fromJson(json['meta'] ?? {}),
//     );
//   }
// }
//
// class Transaction {
//   final String id;
//   final String cid;
//   final String tcn;
//   final String operation;
//   final num amount;
//   final String inv;
//   final String status;
//   final String user;
//   final InitialResponse initialResponse;
//   final CommitResponse commitResponse;
//   final String createdAt;
//   final bool isCancelable;
//
//   Transaction({
//     required this.id,
//     required this.cid,
//     required this.tcn,
//     required this.operation,
//     required this.amount,
//     required this.inv,
//     required this.status,
//     required this.user,
//     required this.initialResponse,
//     required this.commitResponse,
//     required this.createdAt,
//     required this.isCancelable
//   });
//
//   factory Transaction.fromJson(Map<String, dynamic> json) {
//     return Transaction(
//       id: json['_id'] ?? '',
//       cid: json['CID'] ?? '',
//       tcn: json['TCN'] ?? '',
//       operation: json['operation'] ?? '',
//       amount: json['amount'] ?? 0,
//       inv: json['INV'] ?? '',
//       status: json['status'] ?? '',
//       user: json['user'] ?? '',
//       initialResponse: InitialResponse.fromJson(json['initialResponse'] ?? {}),
//       commitResponse: CommitResponse.fromJson(json['commitResponse'] ?? {}),
//       createdAt: json['createdAt'] ?? '',
//         isCancelable: json['isCancelable'] ?? false
//     );
//   }
// }
//
// class InitialResponse {
//   final String mid;
//   final String prg;
//   final String trx;
//   final String wsn;
//   final String wan;
//   final String ctm;
//   final String tcn;
//   final String cid;
//   final String inv;
//   final String aid;
//   final String amt;
//   final String bal;
//   final String lng;
//   final String res;
//   final String msg;
//
//   InitialResponse({
//     required this.mid,
//     required this.prg,
//     required this.trx,
//     required this.wsn,
//     required this.wan,
//     required this.ctm,
//     required this.tcn,
//     required this.cid,
//     required this.inv,
//     required this.aid,
//     required this.amt,
//     required this.bal,
//     required this.lng,
//     required this.res,
//     required this.msg,
//   });
//
//   factory InitialResponse.fromJson(Map<String, dynamic> json) {
//     return InitialResponse(
//       mid: json['MID'] ?? '',
//       prg: json['PRG'] ?? '',
//       trx: json['TRX'] ?? '',
//       wsn: json['WSN'] ?? '',
//       wan: json['WAN'] ?? '',
//       ctm: json['CTM'] ?? '',
//       tcn: json['TCN'] ?? '',
//       cid: json['CID'] ?? '',
//       inv: json['INV'] ?? '',
//       aid: json['AID'] ?? '',
//       amt: json['AMT'] ?? '',
//       bal: json['BAL'] ?? '',
//       lng: json['LNG'] ?? '',
//       res: json['RES'] ?? '',
//       msg: json['MSG'] ?? '',
//     );
//   }
// }
//
// class CommitResponse {
//   final String mid;
//   final String prg;
//   final String trx;
//   final String wsn;
//   final String wan;
//   final String ctm;
//   final String tcn;
//   final String tcr;
//   final String lng;
//   final String res;
//   final String msg;
//
//   CommitResponse({
//     required this.mid,
//     required this.prg,
//     required this.trx,
//     required this.wsn,
//     required this.wan,
//     required this.ctm,
//     required this.tcn,
//     required this.tcr,
//     required this.lng,
//     required this.res,
//     required this.msg,
//   });
//
//   factory CommitResponse.fromJson(Map<String, dynamic> json) {
//     return CommitResponse(
//       mid: json['MID'] ?? '',
//       prg: json['PRG'] ?? '',
//       trx: json['TRX'] ?? '',
//       wsn: json['WSN'] ?? '',
//       wan: json['WAN'] ?? '',
//       ctm: json['CTM'] ?? '',
//       tcn: json['TCN'] ?? '',
//       tcr: json['TCR'] ?? '',
//       lng: json['LNG'] ?? '',
//       res: json['RES'] ?? '',
//       msg: json['MSG'] ?? '',
//     );
//   }
// }



class TransactionResponse {
  final int statusCode;
  final bool success;
  final String message;
  final List<Transaction> data;
  final Meta meta;

  TransactionResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      statusCode: json['statusCode'],
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List<dynamic>)
          .map((e) => Transaction.fromJson(e))
          .toList(),
      meta: Meta.fromJson(json['meta']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "statusCode": statusCode,
      "success": success,
      "message": message,
      "data": data.map((e) => e.toJson()).toList(),
      "meta": meta.toJson(),
    };
  }
}

class Transaction {
  final String id;
  final String cid;
  final String tcn;
  final String transactionType;
  final num amt;
  final String inv;
  final String wsn;
  final String employee;
  final String wan;
  final String user;
  final DateTime createdAt;
  final String employeeFirstName;
  final String employeeLastName;

  Transaction({
    required this.id,
    required this.cid,
    required this.tcn,
    required this.transactionType,
    required this.amt,
    required this.inv,
    required this.wsn,
    required this.employee,
    required this.wan,
    required this.user,
    required this.createdAt,
    required this.employeeFirstName,
    required this.employeeLastName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'],
      cid: json['CID'],
      tcn: json['TCN'],
      transactionType: json['transactionType'],
      amt: json['AMT'],
      inv: json['INV'],
      wsn: json['WSN'],
      employee: json['employee'],
      wan: json['WAN'],
      user: json['user'],
      createdAt: DateTime.parse(json['createdAt']),
      employeeFirstName: json['employeeFirstName'],
      employeeLastName: json['employeeLastName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "CID": cid,
      "TCN": tcn,
      "transactionType": transactionType,
      "AMT": amt,
      "INV": inv,
      "WSN": wsn,
      "employee": employee,
      "WAN": wan,
      "user": user,
      "createdAt": createdAt.toIso8601String(),
      "employeeFirstName": employeeFirstName,
      "employeeLastName": employeeLastName,
    };
  }
}

class Meta {
  final int total;
  final int limit;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  Meta({
    required this.total,
    required this.limit,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'],
      limit: json['limit'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      hasNextPage: json['hasNextPage'],
      hasPreviousPage: json['hasPreviousPage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "total": total,
      "limit": limit,
      "currentPage": currentPage,
      "totalPages": totalPages,
      "hasNextPage": hasNextPage,
      "hasPreviousPage": hasPreviousPage,
    };
  }
}
