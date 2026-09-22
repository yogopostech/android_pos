// class MetaModel {
//     MetaModel({
//         required this.total,
//         required this.limit,
//         required this.currentPage,
//         required this.totalPages,
//         required this.hasNextPage,
//         required this.hasPreviousPage,
//     });

//     final int total;
//     final int limit;
//     final int currentPage;
//     final int totalPages;
//     final bool hasNextPage;
//     final bool hasPreviousPage;

//     factory MetaModel.fromJson(Map<String, dynamic> json){ 
//         return MetaModel(
//             total: json["total"] ?? 0,
//             limit: json["limit"] ?? 0,
//             currentPage: json["currentPage"] ?? 0,
//             totalPages: json["totalPages"] ?? 0,
//             hasNextPage: json["hasNextPage"] ?? false,
//             hasPreviousPage: json["hasPreviousPage"] ?? false,
//         );
//     }

// }

import 'package:json_annotation/json_annotation.dart';

part 'meta_model.g.dart'; 

@JsonSerializable()
class MetaModel {
  MetaModel({
    required this.total,
    required this.limit,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  @JsonKey(defaultValue: 0)
  final int total;

  @JsonKey(defaultValue: 0)
  final int limit;

  @JsonKey(defaultValue: 0)
  final int currentPage;

  @JsonKey(defaultValue: 0)
  final int totalPages;

  @JsonKey(defaultValue: false)
  final bool hasNextPage;

  @JsonKey(defaultValue: false)
  final bool hasPreviousPage;

  factory MetaModel.fromJson(Map<String, dynamic> json) =>
      _$MetaModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetaModelToJson(this);
}