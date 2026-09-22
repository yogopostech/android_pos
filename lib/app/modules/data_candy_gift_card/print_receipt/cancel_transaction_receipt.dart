import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/gift_card_controller.dart';
import 'package:yogo_pos/app/modules/setting/controllers/printers_controller.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

String maskCardNumber(String cardNo) {
  if (cardNo.length < 8) return cardNo;
  String first4 = cardNo.substring(0, 4);
  String last4 = cardNo.substring(cardNo.length - 4);
  String masked = List.filled(cardNo.length - 8, "X").join();
  return "$first4$masked$last4";
}

Future<pw.Widget> dataCandyCancelTransactionPrintReceipt(

    ) async {

  GiftCardController controller = Get.put(GiftCardController());
  var bold = await MyFunc.loadCustomFont("assets/fonts/RobotoMono-Bold.ttf");
  bool is80mm = PrintersController.to.selectedPaperWidth.value == "80mm";


  var lavelStyle = pw.TextStyle(
    fontSize: is80mm ? 9 : 7,
    height: 3,
    font: bold,
  );
  var bodyStyle = pw.TextStyle(
    fontSize: is80mm ? 10 : 8,
  );

  var smallStyle = pw.TextStyle(
    fontSize: 7,
    height: 3,
    font: bold,
  );

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      // --- HEADER ---
      pw.Center(child: pw.Text(  (BaseController.to.restaurantDetails?.restaurant.name ?? "").toUpperCase(),
          style: pw.TextStyle(font: bold, fontSize: is80mm ? 18 : 12)),),


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
      pw.SizedBox(height: 3),
      pw.Divider(),

      // Date + Operator

    pw.Center(child:  pw.Text(
      DateFormat('MMM dd, yyyy, hh:mm a').format(
        controller.cancelTransactionModel.value?.data?.createdAt?.toTimeZone() ?? DateTime.now(),
      ),
      style: bodyStyle,
    ),),

      pw.SizedBox(height: 5),
      pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("Server: ${controller.cancelTransactionModel.value?.data?.employeeFirstName}" , style: bodyStyle),
            pw.Text("", style: bodyStyle),
          ]
      ),


      pw.SizedBox(height: 5),
      _dotDivider(),
      pw.SizedBox(height: 5),

      // Customer Info
      // if (customerName != null)


      // Gift Card Info
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("DC Gift Card No.", style: bodyStyle),
          pw.Text(maskCardNumber(controller.cancelTransactionModel.value?.data?.initialResponse?.cID ?? ""),
              style: bodyStyle),
        ],
      ),
      pw.SizedBox(height: 3),

      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("DC Gift Card Cancel Trans.", style: bodyStyle),
          // pw.Text("${increment.data?.increment?.aMT ?? ""}", style: boldStyle),
          pw.Text("\$${controller.cancelTransactionModel.value?.data?.initialResponse?.aMT}", style: bodyStyle),
        ],
      ),
      pw.SizedBox(height: 3),

      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("Invoice No.", style: bodyStyle),
          // pw.Text(increment.data!.increment!.iNV.toString(), style: boldStyle),
          pw.Text(controller.cancelTransactionModel.value?.data?.initialResponse?.iNV ?? "", style: bodyStyle),
        ],
      ),
      pw.SizedBox(height: 3),

      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("TCN No.", style: bodyStyle),
          // pw.Text(increment.data!.increment!.tCN.toString(), style: boldStyle),
          pw.Text(controller.cancelTransactionModel.value?.data?.commitResponse?.tCN ?? "", style: bodyStyle),
        ],
      ),
      pw.SizedBox(height: 3),

      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            "AVAILABLE BALANCE",
            style: pw.TextStyle(
              fontSize: is80mm ? 9 : 9,
              height: 3,
              font: bold,
            ),
            textAlign: pw.TextAlign.left,
          ),
          // pw.Text("${increment.data!.increment!.bAL}", style: boldStyle),
          pw.Text("\$${controller.cancelTransactionModel.value?.data?.initialResponse?.bAL}", style: pw.TextStyle(
  fontSize: is80mm ? 12 : 12,
  height: 3,
  font: bold,
  ),),
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
