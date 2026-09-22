import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';

import '../models/table_reservations_model.dart';

class TableReservationsWidget extends StatelessWidget {
  final List<Reservations> tables;

  const TableReservationsWidget({super.key, required this.tables});

  @override
  Widget build(BuildContext context) {
    const double rowHeight = 50; // Custom row height
    const double headerHeight = 56; // Approximate header height
    final double totalHeight = headerHeight + (tables.length * rowHeight);
    const EdgeInsetsGeometry headerPadding =
        EdgeInsets.symmetric(horizontal: 8.0, vertical: 17);

    return SizedBox(
      height: totalHeight,
      child: SfDataGrid(
        frozenColumnsCount: 2,
        // footerFrozenColumnsCount: 1,
        columnWidthMode: ColumnWidthMode.auto,
        verticalScrollPhysics: const NeverScrollableScrollPhysics(),
        // gridLinesVisibility: GridLinesVisibility.none,
        rowHeight: rowHeight,
        source: TableReservationDataSource(reservations: tables),
        columns: <GridColumn>[
          GridColumn(
            columnName: 'no',
            label: const Padding(
              padding: headerPadding,
              child: Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          GridColumn(
            columnName: 'id',
            label: const Padding(
                padding: headerPadding,
                child:
                    Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          GridColumn(
              columnName: 'fullName',
              label: const Padding(
                  padding: headerPadding,
                  child: Text('Full Name',
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          GridColumn(
              columnName: 'email',
              label: const Padding(
                  padding: headerPadding,
                  child: Text('Email',
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          GridColumn(
              columnName: 'numberOfGuests',
              label: const Padding(
                  padding: headerPadding,
                  child: Text('Guests',
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          GridColumn(
              columnName: 'phoneNumber',
              label: const Padding(
                  padding: headerPadding,
                  child: Text('Phone',
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          GridColumn(
              columnName: 'notes',
              label: const Padding(
                  padding: headerPadding,
                  child: Text('Notes',
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          GridColumn(
              columnName: 'selectedTable',
              label: const Padding(
                  padding: headerPadding,
                  child: Text('Table',
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          GridColumn(
              columnName: 'bookingTime',
              label: const Padding(
                  padding: headerPadding,
                  child: Text('Booking Time',
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          GridColumn(
              columnName: 'status',
              label: const Padding(
                  padding: headerPadding,
                  child: Text('Status',
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          GridColumn(
              columnName: 'createdAt',
              label: const Padding(
                  padding: headerPadding,
                  child: Text('Created At',
                      style: TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }
}

class TableReservationDataSource extends DataGridSource {
  List<DataGridRow> _dataGridRows = [];

  TableReservationDataSource({required List<Reservations> reservations}) {
    int index = 1; // Start index from 1
    _dataGridRows = reservations.map<DataGridRow>((reservation) {
      return DataGridRow(cells: [
        DataGridCell<int>(
            columnName: 'no', value: index++), // Auto-increment No
        DataGridCell<String>(columnName: 'id', value: reservation.tableBookId),
        DataGridCell<String>(
            columnName: 'fullName', value: reservation.fullName),
        DataGridCell<String>(columnName: 'email', value: reservation.email),
        DataGridCell<int>(
            columnName: 'numberOfGuests', value: reservation.numberOfGuests),
        DataGridCell<String>(
            columnName: 'phoneNumber', value: reservation.phoneNumber),
        DataGridCell<String>(columnName: 'notes', value: reservation.notes),
        DataGridCell<String>(
            columnName: 'selectedTable', value: reservation.selectedTable),
        DataGridCell<String>(
            columnName: 'bookingTime',
            value: DateFormat('MMM dd,hh:mm a')
                .format(reservation.createdAt.toTimeZone())),
        DataGridCell<String>(columnName: 'status', value: reservation.status),
        DataGridCell<String>(
            columnName: 'createdAt',
            value: DateFormat('MMM dd,hh:mm a')
                .format(reservation.createdAt.toTimeZone())),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataCell) {
        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            dataCell.value.toString(),
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }
}
