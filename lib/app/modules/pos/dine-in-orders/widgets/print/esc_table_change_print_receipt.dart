import 'dart:typed_data';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/utils/receipt.dart';

Uint8List escTableChangePrintReceipt({
  required OrderModel order,
  required String oldTableName,
}) {
  Receipt receipt = Receipt();
  
  receipt
      // Header
      .text(
        'TABLE CHANGE',
        fontSize: 2,
        fontWeight: FontWeight.bold,
        align: Align.center,
      )
      .space()
      
      // Check number and Date/Time row
      .flexRow(children: [
        Col.flex(
          'Check:${order.orderId}',
          fontWeight: FontWeight.bold,
        ),
        Col.flex(
          DateFormat('MMM dd,hh:mm a').format(DateTime.now()),
          fontWeight: FontWeight.bold,
          align: Align.right,
        ),
      ])
      .space()
      
      // Table change details
      .text(
        'Table Change ${order.tableName} to $oldTableName'.toUpperCase(),
        fontSize: 2,
        fontWeight: FontWeight.bold,
        align: Align.center,
        maxLines: 2,
      )
      .space(2)
      .cut();
      
  return receipt.bytes;
}