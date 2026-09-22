// import 'package:flutter/material.dart';
// import 'package:yogo_pos/app/utils/urls.dart';
// import 'package:get/get.dart';
// import '../../../services/controller/base_controller.dart';
// import '../../../utils/logger.dart';
// import '../../subCategory/models/category_type_model.dart';
// import '../../subCategory/models/sub_category_model.dart';
// import '../models/add_product_model.dart';

// import '../repository/product_repo.dart';

// class ProductController extends GetxController {
//   static ProductController get to => Get.find();

//   TextEditingController nameTEC = TextEditingController();
//   TextEditingController priceTEC = TextEditingController();
//   TextEditingController descriptionTEC = TextEditingController();

//   var productList = <ProductModel>[].obs;
//   getProductList() async {
//     //     Map<String, dynamic> data = {
//     //   "title": titleController.text,
//     //   "type": selectedCategory // VEG, NON_VEG, DRINKS
//     // };
//     var res = await BaseController.to.apiService.dio.get(URLS.products);

//     if (res.statusCode == 200) {
//       productList.assignAll((res.data["data"] as List)
//           .map((e) => ProductModel.fromJson(e))
//           .toList());
//     }
//   }

//   CategoryTypeModel? selectedproductType;
//   updateSelectedProductType(CategoryTypeModel? value) {
//     selectedCategory = null;

//     selectedproductType = value;

//     filteredCategoryList.value = categoryList
//         .where(
//           (e) => e.type.toLowerCase() == value?.value.toLowerCase(),
//         )
//         .toList();
//     if (value?.title.toLowerCase() == 'drinks') {
//       isShowAlcohol = true;
//     } else {
//       isShowAlcohol = false;
//     }
//     update();
//   }

//   bool isShowAlcohol = false;

//   bool isProductAlcohol = false;
//   void updateIsProductAlcohol(bool? value) {
//     isProductAlcohol = value ?? false;
//     update();
//   }

//   var categoryList = <SubCategoryModel>[].obs;
//   var filteredCategoryList = <SubCategoryModel>[].obs;
//   getCategoryList() async {
//     //     Map<String, dynamic> data = {
//     //   "title": titleController.text,
//     //   "type": selectedCategory // VEG, NON_VEG, DRINKS
//     // };
//     try {
//       var res = await BaseController.to.apiService.dio.get(URLS.categories);

//       if (res.statusCode == 200) {
//         categoryList.assignAll((res.data["data"] as List)
//             .map((e) => SubCategoryModel.fromJson(e))
//             .toList());

//         kLogger.e(categoryList.length);
//       }
//     } catch (e) {
//       kLogger.e('Error from %%%% get category %%%% => $e');
//     }
//   }

//   SubCategoryModel? selectedCategory;
//   updateSelectedCategory(SubCategoryModel? value) {
//     selectedCategory = value;
//     update();
//   }

//   //======== VARIATIONS =======
//   bool hasVariation = false;
//   void updateHasVariation(bool? value) {
//     hasVariation = value ?? false;
//     if (!hasVariation) {
//       variationsList.clear();
//     } else {
//       addVariations();
//     }
//     update();
//   }

//   List<Variations> variationsList = [];
//   addVariations() {
//     if (variationsList.length < 10) {
//       variationsList.add(Variations());
//     }
//     update();
//   }

//   removeVariations(int index) {
//     variationsList.removeAt(index);
//     if (variationsList.isEmpty) {
//       hasVariation = false;
//     }
//     update();
//   }

//   addVariationOption(int variationIndex) {
//     if (variationsList[variationIndex].options.length < 10) {
//       variationsList[variationIndex].options.add(VariationOptions());
//     }

//     update();
//   }

//   removeVariationOption(int variationIndex, int optionIndex) {
//     variationsList[variationIndex].options.removeAt(optionIndex);
//     update();
//   }

//   addProduct() async {
//     List<AddVariation> vari = variationsList.map((v) {
//       return AddVariation(
//         name: v.nameTEC.text,
//         selcetionType: v.selectionType,
//         max: num.tryParse(v.maxPriceTEC.text) ?? 0,
//         min: num.tryParse(v.minPriceTEC.text) ?? 0,
//         isRequired: v.isRequired,
//         options: v.options
//             .map((e) => AddOption(
//                   name: e.nameTEC.text,
//                   price: num.tryParse(e.priceTEC.text) ?? 0,
//                 ))
//             .toList(),
//       );
//     }).toList();

//     AddProductModel product = AddProductModel(
//       name: nameTEC.text.trim(),
//       categoryId: selectedCategory?.id ?? '',
//       description: descriptionTEC.text.trim(),
//       isAlcohol: isProductAlcohol,
//       price: num.tryParse(priceTEC.text) ?? 0,
//       variations: vari,
//     );

//     bool isSuccess = await ProductRepo.addProduct(product);
//     if (isSuccess) {
//       getProductList();
//     }

//     kLogger.i(product);
//   }

//   @override
//   void onInit() {
//     getProductList();
//     getCategoryList();
//     super.onInit();
//   }
// }

// class Variations {
//   final TextEditingController nameTEC = TextEditingController();
//   final TextEditingController minPriceTEC = TextEditingController();
//   final TextEditingController maxPriceTEC = TextEditingController();
//   String selectionType = 'SINGLE';
//   bool isRequired = false;
//   List<VariationOptions> options = [VariationOptions()];

//   void updateIsRequired(bool? value) {
//     isRequired = value ?? false;
//     ProductController.to.update();
//   }

//   void updateSelectionType(String? value) {
//     selectionType = value ?? '';
//     ProductController.to.update();
//   }
// }

// class VariationOptions {
//   final TextEditingController nameTEC = TextEditingController();
//   final TextEditingController priceTEC = TextEditingController();
// }
