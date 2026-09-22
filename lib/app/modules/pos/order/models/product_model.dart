import 'package:yogo_pos/app/modules/pos/order/models/variation_model.dart';

class ProductModel {
  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.status,
    required this.subCategory,
    required this.mainCategory,
    required this.branch,
    required this.itemType,
    required this.category,
    this.printers = const [],
    this.priority =0,
    required this.variations,
    this.isCustomProduct = false,
    this.isLiquor = false,
  });

  final String id;
  final String name;
  final String description;
  final num price;
  final int priority ;
  final String status;
  final bool isCustomProduct;
  final bool isLiquor;
  final String subCategory;
  final String itemType;
  final String category;
  final List<String> printers;
  final String mainCategory;
  final String branch;
  final List<VariationModel> variations;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      price: json["price"] ?? 0,
      priority: json["priority"] ?? 0,
      status: json["status"] ?? "",
      subCategory: json["subCategory"] ?? "",
      mainCategory: json["mainCategory"] ?? "",
      itemType: json["itemType"] ?? "",
      category: json["category"] ?? "",
      isCustomProduct: json["isCustomProduct"] ?? false,
      isLiquor: json["isLiquor"] ?? false,
      branch: json["branch"] ?? "",
      printers: json["printers"] == null
          ? []
          : List<String>.from(json["printers"]!.map((x) => x)),
      variations: json["variations"] == null
          ? []
          : List<VariationModel>.from(
              json["variations"]!.map((x) => VariationModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "priority": priority,
        "status": status,
        "subCategory": subCategory,
        "mainCategory": mainCategory,
        "isCustomProduct": isCustomProduct,
        "isLiquor": isLiquor,
        "itemType": itemType,
        "category": category,
        "printers": printers,
        "branch": branch,
        "variations": variations.map((x) => x.toJson()).toList(),
      };
        ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    num? price,
    String? status,
    String? subCategory,
    String? mainCategory,
    String? branch,
    String? itemType,
    String? category,
    List<String>? printers,
    List<VariationModel>? variations,
    bool? isCustomProduct,
    bool? isLiquor,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      status: status ?? this.status,
      subCategory: subCategory ?? this.subCategory,
      mainCategory: mainCategory ?? this.mainCategory,
      branch: branch ?? this.branch,
      itemType: itemType ?? this.itemType,
      category: category ?? this.category,
      printers: printers ?? this.printers,
      variations: variations ?? List<VariationModel>.from(this.variations),
      isCustomProduct: isCustomProduct ?? this.isCustomProduct,
      isLiquor: isLiquor ?? this.isLiquor,
    );
  }
}


