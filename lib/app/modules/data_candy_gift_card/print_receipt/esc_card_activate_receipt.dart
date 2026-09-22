import 'package:flutter/services.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/models/card_activate_model.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/utils/receipt.dart';

import '../../../services/controller/base_controller.dart';

String maskCardNumber(String cardNo) {
  if (cardNo.length < 8) return cardNo;
  String first4 = cardNo.substring(0, 4);
  String last4 = cardNo.substring(cardNo.length - 4);
  String masked = List.filled(cardNo.length - 8, "X").join();
  return "$first4$masked$last4";
}

String formatPhoneNumber(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');

  if (digits.length < 10) {
    return phone.trim();
  }

  final last10 = digits.substring(digits.length - 10);

  return '${last10.substring(0, 3)}-${last10.substring(3, 6)}-${last10.substring(6, 10)}';
}


Uint8List escDataCandyCardActivateReceipt({
  required DataCandyActiveCardModel cardActivate,
  String? server,
  bool is80mm = true,
}) {
  final r = Receipt(
    printerType: PrinterType.escpos,
  );

  final restaurantName =
      (BaseController.to.restaurantDetails?.restaurant.name ?? "").toUpperCase();

  // --- HEADER ---
  r.header(restaurantName, fontSize: is80mm ? 2 : 1);
  r.space();
  r.center("DataCandy");
  r.separator();

  // Date
  r.text(
    DateFormat('MMM dd, yyyy, hh:mm a').format(
      cardActivate.createdAt.toTimeZone(),
    ),
  );

  // Server
  if (server != null) {
    r.text("Server: $server");
  }
  r.dotted();
  // Gift Card No.
  r.row(
    left: "DC Gift Card No.",
    right: maskCardNumber(cardActivate.cid),
  );

  // Gift Card Activate
  r.row(
    left: "DC Gift Card Activate",
    right: "\$${cardActivate.amt.toStringAsFixed(2)}",
  );

  // Invoice No.
  r.row(
    left: "Invoice No.",
    right: cardActivate.inv,
  );

  // TCN No.
  r.row(
    left: "TCN No.",
    right: cardActivate.tcn,
  );
  // Available Balance
  r.row(
    left: "AVAILABLE BALANCE",
    right: "\$${cardActivate.amt.toStringAsFixed(2)}",
    fontWeight: FontWeight.bold,
  );

  r.separator();

  // Footer
  r.center("Thank you for visiting $restaurantName");
  r.separator();
  r.center("Please review us on Google");
  r.center("Powered by YOGO POS");

  // Cut
  r.space(2);
  r.cut();

  return r.bytes;
}
