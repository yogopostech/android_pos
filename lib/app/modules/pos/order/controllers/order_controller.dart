import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/modules/pos/order/models/cashout_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/product_model.dart';
import 'package:yogo_pos/app/modules/pos/repo/order_repo.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class OrderController extends GetxController {
  static OrderController get to => Get.find();
  //** change page **
  PageController pageController = PageController();

  RxBool isShowOrders = true.obs;
  int? categoryId;

  // RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxInt selectedCategoryIndex = (-1).obs;
  void updateSelectedCategoryIndex(int value) {
    selectedCategoryIndex.value = value;
  }

  RxBool isProductPage = false.obs;

  //** Get all product **
  bool isLoadingProduct = false;
  List<ProductModel> productList = [];
  List<ProductModel> mainProductList = [];

  Future getProductList() async {
    //     Map<String, dynamic> data = {
    //   "title": titleController.text,
    //   "type": selectedCategory // VEG, NON_VEG, DRINKS
    // };
    var res = await BaseController.to.apiService.makeGetRequest(URLS.items);

    if (res.statusCode == 200) {
      mainProductList.assignAll(
        (res.data["data"] as List)
            .map((e) => ProductModel.fromJson(e))
            .toList(),
      );

      productList = [...mainProductList];
      update();
    }
  }

  // takeout cashout
  // DateRange dateRange = DateRange(DateTime.now(), DateTime.now());

  List<String> cashOutTypeList = [];
  String activeCashOutType = "";
  onChangeCashOutType(String value) {
    activeCashOutType = value;
    update();
  }

  CashoutModel? allCashOut;
  CashoutModel? takeOutCashOut;
  CashoutModel? dineInCashOut;
  CashoutModel? oloCashOut;
  CashoutModel? deliveryCashOut;

  Future<void> onCashOut() async {
    final futures = <Future>[];
    if (cashOutTypeList.contains("ALL")) {
      futures.add(getCashOut(URLS.allCashOut).then((v) => allCashOut = v));
    }
    if (cashOutTypeList.contains("DINE_IN")) {
      futures.add(
        getCashOut(URLS.dineInCashOut).then((v) => dineInCashOut = v),
      );
    }
    if (cashOutTypeList.contains("TAKEOUT")) {
      futures.add(
        getCashOut(URLS.takeoutCashOut).then((v) => takeOutCashOut = v),
      );
    }
    if (cashOutTypeList.contains("DELIVERY")) {
      futures.add(
        getCashOut(URLS.deliveryCashOut).then((v) => deliveryCashOut = v),
      );
    }
    if (cashOutTypeList.contains("ONLINE")) {
      futures.add(getCashOut(URLS.oloCashOut).then((v) => oloCashOut = v));
    }
    await Future.wait(futures);
    update();
  }

  Future<CashoutModel?> getCashOut(String url) async {
    final s = BaseController.to.dateRange.start;
    final e = BaseController.to.dateRange.end;

    Map<String, dynamic> param = {
      "startDate": DateFormat('yyyy-MM-dd').format(s),
      "endDate": DateFormat('yyyy-MM-dd').format(e),
      "startTime": DateFormat('HH:mm').format(s),
      "endTime": DateFormat('HH:mm').format(e),
    };
    try {
      var res = await BaseController.to.apiService.makeGetRequest(
        url,
        queryParameters: param,
      );

      if (res.statusCode == 200) {
        // print('Cashout data: ${res.data["data"]}');
        return CashoutModel.fromJson(res.data["data"]);
      }
      return null;
    } catch (e) {
      kLogger.e('Error from %%%% getTakeOutCashOut %%%% => $e');
      return null;
    }
  }

  //** find product by name**
  final searchController = TextEditingController();

  void findProductsByName(String name) async {
    // Log the lengths of the lists
    Logger().e("M=> ${mainProductList.length}");
    Logger().e("S=> ${productList.length}");

    // If the search name is empty, show the full main product list
    if (name.isEmpty) {
      productList.assignAll(mainProductList);
    } else {
      // Filter the products by name
      List<ProductModel> filteredProducts = mainProductList
          .where(
            (product) =>
                product.name.toLowerCase().contains(name.toLowerCase()),
          )
          .toList();

      Logger().d(name);

      // Assign the filtered products to the productList observable
      productList.assignAll(filteredProducts);
    }

    // Update the UI
    update();
  }

  //** find product categoryId**
  void findProductsByCategoryId(String categoryId) {
    List<ProductModel> filteredProducts = mainProductList
        .where((product) => product.subCategory == categoryId)
        .toList();
    if (filteredProducts.isEmpty) {
      productList = [];
    } else {
      productList.assignAll(filteredProducts);
    }
    searchController.clear();
    update();
  }

  @override
  void onInit() {
    searchController.addListener(
      () => findProductsByName(searchController.text),
    );
    cashOutTypeList = OrderRepo.myOrderTypes();
    if (cashOutTypeList.isNotEmpty) {
      activeCashOutType = cashOutTypeList.first;
    }
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
