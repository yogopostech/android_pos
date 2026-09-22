// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';
// import 'package:yogo_pos/app/widgets/custom_btn.dart';
//
// class CancelTransactionTable extends StatelessWidget {
//   const CancelTransactionTable({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SfDataGrid(
//       source: CancelTransactionDataSource(),
//       rowHeight: 55,
//       columnWidthMode: ColumnWidthMode.fill,
//       columns: <GridColumn>[
//         GridColumn(
//           columnName: 'no',
//           label: const Center(
//             child: Text('No.', style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ),
//         GridColumn(
//           columnName: 'cardNumber',
//           label: const Center(
//             child: Text('Card Number',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ),
//         GridColumn(
//           columnName: 'confirmationNumber',
//           label: const Center(
//             child: Text('Confirmation Number',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ),
//         GridColumn(
//           columnName: 'amount',
//           label: const Center(
//             child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ),
//         GridColumn(
//           columnName: 'status',
//           label: const Center(
//             child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ),
//         GridColumn(
//           columnName: 'cancel',
//           label: const Center(
//             child: Text('Cancel',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class CancelTransactionDataSource extends DataGridSource {
//   CancelTransactionDataSource() {
//     _rows = [
//       DataGridRow(cells: [
//         const DataGridCell(columnName: 'no', value: 1),
//         const DataGridCell(columnName: 'cardNumber', value: '1234567890'),
//         const DataGridCell(columnName: 'confirmationNumber', value: 'CNF12345'),
//         const DataGridCell(columnName: 'amount', value: '\$50'),
//         const DataGridCell(columnName: 'status', value: 'Success'),
//         const DataGridCell(columnName: 'cancel', value: '1'),
//       ]),
//       DataGridRow(cells: [
//         const DataGridCell(columnName: 'no', value: 2),
//         const DataGridCell(columnName: 'cardNumber', value: '9876543210'),
//         const DataGridCell(columnName: 'confirmationNumber', value: 'CNF98765'),
//         const DataGridCell(columnName: 'amount', value: '\$100'),
//         const DataGridCell(columnName: 'status', value: 'Pending'),
//         const DataGridCell(columnName: 'cancel', value: '2'),
//       ]),
//     ];
//   }
//
//   late final List<DataGridRow> _rows;
//
//   @override
//   List<DataGridRow> get rows => _rows;
//
//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(
//       cells: row.getCells().map<Widget>((cell) {
//         if (cell.columnName == 'cancel') {
//           return Center(
//             child: SizedBox(
//               height: 35,
//               child: PrimaryBtn(
//                 color: StaticColors.orangeColor,
//                 onPressed: () {
//                   print("Cancel clicked for row: ${cell.value}");
//                 },
//                 text: "Cancel",
//               ),
//             ),
//           );
//         } else {
//           return Container(
//             alignment: Alignment.center,
//             padding: const EdgeInsets.all(6),
//             child: Text(
//               cell.value.toString(),
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 14),
//               overflow: TextOverflow.ellipsis,
//             ),
//           );
//         }
//       }).toList(),
//     );
//   }
// }

// // cancel_transaction_table.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/extension/string_manipulation_extension.dart';
import '../../controller/transaction_controller.dart';
import '../../models/transaction_model.dart';

class TransactionTable extends StatelessWidget {
  const TransactionTable({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController =
        Get.put(TransactionController());

    // fetch once (optional)
    // transactionController.fetchTransactions();

    return Column(
      children: [
        /// Header
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).hintColor),
            ),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(
              child: Text(
                'Gift Card Transaction Details',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 35),
              ),
            ),
          ),
        ),
        // Text("data"),

        /// Data Table
        Expanded(
          child: Obx(() {
            // if (transactionController.isLoading.value) {
            //   return const Center(child: CircularProgressIndicator());
            // }
            //
            // if (transactionController.transactions.isEmpty) {
            //   return const Center(
            //     child: Text("No transactions found",
            //         style: TextStyle(fontSize: 24)),
            //   );
            // }

            return Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: SfDataGrid(
                source:
                    TransactionDataSource(transactionController.transactions),
                rowHeight: 70,
                columnWidthMode: ColumnWidthMode.fill,
                columns: <GridColumn>[
                  GridColumn(
                    columnName: 'date',
                    label: const Center(
                      child: Text('Date',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                    ),
                  ),
                  GridColumn(
                    columnName: 'time',
                    label: const Center(
                      child: Text('Time',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                    ),
                  ),
                  GridColumn(
                    columnName: 'server',
                    label: const Center(
                      child: Text('Server',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                    ),
                  ),
                  GridColumn(
                    columnName: 'cardNo',
                    label: const Center(
                      child: Text('Card No.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                    ),
                  ),
                  GridColumn(
                    columnName: 'transactionType',
                    label: const Center(
                      child: Text('Transaction Type',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                    ),
                  ),
                  GridColumn(
                    columnName: 'tcnNo',
                    label: const Center(
                      child: Text('TCN No.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                    ),
                  ),
                  GridColumn(
                    columnName: 'invoiceNo',
                    label: const Center(
                      child: Text('Invoice No.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// ✅ DataGridSource for Transaction
class TransactionDataSource extends DataGridSource {
  TransactionDataSource(this.transactions) {
    _rows = transactions.map<DataGridRow>((tx) {
      return DataGridRow(cells: [
        DataGridCell(
          columnName: 'date',
          value: DateFormat('MMM dd, yyyy').format(tx.createdAt.toTimeZone()),
        ),
        DataGridCell(
          columnName: 'time',
          value: DateFormat('hh:mm a').format(tx.createdAt.toTimeZone()),
        ),
        DataGridCell(columnName: 'server', value: tx.employeeFirstName ),
        DataGridCell(columnName: 'cardNo', value: maskCardNumber(tx.cid)),
        DataGridCell(
            columnName: 'transactionType',
            value: tx.transactionType.toCapitalize()),
        DataGridCell(columnName: 'tcnNo', value: tx.tcn),
        DataGridCell(columnName: 'invoiceNo', value: tx.inv),
      ]);
    }).toList();
  }

  final List<Transaction> transactions;
  late final List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(6),
          child: Text(
            cell.value.toString(),
            style: const TextStyle(fontSize: 22),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  /// Mask card number
  static String maskCardNumber(String cardNo) {
    if (cardNo.length < 8) return cardNo;
    String first4 = cardNo.substring(0, 4);
    String last4 = cardNo.substring(cardNo.length - 4);
    String masked = List.filled(cardNo.length - 8, "X").join();
    return "$first4$masked$last4";
  }
}
