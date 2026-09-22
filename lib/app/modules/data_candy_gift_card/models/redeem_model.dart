// class RedeemCommitResponse {
//   final int statusCode;
//   final bool success;
//   final String message;
//   final RedeemCommitData data;
//
//   RedeemCommitResponse({
//     required this.statusCode,
//     required this.success,
//     required this.message,
//     required this.data,
//   });
//
//   factory RedeemCommitResponse.fromJson(Map<String, dynamic> json) {
//     return RedeemCommitResponse(
//       statusCode: json['statusCode'],
//       success: json['success'],
//       message: json['message'],
//       data: RedeemCommitData.fromJson(json['data']),
//     );
//   }
// }
//
// class RedeemCommitData {
//   final Redeem redeem;
//   final Commit commit;
//
//   RedeemCommitData({
//     required this.redeem,
//     required this.commit,
//   });
//
//   factory RedeemCommitData.fromJson(Map<String, dynamic> json) {
//     return RedeemCommitData(
//       redeem: Redeem.fromJson(json['redeem']),
//       commit: Commit.fromJson(json['commit']),
//     );
//   }
// }
//
// class Redeem {
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
//   final String ati;
//   final String amt;
//   final String bal;
//   final String lng;
//   final String res;
//   final String msg;
//
//   Redeem({
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
//     required this.ati,
//     required this.amt,
//     required this.bal,
//     required this.lng,
//     required this.res,
//     required this.msg,
//   });
//
//   factory Redeem.fromJson(Map<String, dynamic> json) {
//     return Redeem(
//       mid: json['MID'],
//       prg: json['PRG'],
//       trx: json['TRX'],
//       wsn: json['WSN'],
//       wan: json['WAN'],
//       ctm: json['CTM'],
//       tcn: json['TCN'],
//       cid: json['CID'],
//       inv: json['INV'],
//       aid: json['AID'],
//       ati: json['ATI'],
//       amt: json['AMT'],
//       bal: json['BAL'],
//       lng: json['LNG'],
//       res: json['RES'],
//       msg: json['MSG'],
//     );
//   }
// }
//
// class Commit {
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
//   Commit({
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
//   factory Commit.fromJson(Map<String, dynamic> json) {
//     return Commit(
//       mid: json['MID'],
//       prg: json['PRG'],
//       trx: json['TRX'],
//       wsn: json['WSN'],
//       wan: json['WAN'],
//       ctm: json['CTM'],
//       tcn: json['TCN'],
//       tcr: json['TCR'],
//       lng: json['LNG'],
//       res: json['RES'],
//       msg: json['MSG'],
//     );
//   }
// }
//
//
//
//
//
