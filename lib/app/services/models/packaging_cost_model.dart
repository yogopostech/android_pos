import 'package:json_annotation/json_annotation.dart';

part 'packaging_cost_model.g.dart';

@JsonSerializable()
class PackagingCostModel {
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: 0)
  final num cost;

  PackagingCostModel({
    required this.title,
    required this.cost,
  });

  factory PackagingCostModel.fromJson(Map<String, dynamic> json) =>
      _$PackagingCostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PackagingCostModelToJson(this);
}