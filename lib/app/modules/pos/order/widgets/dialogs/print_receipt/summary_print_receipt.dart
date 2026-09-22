import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<pw.Widget> summaryPrintReceipt() async {
  var bold = await MyFunc.loadCustomFont("assets/fonts/RobotoMono-Bold.ttf");
  var regular =
      await MyFunc.loadCustomFont("assets/fonts/RobotoMono-Regular.ttf");
  // style
  var titleSmallStyle = pw.TextStyle(
    fontSize: 10,
    height: 3,
    font: bold,
    fontWeight: pw.FontWeight.bold,
  );
  var bodyStyle = pw.TextStyle(
    fontSize: 9,
    height: 3,
    font: regular,
  );
  return pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      //  title area
      pw.Center(
          child: pw.Text(
        'Check Summary For HAVELI'.toUpperCase(),
        textAlign: pw.TextAlign.center,
        style: titleSmallStyle,
      )),
      pw.SizedBox(height: 4),
      pw.Text(
        '08/10/2024  11:56:39 PM',
        style: bodyStyle,
      ),
      pw.SizedBox(height: 10),
      // ! item header
      pw.Row(
        children: [
          pw.SizedBox(width: 40, child: pw.Text('Check', style: bodyStyle)),
          pw.SizedBox(width: 6),
          pw.Expanded(child: pw.Text('Total', style: bodyStyle)),
          pw.SizedBox(width: 6),
          pw.Text('Payments', style: bodyStyle),
        ],
      ),
      pw.Divider(color: PdfColor.fromHex('#303030'), height: 2),
      // // ! item
      pw.SizedBox(
        height: 10,
      ),
      ...List.generate(2, (index) {
        // var data = order.carts[index];
        return pw.Column(children: [
          pw.Row(
            children: [
              pw.SizedBox(
                  width: 40, child: pw.Text('122333', style: bodyStyle)),
              pw.SizedBox(width: 6),
              pw.Expanded(child: pw.Text("\$43.43", style: bodyStyle)),
              pw.SizedBox(width: 6),
              pw.Column(children: [
                pw.Text('MasterCard:\$434.43', style: bodyStyle),
                pw.Text('Tips:(\$34.43)', style: bodyStyle),
              ]),
            ],
          ),
          _dotDivider()
        ]);
      }),
    ],
  );
}

pw.Widget _dotDivider() {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: List.generate(30, (index) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 2.0),
          child: pw.Container(
            width: 2.0,
            height: .5,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#303030'),
              // shape: BoxShape.circle,
            ),
          ),
        );
      }),
    ),
  );
}
