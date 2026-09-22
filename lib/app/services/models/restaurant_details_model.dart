import 'package:json_annotation/json_annotation.dart';
import 'package:yogo_pos/app/services/models/restaurant_model.dart';

import 'business_profile_model.dart';

part 'restaurant_details_model.g.dart'; // <- file name onujayi change koro

@JsonSerializable(explicitToJson: true)
class RestaurantDetailsModel {
  RestaurantDetailsModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.role,
    required this.isVerified,
    required this.employeeClockInOut,
    required this.businessProfile,
    required this.restaurant,
    required this.lastLoginAt,
    required this.id,
    required this.printerSelectionMode,
  });

  @JsonKey(defaultValue: "")
  final String name;

  @JsonKey(defaultValue: "")
  final String email;

  @JsonKey(defaultValue: "")
  final String phone;

  @JsonKey(defaultValue: "")
  final String address;

  @JsonKey(defaultValue: "")
  final String status;

  @JsonKey(defaultValue: "")
  final String role;

  @JsonKey(defaultValue: false)
  final bool isVerified;

  @JsonKey(defaultValue: false)
  final bool employeeClockInOut;

  final BusinessProfileModel businessProfile;
  final RestaurantModel restaurant;
  final DateTime? lastLoginAt;

  @JsonKey(defaultValue: "")
  final String id;

  @JsonKey(defaultValue: "")
  final String printerSelectionMode;

  factory RestaurantDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantDetailsModelToJson(this);
}