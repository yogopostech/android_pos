class ModifierModel {
  ModifierModel({
    required this.name,
    required this.selectionType,
    required this.options,
    required this.priority,
    required this.id,
  });

  final String name;
  final String selectionType;
  List<OptionModifiers> options;
  final int priority;
  final String id;

  factory ModifierModel.fromJson(Map<String, dynamic> json) {
    return ModifierModel(
      name: json["name"] ?? "",
      selectionType: json["selectionType"] ?? "",
      options: json["options"] == null
          ? []
          : List<OptionModifiers>.from(
              json["options"]!.map((x) => OptionModifiers.fromJson(x))),
      priority: json["priority"] ?? 0,
      id: json["id"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "selectionType": selectionType,
        "options": options.map((x) => x.toJson()).toList(),
        "priority": priority,
        "id": id,
      };
}

class OptionModifiers {
  OptionModifiers({
    required this.title,
    required this.id,
  });

  final String title;
  final String id;

  factory OptionModifiers.fromJson(Map<String, dynamic> json) {
    return OptionModifiers(
      title: json["title"] ?? "",
      id: json["id"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "id": id,
      };
}


// import 'package:json_annotation/json_annotation.dart';

// part 'modifier_model.g.dart';

// @JsonSerializable(explicitToJson: true)
// class ModifierModel {
//   ModifierModel({
//     required this.name,
//     required this.selectionType,
//     required this.options,
//     required this.priority,
//     required this.id,
//   });

//   @JsonKey(defaultValue: "")
//   final String name;

//   @JsonKey(defaultValue: "")
//   final String selectionType;

//   @JsonKey(defaultValue: [])
//   List<OptionModifiers> options;

//   @JsonKey(defaultValue: 0)
//   final int priority;

//   @JsonKey(defaultValue: "")
//   final String id;

//   factory ModifierModel.fromJson(Map<String, dynamic> json) =>
//       _$ModifierModelFromJson(json);

//   Map<String, dynamic> toJson() => _$ModifierModelToJson(this);
// }

// @JsonSerializable()
// class OptionModifiers {
//   OptionModifiers({
//     required this.title,
//     required this.id,
//   });

//   @JsonKey(defaultValue: "")
//   final String title;

//   @JsonKey(defaultValue: "")
//   final String id;

//   factory OptionModifiers.fromJson(Map<String, dynamic> json) =>
//       _$OptionModifiersFromJson(json);

//   Map<String, dynamic> toJson() => _$OptionModifiersToJson(this);
// }