// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packaging_cost_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackagingCostModel _$PackagingCostModelFromJson(Map<String, dynamic> json) =>
    PackagingCostModel(
      title: json['title'] as String? ?? '',
      cost: json['cost'] as num? ?? 0,
    );

Map<String, dynamic> _$PackagingCostModelToJson(PackagingCostModel instance) =>
    <String, dynamic>{'title': instance.title, 'cost': instance.cost};
