class CategoryModel {
    CategoryModel({
        required this.title,
        required this.mainCategory,
        required this.id,
    });

    final String title;
    final String mainCategory;
    final String id;

    factory CategoryModel.fromJson(Map<String, dynamic> json){ 
        return CategoryModel(
            title: json["title"] ?? "",
            mainCategory: json["mainCategory"] ?? "",
            id: json["id"] ?? "",
        );
    }

    Map<String, dynamic> toJson() => {
        "title": title,
        "mainCategory": mainCategory,
        "id": id,
    };

}