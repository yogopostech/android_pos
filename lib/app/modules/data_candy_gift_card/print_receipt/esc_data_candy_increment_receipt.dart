import 'package:flutter/services.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/utils/receipt.dart';

import '../../../services/controller/base_controller.dart';
import '../models/increment_balance_model.dart';

String maskCardNumber(String cardNo) {
  if (cardNo.length < 8) return cardNo;
  String first4 = cardNo.substring(0, 4);
  String last4 = cardNo.substring(cardNo.length - 4);
  String masked = List.filled(cardNo.length - 8, "X").join();
  return "$first4$masked$last4";
}

Uint8List escDataCandyIncrementReceipt({
  required DataCandyCardReloadModel data,
  String? server,
  bool is80mm = true,
}) {
  final r = Receipt(printerType: PrinterType.escpos);

  final restaurantName =
      (BaseController.to.restaurantDetails?.restaurant.name ?? "")
          .toUpperCase();

  // --- HEADER ---
  r.header(restaurantName, fontSize: is80mm ? 2 : 1);
  r.space();
  r.center("DataCandy");
  r.separator();

  // Date
  r.center(
    DateFormat(
      'MMM dd, yyyy, hh:mm a',
    ).format(data.createdAt?.toTimeZone() ?? DateTime.now()),
  );

  // Server
  if (server != null) {
    r.text("Server: $server");
  }
  r.dotted();
  // Gift Card No.
  r.row(left: "DC Gift Card No.", right: maskCardNumber(data.cID ?? ""));

  // Gift Card Recharge
  r.row(
    left: "DC Gift Card Recharge",
    right: "\$${data.aMT?.toStringAsFixed(2)}",
  );

  // Invoice No.
  r.row(left: "Invoice No.", right: data.iNV ?? "");

  // TCN No.
  r.row(left: "TCN No.", right: data.tCN ?? "");
  // Available Balance
  r.row(
    left: "AVAILABLE BALANCE",
    right: "\$${data.balance?.toStringAsFixed(2)}",
    fontWeight: FontWeight.bold,
  );

  r.separator();

  // Footer
  r.center("Thank you for visiting $restaurantName");
  r.separator();
  r.center("Please review us on Google");
  r.center("Powered by YOGO POS");
  r.space(2);
  r.cut();
  return r.bytes;
}
