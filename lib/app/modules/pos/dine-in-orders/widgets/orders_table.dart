import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/print_order_dialog.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/views/order_details_view.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/duration_extension.dart';
import 'package:yogo_pos/app/utils/extension/formatted_phone.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/extension/string_manipulation_extension.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';

class OrdersTable extends StatelessWidget {
  final List<OrderModel> orders;
  const OrdersTable(this.orders, {super.key});

  @override
  Widget build(BuildContext context) {
    // Determine if "tableName" column should be hidden
    // bool isTakeout = orders.any((order) => order.orderType == "TAKEOUT");
    const double rowHeight = 50; // Custom row height
    const double headerHeight = 56; // Approximate header height
    final double totalHeight = headerHeight + (orders.length * rowHeight);
    return SizedBox(
      height: totalHeight,
      child: SfDataGrid(
        source: OrderDataSource(orders),
        frozenColumnsCount: 2,
        // footerFrozenColumnsCount: 3,
        columnWidthMode: ColumnWidthMode.auto,
        verticalScrollPhysics: const NeverScrollableScrollPhysics(),
        // gridLinesVisibility: GridLinesVisibility.none,
        rowHeight: rowHeight, // Custom row height for better fit
        onCellTap: (data) {
          BaseController.to.playTapSound();
          PosController.to.myOrder = orders[data.rowColumnIndex.rowIndex - 1];
          PosController.to.selectedItemList.clear();
          Get.to(() => const OrderDetailsView());
        },
        columns: [
          GridColumn(
            columnName: 'no',
            label: const Center(child: Text('No.')),
          ),
          GridColumn(
            width: 65,
            columnName: 'action',
            label: const Center(child: Text('Print\nCheck')),
          ),
          GridColumn(
            columnName: 'tokenId',
            label: const Center(child: Text('Token\nNo.')),
          ),
          GridColumn(
            columnName: 'orderId',
            label: const Center(child: Text('Check\nNo.')),
          ),
          GridColumn(
            columnName: 'orderType',
            label: const Center(child: Text('Check\nType')),
          ),
          GridColumn(
            columnName: 'orderStatus',
            label: const Center(child: Text('Check\nStatus')),
          ),

          GridColumn(
            columnName: 'tableName',
            label: const Center(child: Text('Table\nNo.')),
          ),
          GridColumn(
            columnName: 'address',
            label: const Center(child: Text('Address')),
          ),
          GridColumn(
            columnName: 'employeeName',
            label: const Center(child: Text('Employee\nName')),
          ),
          GridColumn(
            columnName: 'guestName',
            label: const Center(child: Text('Guest\nName')),
          ),
          // if (!isTakeout)
          GridColumn(
            columnName: 'numberOfPeople',
            label: const Center(child: Text('Total\nGuests')),
          ),
          GridColumn(
            columnName: 'guestPhoneNumber',
            label: const Center(child: Text('Phone\nNo.')),
          ),
          GridColumn(
            columnName: 'createdAt',
            label: const Center(child: Text('OPT')),
          ),
          GridColumn(
            columnName: 'updatedAt',
            label: const Center(child: Text('OCT')),
          ),
          GridColumn(
            columnName: 'aot',
            label: const Center(child: Text('AOT')),
          ),
          // if (isTakeout)
          GridColumn(
            columnName: 'guestNotes',
            label: const Center(child: Text('Notes')),
            width: 300,
          ),

          // GridColumn(
          //     columnName: 'orderType',
          //     label: const Center(child: Text('Check\nType'))),
          // if (isTakeout)
          GridColumn(
            columnName: 'takeOutType',
            label: const Center(child: Text('Takeout\nType')),
          ),
          GridColumn(
            columnName: 'paymentProcessor',
            label: const Center(child: Text('Pay.\nPro.')),
          ),
          GridColumn(
            columnName: 'paymentMethod',
            label: const Center(child: Text('Pay.\nType')),
          ),
          // if (isTakeout)
          GridColumn(
            columnName: 'packagingCost',
            label: const Center(child: Text('Packaging')),
          ),
          GridColumn(
            columnName: 'totalDiscount',
            label: const Center(child: Text('Discount')),
          ),
          // if (!isTakeout)
          GridColumn(
            columnName: 'totalGratuity',
            label: const Center(child: Text('Grat.')),
          ),
          GridColumn(
            columnName: 'totalGst',
            label: const Center(child: Text('GST')),
          ),
          GridColumn(
            columnName: 'totalPst',
            label: const Center(child: Text('PST')),
          ),
          GridColumn(
            columnName: 'totalPst2',
            label: const Center(child: Text('PST2')),
          ),
          GridColumn(
            columnName: 'maintenanceFee',
            label: const Center(child: Text('Service\nFee')),
          ),
          GridColumn(
            columnName: 'deliveryFee',
            label: const Center(child: Text('Delivery\nFee')),
          ),

          GridColumn(
            columnName: 'subTotal',
            label: const Center(child: Text('Subtotal')),
          ),
          GridColumn(
            columnName: 'tip',
            label: const Center(child: Text('Tip')),
          ),
          GridColumn(
            columnName: 'extraAmount',
            label: const Center(child: Text('Rounded')),
          ),
          GridColumn(
            columnName: 'change',
            label: const Center(child: Text('Change')),
          ),
          GridColumn(
            columnName: 'totalOrderAmount',
            label: const Center(child: Text('Check\nAmount')),
          ),
          // GridColumn(
          //     columnName: 'refund', label: const Center(child: Text('Refund'))),
          // GridColumn(
          //     columnName: 'recall', label: const Center(child: Text('Recall'))),
        ],
      ),
    );
  }
}

class OrderDataSource extends DataGridSource {
  OrderDataSource(this.orders) {
    _orderData = orders.asMap().entries.map<DataGridRow>((entry) {
      final index = entry.key + 1; // Calculate the index (1-based)
      final order = entry.value;
      // bool isTakeout = orders.any((order) => order.orderType == "TAKEOUT");
      return DataGridRow(
        cells: [
          DataGridCell(columnName: 'no', value: index),
          DataGridCell(columnName: 'action', value: order),
          DataGridCell(columnName: 'tokenId', value: order.tokenId),
          DataGridCell(columnName: 'orderId', value: order.orderId),
          DataGridCell(columnName: 'orderType', value: order.orderType),
          DataGridCell(
            columnName: 'orderStatus',
            value: order.orderStatus.toLowerCase() == "canceled"
                ? "Cancelled"
                : order.orderStatus,
          ),

          // if (!isTakeout)
          DataGridCell(columnName: 'tableName', value: order.tableName.orNA()),
          DataGridCell(
            columnName: 'address',
            value: MyFunc.orNA(order.delivery?.address),
          ),

          DataGridCell(
            columnName: 'employeeName',
            value: MyFunc.orNA(order.employee?.firstName),
          ),
          DataGridCell(columnName: 'guestName', value: order.guestName),
          // if (!isTakeout)
          DataGridCell(
            columnName: 'numberOfPeople',
            value: order.numberOfPeople,
          ),

          DataGridCell(
            columnName: 'guestPhoneNumber',
            value: order.guestPhoneNumber.toFormattedPhone(),
          ),
          DataGridCell(
            columnName: 'createdAt',
            value: order.createdAt?.toStringAsSecondaryFormat(),
          ),
          DataGridCell(
            columnName: 'updatedAt',
            value: order.updatedAt?.toStringAsSecondaryFormat(),
          ),
          DataGridCell(
            columnName: 'aot',
            value: order.updatedAt!
                .difference(order.createdAt!)
                .formatDateDifference(),
          ),
          // if (isTakeout)
          DataGridCell(columnName: 'guestNotes', value: order.notes.orNA()),

          // DataGridCell(
          //     columnName: 'orderType',
          //     value: order.orderType.replaceAll("_", "-")),
          // if (isTakeout)
          DataGridCell(
            columnName: 'takeOutType',
            value: order.takeOutType?.replaceAll("_", "-").orNA(),
          ),
          DataGridCell(
            columnName: 'paymentProcessor',
            value: order.payment?.providerName.toCapitalizeEachWord(),
          ),
          DataGridCell(
            columnName: 'paymentMethod',
            value: order.payment?.methods.isNotEmpty == true
                ? (order.payment?.methods.join(', ').replaceAll('_', ' ') ??
                      'N/A')
                : order.payment?.method.isNotEmpty == true
                ? order.payment!.method
                : "N/A",
          ),
          // if (isTakeout)
          DataGridCell(
            columnName: 'packagingCost',
            value: order.packagingCost.toStringAsFixed(2),
          ),
          DataGridCell(
            columnName: 'totalDiscount',
            value: order.totalDiscount.toStringAsFixed(2),
          ),
          // if (!isTakeout)
          DataGridCell(
            columnName: 'totalGratuity',
            value: order.totalGratuity.toStringAsFixed(2),
          ),
          DataGridCell(
            columnName: 'totalGst',
            value: order.totalGst.toStringAsFixed(2),
          ),
          DataGridCell(
            columnName: 'totalPst',
            value: order.totalPst.toStringAsFixed(2),
          ),
          DataGridCell(
            columnName: 'totalPst2',
            value: order.totalPst2.toStringAsFixed(2),
          ),
          DataGridCell(
            columnName: 'maintenanceFee',
            value: order.maintenanceFee.toStringAsFixed(2),
          ),
          DataGridCell(
            columnName: 'deliveryFee',
            value: order.deliveryFee.toStringAsFixed(2),
          ),
          DataGridCell(
            columnName: 'subTotal',
            value: order.subTotal.toStringAsFixed(2),
          ),
          DataGridCell(columnName: 'tip', value: order.tip.toStringAsFixed(2)),
          DataGridCell(
            columnName: 'extraAmount',
            value: order.extraAmount == null
                ? (order.payment?.extraAmount ?? 0).toStringAsFixed(2)
                : order.extraAmount!.toStringAsFixed(2),
          ),
          DataGridCell(
            columnName: 'change',
            value: order.change.toStringAsFixed(2),
          ),
          DataGridCell(
            columnName: 'totalOrderAmount',
            value: order.totalOrderAmount.toStringAsFixed(2),
          ),
          // DataGridCell(columnName: 'refund', value: order.refund ? 'YES' : 'N/A'),
          // DataGridCell(columnName: 'recall', value: order.recall ? 'YES' : 'N/A'),
        ],
      );
    }).toList();
  }

  List<DataGridRow> _orderData = [];
  List<OrderModel> orders;

  @override
  List<DataGridRow> get rows => _orderData;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataCell) {
        if (dataCell.columnName == 'action') {
          final OrderModel order = dataCell.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 1.3,
                child: IconButton(
                  // onPressed: onPrint,
                  onPressed: () {
                    BaseController.to.playTapSound();
                    PopupDialog.customDialog(
                      color: Colors.white,
                      iconColor: Colors.black,
                      width: 435,
                      hasScroll: true,
                      child: PrintOrderDialog(order: order),
                    );
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.print,
                    size: 18,
                    color: StaticColors.greenColor,
                  ),
                ),
              ),
            ],
          );
        } else {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              dataCell.value.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
      }).toList(),
    );
  }
}
