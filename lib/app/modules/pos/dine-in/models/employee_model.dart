import 'package:json_annotation/json_annotation.dart';
import 'package:yogo_pos/app/modules/clockIn/model/clock_model.dart';

part 'employee_model.g.dart';

enum ReportPeriod {
  @JsonValue('3m')
  last3Months,
  @JsonValue('6m')
  last6Months,
  @JsonValue('12m')
  last12Months,
}

@JsonSerializable()
class PosSummaryReportModel {
  PosSummaryReportModel({
    required this.enabled,
    required this.reportPeriod,
    required this.individualEmployeeReport,
    required this.paymentSummaryReport,
    required this.allEmployeesReport,
  });

  @JsonKey(defaultValue: false)
  final bool enabled;

  @JsonKey(defaultValue: ReportPeriod.last3Months)
  final ReportPeriod reportPeriod;

  @JsonKey(defaultValue: false)
  final bool individualEmployeeReport;

  @JsonKey(defaultValue: false)
  final bool paymentSummaryReport;

  @JsonKey(defaultValue: false)
  final bool allEmployeesReport;

  factory PosSummaryReportModel.fromJson(Map<String, dynamic> json) =>
      _$PosSummaryReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$PosSummaryReportModelToJson(this);
}

@JsonSerializable()
class EmployeeModel {
  EmployeeModel({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    required this.loginPin,
    required this.accessPin,
    required this.allowClockInOut,
    required this.posTimeSheetReport,
    required this.lastLoginAt,
    required this.id,
    required this.activeClock,
    this.posSummaryReport,
  });

  @JsonKey(defaultValue: "")
  final String email;

  @JsonKey(defaultValue: "")
  final String firstName;

  @JsonKey(defaultValue: "")
  final String lastName;

  @JsonKey(defaultValue: "")
  final String phone;

  @JsonKey(defaultValue: "")
  final String role;

  @JsonKey(defaultValue: 0)
  final int loginPin;

  @JsonKey(defaultValue: 0)
  final int accessPin;

  @JsonKey(defaultValue: false)
  final bool allowClockInOut;

  @JsonKey(defaultValue: false)
  final bool posTimeSheetReport;

  final PosSummaryReportModel? posSummaryReport;

  final DateTime? lastLoginAt;

  final ClockModel? activeClock;

  @JsonKey(defaultValue: "")
  final String id;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeModelToJson(this);
}
