// class GiftCardModel {
//   final String id;
//   final String cid;
//   final int balance;
//   final String cardType;
//   final String? customerName;
//   final String? customerPhone;
//   final String createdAt;
//   final String lastTransactionDate;
//   final bool prepaid;
//   final String status;

//   GiftCardModel({
//     required this.id,
//     required this.cid,
//     required this.balance,
//     required this.cardType,
//     this.customerName,
//     this.customerPhone,
//     required this.createdAt,
//     required this.lastTransactionDate,
//     required this.prepaid,
//     required this.status,
//   });

//   factory GiftCardModel.fromJson(Map<String, dynamic> json) {
//     return GiftCardModel(
//       id: json["_id"],
//       cid: json["CID"],
//       balance: json["balance"],
//       cardType: json["cardType"],
//       customerName: json["customerName"] ?? "N/A",
//       customerPhone: json["customerPhone"] ?? "N/A",
//       createdAt: json["createdAt"],
//       lastTransactionDate: json["lastTransactionDate"],
//       prepaid: json["prepaid"],
//       status: json["status"],
//     );
//   }
// }


class GiftCardModel {
  final String id;
  final String cid;
  final num balance;
  final String cardType;
  final String? customerName;
  final String? customerPhone;
  final DateTime createdAt;
  final DateTime lastTransactionDate;
  final bool prepaid;
  final String status;


  GiftCardModel({
    required this.id,
    required this.cid,
    required this.balance,
    required this.cardType,
    this.customerName,
    this.customerPhone,
    required this.createdAt,
    required this.lastTransactionDate,
    required this.prepaid,
    required this.status,
  });

  factory GiftCardModel.fromJson(Map<String, dynamic> json) {
    return GiftCardModel(
      id: json["_id"],
      cid: json["CID"],
      balance: json["balance"],
      cardType: json["cardType"],
      customerName: json["customerName"] ?? "N/A",
      customerPhone: json["customerPhone"] ?? "N/A",
      createdAt: DateTime.parse(json["createdAt"]),            // ✅ String → DateTime
      lastTransactionDate: DateTime.parse(json["lastTransactionDate"]), // ✅ String → DateTime
      prepaid: json["prepaid"],
      status: json["status"],
    );
  }

  /// Optional: ekta formatted getter rakhte paren (MMM d, h:mm a)
  String get createdAtFormatted {
    return "${createdAt.month}/${createdAt.day}/${createdAt.year} "
        "${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}";
  }

  String get lastTransactionFormatted {
    return "${lastTransactionDate.month}/${lastTransactionDate.day}/${lastTransactionDate.year} "
        "${lastTransactionDate.hour}:${lastTransactionDate.minute.toString().padLeft(2, '0')}";
  }
}

