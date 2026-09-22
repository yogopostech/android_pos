import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/pos/onlineOrder/repo/online_order_repo.dart';

import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';

import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class OnlineOrderController extends GetxController {
  static OnlineOrderController get to => Get.find();
  TextEditingController estDateController = TextEditingController();
  TextEditingController estTimeController = TextEditingController();
  List<String> tabs = ["Details", "Items"];
  int unseenUnpaidOrders = 0;
  int unseenOrders = 0;
  int unseenPaidOrders = 0;
  int selectedTabIndex = 0;
  List<String> orderType = ["unpaid", "paid", "canceled"];
  List<String> orderTypeForTimeLine = ["confirmed", "completed"];
  List<Color> orderTypeColor = [
    StaticColors.blueColor,
    StaticColors.greenColor,
    StaticColors.orangeColor
  ];

  List<OrderModel> unPaidOrders = [];
  List<OrderModel> paidOrders = [];
  List<OrderModel> canceledOrders = [];

  // get orders
  Future<void> getPaidOrders() async {
    paidOrders = await OnlineOrderRepo.getOnlineOrders(
      orderStatus: ["COMPLETED"],
      paymentStatus: "PAID",
    );
    unseenPaidOrders =
        paidOrders.where((order) => order.orderSeen == false).length;
    unseenOrders = unseenUnpaidOrders + unseenPaidOrders;
    update();
  }

  Future<void> getUnPaidOrders() async {
    unPaidOrders = await OnlineOrderRepo.getOnlineOrders(
      orderStatus: ["COMPLETED", "CONFIRMED"],
      paymentStatus: "UNPAID",
    );
    unseenUnpaidOrders =
        unPaidOrders.where((order) => order.orderSeen == false).length;

    unseenOrders = unseenUnpaidOrders + unseenPaidOrders;
    update();
  }

  Future<void> getCanceledOrders() async {
    canceledOrders = await OnlineOrderRepo.getOnlineOrders(
      orderStatus: ["CANCELED"],
    );

    update();
  }

Future<void> getOrders() async {
  await Future.wait([
    getUnPaidOrders(),
    getPaidOrders(),
    getCanceledOrders(),
  ]);
}

  // uodate order
  Future<bool> updateOrder(
    String id, {
    String? orderStatus,
    String? estimatedTime,
    String? estimatedDate,
    String? paymentStatus,
    bool? orderSeen,
  }) async {
    PopupDialog.showLoadingDialog();
    bool res = await OnlineOrderRepo().onUpdateOrder(
      id,
      orderStatus: orderStatus?.toUpperCase(),
      estimatedTime: estimatedTime,
      estimatedDate: estimatedDate,
      paymentStatus: paymentStatus,
      orderSeen: orderSeen,
    );
    if (res) {
      // estDateController.clear();
      // estTimeController.clear();
      await getOrders();
      PopupDialog.closeLoadingDialog();
      Get.back();
      update();
      return res;
    } else {
      PopupDialog.closeLoadingDialog();
      return res;
    }
  }

  Future<bool> onOrderSeen(
    String id, {
    bool? orderSeen,
  }) async {
    bool res = await OnlineOrderRepo().onUpdateOrder(
      id,
      orderSeen: orderSeen,
    );
    if (res) {
      await getOrders();
      update();
      return res;
    } else {
      return res;
    }
  }

  void changeTabIndex(int index) {
    selectedTabIndex = index;
    update();
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "confirmed":
        return StaticColors.blueColor; // Example: Blue for confirmed
      case "completed":
        return StaticColors.greenColor; // Example: Green for completed
      case "canceled":
        return StaticColors.orangeColor; // Example: Red for canceled
      default:
        return StaticColors.blueColor; // Default color if status is unknown
    }
  }

  @override
  void onInit() {
    getOrders();
    super.onInit();
  }

  @override
  void onClose() {
    estDateController.dispose();
    estTimeController.dispose();
    super.onClose();
  }
}
