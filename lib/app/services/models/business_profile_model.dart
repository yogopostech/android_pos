import 'package:json_annotation/json_annotation.dart';

part 'business_profile_model.g.dart';

@JsonSerializable()
class BusinessProfileModel {
  @JsonKey(defaultValue: '')
  final String legalName;
  @JsonKey(name: 'DBAName', defaultValue: '')
  final String dbaName;
  @JsonKey(defaultValue: '')
  final String phoneNumber;
  @JsonKey(defaultValue: '')
  final String businessEmail;
  @JsonKey(defaultValue: '')
  final String businessAddress;
  @JsonKey(name: 'GSTNumber', defaultValue: 0)
  final int gstNumber;
  @JsonKey(name: 'PSTNumber', defaultValue: 0)
  final int pstNumber;
  @JsonKey(name: 'PSTNumber2', defaultValue: 0)
  final int pstNumber2;
  @JsonKey(defaultValue: 0)
  final int gratuity;
  @JsonKey(defaultValue: '')
  final String country;
  @JsonKey(defaultValue: '')
  final String timeZone;
  @JsonKey(defaultValue: '')
  final String currency;
  @JsonKey(defaultValue: '')
  final String referralSource;
  @JsonKey(defaultValue: '')
  final String notes;
  @JsonKey(defaultValue: '')
  final String id;

  BusinessProfileModel({
    required this.legalName,
    required this.dbaName,
    required this.phoneNumber,
    required this.businessEmail,
    required this.businessAddress,
    required this.gstNumber,
    required this.pstNumber,
    required this.pstNumber2,
    required this.gratuity,
    required this.country,
    required this.timeZone,
    required this.currency,
    required this.referralSource,
    required this.notes,
    required this.id,
  });

  factory BusinessProfileModel.fromJson(Map<String, dynamic> json) =>
      _$BusinessProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessProfileModelToJson(this);
}
