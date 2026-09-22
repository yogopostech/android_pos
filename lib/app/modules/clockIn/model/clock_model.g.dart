// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClockModel _$ClockModelFromJson(Map<String, dynamic> json) => ClockModel(
  clockIn: json['clockIn'] == null
      ? null
      : DateTime.parse(json['clockIn'] as String),
  clockOut: json['clockOut'] == null
      ? null
      : DateTime.parse(json['clockOut'] as String),
  startBreak: json['startBreak'] == null
      ? null
      : DateTime.parse(json['startBreak'] as String),
  endBreak: json['endBreak'] == null
      ? null
      : DateTime.parse(json['endBreak'] as String),
  id: json['id'] as String,
);

Map<String, dynamic> _$ClockModelToJson(ClockModel instance) =>
    <String, dynamic>{
      'clockIn': instance.clockIn?.toIso8601String(),
      'clockOut': instance.clockOut?.toIso8601String(),
      'startBreak': instance.startBreak?.toIso8601String(),
      'endBreak': instance.endBreak?.toIso8601String(),
      'id': instance.id,
    };
