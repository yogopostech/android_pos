import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/gift_card_controller.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/utils/receipt.dart';

String maskCardNumber(String cardNo) {
  if (cardNo.length < 8) return cardNo;
  String first4 = cardNo.substring(0, 4);
  String last4 = cardNo.substring(cardNo.length - 4);
  String masked = List.filled(cardNo.length - 8, "X").join();
  return "$first4$masked$last4";
}

Uint8List escDataCandyCancelTransactionReceipt({
  bool is80mm = true,
}) {
  final controller = Get.put(GiftCardController());
  final cancelData = controller.cancelTransactionModel.value?.data;
  final initial = cancelData?.initialResponse;
  final commit = cancelData?.commitResponse;

  final r = Receipt(
    width: is80mm ? 48 : 32,
    printerType: PrinterType.escpos,
  );

  final restaurantName =
      (BaseController.to.restaurantDetails?.restaurant.name ?? "")
          .toUpperCase();

  // --- HEADER ---
  r.header(restaurantName, fontSize: is80mm ? 2 : 1);
  r.space();
  r.center("DataCandy");
  r.space();
  r.separator();

  // Date
  r.center(
    DateFormat('MMM dd, yyyy, hh:mm a').format(
      cancelData?.createdAt?.toTimeZone() ?? DateTime.now(),
    ),
  );

  // Server
  r.text("Server: ${cancelData?.employeeFirstName}");

  r.dotted();

  // Gift Card No.
  r.row(
    left: "DC Gift Card No.",
    right: maskCardNumber(initial?.cID ?? ""),
  );

  // Cancel Transaction
  r.row(
    left: "DC Gift Card Cancel Trans.",
    right: "\$${initial?.aMT}",
  );

  // Invoice No.
  r.row(
    left: "Invoice No.",
    right: initial?.iNV ?? "",
  );

  // TCN No.
  r.row(
    left: "TCN No.",
    right: commit?.tCN ?? "",
  );
  // Available Balance
  r.row(
    left: "AVAILABLE BALANCE",
    right: "\$${initial?.bAL}",
    fontWeight: FontWeight.bold,
  );

  r.separator();

  // Footer
  r.center("Thank you for visiting $restaurantName");
  r.separator();
  r.center("Please review us on Google");
  r.space();
  r.center("Powered by YOGO POS");
  r.space(2);
  r.cut();
  return r.bytes;
}
