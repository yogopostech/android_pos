import 'package:yogo_pos/app/modules/pos/tableReservations/models/table_reservations_model.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<pw.Widget> tableReservationPrintReceipt(
    {required Reservations data,
    bool isCheckCanceled = false,
    bool isShowItems = true,
    String? title,
    bool isItemsCanceled = false}) async {
  var bold = await MyFunc.loadCustomFont("assets/fonts/RobotoMono-Bold.ttf");
  bool is80mm = Preferences.paperWidth == "80mm";
 
  var bodyStyle = pw.TextStyle(
    fontSize: is80mm ? 10 : 8,
    height: 3,
    font: bold,
  );
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    mainAxisSize: pw.MainAxisSize.max,
    children: [
      pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text(
          '** Reservation **'.toUpperCase(),
          style: bodyStyle.copyWith(fontSize: 16),
        ),
      ),
      pw.Divider(color: PdfColor.fromHex('#303030'), height: 2),
      pw.SizedBox(height: 10),
      pw.Align(
        alignment: pw.Alignment.topLeft,
        child: pw.Text(
          'Check# ${data.tableBookId}',
          style: bodyStyle,
        ),
      ),
      pw.Align(
        alignment: pw.Alignment.topLeft,
        child: pw.Text(
          DateFormat('MMM dd,hh:mm a').format(data.createdAt.toTimeZone()),
          style: bodyStyle,
          textAlign: pw.TextAlign.left,
        ),
      ),
      pw.Align(
        alignment: pw.Alignment.bottomLeft,
        child: pw.Text('Guest:${MyFunc.capitalize(data.fullName)}',
            style: bodyStyle.copyWith(fontSize: 14),
            maxLines: 1,
            textAlign: pw.TextAlign.left),
      ),
      pw.Row(children: [
        pw.Text('No. Guest:${data.numberOfGuests}',
            style: bodyStyle, maxLines: 2, textAlign: pw.TextAlign.start),
      ]),
      pw.Row(children: [
        pw.Text('Number:${data.phoneNumber}',
            style: bodyStyle, maxLines: 2, textAlign: pw.TextAlign.start),
      ]),
      //est time
      pw.Text(
          'Booking Time:${data.bookingDate.toFormattedDate()},${data.bookingTime}',
          style: bodyStyle.copyWith(fontSize: 12),
          maxLines: 2,
          textAlign: pw.TextAlign.start),

      if (data.notes.isNotEmpty)
        pw.Text('Notes:${data.notes}',
            style: bodyStyle, textAlign: pw.TextAlign.start),
    ],
  );
}
