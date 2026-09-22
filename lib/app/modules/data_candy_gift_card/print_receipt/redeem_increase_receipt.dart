import 'package:flutter/services.dart';
import 'package:yogo_pos/app/modules/setting/controllers/printers_controller.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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

Future<pw.Widget> dataCandyRedeemIncreasePrintReceipt(
    {required  DataCandyPaymentModel data,String? server
    }) async {
  var bold = await MyFunc.loadCustomFont("assets/fonts/RobotoMono-Bold.ttf");
  bool is80mm = PrintersController.to.selectedPaperWidth.value == "80mm";
  // style

  var bodyStyle = pw.TextStyle(
    fontSize: is80mm ? 10 : 8,
    height: 3,
    // font: bold,
  );

  var smallStyle = pw.TextStyle(
    fontSize: 7,
    height: 3,
    font: bold,
  );
  var lavelStyle = pw.TextStyle(
    fontSize: is80mm ? 9 : 7,
    height: 3,
    font: bold,
  );
  return pw.Column(
    mainAxisSize: pw.MainAxisSize.max,
    children: [
      // --- HEADER ---
      pw.Text( (BaseController.to.restaurantDetails?.restaurant.name ?? "").toUpperCase(),
          style: pw.TextStyle(font: bold, fontSize: is80mm ? 18 : 12)),

      pw.SizedBox(height: 3),
      // pw.Center(
      //   child: pw.Text("DataCandy Gift Card",
      //       style: pw.TextStyle(fontSize: is80mm ? 9 : 7)),
      // ),


// Inside your PDF build:
      pw.Center(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // ✅ Image
                pw.Image(
                  pw.MemoryImage(
                    (await rootBundle.load("assets/images/datacandy.png"))
                        .buffer
                        .asUint8List(),
                  ),
                  height: 15,
                  width: 15,
                ),
                pw.SizedBox(width: 3), // spacing between image & text
                // ✅ Custom Text equivalent
                pw.Text(
                    "DataCandy",
                    style: bodyStyle
                ),
              ],
            ),
          ],
        ),
      ),

      pw.Divider(),
      // pw.SizedBox(height: 5),
      // pw.Text(
      //   DateFormat('MMM dd, yyyy, hh:mm a').format(
      //     data.createdAt.toTimeZone() ?? DateTime.now(),
      //   ),
      //   style: bodyStyle,
      // ),
      if(server != null)...[
        pw.SizedBox(height: 5),
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Server: $server ", style: bodyStyle),
              pw.Text("", style: bodyStyle),
            ]
        ),
      ],


      pw.SizedBox(height: 5),
      _dotDivider(),
      pw.SizedBox(height: 5),
      pw.Row(
        children: [
          pw.Text(
            "DC Gift Card Redeem",
            style: bodyStyle,
            textAlign: pw.TextAlign.left,
          ),
          pw.SizedBox(width: 2),
          pw.Expanded(
              child: pw.Text(
                "\$${data.amt.toStringAsFixed(2)}",
                style: bodyStyle,
                textAlign: pw.TextAlign.right,
              )),
        ],
      ),
      pw.SizedBox(height: 5),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            "DC Gift Card No.",
            style: bodyStyle,
            textAlign: pw.TextAlign.left,
          ),

           pw.Text(
                maskCardNumber(data.cid ),
                style: bodyStyle,
                textAlign: pw.TextAlign.right,
              ),
        ],
      ),
      pw.SizedBox(height: 5),
      pw.Row(
        children: [
          pw.Text(
            "TCN No:",
            style: bodyStyle,
            textAlign: pw.TextAlign.left,
          ),
          pw.SizedBox(width: 2),
          pw.Expanded(
              child: pw.Text(
                data.tcn,
                style: bodyStyle,
                textAlign: pw.TextAlign.right,
              ),),
        ],
      ),
      // pw.SizedBox(height: 5),
      // pw.Row(
      //   children: [
      //     pw.Text(
      //       "Balance:",
      //       style: bodyStyle,
      //       textAlign: pw.TextAlign.left,
      //     ),
      //     pw.SizedBox(width: 2),
      //     pw.Expanded(
      //         child: pw.Text(
      //           data.inv ?? "",
      //           style: bodyStyle,
      //           textAlign: pw.TextAlign.right,
      //         )),
      //   ],
      // ),
      pw.SizedBox(height: 5),
      pw.Row(
        children: [
          pw.Text(
            "Tran_Date:",
            style: bodyStyle,
            textAlign: pw.TextAlign.left,
          ),
          pw.SizedBox(width: 2),
          pw.Expanded(
              child: pw.Text(
                DateFormat('MMM dd, yyyy, hh:mm a').format(
                  data.createdAt.toTimeZone() ,
                ),
                style: bodyStyle,
                textAlign: pw.TextAlign.right,
              )),
        ],
      ),

      pw.SizedBox(height: 3),
      pw.Row(
        children: [
          pw.Expanded(
              child:pw.Text(
                "AVAILABLE BALANCE",
                style: pw.TextStyle(
                  fontSize: is80mm ? 9 : 9,
                  height: 3,
                  font: bold,
                ),
                textAlign: pw.TextAlign.left,
              )),
          pw.SizedBox(width: 2),
          pw.Expanded(
              child: pw.Text(
                "\$${data.balance.toStringAsFixed(2) }",
                style: pw.TextStyle(
                  fontSize: is80mm ? 12 : 12,
                  height: 3,
                  font: bold,
                ),
                textAlign: pw.TextAlign.right,
              )),
        ],
      ),
      pw.SizedBox(height: 5),
      pw.Divider(color: PdfColor.fromHex('#303030'), height: 12),
      //Todo
      pw.Text(
          'Thank you for visiting ${(BaseController.to.restaurantDetails?.restaurant.name ?? "").toUpperCase()}',
          style: lavelStyle,
          textAlign: pw.TextAlign.center),
      pw.Divider(color: PdfColor.fromHex('#303030'), height: 12),
      pw.Text(
        'Please review us on Google',
        style: lavelStyle,
      ),
      // pw.Divider(color: PdfColor.fromHex('#303030'), height: 12),
      // pw.Text(
      //   'GST NUMBER: ${Restaurant.gst}',
      //   style: lavelStyle,
      // ),
      pw.SizedBox(height: 2),
      pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text(
          'Powered by YOGO POS',
          style: smallStyle,
        ),
      ),


    ],
  );
}


pw.Widget _dotDivider() {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(
            color: PdfColor.fromHex('#303030'),
            width: 2,
            style: pw.BorderStyle(
                phase: 3, pattern: const [2, 2] /* 2 dots, 2 spaces */)),
      ),
    ),
  );
}
