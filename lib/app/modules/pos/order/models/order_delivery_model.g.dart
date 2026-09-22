// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_delivery_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDeliveryModel _$OrderDeliveryModelFromJson(Map<String, dynamic> json) =>
    OrderDeliveryModel(
      address: json['address'] as String,
      additionalDetails: json['additionalDetails'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$OrderDeliveryModelToJson(OrderDeliveryModel instance) =>
    <String, dynamic>{
      'address': instance.address,
      'additionalDetails': instance.additionalDetails,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
