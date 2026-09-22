class OptionModel {
  OptionModel({
    required this.id,
    required this.variationOptionId,
    required this.name,
    required this.price,
    required this.isQuantityOn,
    required this.quantity,
    required this.maxQuantity,
    required this.isSelected,
  });

  final String id;
  final String variationOptionId;
  final String name;
  final num price;
  final bool isQuantityOn;
  final num quantity;
  final num maxQuantity;
  final bool isSelected;

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json["id"] ?? "id",
      variationOptionId: json["variationOptionId"] ?? json["id"],
      name: json["name"] ?? "",
      price: json["price"] ?? 0,
      isQuantityOn: json["isQuantityOn"] ?? false,
      quantity: json["quantity"] ?? 0,
      maxQuantity: json["maxQuantity"] ?? 0,
      isSelected: false,
    );
  }

  Map<String, dynamic> toJson() => {
        "variationOptionId": variationOptionId,
        "name": name,
        "price": price,
        "isQuantityOn": isQuantityOn,
        "quantity": quantity,
        "maxQuantity": maxQuantity,
      };
  OptionModel copyWith({
    String? id,
    String? variationOptionId,
    String? name,
    num? price,
    bool? isQuantityOn,
    num? quantity,
    num? maxQuantity,
    bool? isSelected,
  }) {
    return OptionModel(
      id: id ?? this.id,
      variationOptionId: variationOptionId ?? this.variationOptionId,
      name: name ?? this.name,
      price: price ?? this.price,
      isQuantityOn: isQuantityOn ?? this.isQuantityOn,
      quantity: quantity ?? this.quantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
