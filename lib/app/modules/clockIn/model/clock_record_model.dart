import 'package:json_annotation/json_annotation.dart';

part 'clock_record_model.g.dart';

@JsonSerializable()
class ClockRecordModel {
  ClockRecordModel({
    required this.id,
    required this.startDate,
    this.endDate,
    this.totalTime
  });
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int? totalTime;

  factory ClockRecordModel.fromJson(Map<String, dynamic> json) =>
      _$ClockRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClockRecordModelToJson(this);
}