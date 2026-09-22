// ignore_for_file: constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/helper/discount_type.dart';
import 'package:yogo_pos/app/modules/auth/controllers/auth_controller.dart';
import 'package:yogo_pos/app/modules/pos/delivery/controllers/delivery_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/controllers/dine_in_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_order_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/kitchen_print.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/models/category_and_item.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/models/employee_model.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/models/table_mapping_management_model.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/models/table_model.dart';
import 'package:yogo_pos/app/modules/pos/onlineOrder/controllers/online_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/category_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/discount_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/option_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_delivery_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/product_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/terminals_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/variation_model.dart';
import 'package:yogo_pos/app/modules/pos/takeout/controllers/takeout_controller.dart';
import 'package:yogo_pos/app/routes/app_pages.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/modules/pos/repo/pos_repo.dart';
import 'package:yogo_pos/app/utils/extension/order_extention.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/moneris_dialog.dart';
import '../../../widgets/popup_dialogs.dart';
import '../order/models/modifier_model.dart';

class PosController extends GetxController {
  static PosController get to => Get.find();
  BaseController baseController = Get.find<BaseController>();
  // for table number
  TextEditingController tableController = TextEditingController();
  TextEditingController guestController = TextEditingController();
  TextEditingController guestNameController = TextEditingController();
  TextEditingController guestPhoneController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController additionalDetailsController = TextEditingController();
  double? selectedLat;
  double? selectedLon;

  //scrollController
  final ScrollController itemScrollController = ScrollController();
  final ScrollController categoryScrollController = ScrollController();
  final ScrollController modifierScrollController = ScrollController();

  void scrollHomePage() {
    scrollToTop(itemScrollController);
    scrollToTop(categoryScrollController);
    scrollToTop(modifierScrollController);
    itemTypeActiveIndex = -1;
    itemCayegoryActiveIndex = -1;
    productList.assignAll(mainProductList);
    productsForShow.assignAll(productList);
  }

  void scrollToBottom(
    ScrollController controller, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) {
    if (!controller.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: duration,
        curve: curve,
      );
    });
  }

  void scrollToTop(
    ScrollController controller, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) {
    if (!controller.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;
      controller.animateTo(
        controller.position.minScrollExtent,
        duration: duration,
        curve: curve,
      );
    });
  }

  bool isTableReadOnly = false;
  bool isGuestReadOnly = false;
  bool isGuestNameReadOnly = false;
  bool isGuestPhoneReadOnly = false;

  onReadOnlyAllCartTextField() {
    isTableReadOnly = true;
    isGuestReadOnly = true;
    isGuestNameReadOnly = true;
    isGuestPhoneReadOnly = true;
    update();
  }

  onEditableAllCartTextField() {
    isTableReadOnly = false;
    isGuestReadOnly = false;
    isGuestNameReadOnly = false;
    isGuestPhoneReadOnly = false;
    update();
  }

  // for Focus
  final FocusNode totalAmountFocusNode = FocusNode();
  final FocusNode guestNameFocusNode = FocusNode();
  final FocusNode tableFocusNode = FocusNode();
  final FocusNode guestFocusNode = FocusNode();
  final FocusNode guestPhoneFocusNode = FocusNode();
  final FocusNode notesFocusNode = FocusNode();
  final FocusNode addressFocusNode = FocusNode();
  final FocusNode additionalDetailsFocusNode = FocusNode();

  //search Focus
  final FocusNode searchFocusNode = FocusNode();

  bool isUpdateView = false;

  // main order type
  List<String> orderTypeList = [];
  String orderType = "";

  onChangeOrderType(String value) {
    orderType = value;
    myOrder.orderType = value;
    update();
  }

  // Take-out type
  List<String> takeOutTypeList = ["PHONE", "WALK_IN", "ONLINE"];
  String takeOutType = "WALK_IN";
  int takeOutActiveIndex = 0;
  onChangetakeOutType(int index) {
    takeOutActiveIndex = index;
    takeOutType = takeOutTypeList[index];
    update();
  }

  setTakeOutTypeIndexAndValue(String type) {
    if (type.isNotEmpty) {
      takeOutType = type;
      takeOutActiveIndex = takeOutTypeList.indexOf(type);
    }
  }

  void changeFocusToGuest() {
    Future.delayed(const Duration(seconds: 1), () {
      tableFocusNode.unfocus();
      guestNameFocusNode.unfocus();
      FocusScope.of(Get.context!).requestFocus(guestFocusNode);
    });
  }

  void onFocusGuestName() {
    // tableFocusNode.unfocus();
    // guestFocusNode.unfocus();
    // Future.delayed(const Duration(seconds: 1), () {
    //   Get.focusScope?.requestFocus(guestNameFocusNode);
    // });
  }

  TableModel? currentTable;
  void updateTableName(TableModel table, {bool isUpdateView = false}) async {
    String oldTableName = myOrder.tableName;
    currentTable = table;

    tableController = TextEditingController(text: table.tableName);
    myOrder.table = table.id;
    myOrder.tableName = table.tableName;
    // Todo : need to delete it
    if (isUpdateView) {
      if (oldTableName != table.tableName) {
        await onUpdateOrderItems(
          myOrder.id,
          table: table.id,
          tableName: table.tableName,
        );
        // if (isUpdated) {
        //   kitchenPrint(myOrder, title: oldTableName, isTableChange: true);
        // }
      } else {
        kLogger.e("Table is not change");
      }
    }
    oldTableName = "";
    changeFocusToGuest();
    AppKeyboard.open(
      Get.context!,
      keyboardType: KeyboardType.numeric,
      controller: guestController,
      focusNode: guestFocusNode,
    );

    update();
  }

  // ** items view or category view **
  bool isItemsShow = false;
  void changeItemsView() {
    final bool newValue = !isItemsShow;
    searchController.clear();
    isItemsShow = newValue;
    update();
  }

  //** change page **
  late PageController pageController;
  RxBool isShowPos = false.obs;
  onchangePage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 3),
      curve: Curves.ease,
    );
    if (index == 0) {
      isShowPos.value = false;
    } else {
      isShowPos.value = true;
    }
  }

  RxBool isShowOrders = true.obs;
  int? categoryId;

  // RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxInt selectedCategoryIndex = (-1).obs;
  void updateSelectedCategoryIndex(int value) {
    selectedCategoryIndex.value = value;
  }

  RxBool isProductPage = false.obs;
  // ! category and item filter
  List<CategoryType> categoryTypeList = [
    CategoryType(color: StaticColors.greenColor, title: "All"),
    CategoryType(color: StaticColors.greenColor, title: "Food"),
    CategoryType(color: StaticColors.blueColor, title: "Drinks"),
    CategoryType(color: StaticColors.greenColor, title: "Dessert"),
    CategoryType(color: StaticColors.orangeColor, title: "groceries/meat"),
  ];
  int categoryTypeActiveIndex = 0;
  List<String> itemTypeList = [];

  int itemTypeActiveIndex = -1;
  int itemCayegoryActiveIndex = -1;
  // get main and sub category
  var categoryList = <CategoryModel>[];
  var mainCategoryList = <CategoryModel>[];
  RxBool isLoadingCategory = false.obs;

  Future getCategoryList() async {
    try {
      var res = await BaseController.to.apiService.makeGetRequest(
        URLS.posCategories,
      );
      if (res.statusCode == 200) {
        // ! category
        mainCategoryList.assignAll(
          (res.data["data"]["category"] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList(),
        );

        categoryList = [...mainCategoryList];
        update();
      }
    } catch (e) {
      kLogger.e('Error from %%%% get category %%%% => $e');
    }
  }

  void filterCategoriesByMainCategory() {
    String mainCategory = categoryTypeList[categoryTypeActiveIndex].title
        .toLowerCase();

    if (mainCategory.toLowerCase() == "all") {
      categoryList = [...mainCategoryList];
    } else {
      categoryList = mainCategoryList
          .where(
            (category) => category.mainCategory.toLowerCase() == mainCategory,
          )
          .toList();
    }
  }

  //** find product by name**
  final searchController = TextEditingController();
  // find order by check number, phone number and guest name
  final searchOrderController = TextEditingController();

  // search check Lisr
  // get all order list for search
  List<OrderModel> searchOrderList = [];
  bool isSearchOrderLoading = false;

  getSearchCheckList({String? search}) async {
    Map<String, dynamic>? queryParameters = {
      "orderType": "TAKEOUT",
      "limit": 20,
      if (search != null) "search": search,
      "takeoutType": "WALK_IN",
    };
    try {
      isSearchOrderLoading = true;
      update();
      var res = await BaseController.to.apiService.makeGetRequest(
        URLS.orders,
        queryParameters: queryParameters,
      );
      isSearchOrderLoading = false;
      update();

      if (res.statusCode == 200) {
        searchOrderList.assignAll(
          (res.data["data"] as List)
              .map((e) => OrderModel.fromJson(e))
              .toList(),
        );
        update();
      }
    } catch (e) {
      kLogger.e('Error from %%%% Get orders for export OrderStatus %%%% => $e');
    }
  }

  //** Get all product **
  bool isLoadingProduct = false;
  List<ProductModel> mainProductList = [];
  List<ProductModel> productList = [];
  List<ProductModel> productsForShow = [];

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
      productsForShow = [...mainProductList];
      update();
    }
  }

  void findProductsByName(String name) async {
    isItemsShow = true;
    categoryTypeActiveIndex = 0;
    itemTypeActiveIndex = -1;
    itemCayegoryActiveIndex = -1;
    filterCategoriesByMainCategory();
    if (name.isEmpty) {
      productList.assignAll(mainProductList);
      productsForShow.assignAll(productList);
    } else {
      // Filter the products by name
      List<ProductModel> filteredProducts = mainProductList
          .where(
            (product) =>
                product.name.toLowerCase().contains(name.toLowerCase()),
          )
          .toList();
      // Assign the filtered products to the productList observable
      productList.assignAll(filteredProducts);
      productsForShow.assignAll(productList);
    }
    // Update the UI
    update();
  }

  TableMappingModel? curentTable1;
  void updateTableName1(
    TableMappingModel table, {
    bool isUpdateView = false,
  }) async {
    String oldTableName = myOrder.tableName;
    curentTable1 = table;

    tableController = TextEditingController(text: table.tableName);
    myOrder.table = table.id;
    myOrder.tableName = table.tableName;
    // Todo : need to delete it
    if (isUpdateView) {
      if (oldTableName != table.tableName) {
        bool isUpdated = await onUpdateOrderItems(
          myOrder.id,
          table: table.id,
          tableName: table.tableName,
        );
        if (isUpdated) {
          kitchenPrint(myOrder, title: oldTableName, isTableChange: true);
        }
      } else {
        kLogger.e("Table is not change");
      }
    }
    oldTableName = "";
    AppKeyboard.open(
      Get.context!,
      keyboardType: KeyboardType.numeric,
      controller: guestController,
      focusNode: guestFocusNode,
    );
    changeFocusToGuest();
    update();
  }

  void findCategoriesByName(String name) async {
    Logger().e("M=> ${mainProductList.length}");
    // Logger().e("S=> ${productList.length}");

    // If the search name is empty, show the full main product list
    if (name.isEmpty) {
      categoryList.assignAll(mainCategoryList);
    } else {
      // Filter the products by name
      List<CategoryModel> filteredCategoryList = mainCategoryList
          .where(
            (product) =>
                product.title.toLowerCase().contains(name.toLowerCase()),
          )
          .toList();

      // Assign the filtered products to the productList observable
      categoryList.assignAll(filteredCategoryList);
    }

    // Update the UI
    update();
  }

  //** find product categoryId**
  String currentCategoryId = "";
  String currentCategoryType = "";
  void findProductsByCategoryId(String categoryId) {
    itemTypeActiveIndex = -1;
    currentCategoryId = categoryId;

    List<ProductModel> filteredProducts = mainProductList
        .where((product) => product.category == categoryId)
        .toList();
    if (filteredProducts.isEmpty) {
      productList = [];
      productsForShow.assignAll(productList);
    } else {
      productList.assignAll(filteredProducts);
      productsForShow.assignAll(productList);
    }
    searchController.clear();
    update();
  }

  void findProductsBytype(String type) {
    // itemTypeActiveIndex = -1;
    List<ProductModel> filteredProducts = productList
        .where(
          (product) => product.itemType.toLowerCase() == type.toLowerCase(),
        )
        .toList();
    if (filteredProducts.isEmpty) {
      productsForShow = [];
    } else {
      productsForShow.assignAll(filteredProducts);
      // productList.assignAll(filteredProducts);
    }

    // searchController.clear();
    update();
  }

  TextEditingController kitchenNoteTEC = TextEditingController();
  void addKitchenNote() {
    if (selectedItemList.length == 1) {
      // Find the index of the selected cart
      int cartIndex = myOrder.carts.indexWhere(
        (c) => c.id == selectedItemList.first,
      );

      if (cartIndex != -1) {
        // Update the found cart's kitchen note
        myOrder.carts[cartIndex] = myOrder.carts[cartIndex].copyWith(
          kitchenNote: kitchenNoteTEC.text.trim(),
        );
        update();
        kitchenNoteTEC.clear();
      } else {
        // Handle error: cart not found
        debugPrint("Cart not found for ID: ${selectedItemList.first}");
      }
    } else if (selectedItemList.isEmpty) {
      myOrder.carts.last.kitchenNote = kitchenNoteTEC.text.trim();
      update();
      cartListScrollToBottom();
      kitchenNoteTEC.clear();
    }
  }

  void resetModifierSelections() {
    orderQuantity = 1;
    selectedProductVariationValue = null;
    kitchenNoteTEC.clear();
    update();
  }

  bool hasVariations = false;
  void checkHasVariations(List<VariationModel> variations) {
    if (variations.isEmpty) {
      hasVariations = false;
    } else {
      hasVariations = true;
      productVariations = variations;
    }
  }

  List<VariationModel> productVariations = [];
  int? selectedProductVariationValue;
  void setSelectedProductVariationValue(int index) {
    selectedProductVariationValue = index;
    update();
  }

  int orderQuantity = 1;
  num orderTotalPrice = 0;
  void updateOrderQuantity(bool isIncrease, num price) {
    if (isIncrease && orderQuantity < 10) {
      orderQuantity++;
      orderTotalPrice = price * orderQuantity;
      update();
    } else if (!isIncrease && orderQuantity > 1) {
      orderQuantity--;
      orderTotalPrice = price / orderQuantity;
      update();
    }
  }

  //** Order Process **ff
  // **======+=======**
  //** Order Process **

  // zubair ==== + +++++++
  // zubair ==== + +++++++
  OrderModel myOrder = OrderModel();

  onPlaseOrder({
    String orderStatus = "CONFIRMED",
    String paymentStatus = "UNPAID",
    bool isPrint = true,
    bool isMonerisPay = false,
    bool isElavonPay = false,
    bool isSendOrder = false,
    required bool isDirectPay,
  }) async {
    // moneris terminal id
    String? terminalId;
    if (isMonerisPay) {
      final match = terminals?.terminalIds.firstWhereOrNull(
        (t) => t.terminalId == Preferences.terminalId,
      );

      terminalId = match?.id;

      if (terminalId == null || terminalId.isEmpty) {
        PopupDialog.showErrorMessage("Moneris Terminal is not set.");
        return;
      }
    }
    // !for DINE_IN
    DineInOrderController.to.clearOrderField();
    if (orderType == "DINE_IN") {
      if (guestPhoneController.text.isNotEmpty &&
          10 > guestPhoneController.text.length) {
        PopupDialog.showErrorMessage("The phone number should be 10");
      } else if (guestController.text.isEmpty) {
        PopupDialog.showErrorMessage("Guest Number is required");
      } else if (tableController.text.isEmpty) {
        PopupDialog.showErrorMessage("Table No. required");
      } else if (myOrder.carts.isEmpty) {
        PopupDialog.showErrorMessage("Add an item");
      } else {
        myOrder.orderId = MyFunc.generateRandomNumericId().toString();
        myOrder.orderType = orderType;
        myOrder.takeOutType = null;
        myOrder.notes = "";
        myOrder.orderStatus = orderStatus;
        myOrder.paymentStatus = paymentStatus;
        myOrder.delivery = null;
        try {
          PopupDialog.showLoadingDialog();
          var res = await BaseController.to.apiService.makePostRequest(
            isMonerisPay
                ? URLS.monerisPlaceOrder(terminalId!)
                : URLS.placeOrder,
            myOrder.toJson(),
          );

          if (res.statusCode == 201) {
            myOrder = OrderModel.fromJson(res.data["data"]);

            if (!isMonerisPay) {
              PopupDialog.closeLoadingDialog();
              if (isPrint) {
                if (isDirectPay) {
                  await PrintUtils().directPrint(
                    data: escOrderPrintReceipt(order: myOrder),
                    printer: Preferences.counterPrinter,
                  );
                } else {
                  kitchenPrint(myOrder);
                }
              } else if (isElavonPay) {
                monerisDialog(
                  status: PurchaseDialogStatus.success,
                  message: "transaction approved".toUpperCase(),
                  order: myOrder,
                );
              }
              clearCartList();
              PopupDialog.showSuccessDialog(res.data["message"], width: 300);
            }
            if (Preferences.fireAndLogout) {
              AuthController.to.isShowSplashScreen.value = false;
              Get.offAllNamed(Routes.AUTH);
              Future.delayed(Duration(milliseconds: 1300), () {
                Get.delete<PosController>(force: true);
              });
            } else {
              DataUpdateHelper.getApiCallForDineIn();
            }
          } else if (res.statusCode == 400 || res.statusCode == 406) {
            myOrder.payment = null;
            PopupDialog.closeLoadingDialog();
            PopupDialog.showErrorMessage(res.data["message"]);
          }
        } catch (e) {
          myOrder.payment = null;
          PopupDialog.closeLoadingDialog();
          kLogger.e('Error from %%%% Plase order %%%% => $e');
        }
      }

      // !for TakeOut
    } else if (orderType == "TAKEOUT") {
      if (myOrder.carts.isEmpty) {
        PopupDialog.showErrorMessage("Add an item");
      } else {
        myOrder.orderId = MyFunc.generateRandomNumericId().toString();
        myOrder.orderType = orderType;
        myOrder.takeOutType = takeOutType;
        myOrder.orderStatus = orderStatus;
        myOrder.notes = notesController.text;
        myOrder.table = null;
        myOrder.tableName = "";
        myOrder.delivery = null;
        // myOrder.tableId = null;
        myOrder.paymentStatus = paymentStatus;

        try {
          PopupDialog.showLoadingDialog();
          var res = await BaseController.to.apiService.makePostRequest(
            isMonerisPay
                ? URLS.monerisPlaceOrder(terminalId!)
                : URLS.placeOrder,
            myOrder.toJson(),
          );

          if (res.statusCode == 201) {
            if (!isMonerisPay) {
              PopupDialog.closeLoadingDialog();
              myOrder = OrderModel.fromJson(res.data["data"]);

              if (isPrint) {
                if (isDirectPay) {
                  await PrintUtils().directPrint(
                    data: escOrderPrintReceipt(order: myOrder),
                    printer: Preferences.counterPrinter,
                  );
                } else {
                  kitchenPrint(myOrder);
                }
              } else if (isElavonPay) {
                monerisDialog(
                  status: PurchaseDialogStatus.success,
                  message: "transaction approved".toUpperCase(),
                  order: myOrder,
                );
              }
              if (Preferences.takeoutCustomerReceipt && isSendOrder) {
                await PrintUtils().directPrint(
                  data: escOrderPrintReceipt(order: myOrder),
                  printer: Preferences.counterPrinter,
                );
              }

              clearCartList();
              PopupDialog.showSuccessDialog(res.data["message"], width: 300);
            }
            if (Preferences.fireAndLogout) {
              AuthController.to.isShowSplashScreen.value = false;
              Get.offAllNamed(Routes.AUTH);
              Future.delayed(Duration(milliseconds: 1300), () {
                Get.delete<PosController>(force: true);
              });
            } else {
              DataUpdateHelper.getApiCallForTakeout();
            }
          } else if (res.statusCode == 400 || res.statusCode == 406) {
            myOrder.payment = null;
            PopupDialog.closeLoadingDialog();
            PopupDialog.showErrorMessage(res.data["message"]);
          }
        } catch (e) {
          myOrder.payment = null;
          PopupDialog.closeLoadingDialog();
          kLogger.e('Error from %%%% plase order (Takeout) %%%% => $e');
        }
      }
    } else if (orderType == "DELIVERY") {
      if (myOrder.carts.isEmpty) {
        PopupDialog.showErrorMessage("Add an item");
      } else if (addressController.text.isEmpty) {
        PopupDialog.showErrorMessage("Address is required");
      } else if (guestNameController.text.isEmpty) {
        PopupDialog.showErrorMessage("Guest Name is required");
      } else if (guestPhoneController.text.isEmpty) {
        PopupDialog.showErrorMessage("Guest Phone is required");
      } else {
        myOrder.orderId = MyFunc.generateRandomNumericId().toString();
        myOrder.orderType = orderType;
        myOrder.takeOutType = null;
        myOrder.notes = notesController.text;
        myOrder.orderStatus = orderStatus;
        myOrder.paymentStatus = paymentStatus;
        myOrder.table = null;
        myOrder.tableName = "";
        if (selectedLat == null && selectedLon == null) {
          PopupDialog.showErrorMessage(
            "Delivery address coordinates are missing.",
          );
          return;
        }

        myOrder.delivery = OrderDeliveryModel(
          address: addressController.text,
          additionalDetails: additionalDetailsController.text,
          latitude: selectedLat!,
          longitude: selectedLon!,
        );

        try {
          PopupDialog.showLoadingDialog();
          var res = await BaseController.to.apiService.makePostRequest(
            isMonerisPay
                ? URLS.monerisPlaceOrder(terminalId!)
                : URLS.placeOrder,
            myOrder.toJson(),
          );

          if (res.statusCode == 201) {
            myOrder = OrderModel.fromJson(res.data["data"]);
            if (!isMonerisPay) {
              PopupDialog.closeLoadingDialog();
              if (isPrint) {
                if (isDirectPay) {
                  await PrintUtils().directPrint(
                    data: escOrderPrintReceipt(order: myOrder),
                    printer: Preferences.counterPrinter,
                  );
                } else {
                  kitchenPrint(myOrder);
                }
              } else if (isElavonPay) {
                monerisDialog(
                  status: PurchaseDialogStatus.success,
                  message: "transaction approved".toUpperCase(),
                  order: myOrder,
                );
              }
              if (Preferences.deliveryPosCustomerReceipt && isSendOrder) {
                PrintUtils().directPrint(
                  data: escOrderPrintReceipt(order: myOrder),
                  printer: Preferences.counterPrinter,
                );
              }
              clearCartList();
              PopupDialog.showSuccessDialog(res.data["message"], width: 300);
            }
            if (Preferences.fireAndLogout) {
              AuthController.to.isShowSplashScreen.value = false;
              Get.offAllNamed(Routes.AUTH);
              Future.delayed(Duration(milliseconds: 1300), () {
                Get.delete<PosController>(force: true);
              });
            } else {
              DataUpdateHelper.getApiCallForDeliveryOrder();
            }
          } else if (res.statusCode == 400 || res.statusCode == 406) {
            myOrder.payment = null;
            PopupDialog.closeLoadingDialog();
            PopupDialog.showErrorMessage(res.data["message"]);
          }
        } catch (e) {
          myOrder.payment = null;
          PopupDialog.closeLoadingDialog();
          kLogger.e('Error from %%%% plase order (Takeout) %%%% => $e');
        }
      }
    }
  }

  List<ModifierModel> modifiers = [];
  Future getModifiers() async {
    try {
      var res = await BaseController.to.apiService.makeGetRequest(
        URLS.modifiers,
      );

      if (res.statusCode == 200) {
        modifiers.assignAll(
          (res.data["data"] as List)
              .map((e) => ModifierModel.fromJson(e))
              .toList(),
        );
        update();
      }
    } catch (e) {
      kLogger.e('Error from %%%% get all Modifiers %%%% => $e');
    }
  }

  List<String> selectedModifiers = [];

  void singleSelect(String modifier) {
    if (selectedModifiers.contains(modifier)) {
      selectedModifiers.remove(modifier);
    } else {
      selectedModifiers.add(modifier);
    }
    myOrder.carts.last.modifiers = List.from(selectedModifiers);
    // Update the order's modifiers
    update(); // Notify state changes
  }

  void multiSelect(String modifier) {
    if (selectedModifiers.contains(modifier)) {
      selectedModifiers.remove(modifier); // Deselect if already selected
    } else {
      selectedModifiers.add(modifier); // Select the new option
    }
    myOrder.carts.last.modifiers = List.from(
      selectedModifiers,
    ); // Update the order's modifiers
    update(); // Notify state changes
  }

  String? cartId;
  // int? cartIndex;
  CartModel? cart;
  void editModifier(
    String modifierItemId,
    String newModifierTitle,
    String modifierId,
  ) {
    if (selectedItemList.isEmpty) {
      kLogger.e('No carts selected.');
      return;
    }
    // Only edit the first selected cart
    String firstCartId = selectedItemList.first;

    cart = myOrder.carts.firstWhere(
      (c) => c.id == firstCartId,
      orElse: () => throw Exception("Cart not found for ID: $firstCartId"),
    );
    //  Ensure modifiers list exists and is modifiable
    cart?.modifiers ?? [];
    cart?.modifiers = List<String>.from(
      cart!.modifiers,
    ); // THIS FIXES YOUR ERROR
    selectedModifiers = List.from(cart!.modifiers);

    //  Get the modifier group (ModifierModel)
    ModifierModel? mod = modifiers.firstWhere(
      (m) => m.id == modifierId,
      orElse: () => throw Exception("Modifier not found: $modifierId"),
    );

    if (mod.selectionType == "MULTIPLE") {
      // MULTIPLE: toggle add/remove
      if (cart!.modifiers.contains(newModifierTitle)) {
        selectedModifiers.remove(newModifierTitle);
      } else {
        selectedModifiers.add(newModifierTitle);
      }
    } else {
      // SINGLE: toggle on double click
      List<String> titlesInGroup = mod.options
          .map((option) => option.title)
          .toList();

      bool isAlreadySelected = selectedModifiers.contains(newModifierTitle);

      // Remove all existing options from that modifier group
      selectedModifiers.removeWhere((item) => titlesInGroup.contains(item));

      if (!isAlreadySelected) {
        // Add if it wasn’t already selected
        selectedModifiers.add(newModifierTitle);
      } else {
        // Don’t add again = user double-clicked to deselect
        kLogger.e("Deselected SINGLE modifier: $newModifierTitle");
      }
    }
    cart!.modifiers = List.from(selectedModifiers);
    update(); // Trigger UI refresh or state management update
  }

  void clearModifier() {
    selectedModifiers.clear(); // Clear all selected modifiers
    update(); // Notify state changes
  }

  // ** Update order
  Future<bool> onUpdateOrder(String id, {bool isClearList = false}) async {
    try {
      var res = await BaseController.to.apiService.makePatchRequest(
        "${URLS.orders}/$id",
        myOrder.toJson(),
      );
      if (res.statusCode == 200) {
        if (isClearList) {
          clearCartList();
          onEditableAllCartTextField();
          update();
        } else {
          myOrder = OrderModel.fromJson(res.data["data"]);
          DineInOrderController.to.getAllOrders(
            orderStatus: DineInOrderController.to.selectedOrderStatus.isEmpty
                ? null
                : DineInOrderController.to.selectedOrderStatus,
          );
          DineInOrderController.to.getOrderStatus();
          update();
        }
        PopupDialog.showSuccessDialog(res.data["message"]);
        update();

        return true;
      } else {
        PopupDialog.showErrorMessage(res.data["message"]);
        return false;
      }
    } catch (e) {
      kLogger.e('Error from %%%% update order %%%% => $e');
      return false;
    }
  }

  // ** Update  with order type
  Future<bool> onUpdateOrderWithOrderType(
    String id, {
    bool isClearList = false,
  }) async {
    try {
      var res = await BaseController.to.apiService.makePatchRequest(
        "${URLS.changeOrderType}/$id",
        myOrder.toJson(),
      );
      // print("delivery: ${myOrder.delivery!.toJson()}");
      if (res.statusCode == 200) {
        // var data = OrderModel.fromJson(res.data["data"]);
        // print(
        //   "delivery2: ${data.delivery == null ? "Null" : data.delivery!.toJson()}",
        // );
        if (isClearList) {
          clearCartList();

          onEditableAllCartTextField();
          update();
        } else {
          myOrder = OrderModel.fromJson(res.data["data"]);
          OnlineOrderController.to.getUnPaidOrders();
          TakeOutController.to.getAllTakeOutUnPaidOrders();
          DeliveryController.to.getAllDeliveryUnPaidOrders();
          update();
        }
        PopupDialog.showSuccessDialog(res.data["message"]);
        update();

        return true;
      } else {
        PopupDialog.showErrorMessage(res.data["message"]);
        return false;
      }
    } catch (e) {
      kLogger.e('Error from %%%% update order %%%% => $e');
      return false;
    }
  }

  // ** update order items
  Future<bool> onUpdateOrderItems(
    String id, {
    String? table,
    String? tableName,
    String? orderStatus,
    String? paymentStatus,
    String? employeeId,
    String? notes,
    bool? refund,
    bool? isVoid,
    int? declineAttempt,
  }) async {
    Map<String, dynamic>? data = {
      if (orderStatus != null) "orderStatus": orderStatus,
      if (orderStatus != null) "orderStatus": orderStatus,
      if (paymentStatus != null) "paymentStatus": paymentStatus,
      if (employeeId != null) "employeeId": employeeId,
      if (tableName != null) "tableName": tableName,
      if (table != null) "table": table,
      if (notes != null) "notes": notes,
      if (refund != null) "refund": refund,
      if (isVoid != null) "isVoid": isVoid,
      if (declineAttempt != null) "declineAttempt": declineAttempt,
    };
    try {
      var res = await BaseController.to.apiService.makePatchRequest(
        "${URLS.orders}/$id",
        data,
      );

      if (res.statusCode == 200) {
        kLogger.i("Update Order Response => ${res.data}");
        myOrder = OrderModel.fromJson(res.data["data"]);
        DineInOrderController.to.getAllOrders(
          orderStatus: DineInOrderController.to.selectedOrderStatus.isEmpty
              ? null
              : DineInOrderController.to.selectedOrderStatus,
        );
        DineInOrderController.to.getOrderStatus();
        update();
        return true;
      }
      PopupDialog.showErrorMessage(res.data["message"]);
      return false;
    } catch (e) {
      kLogger.e('Error from %%%% update order %%%% => $e');
      return false;
    }
  }

  //** Add cart item  **
  onAddCartItem(CartModel item) {
    if (orderType == "DINE_IN") {
      onRemovePackagingCost();
    } else {
      onAddPackagingCost();
    }
    // myOrder.carts.add(item.copyWith(
    //   printers: item.printers.toRoutedPrinter(),
    // ));
    myOrder.carts.add(item);
    calculateTotalPrice();
    //scroll listview to end
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartListScrollController.animateTo(
        cartListScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    update();
  }

  //** Remove cart item with index **
  // bool isEditableItems = true;
  onRemoveCartItemWithIndex(int index) {
    // Check if the index is within bounds
    if (index >= 0 && index < myOrder.carts.length) {
      myOrder.carts.removeAt(index);
    }
    calculateTotalPrice();
    update();
  }

  //** Quantity Update **
  void quantityUpdateWithCartListIndex(int index, num quantity) {
    myOrder.carts[index].quantity = quantity;
    calculateTotalPrice();
    update();
  }

  // gratuity Percentage
  void onDeleteGratuity() {
    myOrder.gratuityPercentage = 0;
    calculateTotalPrice();
  }

  // delete delivery fee
  void onDeleteDeliveryFee() {
    myOrder.deliveryFee = 0;
    calculateTotalPrice();
  }

  void onChangeGratuity(int percentage) {
    myOrder.gratuityPercentage = percentage;
    debugPrint(myOrder.gratuityPercentage.toString());
    calculateTotalPrice();
  }

  void onChangeDeliveryFee(num fee) {
    myOrder.deliveryFee = fee;
    calculateTotalPrice();
  }

  // order type change
  void onChangeDeliveryToTakeout() async {
    try {
      PopupDialog.showLoadingDialog();
      myOrder.delivery = null;
      myOrder = myOrder.copyWith(orderType: "TAKEOUT", deliveryFee: 0);
      calculateTotalPrice();
      await onUpdateOrderWithOrderType(myOrder.id);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      PopupDialog.closeLoadingDialog();
    }
  }

  onAddPackagingCost() {
    myOrder.packagingCost =
        BaseController.to.restaurantDetails?.restaurant.packagingCost.cost ?? 0;
    calculateTotalPrice();
    update();
  }

  onRemovePackagingCost() {
    myOrder.packagingCost = 0;
    calculateTotalPrice();
    update();
  }

  calculateTotalPrice() {
    myOrder = PosRepo.recalculateOrderPrice(myOrder);
    update();

  }

  /// ==== Discount ======
  List percentageDiscountList = [5, 10, 15, 20, 25, 30, 40];
  List amountDiscountList = [5, 10, 15, 20, 25, 30, 40];
  RxInt passwordLength = 6.obs;
  List<String> numberList = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0",
    ".",
    "X",
  ];
  List<String> selectedItemList = [];
  onChangeSelectedItemList(String id, {bool isLongPress = false}) {
    if (isLongPress) {
      selectedItemList.clear();
      selectedItemList.add(id);
    } else {
      if (selectedItemList.contains(id)) {
        selectedItemList.remove(id);
      } else {
        selectedItemList.add(id);
      }
    }
    if (kDebugMode) {
      debugPrint("Selected Items: $selectedItemList");
    }
    update();
  }

  void toggleAllSelectedItem() {
    if (selectedItemList.isNotEmpty) {
      selectedItemList.clear();
    } else {
      selectedItemList = myOrder.carts.map((cart) => cart.id).toList();
    }
    kLogger.e(selectedItemList);
    update();
  }

  //  ! +++++++++ Remove Items +++++++++
  Future removeAllSelectedItems({bool isUpdateView = true}) async {
    if (selectedItemList.isNotEmpty) {
      if (!isUpdateView) {
        myOrder = myOrder.removeSelectedItemsByIds(selectedItemList);
        selectedItemList.clear();
        await calculateTotalPrice();
        update();
        return;
      }
      var removedOrder = myOrder.filterCartsByIds(selectedItemList);
      myOrder = myOrder.removeSelectedItemsByIds(selectedItemList);

      // **** for print *****
      kitchenPrint(
        removedOrder,
        isCheckCanceled: true,
        title: "${removedOrder.carts.length > 1 ? 'Items' : 'Item'} CANCELLED",
        receipt: 1,
      );

      selectedItemList.clear();
      await calculateTotalPrice();
      onUpdateOrder(myOrder.id);
      update();
    }
    update();
  }

  repeatOrder(OrderModel order, {bool isCleanItem = false}) {
    // print("Repeat Order: ${order.toJson()}");
    final currentRoute = Get.currentRoute;
    if (currentRoute != '/pos') {
      Get.until((route) => route.settings.name == '/pos');
    }
    clearCartList();
    // check page
    if (pageController.page != 0) {
      pageController.jumpToPage(0);
    }
    myOrder = OrderModel(
      takeOutType: "WALK_IN",
      deliveryFee: order.deliveryFee,

      carts: isCleanItem
          ? []
          : order.carts.map((c) => c.copyWith(isUpdated: false)).toList(),
    );
    // print(myOrder.toJson());
    // print("XXXXX");
    // print(myOrder.payment!.cardPaidAmount);
    onChangeOrderType(order.orderType);
    // setTakeOutTypeIndexAndValue(order.takeOutType ?? "");

    guestController.text = '1';
    tableController.text = "";
    guestNameController.text = order.guestName;
    guestPhoneController.text = order.guestPhoneNumber;
    notesController.text = order.notes;

    selectedLat = order.delivery?.latitude;
    selectedLon = order.delivery?.longitude;
    addressController.text = order.delivery?.address ?? "";
    additionalDetailsController.text = order.delivery?.additionalDetails ?? "";

    update();
  }

  //  ! +++++++++ Repeat Items +++++++++
  void onRepeatCartItemWithIndex(int index) {
    var uuid = Uuid();
    if (index >= 0 && index < myOrder.carts.length) {
      CartModel cartToRepeat = myOrder.carts[index];
      CartModel repeatedCart = cartToRepeat.copyWith(
        id: uuid.v4(),
        isUpdated: false,
      );
      myOrder.carts.add(repeatedCart);
      calculateTotalPrice();
      update();
    } else {
      kLogger.e("Index out of bounds for repeating cart item.");
    }
  }

  Future repeatAllSelectedItems({bool isUpdateView = true}) async {
    if (selectedItemList.isNotEmpty) {
      // Use the extension method to replicate selected items
      var selecteOrder = myOrder.filterCartsByIds(selectedItemList);
      myOrder = myOrder.replicateSelectedItemsByIds(selectedItemList);
      // clear the selected Item List
      selectedItemList.clear();
      await calculateTotalPrice();
      if (isUpdateView) {
        // update the order
        PopupDialog.showLoadingDialog();
        await onUpdateOrder(myOrder.id);
        // PosController.to.isUpdateView = false;
        update();
        PopupDialog.closeLoadingDialog();
        orderDetailItemsScrollToBottom();
        DineInOrderController.to.clearOrderField();

        // ! print function
        kitchenPrint(
          selecteOrder,
          isCheckCanceled: true,
          title: "${selecteOrder.carts.length > 1 ? 'Items' : 'Item'} ADDED",
        );
      } else {
        cartListScrollToBottom();
      }
    }
    update();
  }

  //  ! +++++++++ Transfer Items +++++++++
  Future transferItemsAllSelectedItems({
    required String transferTableId,
    required List<String> selectedItemIds,
  }) async {
    if (transferTableId != myOrder.table) {
      if (selectedItemIds.isNotEmpty) {
        kLogger.i("Selected Items: $selectedItemIds");

        // Get carts matching the selected IDs
        List<CartModel> transferItemList = myOrder.carts
            .where((cart) => selectedItemIds.contains(cart.id))
            .toList();

        selectedItemIds.clear();

        Map<String, dynamic> data = {
          "currentTableId": myOrder.table,
          "transferTableId": transferTableId,
          "transferCarts": transferItemList
              .map((item) => item.toJson())
              .toList(),
        };

        PopupDialog.showLoadingDialog();
        var res = await BaseController.to.apiService.makePostRequest(
          URLS.transferItems,
          data,
        );
        PopupDialog.closeLoadingDialog();

        if (res.statusCode == 200 || res.statusCode == 201) {
          myOrder = OrderModel.fromJson(res.data["data"]);
          Get.back();
          update();
        } else {
          PopupDialog.showErrorMessage(res.data["message"]);
        }
        update();
      } else {
        PopupDialog.showErrorMessage("No items selected for transfer.");
        update();
      }
    } else {
      PopupDialog.showErrorMessage(
        "The existing table and the transfer table refer to the same tables.",
      );
    }
  }

  bool checkDiscountPossibilities(num amount, List<String> selectedItemIds) {
    for (final cart in myOrder.carts) {
      if (selectedItemIds.contains(cart.id)) {
        if (amount <= cart.price) {
          return true;
        }
      }
    }
    return false;
  }

  void applyDiscount(
    num amount,
    List<String> selectedItemIds, {
    bool isPercentage = true,
  }) {
    if (selectedItemIds.isNotEmpty) {
      for (var cart in myOrder.carts) {
        if (selectedItemIds.contains(cart.id)) {
          if (isPercentage) {
            var discount = cart.price * amount / 100;
            if (discount <= cart.price) {
              cart.discountAmount = discount;
              cart.discount = Discount(
                type: DiscountType.percentage,
                value: amount,
              );
            }
            // If you want to handle over-discounting with a popup for percentage, add else here if needed
          } else {
            if (amount <= cart.price) {
              cart.discountAmount = amount;
              cart.discount = Discount(type: DiscountType.flat, value: amount);
            } else {
              PopupDialog.showErrorMessage(
                "Discount cannot exceed the Item amount. Check Discount applied on all individual items.",
              );
            }
          }
        }
      }
      calculateTotalPrice();
    } else {
      PopupDialog.showErrorMessage("Select an Item to apply Discount.");
    }
  }

  deleteDiscount() {
    for (var index = 0; index < myOrder.carts.length; index++) {
      myOrder.carts[index].discountAmount = 0;
      myOrder.carts[index].discount = Discount();
    }
    myOrder.discountReason = "";
    myOrder.totalDiscount = 0;
    calculateTotalPrice();
    update();
  }

  /// ++++ Get all employee
  List<EmployeeModel> employeeList = [];
  getAllEmployee() async {
    try {
      var res = await BaseController.to.apiService.makeGetRequest(
        URLS.employees,
      );
      if (res.statusCode == 200) {
        employeeList.assignAll(
          (res.data["data"] as List)
              .map((e) => EmployeeModel.fromJson(e))
              .toList(),
        );
      }
    } catch (e) {
      kLogger.e('Error from %%%% Get all employee %%%% => $e');
    }
  }

  // zubair ==== + +++++++
  // zubair ==== + +++++++
  void onUpdateCartItemWithOptions(
    String itemId,
    List<OptionModel> options,
    num price,
    num quantity,
  ) {
    // Find the index of the matching cart item
    final index = myOrder.carts.indexWhere((cart) => cart.itemId == itemId);

    if (index != -1) {
      // Found the cart item — update only the desired fields
      final updatedCart = myOrder.carts[index].copyWith(
        variationOptions: options,
        price: price,
        quantity: quantity,
      );

      // Replace the old item with the updated one
      myOrder.carts[index] = updatedCart;
      calculateTotalPrice();
    }
  }

  // List<Cart> cartList = <Cart>[];
  ScrollController cartListScrollController = ScrollController();
  void cartListScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartListScrollController.animateTo(
        cartListScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  ScrollController orderDetailItemsScrollController = ScrollController();
  void orderDetailItemsScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderDetailItemsScrollController.animateTo(
        orderDetailItemsScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  bool checkSplitChecksAllPaid() {
    if (myOrder.splitAmounts.any((item) => item.payment != null) ||
        myOrder.splitOrders.any((item) => item.payment != null)) {
      return true;
    } else {
      return false;
    }
  }

  // get terminal info
  TerminalsModel? terminals;
  getTerminalInfo() async {
    terminals = await PosRepo.getTerminalData();
    update();
  }

  void clearCartList() {
    myOrder = OrderModel();
    myOrder.orderType = orderType;
    isItemsShow = false;
    resetModifierSelections();
    guestController.clear();
    tableController.clear();
    guestNameController.clear();
    guestPhoneController.clear();
    notesController.clear();
    addressController.clear();
    additionalDetailsController.clear();
    selectedItemList.clear();
    selectedLat = null;
    selectedLon = null;
    isUpdateView = false;
    isGuestNameReadOnly = false;
    isGuestPhoneReadOnly = false;
    isGuestReadOnly = false;
    isTableReadOnly = false;

    currentTable = null;
    update();
  }

  Future<double?> getDeliveryFee() async {
    try {
      var res = await BaseController.to.apiService.makePostRequest(
        URLS.deliveryCost,
        {
          "destinationLat": selectedLat ?? 0.0,
          "destinationLng": selectedLon ?? 0.0,
        },
      );

      if (res.statusCode == 200) {
        if (res.data["data"]["deliveryAvailable"] == true) {
          double deliveryFee = (res.data["data"]["deliveryCost"] as num)
              .toDouble();
          myOrder.deliveryFee = deliveryFee;
          calculateTotalPrice();
          return deliveryFee;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      kLogger.e('Error from %%%% get delivery fee %%%% => $e');
      return null;
    }
  }

  // ! ++++++++++ DualScreen ++++++++++

  @override
  void onInit() {
    // api  call
    pageController = PageController();
    getModifiers();
    getCategoryList();
    getProductList();
    getAllEmployee();
    getTerminalInfo();
    // getPrinters();
    // searchOrderController.addListener(
    //     () => getSearchCheckList(search: searchOrderController.text));
    searchController.addListener(
      () => findProductsByName(searchController.text),
    );
    guestController.addListener(() {
      calculateTotalPrice();
      if (guestController.text.isNotEmpty) {
        myOrder.numberOfPeople = int.parse(guestController.text);
        calculateTotalPrice();
      }
    });
    guestNameController.addListener(() {
      myOrder.guestName = guestNameController.text;
      // if (guestNameController.text.isNotEmpty) {
      //   myOrder.guestName = guestNameController.text;
      // }
    });
    guestPhoneController.addListener(() {
      myOrder.guestPhoneNumber = guestPhoneController.text;
    });
    notesController.addListener(() {
      myOrder.notes = notesController.text;
    });
    additionalDetailsController.addListener(() {
      myOrder.delivery?.additionalDetails = additionalDetailsController.text;
    });

    super.onInit();
  }

  @override
  void onReady() {
    orderTypeList = PosRepo.getOrderType();
    if (orderTypeList.isNotEmpty) {
      orderType = orderTypeList.first;
      myOrder.orderType = orderType;
      if (orderType == "DINE_IN") {
        onRemovePackagingCost();
      } else {
        onAddPackagingCost();
      }
    }
    super.onReady();
  }

  @override
  void onClose() {
    pageController.dispose();
    itemScrollController.dispose();
    categoryScrollController.dispose();
    modifierScrollController.dispose();
    super.onClose();
  }
}
