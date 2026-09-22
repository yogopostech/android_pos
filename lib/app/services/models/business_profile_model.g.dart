// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessProfileModel _$BusinessProfileModelFromJson(
  Map<String, dynamic> json,
) => BusinessProfileModel(
  legalName: json['legalName'] as String? ?? '',
  dbaName: json['DBAName'] as String? ?? '',
  phoneNumber: json['phoneNumber'] as String? ?? '',
  businessEmail: json['businessEmail'] as String? ?? '',
  businessAddress: json['businessAddress'] as String? ?? '',
  gstNumber: (json['GSTNumber'] as num?)?.toInt() ?? 0,
  pstNumber: (json['PSTNumber'] as num?)?.toInt() ?? 0,
  pstNumber2: (json['PSTNumber2'] as num?)?.toInt() ?? 0,
  gratuity: (json['gratuity'] as num?)?.toInt() ?? 0,
  country: json['country'] as String? ?? '',
  timeZone: json['timeZone'] as String? ?? '',
  currency: json['currency'] as String? ?? '',
  referralSource: json['referralSource'] as String? ?? '',
  notes: json['notes'] as String? ?? '',
  id: json['id'] as String? ?? '',
);

Map<String, dynamic> _$BusinessProfileModelToJson(
  BusinessProfileModel instance,
) => <String, dynamic>{
  'legalName': instance.legalName,
  'DBAName': instance.dbaName,
  'phoneNumber': instance.phoneNumber,
  'businessEmail': instance.businessEmail,
  'businessAddress': instance.businessAddress,
  'GSTNumber': instance.gstNumber,
  'PSTNumber': instance.pstNumber,
  'PSTNumber2': instance.pstNumber2,
  'gratuity': instance.gratuity,
  'country': instance.country,
  'timeZone': instance.timeZone,
  'currency': instance.currency,
  'referralSource': instance.referralSource,
  'notes': instance.notes,
  'id': instance.id,
};
