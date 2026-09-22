import 'package:json_annotation/json_annotation.dart';

part 'delivery_model.g.dart';

@JsonSerializable()
class DeliveryModel {
  @JsonKey(defaultValue: 0.0)
  final double baseDeliveryFee;
  @JsonKey(defaultValue: 0.0)
  final double perKmRate;
  @JsonKey(defaultValue: 0)
  final int maxDeliveryDistanceKm;
  @JsonKey(defaultValue: 0)
  final int minimumOrderForFreeDelivery;
  @JsonKey(defaultValue: 0.0)
  final double latitude;
  @JsonKey(defaultValue: 0.0)
  final double longitude;
  @JsonKey(defaultValue: '')
  final String id;

  DeliveryModel({
    required this.baseDeliveryFee,
    required this.perKmRate,
    required this.maxDeliveryDistanceKm,
    required this.minimumOrderForFreeDelivery,
    required this.id,
    required this.latitude,
    required this.longitude,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryModelToJson(this);
}