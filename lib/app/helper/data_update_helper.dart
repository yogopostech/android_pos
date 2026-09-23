import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/delivery/controllers/delivery_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/controllers/dine_in_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/table_mapping_managment_controller.dart';
import 'package:yogo_pos/app/modules/pos/takeout/controllers/takeout_controller.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

import '../modules/pos/onlineOrder/controllers/online_order_controller.dart';

class DataUpdateHelper {
  DataUpdateHelper._();

  /// A safe wrapper for API calls to handle errors gracefully
  static Future<void> _safeApiCall(
    Future<void> Function() apiCall,
    String apiName,
  ) async {
    try {
      kLogger.i("Starting API call: $apiName");
      await apiCall();
      kLogger.i("Completed API call: $apiName");
    } catch (e) {
      kLogger.e("Error in API call ($apiName): $e");
    }
  }

  /// Fetch all required data concurrently
  static Future<void> allGetApiCall() async {
    try {
      kLogger.i("Starting allGetApiCall...");
      PopupDialog.showLoadingDialog();
      await Future.wait([
        _safeApiCall(
          () => BaseController.to.getRestaurantsDetailsFromAPI(),
          "getRestaurantsDetailsFromAPI",
        ),
        _safeApiCall(
          () => PosController.to.getCategoryList(),
          "getCategoryList",
        ),
        _safeApiCall(() => PosController.to.getProductList(), "getProductList"),
        _safeApiCall(() => PosController.to.getModifiers(), "getModifiers"),
        _safeApiCall(() => PosController.to.getTerminalInfo(), "TerminalInfo"),
        _safeApiCall(
          () => DineInOrderController.to.getOrderStatus(),
          "getOrderStatus",
        ),
        _safeApiCall(
          () => DineInOrderController.to.getAllOrders(),
          "getAllOrders",
        ),
        _safeApiCall(
          () => DineInController.to.getTableCategories(),
          "getTableCategories",
        ),
        _safeApiCall(
          () => TableMappingController.to.getMappingALlTables(),
          "getTableCategories",
        ),
        _safeApiCall(
          () => TakeOutController.to.getAllTakeOutPaidOrders(),
          "getAllTakeOutPaidOrders",
        ),
        _safeApiCall(
          () => TakeOutController.to.getAllTakeOutUnPaidOrders(),
          "getAllTakeOutUnPaidOrders",
        ),

        // _safeApiCall(() => OnlineOrderController.to.getOrders(), "getOrders"),
      ]);

      // Perform dependent tasks after all API calls
      DineInOrderController.to.clearOrderField();
      kLogger.i("Completed allGetApiCall.");
    } catch (e) {
      kLogger.e("Error in allGetApiCall: $e");
    } finally {
      PopupDialog.closeLoadingDialog();
    }
  }

  /// Fetch data for Takeout
  static Future<void> getApiCallForTakeout() async {
    try {
      kLogger.i("Starting getApiCallForTakeout...");
      await Future.wait([
        _safeApiCall(
          () => TakeOutController.to.getAllTakeOutPaidOrders(),
          "getAllTakeOutPaidOrders",
        ),
        _safeApiCall(
          () => TakeOutController.to.getAllTakeOutUnPaidOrders(),
          "getAllTakeOutUnPaidOrders",
        ),
      ]);
      kLogger.i("Completed getApiCallForTakeout.");
    } catch (e) {
      kLogger.e("Error in getApiCallForTakeout: $e");
    }
  }

  /// Fetch data for Dine-In
  static Future<void> getApiCallForDineIn() async {
    try {
      kLogger.i("Starting getApiCallForDineIn...");
      await Future.wait([
        _safeApiCall(
          () => DineInController.to.getTableCategories(),
          "getTableCategories",
        ),
        _safeApiCall(
          () => _safeApiCall(
            () => TableMappingController.to.getMappingALlTables(),
            "getTableCategories",
          ),
          "getTableCategories",
        ),
      ]);

      // Perform dependent tasks
      DineInOrderController.to.clearOrderField();
      kLogger.i("Completed getApiCallForDineIn.");
    } catch (e) {
      kLogger.e("Error in getApiCallForDineIn: $e");
    }
  }

  /// Fetch data for Online Orders
  static Future<void> getApiCallForOnlineOrder() async {
    // try {
    //   kLogger.i("Starting getApiCallForOnlineOrder...");
    //   await _safeApiCall(
    //     () => OnlineOrderController.to.getOrders(),
    //     "getOrders",
    //   );
    //   kLogger.i("Completed getApiCallForOnlineOrder.");
    // } catch (e) {
    //   kLogger.e("Error in getApiCallForOnlineOrder: $e");
    // }
  }

  /// Fetch data for Delivery Orders
  static Future<void> getApiCallForDeliveryOrder() async {
    // try {
    //   kLogger.i("Starting getApiCallForDeliveryOrder...");
    //   await Future.wait([
    //     _safeApiCall(
    //       () => DeliveryController.to.getAllDeliveryPaidOrders(),
    //       "getAllDeliveryPaidOrders",
    //     ),
    //     _safeApiCall(
    //       () => DeliveryController.to.getAllDeliveryUnPaidOrders(),
    //       "getAllDeliveryUnPaidOrders",
    //     ),
    //   ]);
    //   kLogger.i("Completed getApiCallForDeliveryOrder.");
    // } catch (e) {
    //   kLogger.e("Error in getApiCallForDeliveryOrder: $e");
    // }
  }

  /// Fetch data based on the order type
  static Future<void> getDataByCheckType({String? type}) async {
    var orderType = type ?? PosController.to.myOrder.orderType;
    try {
      kLogger.i("Starting getDataByCheckType...");
      if (orderType == "DINE_IN") {
        await getApiCallForDineIn();
      } else if (orderType == "TAKEOUT" &&
          PosController.to.myOrder.takeOutType == "ONLINE") {
        await getApiCallForOnlineOrder();
      } else if (orderType == "TAKEOUT" &&
          PosController.to.myOrder.takeOutType == "WALK_IN") {
        await getApiCallForTakeout();
      } else if (orderType == "DELIVERY") {
        await getApiCallForDeliveryOrder();
      }
      kLogger.i("Completed getDataByCheckType.");
    } catch (e) {
      kLogger.e("Error in getDataByCheckType: $e");
    }
  }

  static Future<void> getDataBySocket(String checkType) async {
    switch (checkType) {
      case "DINE_IN":
        await getApiCallForDineIn();
        break;
      case "TAKEOUT":
        await getApiCallForTakeout();
        break;
      case "ONLINE":
        await getApiCallForOnlineOrder();
        break;
      case "DELIVERY":
        await getApiCallForDeliveryOrder();
        break;
    }
  }
}
