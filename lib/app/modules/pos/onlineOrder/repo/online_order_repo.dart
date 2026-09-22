import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class OnlineOrderRepo {
  static Future<List<OrderModel>> getOnlineOrders({
    List<String>? orderStatus,
    String orderType = "TAKEOUT",
    String takeoutType = "ONLINE",
    String? page,
    String? paymentStatus,
    String? limit = "15",
    String? search,
    // String day = "2",
  }) async {
    //DateFormat('yyyy-MM-dd').format(date)
    Map<String, dynamic>? queryParameters = {
      "day": "2",
      "takeoutType": takeoutType,
      "orderType": orderType,
      if (paymentStatus != null) "paymentStatus": paymentStatus,
      if (orderStatus != null) "orderStatus": orderStatus,
      if (page != null) "page": page,
      if (limit != null) "limit": limit,
      if (search != null) "search": search,
    };
    try {
      var res = await BaseController.to.apiService.makeGetRequest(
        URLS.orders,
        queryParameters: queryParameters,
      );
      if (res.statusCode == 200 && res.data["data"] != null) {
        return (res.data["data"] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      kLogger.e('Error from %%%% get All online  Orders %%%% => $e');
      return [];
    }
  }

  Future<bool> onUpdateOrder(
    String id, {
    String? orderStatus,
    String? paymentStatus,
    String? estimatedTime,
    String? estimatedDate,
    bool? orderSeen,
  }) async {
    Map<String, dynamic>? data = {
      if (orderStatus != null) "orderStatus": orderStatus,
      if (orderStatus != null) "orderStatus": orderStatus,
      if (paymentStatus != null) "paymentStatus": paymentStatus,
      if (estimatedTime != null) "estimatedTime": estimatedTime,
      if (estimatedDate != null) "estimatedDate": estimatedDate,
      if (orderSeen != null) "orderSeen": orderSeen,
    };
    try {
      var res = await BaseController.to.apiService.makePatchRequest(
        "${URLS.orders}/$id",
        data,
      );
      debugPrint("Update Order Response: ${res.data}");

      if (res.statusCode == 200) {
        return true;
      }
      PopupDialog.showErrorMessage(res.data["message"]);
      return false;
    } catch (e) {
      kLogger.e('Error from %%%% update order %%%% => $e');
      return false;
    }
  }
}
