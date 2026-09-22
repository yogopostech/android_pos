// class MainCategoryModel {
//     MainCategoryModel({
//         required this.title,
//     });

//     final String title;

//     factory MainCategoryModel.fromJson(Map<String, dynamic> json){ 
//         return MainCategoryModel(
//             title: json["title"] ?? "",
//         );
//     }

//     Map<String, dynamic> toJson() => {
//         "title": title,
//     };

// }

import 'package:json_annotation/json_annotation.dart';

part 'main_category_model.g.dart';

@JsonSerializable()
class MainCategoryModel {
  MainCategoryModel({
    required this.title,
  });

  @JsonKey(defaultValue: "")
  final String title;

  factory MainCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$MainCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$MainCategoryModelToJson(this);
}