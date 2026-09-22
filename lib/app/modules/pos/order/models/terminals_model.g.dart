// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminals_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TerminalsModel _$TerminalsModelFromJson(Map<String, dynamic> json) =>
    TerminalsModel(
      storeId: json['storeId'] as String? ?? '',
      storeName: json['storeName'] as String? ?? '',
      merchantId: json['merchantId'] as String? ?? '',
      apiToken: json['apiToken'] as String? ?? '',
      istConfigCode: json['istConfigCode'] as String? ?? '',
      terminalIds:
          (json['terminalIds'] as List<dynamic>?)
              ?.map((e) => TerminalId.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      deviceType: json['deviceType'] as String? ?? '',
      environment:
          $enumDecodeNullable(_$MonerisEnvEnumMap, json['environment']) ??
          MonerisEnv.prod,
    );

Map<String, dynamic> _$TerminalsModelToJson(TerminalsModel instance) =>
    <String, dynamic>{
      'storeId': instance.storeId,
      'storeName': instance.storeName,
      'merchantId': instance.merchantId,
      'apiToken': instance.apiToken,
      'istConfigCode': instance.istConfigCode,
      'terminalIds': instance.terminalIds.map((e) => e.toJson()).toList(),
      'deviceType': instance.deviceType,
      'environment': _$MonerisEnvEnumMap[instance.environment]!,
    };

const _$MonerisEnvEnumMap = {MonerisEnv.prod: 'prod', MonerisEnv.qa: 'qa'};

TerminalId _$TerminalIdFromJson(Map<String, dynamic> json) => TerminalId(
  terminalId: json['terminalId'] as String? ?? '',
  status: json['status'] as String? ?? '',
  id: json['id'] as String? ?? '',
);

Map<String, dynamic> _$TerminalIdToJson(TerminalId instance) =>
    <String, dynamic>{
      'terminalId': instance.terminalId,
      'status': instance.status,
      'id': instance.id,
    };
