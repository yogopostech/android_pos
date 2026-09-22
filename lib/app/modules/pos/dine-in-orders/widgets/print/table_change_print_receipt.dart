import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

Future<pw.Widget> tableChangePrintReceipt(
    {required OrderModel order, required String oldTableName}) async {
  var bold = await MyFunc.loadCustomFont("assets/fonts/RobotoMono-Bold.ttf");
  // style
  var titleStyle = pw.TextStyle(
    fontSize: 14,
    height: 3,
    font: bold,
    fontWeight: pw.FontWeight.bold,
  );
  var bodyStyle = pw.TextStyle(
    fontSize: 10,
    height: 3,
    font: bold,
    // fontWeight: pw.FontWeight.bold,
  );
  return pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              'Check:${order.orderId}',
              style: bodyStyle,
              maxLines: 1,
            ),
          ),
          pw.SizedBox(width: 2),
          pw.Expanded(
              child: pw.Text(
            DateFormat('MMM dd,hh:mm a').format(DateTime.now().toTimeZone()),
            style: bodyStyle,
            maxLines: 1,
          )),
        ],
      ),
      pw.SizedBox(height: 6.0),
      pw.Text('Table Change ${order.tableName} to $oldTableName'.toUpperCase(),
          style: titleStyle),
    ],
  );
}
