// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryModel _$DeliveryModelFromJson(Map<String, dynamic> json) =>
    DeliveryModel(
      baseDeliveryFee: (json['baseDeliveryFee'] as num?)?.toDouble() ?? 0.0,
      perKmRate: (json['perKmRate'] as num?)?.toDouble() ?? 0.0,
      maxDeliveryDistanceKm:
          (json['maxDeliveryDistanceKm'] as num?)?.toInt() ?? 0,
      minimumOrderForFreeDelivery:
          (json['minimumOrderForFreeDelivery'] as num?)?.toInt() ?? 0,
      id: json['id'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$DeliveryModelToJson(DeliveryModel instance) =>
    <String, dynamic>{
      'baseDeliveryFee': instance.baseDeliveryFee,
      'perKmRate': instance.perKmRate,
      'maxDeliveryDistanceKm': instance.maxDeliveryDistanceKm,
      'minimumOrderForFreeDelivery': instance.minimumOrderForFreeDelivery,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'id': instance.id,
    };
