// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantDetailsModel _$RestaurantDetailsModelFromJson(
  Map<String, dynamic> json,
) => RestaurantDetailsModel(
  name: json['name'] as String? ?? '',
  email: json['email'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  address: json['address'] as String? ?? '',
  status: json['status'] as String? ?? '',
  role: json['role'] as String? ?? '',
  isVerified: json['isVerified'] as bool? ?? false,
  employeeClockInOut: json['employeeClockInOut'] as bool? ?? false,
  businessProfile: BusinessProfileModel.fromJson(
    json['businessProfile'] as Map<String, dynamic>,
  ),
  restaurant: RestaurantModel.fromJson(
    json['restaurant'] as Map<String, dynamic>,
  ),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  id: json['id'] as String? ?? '',
  printerSelectionMode: json['printerSelectionMode'] as String? ?? '',
);

Map<String, dynamic> _$RestaurantDetailsModelToJson(
  RestaurantDetailsModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'address': instance.address,
  'status': instance.status,
  'role': instance.role,
  'isVerified': instance.isVerified,
  'employeeClockInOut': instance.employeeClockInOut,
  'businessProfile': instance.businessProfile.toJson(),
  'restaurant': instance.restaurant.toJson(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'id': instance.id,
  'printerSelectionMode': instance.printerSelectionMode,
};
