
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';

class TableMappingModel {
  final String user;
  final String tableId;
  final String tableType;
  final double left;
  final double top;
  final double scaleX;
  final double scaleY;
  final double angle;
  final String tableName;
  final int tableCapacity;
    final TableCategory tableCategory;
  final double tablePrice;
  final double bookingTime;
  final double width;
  final double height;
  final String fillColor;
  final String layoutId;
  final String arcType;
  final String status;
  final String tableAvailability;
  final dynamic customer;
  final Employee? employee;
  final OrderModel? currentOrder;
  final String id;

  TableMappingModel({
    required this.user,
    required this.tableId,
    required this.tableType,
    required this.left,
    required this.top,
    required this.scaleX,
    required this.scaleY,
    required this.angle,
    required this.tableName,
    required this.tableCapacity,
    required this.tableCategory,
    required this.tablePrice,
    required this.bookingTime,
    required this.width,
    required this.height,
    required this.fillColor,
    required this.layoutId,
    required this.arcType,
    required this.status,
    required this.tableAvailability,
    this.customer,
    this.employee,
    this.currentOrder,
    required this.id,
  });

  factory TableMappingModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    return TableMappingModel(
      user: json['user'] ?? '',
      tableId: json['tableId'] ?? '',
      tableType: json['tableType'] ?? '',
      left: toDouble(json['left']),
      top: toDouble(json['top']),
      scaleX: toDouble(json['scaleX']),
      scaleY: toDouble(json['scaleY']),
      angle: toDouble(json['angle']),
      tableName: json['tableName'] ?? '',
      tableCapacity: toInt(json['tableCapacity']),
        tableCategory: TableCategory.fromJson(json["tableCategory"] ?? {}),
      tablePrice: toDouble(json['tablePrice']),
      bookingTime: toDouble(json['bookingTime']),
      width: toDouble(json['width']),
      height: toDouble(json['height']),
      fillColor: json['fillColor'] ?? '',
      layoutId: json['layoutId'] ?? '',
      arcType: json['arcType'] ?? '',
      status: json['status'] ?? '',
      tableAvailability: json['tableAvailability'] ?? '',
      customer: json['customer'],
      employee:
      json["employee"] == null ? null : Employee.fromJson(json["employee"]),
      currentOrder: json["currentOrder"] == null
          ? null
          : OrderModel.fromJson(json["currentOrder"]),
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user,
    'tableId': tableId,
    'tableType': tableType,
    'left': left,
    'top': top,
    'scaleX': scaleX,
    'scaleY': scaleY,
    'angle': angle,
    'tableName': tableName,
    'tableCapacity': tableCapacity,
    "tableCategory": tableCategory.toJson(),
    'tablePrice': tablePrice,
    'bookingTime': bookingTime,
    'width': width,
    'height': height,
    'fillColor': fillColor,
    'layoutId': layoutId,
    'arcType': arcType,
    'status': status,
    'tableAvailability': tableAvailability,
    'customer': customer,
    'employee': employee,
    'currentOrder': currentOrder,
    'id': id,
  };
}

class TableCategory {
  final String name;
  final String tableCategoryType;
  final String id;

  const TableCategory({
    required this.name,
    required this.tableCategoryType,
    required this.id,
  });

  factory TableCategory.fromJson(Map<String, dynamic> json) {
    return TableCategory(
      name: json["name"] ?? '',
      tableCategoryType: json["tableCategoryType"] ?? '',
      id: json["id"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "tableCategoryType": tableCategoryType,
      "id": id,
    };
  }

}


class TableMappingModel1 {
  final String user;
  final String tableId;
  final String tableType;
  final double left;
  final double top;
  final double scaleX;
  final double scaleY;
  final double angle;
  final String tableName;
  final int tableCapacity;
  final String tableCategory;
  final double tablePrice;
  final double bookingTime;
  final double width;
  final double height;
  final String fillColor;
  final String layoutId;
  final String arcType;
  final String status;
  final String tableAvailability;
  final dynamic customer;
  final dynamic employee;
  final dynamic currentOrder;
  final String id;

  TableMappingModel1({
    required this.user,
    required this.tableId,
    required this.tableType,
    required this.left,
    required this.top,
    required this.scaleX,
    required this.scaleY,
    required this.angle,
    required this.tableName,
    required this.tableCapacity,
    required this.tableCategory,
    required this.tablePrice,
    required this.bookingTime,
    required this.width,
    required this.height,
    required this.fillColor,
    required this.layoutId,
    required this.arcType,
    required this.status,
    required this.tableAvailability,
    this.customer,
    this.employee,
    this.currentOrder,
    required this.id,
  });

  factory TableMappingModel1.fromJson(Map<String, dynamic> json) {
    return TableMappingModel1(
      user: json['user'] ?? '',
      tableId: json['tableId'] ?? '',
      tableType: json['tableType'] ?? '',
      left: (json['left'] as num).toDouble(),
      top: (json['top'] as num).toDouble(),
      scaleX: (json['scaleX'] as num).toDouble(),
      scaleY: (json['scaleY'] as num).toDouble(),
      angle: (json['angle'] as num).toDouble(),
      tableName: json['tableName'] ?? '',
      tableCapacity: json['tableCapacity'] ?? 0,
      tableCategory: json['tableCategory'] ?? '',
      tablePrice: (json['tablePrice'] as num).toDouble(),
      bookingTime: (json['bookingTime'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      fillColor: json['fillColor'] ?? '',
      layoutId: json['layoutId'] ?? '',
      arcType: json['arcType'] ?? '',
      status: json['status'] ?? '',
      tableAvailability: json['tableAvailability'] ?? '',
      customer: json['customer'],
      employee: json['employee'],
      currentOrder: json['currentOrder'],
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user,
    'tableId': tableId,
    'tableType': tableType,
    'left': left,
    'top': top,
    'scaleX': scaleX,
    'scaleY': scaleY,
    'angle': angle,
    'tableName': tableName,
    'tableCapacity': tableCapacity,
    'tableCategory': tableCategory,
    'tablePrice': tablePrice,
    'bookingTime': bookingTime,
    'width': width,
    'height': height,
    'fillColor': fillColor,
    'layoutId': layoutId,
    'arcType': arcType,
    'status': status,
    'tableAvailability': tableAvailability,
    'customer': customer,
    'employee': employee,
    'currentOrder': currentOrder,
    'id': id,
  };
}
