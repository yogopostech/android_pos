import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<pw.Widget> kitchenPrintReceipt({
  required OrderModel order,
  bool isCheckCanceled = false,
  bool isShowItems = true,
  String? title,
  bool isItemsCanceled = false,
}) async {
  var bold = await MyFunc.loadCustomFont("assets/fonts/RobotoMono-Bold.ttf");
  var boldItalic = await MyFunc.loadCustomFont(
    "assets/fonts/RobotoMono-BoldItalic.ttf",
  );
  bool is80mm = Preferences.paperWidth == "80mm";
  // style
  var titleStyle = pw.TextStyle(
    fontSize: is80mm ? 18 : 10,
    height: 3,
    font: bold,
    fontWeight: pw.FontWeight.bold,
  );
  var bodyStyle = pw.TextStyle(
    fontSize: is80mm ? 10 : 8,
    height: 3,
    font: bold,
  );
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    mainAxisSize: pw.MainAxisSize.max,
    children: [
      pw.Row(
        children: [
          pw.Text(
            'Token# ',
            style: bodyStyle.copyWith(fontSize: 14),
            textAlign: pw.TextAlign.left,
            maxLines: 1,
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: PdfColors.black,
            ),
            alignment: pw.Alignment.topLeft,
            child: pw.Text(
              order.tokenId,
              style: bodyStyle.copyWith(fontSize: 14, color: PdfColors.white),
              textAlign: pw.TextAlign.left,
              maxLines: 1,
            ),
          ),
        ],
      ),
      pw.Align(
        alignment: pw.Alignment.topLeft,
        child: pw.Text('Check# ${order.orderId}', style: bodyStyle),
      ),
      pw.Align(
        alignment: pw.Alignment.topLeft,
        child: pw.Text(
          DateFormat('MMM dd,hh:mm a').format(
            order.createdAt == null
                ? DateTime.now()
                : order.createdAt!.toTimeZone(),
          ),
          style: bodyStyle,
          textAlign: pw.TextAlign.left,
        ),
      ),
      pw.Text(
        'Server:${order.employee != null ? order.employee?.firstName.toUpperCase() : "OLO"}',
        style: bodyStyle,
        textAlign: pw.TextAlign.right,
        maxLines: 1,
      ),
      pw.Align(
        alignment: pw.Alignment.bottomLeft,
        child: pw.Text(
          'Guest:${MyFunc.capitalize(order.guestName)}',
          style: bodyStyle.copyWith(fontSize: 14),
          maxLines: 1,
          textAlign: pw.TextAlign.left,
        ),
      ),
      if (order.orderType == "DINE_IN")
        pw.Row(
          children: [
            pw.Text(
              'No. Guest:${order.numberOfPeople}',
              style: bodyStyle,
              maxLines: 2,
              textAlign: pw.TextAlign.start,
            ),
          ],
        ),
      pw.Row(
        children: [
          pw.Text(
            'Number:${order.guestPhoneNumber}',
            style: bodyStyle,
            maxLines: 2,
            textAlign: pw.TextAlign.start,
          ),
        ],
      ),
      //est time
      if ((order.orderType == "TAKEOUT" && order.takeOutType == "ONLINE") ||
          order.orderType == "DELIVERY")
        pw.Row(
          children: [
            pw.Text(
              'Pickup:${order.estimatedDate.toFormattedDate()},${order.estimatedTime}',
              style: bodyStyle.copyWith(fontSize: 14),
              maxLines: 2,
              textAlign: pw.TextAlign.start,
            ),
          ],
        ),

      if (order.notes.isNotEmpty)
        pw.Text(
          'Notes:${order.notes}',
          style: bodyStyle,
          textAlign: pw.TextAlign.start,
        ),
      if (order.delivery != null && order.orderType == "DELIVERY") ...[
        if (order.delivery?.address.isNotEmpty ?? false)
          pw.Text(
            'Delivery Address:${order.delivery?.address}',
            style: bodyStyle,
            textAlign: pw.TextAlign.start,
            maxLines: 5,
          ),
        if (order.delivery?.additionalDetails.isNotEmpty ?? false)
          pw.Text(
            'Additional Details:${order.delivery?.additionalDetails}',
            style: bodyStyle,
            textAlign: pw.TextAlign.start,
            maxLines: 5,
          ),
      ],
      pw.SizedBox(height: is80mm ? 12.0 : 8),
      pw.Divider(color: PdfColor.fromHex('#303030'), height: 2),
      pw.SizedBox(height: is80mm ? 15.0 : 10),
      if (order.orderType == "TAKEOUT" && order.takeOutType == "ONLINE")
        pw.Text(
          '**** ${order.takeOutType} ****',
          style: titleStyle,
          maxLines: 1,
          textAlign: pw.TextAlign.center,
        ),
      pw.Text(
        '**** ${order.orderType.replaceAll("_", "-")} ****',
        style: titleStyle,
        maxLines: 1,
        textAlign: pw.TextAlign.center,
      ),
      if (order.orderType == "DINE_IN")
        pw.Text(
          '**** ${order.tableName} ****',
          style: titleStyle,
          maxLines: 1,
          textAlign: pw.TextAlign.center,
        ),

      pw.SizedBox(height: is80mm ? 15.0 : 10),
      pw.Divider(color: PdfColor.fromHex('#303030'), height: 2),
      // ! item
      pw.SizedBox(height: 10),
      if (isCheckCanceled) ...[
        pw.Text(
          "****${title?.toUpperCase() ?? 'Check CANCELED'.toUpperCase()}****",
          style: titleStyle.copyWith(fontSize: is80mm ? 14 : 8),
          maxLines: 1,
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
      ],

      if (isShowItems)
        ...List.generate(order.carts.combineItems().length, (index) {
          var data = order.carts.combineItems()[index];
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 0),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      child: pw.Text(
                        '${data.quantity}',
                        style: titleStyle.copyWith(fontSize: is80mm ? 16 : 12),
                        maxLines: 1,
                      ),
                    ),
                    pw.SizedBox(width: 4),
                    pw.Expanded(
                      child: pw.Text(
                        (data.itemType == "weighing scale"
                                ? "${data.name}(${data.weight}LB)"
                                : data.name)
                            .toUpperCase(),
                        style: titleStyle.copyWith(fontSize: is80mm ? 14 : 8),
                      ),
                    ),
                  ],
                ),
              ),
              // pw.Divider(color: PdfColor.fromHex('#303030'), height: 2),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // option
                  if (data.variationOptions.isNotEmpty)
                    ...List.generate(data.variationOptions.length, (index) {
                      final optionData = data.variationOptions[index];
                      final isLast = index == data.variationOptions.length - 1;

                      return pw.Column(
                        crossAxisAlignment:
                            pw.CrossAxisAlignment.start, // Align text to start
                        children: [
                          pw.Text(
                            "${optionData.quantity} x ${MyFunc.capitalizeEachWord(s: optionData.name)}",
                            style: pw.TextStyle(
                              font: boldItalic,
                              fontSize: is80mm ? 14 : 8,
                            ),
                          ),
                          if (!isLast)
                            _dotDivider(), // Only add divider if not the last item
                        ],
                      );
                    }),
                  ...List.generate(data.modifiers.length, (index) {
                    var modifier = data.modifiers[index];
                    return pw.Text(
                      modifier.toUpperCase(),
                      style: titleStyle.copyWith(
                        decoration: pw.TextDecoration.underline,
                        fontSize: is80mm ? 11 : 8,
                      ),
                    );
                  }),

                  //kitchenNote
                  if (data.kitchenNote.isNotEmpty) ...[
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Note: ".toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: is80mm ? 11 : 9,
                            fontWeight: pw.FontWeight.bold,
                            decoration:
                                pw.TextDecoration.underline, // Add underline
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            data.kitchenNote.toUpperCase(),
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: is80mm ? 11 : 9,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              // _dotDivider()
              pw.SizedBox(height: is80mm ? 5 : 4),
              pw.Divider(color: PdfColor.fromHex('#303030'), height: 2),
              pw.SizedBox(height: is80mm ? 5 : 4),
            ],
          );
        }),
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
            phase: 3,
            pattern: const [2, 2] /* 2 dots, 2 spaces */,
          ),
        ),
      ),
    ),
  );
}
