import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/gift_card_controller.dart';
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

Uint8List escDataCandyCheckBalanceReceipt({
  bool is80mm = true,
}) {
  final controller = Get.put(GiftCardController());
  final balanceData = controller.checkBalanceModel.value?.data;

  final r = Receipt(
    width: is80mm ? 48 : 32,
    printerType: PrinterType.escpos,
  );

  final restaurantName =
      (BaseController.to.restaurantDetails?.restaurant.name ?? "")
          .toUpperCase();

  final balance = balanceData?.balance?.toStringAsFixed(2) ?? "0.00";

  // --- HEADER ---
  r.header(restaurantName, fontSize: is80mm ? 2 : 1);
  r.space();
  r.center("DataCandy");
  r.separator();

  // Date
  r.text(
    DateFormat('MMM dd, yyyy, hh:mm a').format(DateTime.now()),
  );

  // Server
  r.text("Server: ${balanceData?.employeeFirstName}");
  r.dotted();
  // Gift Card No.
  r.row(
    left: "DC Gift Card No.",
    right: maskCardNumber(balanceData?.cID ?? ""),
  );

  // Balance Check
  r.row(
    left: "DC Gift Card Balance Check",
    right: "\$$balance",
  );

  // TCN No.
  r.row(
    left: "TCN No.",
    right: balanceData?.rawResponse?.tCN ?? "",
  );
  // Balance
  r.row(
    left: "Balance",
    right: "\$$balance",
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
