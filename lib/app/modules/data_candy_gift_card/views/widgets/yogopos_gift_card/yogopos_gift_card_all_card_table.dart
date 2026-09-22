import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

import '../../../../../widgets/custom_Btn.dart';

class YogoposGiftCardAllCardTable extends StatelessWidget {
  const YogoposGiftCardAllCardTable({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Static demo data
    final List<GiftCardModel> cards = [
      GiftCardModel(
        cid: "1234567812345678",
        customerName: "John Doe",
        customerPhone: "01712345678",
        createdAt: DateTime(2025, 9, 1, 15, 30),
        lastTransactionDate: DateTime(2025, 9, 15, 18, 45),
      ),
      GiftCardModel(
        cid: "8765432187654321",
        customerName: "Alice Smith",
        customerPhone: "01898765432",
        createdAt: DateTime(2025, 8, 25, 11, 10),
        lastTransactionDate: DateTime(2025, 9, 10, 13, 5),
      ),
      GiftCardModel(
        cid: "1111222233334444",
        customerName: "Bob Lee",
        customerPhone: "01911223344",
        createdAt: DateTime(2025, 7, 10, 9, 0),
        lastTransactionDate: DateTime(2025, 9, 5, 20, 20),
      ),
    ];

    return SfDataGrid(
      source: GiftCardStaticDataSource(cards),
      rowHeight: 80,
      columnWidthMode: ColumnWidthMode.fill,
      columns: <GridColumn>[
        GridColumn(
          columnName: 'cid',
          label: const Center(
            child: Text('Card No.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
        ),
        GridColumn(
          columnName: 'customerName',
          label: const Center(
            child: Text('Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
        ),
        GridColumn(
          columnName: 'customerPhone',
          label: const Center(
            child: Text('Phone',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
        ),
        GridColumn(
          columnName: 'createdAt',
          label: const Center(
            child: Text('Start Date',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
        ),
        GridColumn(
          columnName: 'lastTransactionDate',
          label: const Center(
            child: Text('Last Transaction',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
        ),
        GridColumn(
          columnName: 'actions',
          width: 250, // ✅ Fixed width (change as you need)
          label: const Center(
            child: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),
            ),
          ),
        ),
      ],
    );
  }
}

/// ✅ Dummy GiftCard model
class GiftCardModel {
  final String cid;
  final String customerName;
  final String customerPhone;
  final DateTime createdAt;
  final DateTime lastTransactionDate;

  GiftCardModel({
    required this.cid,
    required this.customerName,
    required this.customerPhone,
    required this.createdAt,
    required this.lastTransactionDate,
  });
}

class GiftCardStaticDataSource extends DataGridSource {
  GiftCardStaticDataSource(this.cards) {
    _rows = cards.map<DataGridRow>((card) {
      
      return DataGridRow(cells: [
        DataGridCell(columnName: 'cid', value: maskCardNumber(card.cid)),
        DataGridCell(columnName: 'customerName', value: card.customerName),
        DataGridCell(
            columnName: 'customerPhone',
            value: formatPhoneNumber(card.customerPhone)),
        DataGridCell(
            columnName: 'createdAt', value: formatDate(card.createdAt)),
        DataGridCell(
            columnName: 'lastTransactionDate',
            value: formatDate(card.lastTransactionDate)),
        DataGridCell(columnName: 'actions', value: card),
      ]);
    }).toList();
  }

  final List<GiftCardModel> cards;
  late final List<DataGridRow> _rows;

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'actions') {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // _actionBtn("Redeem",(){},StaticColors.blueColor,),
              // const SizedBox(width: 8),
              _actionBtn("Recharge",(){},StaticColors.blueColor,),
              // _actionBtn("Recharge"),
              const SizedBox(width: 8),
              _actionBtn("Check",(){},StaticColors.blueColor,),

              // _actionBtn("Check"),
            ],
          );
        } else {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(6),
            child: Text(
              cell.value.toString(),
              style: const TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
      }).toList(),
    );
  }

  // Widget _actionBtn(String text) {
  //   return ElevatedButton(
  //     onPressed: () {
  //       debugPrint("$text clicked");
  //     },
  //     child: Text(text, style: const TextStyle(fontSize: 14)),
  //   );
  // }

  Widget _actionBtn(String text, VoidCallback onPressed, Color color) {
    return SizedBox(
      height: 65,
      width: 100,
      child: PrimaryBtn(
        fontWeight: FontWeight.w900,
        textMaxSize: 17,
        textMinSize: 17,
        maxLines: 2,
        color: color,
        onPressed: onPressed,
        text: text,
      ),
    );
  }

  /// ✅ Helper functions (same as dynamic version)
  static String maskCardNumber(String cardNo) {
    if (cardNo.length < 8) return cardNo;
    String first4 = cardNo.substring(0, 4);
    String last4 = cardNo.substring(cardNo.length - 4);
    String masked = List.filled(cardNo.length - 8, "X").join();
    return "$first4$masked$last4";
  }

  static String formatPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return phone.trim();
    final last10 = digits.substring(digits.length - 10);
    return '${last10.substring(0, 3)}-${last10.substring(3, 6)}-${last10.substring(6, 10)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, hh:mm a').format(date);
  }
}
