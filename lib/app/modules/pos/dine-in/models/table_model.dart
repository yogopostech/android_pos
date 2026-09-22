// import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';

// class TableModel {
//   TableModel(
//       {required this.id,
//       required this.tableName,
//       required this.tableAvailability,
//       required this.tableCapacity,
//       this.currentOrderId,
//       this.employee,
//       this.currentOrder});

//   final String id;
//   final String tableName;
//   final String tableAvailability;
//   final int tableCapacity;
//   final String? currentOrderId;
//   final Employee? employee;
//   final OrderModel? currentOrder;
//   factory TableModel.fromJson(Map<String, dynamic> json) {
//     return TableModel(
//       id: json["id"] ?? "",
//       tableName: json["tableName"] ?? "",
//       tableAvailability: json["tableAvailability"] ?? "",
//       tableCapacity: json["tableCapacity"] ?? 0,
//       currentOrderId: json["currentOrderId"],
//       employee:
//           json["employee"] == null ? null : Employee.fromJson(json["employee"]),
//       currentOrder: json["currentOrder"] == null
//           ? null
//           : OrderModel.fromJson(json["currentOrder"]),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "tableName": tableName,
//         "tableAvailability": tableAvailability,
//         "tableCapacity": tableCapacity,
//         "currentOrderId": currentOrderId,
//         "employee": employee,
//       };
// }




import 'package:json_annotation/json_annotation.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';

part 'table_model.g.dart';

@JsonSerializable()
class TableModel {
  TableModel({
    required this.id,
    required this.tableName,
    required this.tableAvailability,
    required this.tableCapacity,
    this.currentOrderId,
    this.employee,
    this.currentOrder,
  });

  final String id;
  final String tableName;
  final String tableAvailability;
  final int tableCapacity;

  final String? currentOrderId;
  final Employee? employee;
  final OrderModel? currentOrder;

  factory TableModel.fromJson(Map<String, dynamic> json) =>
      _$TableModelFromJson(json);

  Map<String, dynamic> toJson() => _$TableModelToJson(this);
}