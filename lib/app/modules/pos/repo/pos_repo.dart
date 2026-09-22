import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/models/split_amount_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/address_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/num_extensions.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

import '../order/models/terminals_model.dart';

class PosRepo {
  static OrderModel recalculateOrderPrice(
    OrderModel order, {
    num? customMaintenanceFee,
  }) {
    // Extract businessProfile to a local variable
    final restaurantDetails = BaseController.to.restaurantDetails;

    // Reset Packaging Cost
    // Variables for calculations
    num totalPrice = 0;
    num totalDiscount = 0;
    num totalGst = 0;
    num totalGratuity = 0;
    num totalPst = 0;
    num totalPst2 = 0;

    // Constants for tax rates
    final gstRate = (restaurantDetails?.businessProfile.gstNumber ?? 0) / 100;
    final gratuityRate =
        (order.gratuityPercentage ??
            (restaurantDetails?.businessProfile.gratuity ?? 0)) /
        100;
    final pstRate = (restaurantDetails?.businessProfile.pstNumber ?? 0) / 100;
    final pst2Rate = (restaurantDetails?.businessProfile.pstNumber2 ?? 0) / 100;
    final gratuityThreshold =
        restaurantDetails?.restaurant.gratuityPersonCount ?? 6;

    // Iterate through the cart items
    for (var item in order.carts) {
      final itemTotal = (item.price - item.discountAmount) * item.quantity;

      totalPrice += item.price * item.quantity;
      totalDiscount += item.discountAmount * item.quantity;

      // GST Calculation
      if (item.itemType != "weighing scale") {
        totalGst += itemTotal * gstRate;
      }

      // Gratuity Calculation
      if (item.itemType != "weighing scale" &&
          order.numberOfPeople >= gratuityThreshold) {
        totalGratuity += itemTotal * gratuityRate;
      }

      // PST Calculation
      if (item.itemType.toLowerCase() == "liquor") {
        totalPst += itemTotal * pstRate;
      }

      // PST2 Calculation (Carbonated)
      if (item.itemType.toLowerCase() == "carbonated") {
        totalPst2 += itemTotal * pst2Rate;
      }
    }

    // Update OrderModel fields
    order.subTotal = totalPrice.toFixed2();
    order.totalDiscount = totalDiscount.toFixed2();
    order.totalGst = totalGst.toFixed2();
    order.totalGratuity = totalGratuity.toFixed2();
    order.totalPst = totalPst.toFixed2();
    order.totalPst2 = totalPst2.toFixed2();
    if (customMaintenanceFee != null) {
      order.maintenanceFee = customMaintenanceFee;
    }

    // Calculate Tip
    order.tip =
        ((order.payment?.cashTipAmount ?? 0) +
                (order.payment?.cardTipAmount ?? 0))
            .toFixed2();
    order.extraAmount = order.payment?.extraAmount ?? 0;
    // Calculate Total Order Amount
    order.totalOrderAmount =
        (order.subTotal +
                order.totalGst +
                order.totalPst +
                order.totalGratuity +
                order.totalPst2 +
                order.maintenanceFee +
                order.deliveryFee +
                (order.carts.isEmpty ? 0 : order.packagingCost) +
                order.tip +
                (order.payment?.extraAmount ?? 0) -
                order.totalDiscount)
            .toFixed2();
    return order;
  }

  static List<OrderModel> calculateSplitChecks(
    List<OrderModel> listOfSpitChecksByItems, {
    num? customMaintenanceFee,
  }) {
    List<OrderModel> updatedList = [];

    for (var order in listOfSpitChecksByItems) {
      // Use the renamed function to calculate totals for each OrderModel
      var updatedOrder = recalculateOrderPrice(
        order,
        customMaintenanceFee: customMaintenanceFee,
      ); // Replace with your renamed function
      updatedList.add(updatedOrder);
    }

    return updatedList;
  }

  static List<String> getOrderType() {
    List<String> myList = [];
    bool dineIn =
        BaseController.to.restaurantDetails?.restaurant.dineIn ?? false;
    bool takeOut =
        BaseController.to.restaurantDetails?.restaurant.takeout ?? false;
    bool delivery =
        BaseController.to.restaurantDetails?.restaurant.posDelivery ?? false;

    if (takeOut) myList.add("TAKEOUT");
    if (dineIn) myList.add("DINE_IN");
    if (delivery) myList.add("DELIVERY");

    if (myList.isNotEmpty) {
      PosController.to.myOrder.orderType = myList.first;
      PosController.to.orderType = myList.first;
      PosController.to.myOrder.numberOfPeople = 1;
      PosController.to.guestController.clear();
    }

    return myList;
  }

  static Future<TerminalsModel?> getTerminalData() async {
    try {
      var res = await BaseController.to.apiService.makeGetRequest(
        URLS.terminalData,
      );
      debugPrint("object: ${res.data}");

      if (res.statusCode == 200 && res.data["data"] != null) {
        // return null;
        return TerminalsModel.fromJson(
          res.data["data"],
        ); // Assuming TerminalsModel has a fromJson method
      } else {
        kLogger.e('Failed to fetch terminal data. Status: ${res.statusCode}');
        return null;
      }
    } catch (e) {
      kLogger.e('Error from %%%% get terminal data %%%% => $e');
      return null;
    }
  }

  static SplitAmountModel calculateSplitAmounts(List<SplitAmount> splits) {
    // Iterate through each SplitAmount and calculate the total
    for (var split in splits) {
      var myTotal = split.splitAmount + split.packagingCost;
      var roundedTotal = MyFunc.yogoRound(myTotal);
      split.total = roundedTotal;
      split.extraAmount = (roundedTotal - myTotal).toFixed2();
    }

    // Return a new SplitAmountModel with the updated splits
    return SplitAmountModel(splitAmounts: splits);
  }

  static Future<List<AddressModel>> fetchAddrassSuggestions(
    String query,
  ) async {
    // final dio = Dio();
    // const String googleApiKey = 'AIzaSyCOKkuWege1QdwYUZCRe91WqJkAGIy3f5A';

    try {
      final response = await BaseController.to.apiService.makeGetRequest(
        URLS.searchAddress,
        queryParameters: {'address': query},
      );
      // if (kDebugMode) {
      //   print(response.data["predictions"][0]);
      // }

      if (response.statusCode == 200) {
        var data = (response.data['data'] as List)
            .map((item) => AddressModel.fromJson(item))
            .toList();
        if (data.isEmpty) {
          PopupDialog.showErrorMessage(
            duration: Duration(seconds: 2),
            "Address Is Outside Coverage Area Or Invalid Address",
          );
        }
        return data;
      } else {
        kLogger.e(
          'Failed to fetch address suggestions. Status: ${response.statusCode}',
        );
        return [];
      }
    } on DioException catch (e) {
      kLogger.e('Error fetching address suggestions: $e');
      return [];
    } catch (e) {
      kLogger.e('Unknown error fetching address suggestions: $e');
      return [];
    }
  }
}
