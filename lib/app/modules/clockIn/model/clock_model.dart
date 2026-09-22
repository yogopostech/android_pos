import 'package:json_annotation/json_annotation.dart';

part 'clock_model.g.dart'; 

@JsonSerializable()
class ClockModel {
  ClockModel({
    required this.clockIn,
    required this.clockOut,
    required this.startBreak,
    required this.endBreak,
    required this.id,
  });

  final DateTime? clockIn;
  final DateTime? clockOut;
  final DateTime? startBreak;
  final DateTime? endBreak;
  final String id;

  factory ClockModel.fromJson(Map<String, dynamic> json) =>
      _$ClockModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClockModelToJson(this);
}