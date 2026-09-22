import 'package:json_annotation/json_annotation.dart';

part 'order_delivery_model.g.dart';

@JsonSerializable()
class OrderDeliveryModel {
  OrderDeliveryModel({
    required this.address,
    required this.additionalDetails,
    required this.latitude,
    required this.longitude,
  });

  String address;
  String additionalDetails;
  double latitude;
  double longitude;

  factory OrderDeliveryModel.fromJson(Map<String, dynamic> json) =>
      _$OrderDeliveryModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDeliveryModelToJson(this);
}
