// // To parse this JSON data, do
// //
// //     final splitOrderModel = splitOrderModelFromJson(jsonString);

// import 'dart:convert';

// import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';

// SplitOrderModel splitOrderModelFromJson(String str) =>
//     SplitOrderModel.fromJson(json.decode(str));

// String splitOrderModelToJson(SplitOrderModel data) =>
//     json.encode(data.toJson());

// class SplitOrderModel {
//   String orderId;
//   num addOn;
//   num totalGst;
//   num totalPst;
//   int numberOfPeople;
//   String orderNote;
//   num totalOrderAmount;
//   String guestName;
//   String guestPhoneNumber;
//   String orderType;
//   num totalGratuity;
//   num totalDiscount;
//   String orderStatus;
//   String table;
//   String tableName;
//   List<CartModel> carts;
//   num tip;
//   bool recall;
//   bool refund;
//   num subTotal;
//   Payment? payment;

//   SplitOrderModel({
//     this.orderId = '',
//     this.addOn = 0,
//     this.totalGst = 0,
//     this.totalPst = 0,
//     this.numberOfPeople = 0,
//     this.orderNote = '',
//     this.totalOrderAmount = 0,
//     this.guestName = '',
//     this.guestPhoneNumber = '',
//     this.orderType = '',
//     this.totalGratuity = 0,
//     this.totalDiscount = 0,
//     this.orderStatus = '',
//     this.table = '',
//     this.tableName = '',
//     List<CartModel>? carts,
//     this.tip = 0,
//     this.recall = false,
//     this.refund = false,
//     this.subTotal = 0,
//     this.payment,
//   }) : carts = carts ?? [];

//   factory SplitOrderModel.fromJson(Map<String, dynamic> json) =>
//       SplitOrderModel(
//         orderId: json["orderId"],
//         addOn: json["addOn"],
//         totalGst: json["totalGst"].toDouble(),
//         totalPst: json["totalPst"],
//         numberOfPeople: json["numberOfPeople"],
//         orderNote: json["orderNote"],
//         totalOrderAmount: json["totalOrderAmount"].toDouble(),
//         guestName: json["guestName"],
//         guestPhoneNumber: json["guestPhoneNumber"],
//         orderType: json["orderType"],
//         totalGratuity: json["totalGratuity"],
//         totalDiscount: json["totalDiscount"],
//         orderStatus: json["orderStatus"],
//         table: json["table"],
//         tableName: json["tableName"],
//         carts: List<CartModel>.from(
//             json["carts"].map((x) => CartModel.fromJson(x))),
//         tip: json["tip"],
//         recall: json["recall"],
//         refund: json["refund"],
//         subTotal: json["subTotal"],
//         payment:
//             json["payment"] == null ? null : Payment.fromJson(json["payment"]),
//       );

//   Map<String, dynamic> toJson() {
//     final data = {
//       "orderId": orderId,
//       "addOn": addOn,
//       "totalGst": totalGst,
//       "totalPst": totalPst,
//       "numberOfPeople": numberOfPeople,
//       "orderNote": orderNote,
//       "totalOrderAmount": totalOrderAmount,
//       "guestName": guestName,
//       "guestPhoneNumber": guestPhoneNumber,
//       "orderType": orderType,
//       "totalGratuity": totalGratuity,
//       "totalDiscount": totalDiscount,
//       "table": table,
//       "tableName": tableName,
//       "carts": List<dynamic>.from(carts.map((x) => x.toJson())),
//       "tip": tip,
//       "recall": recall,
//       "refund": refund,
//       "subTotal": subTotal,
//       "payment": payment?.toJson(),
//     };

//     if (orderStatus != '') {
//       data["orderStatus"] = orderStatus;
//     }

//     return data;
//   }
// }

// class Payment {
//   final String method;
//   final num tipAmount;
//   final num paidAmount;

//   Payment({
//     this.method = '',
//     this.tipAmount = 0,
//     this.paidAmount = 0,
//   });

//   factory Payment.fromJson(Map<String, dynamic> json) => Payment(
//         method: json["method"],
//         tipAmount: json["tipAmount"],
//         paidAmount: json["paidAmount"],
//       );

//   Map<String, dynamic> toJson() => {
//         "method": method,
//         "tipAmount": tipAmount,
//         "paidAmount": paidAmount,
//       };
// }
