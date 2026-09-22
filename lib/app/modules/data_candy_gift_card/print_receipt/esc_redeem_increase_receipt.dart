import 'package:flutter/services.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/utils/receipt.dart';

import '../../../services/controller/base_controller.dart';
import '../../pos/dine-in/models/datacandy_payment_model.dart';

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

Uint8List escDataCandyRedeemIncreaseReceipt({
  required DataCandyPaymentModel data,
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

  // Server
  if (server != null) {
    r.text("Server: $server");
  }

  r.dotted();
  // DC Gift Card Redeem
  r.row(left: "DC Gift Card Redeem", right: "\$${data.amt.toStringAsFixed(2)}");

  // Gift Card No.
  r.row(left: "DC Gift Card No.", right: maskCardNumber(data.cid));

  // TCN No.
  r.row(left: "TCN No:", right: data.tcn);

  // Transaction Date
  r.row(
    left: "Tran_Date:",
    right: DateFormat(
      'MMM dd, yyyy, hh:mm a',
    ).format(data.createdAt.toTimeZone()),
  );
  // Available Balance
  r.row(
    left: "AVAILABLE BALANCE",
    right: "\$${data.balance.toStringAsFixed(2)}",
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
