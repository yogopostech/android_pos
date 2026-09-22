// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:yogo_pos/app/modules/terminalIntegration/moneris/models/moneris_purchase_model.dart';

// // import '../../moneries_response_table/models/table_reservations_model.dart';

// class MonerisResponseTableWidget extends StatelessWidget {
//   // final List<Reservations> tables;
//   final List<Response> tables;

//   const MonerisResponseTableWidget({super.key, required this.tables});

//   @override
//   Widget build(BuildContext context) {
//     const double rowHeight = 50; // Custom row height
//     return SfDataGrid(

//       frozenColumnsCount: 2,
//       columnWidthMode: ColumnWidthMode.auto,
//       rowHeight: rowHeight,
//       source: TableReservationDataSource(response: tables),
//       columns: <GridColumn>[
//         GridColumn(
//           columnName: 'no',
//           label: Center(
//               child: Text('No',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//         ),
//         GridColumn(
//           columnName: 'orderId',
//           label: Center(
//             child: Text(
//               'Order\nId',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//         GridColumn(
//             columnName: 'transactionId',
//             label: Center(
//               child: Text('Transaction\n       Id',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             )),
//         GridColumn(
//             columnName: 'linkId',
//             label: Center(
//               child: Text(
//                 'Link\nId',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'statusCode',
//             label: Center(
//               child: Text(
//                 'Status\nCode',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'status',
//             label: Center(
//               child: Text(
//                 'Status',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             )),
//         GridColumn(
//             columnName: 'idempotencyKey',
//             label: Center(
//               child: Text(
//                 'Idempotency\n        Key',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'cloudTicket',
//             label: Center(
//               child: Text(
//                 'Cloud\nTicket',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'completed',
//             label: Center(
//               child: Text(
//                 'Completed',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'responseCode',
//             label: Center(
//               child: Text(
//                 'Response\n    Code',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'iso',
//             label: Center(
//               child: Text(
//                 'ISO',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'tipAmount',
//             label: Center(
//               child: Text(
//                 '      Tip\nAmount',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'cashback',
//             label: Center(
//               child: Text(
//                 'Cashback',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'surcharge',
//             label: Center(
//               child: Text(
//                 'Surcharge',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'approvedAmount',
//             label: Center(
//               child: Text(
//                 'Approved\n  Amount',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'tenderType',
//             label: Center(
//               child: Text(
//                 'Tender Type',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'cardType',
//             label: Center(
//               child: Text(
//                 'CardType',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'sequenceNum',
//             label: Center(
//               child: Text(
//                 'Sequence\n Number',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'realTimeUniqueId',
//             label: Center(
//               child: Text(
//                 'Real Time\nUnique Id',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'authCode',
//             label: Center(
//               child: Text(
//                 'Auth\nCode',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'formFactor',
//             label: Center(
//               child: Text(
//                 'Form Factor',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'maskedPan',
//             label: Center(
//               child: Text(
//                 'Masked Pan',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'action',
//             label: Center(
//               child: Text(
//                 'Action',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'terminalId',
//             label: Center(
//               child: Text(
//                 'Terminal Id',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'receipt',
//             label: Center(
//               child: Text(
//                 'Receipt',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             )),
//         GridColumn(
//             columnName: 'totalAmount',
//             label: Center(
//               child: Text('Total Amount',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             )),
//       ],
//     );
//   }
// }

// class TableReservationDataSource extends DataGridSource {
//   List<DataGridRow> _dataGridRows = [];

//   TableReservationDataSource({required List<Response> response}) {
//     int index = 1; // Start index from 1
//     _dataGridRows = response.map<DataGridRow>((reservation) {
//       return DataGridRow(cells: [
//         DataGridCell<int>(
//             columnName: 'no', value: index++), // Auto-increment No
//         // DataGridCell<String>(columnName: '', value: reservation.orderId),
//         DataGridCell<String>(
//             columnName: 'orderId',
//             value: reservation.orderId.length >= 6
//                 ? reservation.orderId.substring(0, 6)
//                 : reservation.orderId),
//         DataGridCell<String>(
//             columnName: 'transactionId', value: reservation.transactionId),
//         DataGridCell<String>(columnName: 'linkId', value: reservation.linkId),
//         DataGridCell<String>(
//             columnName: 'statusCode', value: reservation.statusCode),
//         DataGridCell<String>(columnName: 'status', value: reservation.status),
//         DataGridCell<String>(
//             columnName: 'idempotencyKey',
//             value: reservation.idempotencyKey.length >= 20
//                 ? reservation.idempotencyKey.substring(0, 20)
//                 : reservation.idempotencyKey),
//         DataGridCell<String>(
//             columnName: 'cloudTicket', value: reservation.cloudTicket),
//         DataGridCell<String>(
//             columnName: 'completed', value: reservation.completed),
//         DataGridCell<String>(
//             columnName: 'responseCode', value: reservation.responseCode),
//         DataGridCell<String>(columnName: 'iso', value: reservation.iso),
//         DataGridCell<String>(
//             columnName: 'tipAmount', value: reservation.tipAmount),
//         DataGridCell<String>(
//             columnName: 'cashback', value: reservation.cashback),
//         DataGridCell<String>(
//             columnName: 'surcharge', value: reservation.surcharge),
//         DataGridCell<String>(
//             columnName: 'approvedAmount', value: reservation.approvedAmount),
//         DataGridCell<String>(
//             columnName: 'tenderType', value: reservation.tenderType),
//         DataGridCell<String>(
//             columnName: 'cardType', value: reservation.cardType),
//         DataGridCell<String>(
//             columnName: 'sequenceNum', value: reservation.sequenceNum),
//         DataGridCell<String>(
//             columnName: 'realTimeUniqueId',
//             value: reservation.realTimeUniqueId),
//         DataGridCell<String>(
//             columnName: 'authCode', value: reservation.authCode),
//         DataGridCell<String>(
//             columnName: 'formFactor', value: reservation.formFactor),
//         DataGridCell<String>(
//             columnName: 'maskedPan', value: reservation.maskedPan),
//         DataGridCell<String>(columnName: 'action', value: reservation.action),
//         DataGridCell<String>(
//             columnName: 'terminalId', value: reservation.terminalId),
//         DataGridCell<String>(columnName: 'receipt', value: reservation.receipt),
//         DataGridCell<String>(
//             columnName: 'totalAmount', value: reservation.totalAmount),
//       ]);
//     }).toList();
//   }

//   @override
//   List<DataGridRow> get rows => _dataGridRows;

//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(
//       cells: row.getCells().map<Widget>((dataCell) {
//         return Container(
//           alignment: Alignment.center,
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             dataCell.value.toString(),
//             style: const TextStyle(fontSize: 14),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/moneris/models/moneris_purchase_model.dart';

class MonerisResponseTableWidget extends StatelessWidget {
  final List<Response> tables;

  const MonerisResponseTableWidget({super.key, required this.tables});

  @override
  Widget build(BuildContext context) {
    const double rowHeight = 50;
    return SfDataGrid(
      frozenColumnsCount: 2,
      columnWidthMode: ColumnWidthMode.auto,
      rowHeight: rowHeight,
      source: MonerisResponseDataSource(response: tables, context: context),
      columns: <GridColumn>[
        _buildColumn('no', 'No'),
        _buildColumn('orderId', 'Order\nId'),
        _buildColumn('transactionId', 'Transaction\n       Id'),
        _buildColumn('linkId', 'Link\nId'),
        _buildColumn('statusCode', 'Status\nCode'),
        _buildColumn('status', 'Status'),
        _buildColumn('idempotencyKey', 'Idempotency\n        Key'),
        _buildColumn('cloudTicket', 'Cloud\nTicket'),
        _buildColumn('completed', 'Completed'),
        _buildColumn('responseCode', 'Response\n    Code'),
        _buildColumn('iso', 'ISO'),
        _buildColumn('tipAmount', '      Tip\nAmount'),
        _buildColumn('cashback', 'Cashback'),
        _buildColumn('surcharge', 'Surcharge'),
        _buildColumn('approvedAmount', 'Approved\n  Amount'),
        _buildColumn('tenderType', 'Tender Type'),
        _buildColumn('cardType', 'CardType'),
        _buildColumn('sequenceNum', 'Sequence\n Number'),
        _buildColumn('realTimeUniqueId', 'Real Time\nUnique Id'),
        _buildColumn('authCode', 'Auth\nCode'),
        _buildColumn('formFactor', 'Form Factor'),
        _buildColumn('maskedPan', 'Masked Pan'),
        _buildColumn('action', 'Action'),
        _buildColumn('terminalId', 'Terminal Id'),
        _buildColumn('receipt', 'Receipt'),
        _buildColumn('totalAmount', 'Total Amount'),
      ],
    );
  }

  GridColumn _buildColumn(String name, String label) {
    return GridColumn(
      columnName: name,
      label: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class MonerisResponseDataSource extends DataGridSource {
  List<DataGridRow> _dataGridRows = [];
  final BuildContext context;

  static const _copyableColumns = {'orderId', 'idempotencyKey'};

  MonerisResponseDataSource({
    required List<Response> response,
    required this.context,
  }) {
    int index = 1;
    _dataGridRows = response.map<DataGridRow>((r) {
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: 'no', value: index++),
        DataGridCell<String>(columnName: 'orderId', value: r.orderId),
        DataGridCell<String>(
            columnName: 'transactionId', value: r.transactionId),
        DataGridCell<String>(columnName: 'linkId', value: r.linkId),
        DataGridCell<String>(columnName: 'statusCode', value: r.statusCode),
        DataGridCell<String>(columnName: 'status', value: r.status),
        DataGridCell<String>(
            columnName: 'idempotencyKey', value: r.idempotencyKey),
        DataGridCell<String>(columnName: 'cloudTicket', value: r.cloudTicket),
        DataGridCell<String>(columnName: 'completed', value: r.completed),
        DataGridCell<String>(columnName: 'responseCode', value: r.responseCode),
        DataGridCell<String>(columnName: 'iso', value: r.iso),
        DataGridCell<String>(columnName: 'tipAmount', value: r.tipAmount),
        DataGridCell<String>(columnName: 'cashback', value: r.cashback),
        DataGridCell<String>(columnName: 'surcharge', value: r.surcharge),
        DataGridCell<String>(
            columnName: 'approvedAmount', value: r.approvedAmount),
        DataGridCell<String>(columnName: 'tenderType', value: r.tenderType),
        DataGridCell<String>(columnName: 'cardType', value: r.cardType),
        DataGridCell<String>(columnName: 'sequenceNum', value: r.sequenceNum),
        DataGridCell<String>(
            columnName: 'realTimeUniqueId', value: r.realTimeUniqueId),
        DataGridCell<String>(columnName: 'authCode', value: r.authCode),
        DataGridCell<String>(columnName: 'formFactor', value: r.formFactor),
        DataGridCell<String>(columnName: 'maskedPan', value: r.maskedPan),
        DataGridCell<String>(columnName: 'action', value: r.action),
        DataGridCell<String>(columnName: 'terminalId', value: r.terminalId),
        DataGridCell<String>(columnName: 'receipt', value: r.receipt),
        DataGridCell<String>(columnName: 'totalAmount', value: r.totalAmount),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataCell) {
        final fullValue = dataCell.value.toString();
        final isCopyable = _copyableColumns.contains(dataCell.columnName);

        final displayText = switch (dataCell.columnName) {
          'orderId' when fullValue.length >= 6 =>
            '${fullValue.substring(0, 6)}...',
          'idempotencyKey' when fullValue.length >= 20 =>
            '${fullValue.substring(0, 20)}...',
          _ => fullValue,
        };

        final textWidget = Text(
          displayText,
          style: TextStyle(
            fontSize: 14,
            color: isCopyable ? Colors.blue.shade700 : null,
            decoration: isCopyable ? TextDecoration.underline : null,
          ),
        );

        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: isCopyable
              ? Tooltip(
                  message: fullValue,
                  child: InkWell(
                    onTap: () => _copyToClipboard(fullValue),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(child: textWidget),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.copy,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : textWidget,
        );
      }).toList(),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        width: 300,
      ),
    );
  }
}
