// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosSummaryReportModel _$PosSummaryReportModelFromJson(
  Map<String, dynamic> json,
) => PosSummaryReportModel(
  enabled: json['enabled'] as bool? ?? false,
  reportPeriod:
      $enumDecodeNullable(_$ReportPeriodEnumMap, json['reportPeriod']) ??
      ReportPeriod.last3Months,
  individualEmployeeReport: json['individualEmployeeReport'] as bool? ?? false,
  paymentSummaryReport: json['paymentSummaryReport'] as bool? ?? false,
  allEmployeesReport: json['allEmployeesReport'] as bool? ?? false,
);

Map<String, dynamic> _$PosSummaryReportModelToJson(
  PosSummaryReportModel instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'reportPeriod': _$ReportPeriodEnumMap[instance.reportPeriod]!,
  'individualEmployeeReport': instance.individualEmployeeReport,
  'paymentSummaryReport': instance.paymentSummaryReport,
  'allEmployeesReport': instance.allEmployeesReport,
};

const _$ReportPeriodEnumMap = {
  ReportPeriod.last3Months: '3m',
  ReportPeriod.last6Months: '6m',
  ReportPeriod.last12Months: '12m',
};

EmployeeModel _$EmployeeModelFromJson(Map<String, dynamic> json) =>
    EmployeeModel(
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? '',
      loginPin: (json['loginPin'] as num?)?.toInt() ?? 0,
      accessPin: (json['accessPin'] as num?)?.toInt() ?? 0,
      allowClockInOut: json['allowClockInOut'] as bool? ?? false,
      posTimeSheetReport: json['posTimeSheetReport'] as bool? ?? false,
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      id: json['id'] as String? ?? '',
      activeClock: json['activeClock'] == null
          ? null
          : ClockModel.fromJson(json['activeClock'] as Map<String, dynamic>),
      posSummaryReport: json['posSummaryReport'] == null
          ? null
          : PosSummaryReportModel.fromJson(
              json['posSummaryReport'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$EmployeeModelToJson(EmployeeModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'role': instance.role,
      'loginPin': instance.loginPin,
      'accessPin': instance.accessPin,
      'allowClockInOut': instance.allowClockInOut,
      'posTimeSheetReport': instance.posTimeSheetReport,
      'posSummaryReport': instance.posSummaryReport,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'activeClock': instance.activeClock,
      'id': instance.id,
    };
