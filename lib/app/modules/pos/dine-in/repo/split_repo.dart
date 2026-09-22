import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/split_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/models/split_amount_model.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import '../../../../services/base/base_model.dart';
import '../../../../services/controller/base_controller.dart';
import '../../../../widgets/popup_dialogs.dart';
import '../../order/models/order_model.dart';

class SplitRepo {
  SplitRepo._();

  static Future<bool> splitAmount({
    required String orderId,
    required SplitAmountModel splitAmount,
  }) async {
    try {
      final BaseModel res = await BaseController.to.apiService.makePatchRequest(
        URLS.splitAmount(orderId),
        splitAmount.toJson(),
      );

      if (res.statusCode == 200) {
        PosController.to.myOrder = OrderModel.fromJson(res.data["data"]);
        SplitOrderController.to.mainOrder =
            OrderModel.fromJson(res.data["data"]);
        SplitOrderController.to.order = SplitOrderController.to.mainOrder;
        PosController.to.update();
        SplitOrderController.to.update();

        return true;
      } else {
        PopupDialog.showErrorMessage(
            'Unable to pay!\n${res.data['message']}[${res.statusCode}]');

        return false;
      }
    } catch (e) {
      // showCustomSnackbar(message: e.toString());
      return false;
    }
  }

  static Future<bool> splitOrder({
    required String orderId,
    required OrderModel order,
  }) async {
    try {
      final BaseModel res = await BaseController.to.apiService.makePostRequest(
        URLS.splitOrder(orderId),
        order.toJson(),
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        PopupDialog.showErrorMessage(
            'Unable to pay!\n${res.data['message']}[${res.statusCode}]');

        return false;
      }
    } catch (e) {
      // showCustomSnackbar(message: e.toString());
      return false;
    }
  }

  static Future<bool> newSplitOrder({
    required String orderId,
    required List<OrderModel> splitOrders,
    required List<CartModel> restOfItems,
  }) async {
    try {
      // Convert splitOrders and restOfItems to the required format
      Map<String, dynamic> data = {
        "splitOrders": splitOrders.map((order) => order.toJson()).toList(),
        "splitOrderCarts": restOfItems.map((cart) => cart.toJson()).toList(),
      };

      // Make the POST request
      final BaseModel res = await BaseController.to.apiService.makePostRequest(
        URLS.splitOrder(orderId),
        data,
      );

      // Check the response status
      if (res.statusCode == 200) {
        PosController.to.myOrder = OrderModel.fromJson(res.data["data"]);
        PosController.to.update();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Handle exceptions and log the error
      PopupDialog.showErrorMessage('An error occurred: $e');
      return false;
    }
  }

  static Future<bool> clearSplitData(String id) async {
    // Payload for clearing split data
    Map<String, dynamic> data = {
      'splitOrderCarts': [],
      'splitAmounts': [],
      'splitOrders': [],
    };

    try {
      // Send a PATCH request to the API
      var res = await BaseController.to.apiService
          .makePatchRequest("${URLS.orders}/$id", data);

      // Handle successful response
      if (res.statusCode == 200) {
        PosController.to.myOrder = OrderModel.fromJson(res.data["data"]);
        SplitOrderController.to.mainOrder =
            OrderModel.fromJson(res.data["data"]);
        SplitOrderController.to.order = SplitOrderController.to.mainOrder;
        PosController.to.update();
        SplitOrderController.to.update();
        return true;
      } else {
        // Show error message from the API response
        PopupDialog.showErrorMessage(
          res.data?["message"] ?? "Failed to clear split data.",
        );
        return false;
      }
    } catch (e) {
      // Log the exception and return false
      kLogger.e('Error in clearSplitData => $e');
      PopupDialog.showErrorMessage('An unexpected error occurred: $e');
      return false;
    }
  }
}
