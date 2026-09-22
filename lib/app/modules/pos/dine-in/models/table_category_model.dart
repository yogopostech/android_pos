// import 'package:yogo_pos/app/modules/pos/dine-in/models/table_model.dart';

// class TableCategoryModel {
//   TableCategoryModel({
//     required this.id,
//     required this.name,
//     required this.tableCategoryType,
//     required this.tables,
//   });

//   final String id;
//   final String name;
//   final String tableCategoryType;
//   final List<TableModel> tables;

//   factory TableCategoryModel.fromJson(Map<String, dynamic> json) {
//     return TableCategoryModel(
//       id: json["id"] ?? "",
//       name: json["name"] ?? "",
//       tableCategoryType: json["tableCategoryType"] ?? "",
//       tables: json["tables"] == null
//           ? []
//           : List<TableModel>.from(
//               json["tables"]!.map((x) => TableModel.fromJson(x))),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "tableCategoryType": tableCategoryType,
//         "tables": tables.map((x) => x.toJson()).toList(),
//       };
// }
import 'package:json_annotation/json_annotation.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/models/table_model.dart';

part 'table_category_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TableCategoryModel {
  TableCategoryModel({
    required this.id,
    required this.name,
    required this.tableCategoryType,
    required this.tables,
  });

  @JsonKey(defaultValue: "")
  final String id;

  @JsonKey(defaultValue: "")
  final String name;

  @JsonKey(defaultValue: "")
  final String tableCategoryType;

  @JsonKey(defaultValue: [])
  final List<TableModel> tables;

  factory TableCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$TableCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$TableCategoryModelToJson(this);
}