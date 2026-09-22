// import 'dart:convert';

// AddProductModel addProductModelFromJson(String str) =>
//     AddProductModel.fromJson(json.decode(str));

// Map<String, dynamic> addProductModelToJson(AddProductModel data) =>
//     data.toJson();

// class AddProductModel {
//   AddProductModel({
//     required this.name,
//     required this.categoryId,
//     required this.description,
//     required this.isAlcohol,
//     required this.price,
//     required this.variations,
//   });

//   final String name;
//   final String categoryId;
//   final String description;
//   final num price;
//   final bool isAlcohol;
//   final List<AddVariation> variations;

//   factory AddProductModel.fromJson(Map<String, dynamic> json) {
//     return AddProductModel(
//       name: json["name"] ?? "",
//       categoryId: json["categoryId"] ?? "",
//       description: json["description"] ?? "",
//       price: json["price"] ?? 0,
//       isAlcohol: json["isAlcohol"] ?? 0,
//       variations: json["variations"] == null
//           ? []
//           : List<AddVariation>.from(
//               json["variations"]!.map((x) => AddVariation.fromJson(x))),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "categoryId": categoryId,
//         "description": description,
//         "price": price,
//         "isAlcohol": isAlcohol,
//         "variations": List<dynamic>.from(variations.map((x) => x.toJson())),
//       };

//   @override
//   String toString() {
//     return " $name, $description, $price, $isAlcohol, $categoryId, $variations, ";
//   }
// }

// class AddVariation {
//   AddVariation({
//     required this.name,
//     required this.selcetionType,
//     required this.max,
//     required this.min,
//     required this.isRequired,
//     required this.options,
//   });

//   final String name;
//   final String selcetionType;
//   final num max;
//   final num min;
//   final bool isRequired;
//   final List<AddOption> options;

//   factory AddVariation.fromJson(Map<String, dynamic> json) {
//     return AddVariation(
//       name: json["name"] ?? "",
//       selcetionType: json["selcetionType"] ?? "",
//       max: json["max"] ?? 0,
//       min: json["min"] ?? 0,
//       isRequired: json["required"] ?? false,
//       options: json["options"] == null
//           ? []
//           : List<AddOption>.from(
//               json["options"]!.map((x) => AddOption.fromJson(x))),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "selcetionType": selcetionType,
//         "min": min,
//         "max": max,
//         "required": isRequired,
//         "options": List<dynamic>.from(options.map((x) => x.toJson())),
//       };

//   @override
//   String toString() {
//     return " $name, $selcetionType, $min, $max, $isRequired, $options, ";
//   }
// }

// class AddOption {
//   AddOption({
//     required this.name,
//     required this.price,
//   });

//   final String name;
//   final num price;

//   factory AddOption.fromJson(Map<String, dynamic> json) {
//     return AddOption(
//       name: json["name"] ?? "",
//       price: json["price"] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "price": price,
//       };

//   @override
//   String toString() {
//     return "$name, $price";
//   }
// }
