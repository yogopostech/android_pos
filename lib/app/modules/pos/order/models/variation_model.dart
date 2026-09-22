import 'package:yogo_pos/app/modules/pos/order/models/option_model.dart';

class VariationModel {
  VariationModel({
    required this.id,
    required this.name,
    required this.selectionType,
    required this.max,
    required this.min,
    required this.required,
    required this.posVariationOn,
    required this.options,
  });

  final String id;
  final String name;
  final String selectionType;
  final int max;
  final int min;
  final bool required;
  final bool posVariationOn;
  List<OptionModel> options;

  factory VariationModel.fromJson(Map<String, dynamic> json) {
    return VariationModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      selectionType: json["selectionType"] ?? "",
      max: json["max"] ?? 0,
      min: json["min"] ?? 0,
      required: json["required"] ?? false,
      posVariationOn: json["posVariationOn"] ?? false,
      options: json["options"] == null
          ? []
          : List<OptionModel>.from(
              json["options"]!.map((x) => OptionModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "selectionType": selectionType,
        "max": max,
        "min": min,
        "required": required,
        "posVariationOn": posVariationOn,
        "options": options.map((x) => x.toJson()).toList(),
      };
  VariationModel copyWith({
    String? id,
    String? name,
    String? selectionType,
    int? max,
    int? min,
    bool? required,
    bool? posVariationOn,
    List<OptionModel>? options,
  }) {
    return VariationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      selectionType: selectionType ?? this.selectionType,
      max: max ?? this.max,
      min: min ?? this.min,
      required: required ?? this.required,
      posVariationOn: posVariationOn ?? this.posVariationOn,
      options: options ?? this.options,
    );
  }
}
