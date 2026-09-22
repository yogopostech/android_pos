import 'package:json_annotation/json_annotation.dart';

part 'terminals_model.g.dart';

enum MonerisEnv {
  @JsonValue('prod')
  prod,
  @JsonValue('qa')
  qa,
}

@JsonSerializable(explicitToJson: true)
class TerminalsModel {
  TerminalsModel({
    required this.storeId,
    required this.storeName,
    required this.merchantId,
    required this.apiToken,
    required this.istConfigCode,
    required this.terminalIds,
    required this.deviceType,
    this.environment = MonerisEnv.prod,
  });

  @JsonKey(defaultValue: "")
  final String storeId;

  @JsonKey(defaultValue: "")
  final String storeName;

  @JsonKey(defaultValue: "")
  final String merchantId;

  @JsonKey(defaultValue: "")
  final String apiToken;

  @JsonKey(defaultValue: "")
  final String istConfigCode;

  @JsonKey(defaultValue: [])
  final List<TerminalId> terminalIds;

  @JsonKey(defaultValue: "")
  final String deviceType;

  @JsonKey(defaultValue: MonerisEnv.prod)
  final MonerisEnv environment;

  factory TerminalsModel.fromJson(Map<String, dynamic> json) =>
      _$TerminalsModelFromJson(json);

  Map<String, dynamic> toJson() => _$TerminalsModelToJson(this);
}

@JsonSerializable()
class TerminalId {
  TerminalId({
    required this.terminalId,
    required this.status,
    this.id = "",
  });

  @JsonKey(defaultValue: "")
  final String terminalId;

  @JsonKey(defaultValue: "")
  final String status;

  @JsonKey(defaultValue: "")
  final String id;

  factory TerminalId.fromJson(Map<String, dynamic> json) =>
      _$TerminalIdFromJson(json);

  Map<String, dynamic> toJson() => _$TerminalIdToJson(this);
}
