// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableCategoryModel _$TableCategoryModelFromJson(Map<String, dynamic> json) =>
    TableCategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      tableCategoryType: json['tableCategoryType'] as String? ?? '',
      tables:
          (json['tables'] as List<dynamic>?)
              ?.map((e) => TableModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$TableCategoryModelToJson(TableCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tableCategoryType': instance.tableCategoryType,
      'tables': instance.tables.map((e) => e.toJson()).toList(),
    };
