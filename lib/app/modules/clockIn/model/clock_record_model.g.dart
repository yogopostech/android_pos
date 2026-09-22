// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClockRecordModel _$ClockRecordModelFromJson(Map<String, dynamic> json) =>
    ClockRecordModel(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      totalTime: (json['totalTime'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ClockRecordModelToJson(ClockRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'totalTime': instance.totalTime,
    };
