import 'package:json_annotation/json_annotation.dart';

part 'order_status_model.g.dart'; 

@JsonSerializable()
class OrderStatusModel {
  OrderStatusModel({
    required this.status,
    required this.count,
  });

  @JsonKey(defaultValue: "")
  final String status;

  @JsonKey(defaultValue: 0)
  final int count;

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatusModelToJson(this);
}