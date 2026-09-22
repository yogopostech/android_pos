import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/modules/pos/tableReservations/models/table_reservations_model.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/receipt.dart';

Uint8List escTableReservationReceipt({
  required Reservations data,
  bool is80mm = true,
}) {
  final r = Receipt(width: is80mm ? 48 : 32, printerType: PrinterType.escpos);

  // Header
  r.header("** RESERVATION **", fontSize: 2);
  r.separator();
  // Check # & Date
  r.text("Check# ${data.tableBookId}");
  r.text(DateFormat('MMM dd, hh:mm a').format(data.createdAt.toTimeZone()));

  // Guest Info
  r.text(
    "Guest: ${MyFunc.capitalize(data.fullName)}",
    fontSize: is80mm ? 2 : 1,
    fontWeight: FontWeight.bold,
  );
  r.text("No. Guest: ${data.numberOfGuests}");
  r.text("Number: ${data.phoneNumber}");

  // Booking Time
  r.text(
    "Booking Time: ${data.bookingDate.toFormattedDate()}, ${data.bookingTime}",
    fontWeight: FontWeight.bold,
  );

  // Notes
  if (data.notes.isNotEmpty) {
    r.text("Notes: ${data.notes}");
  }
  r.space(2);
  r.cut();

  return r.bytes;
}
