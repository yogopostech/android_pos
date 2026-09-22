// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableModel _$TableModelFromJson(Map<String, dynamic> json) => TableModel(
  id: json['id'] as String,
  tableName: json['tableName'] as String,
  tableAvailability: json['tableAvailability'] as String,
  tableCapacity: (json['tableCapacity'] as num).toInt(),
  currentOrderId: json['currentOrderId'] as String?,
  employee: json['employee'] == null
      ? null
      : Employee.fromJson(json['employee'] as Map<String, dynamic>),
  currentOrder: json['currentOrder'] == null
      ? null
      : OrderModel.fromJson(json['currentOrder'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TableModelToJson(TableModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tableName': instance.tableName,
      'tableAvailability': instance.tableAvailability,
      'tableCapacity': instance.tableCapacity,
      'currentOrderId': instance.currentOrderId,
      'employee': instance.employee,
      'currentOrder': instance.currentOrder,
    };
