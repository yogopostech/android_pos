import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/order/models/discount_model.dart';
import 'package:yogo_pos/app/modules/pos/repo/pos_repo.dart';
import 'package:yogo_pos/app/utils/extension/num_extensions.dart';
import 'package:get/get.dart';

import '../../../../services/controller/base_controller.dart';
import '../../../../utils/logger.dart';
import '../../../../widgets/popup_dialogs.dart';
import '../../controllers/pos_controller.dart';
import '../../dine-in-orders/controllers/dine_in_order_controller.dart';
import '../../order/models/order_model.dart';
import '../../order/models/payment_model.dart';
import '../models/split_amount_model.dart';
import '../repo/split_repo.dart';

class SplitOrderController extends GetxController {
  static SplitOrderController get to => Get.find();
  BaseController baseController = Get.find<BaseController>();
  late final people =
      baseController.restaurantDetails?.restaurant.gratuityPersonCount ?? 6;

  OrderModel mainOrder = PosController.to.myOrder;
  List<CartModel> mainCartItems = [];
  OrderModel order = OrderModel();
  bool isSplitByAmount = false;

  //split by amount
  TextEditingController noOfGuestTEC = TextEditingController();
  TextEditingController totalAmountTEC = TextEditingController();
  // int guestCounter = 1; //default guest name.
  TextEditingController guestNameTEC = TextEditingController();

  // update Guest Name
  void updateGuestName(int index) {
    bool isTrue = isSplitByAmount;
    if (isTrue) {
      splitAmountChecks.splitAmounts[index].guestName = guestNameTEC.text
          .trim();
    } else {
      listOfSpitChecksByItems[index].guestName = guestNameTEC.text.trim();
    }
    update();
    Get.back();
    guestNameTEC.clear();
  }

  final GlobalKey<FormState> splitPayAmountFormKey = GlobalKey<FormState>();
  TextEditingController splitPayAmountTEC = TextEditingController();

  SplitAmountModel splitAmountChecks = SplitAmountModel(splitAmounts: []);
  splitAmountRemovePackagingCost(int index) {
    splitAmountChecks.splitAmounts[index].packagingCost = 0;
    splitAmountChecks = PosRepo.calculateSplitAmounts(
      splitAmountChecks.splitAmounts,
    );
    update();
  }

  num splitAmountPerGuest = 0;
  // **** calculate Split Receipts *****
  void calculateSplitReceipts() {
    //amount only upto 2 decimal points
    num splitAmount =
        ((order.totalOrderAmount - order.packagingCost) /
                (int.tryParse(noOfGuestTEC.text) ?? 1))
            .toFixed2();
    var myTotal = splitAmount + order.packagingCost;
    splitAmountChecks.splitAmounts = List.generate(
      int.parse(noOfGuestTEC.text),
      (index) {
        return SplitAmount(
          guestName: 'Guest ${index + 1}',
          orderId: "${order.orderId}-SC${index + 1}",
          packagingCost: order.packagingCost,
          splitAmount: splitAmount,
          total: myTotal,
          payment: null,
        );
      },
    );

    if (splitAmountChecks.splitAmounts.isNotEmpty) {
      isSplitByAmount = true;
    } else {
      isSplitByAmount = false;
    }
    noOfGuestTEC.clear();
    update();
  }

  removeToListOfSelectedItems(OrderModel item) {
    if (item.payment == null) {
      if (listOfSpitChecksByItems.contains(item)) {
        listOfSpitChecksByItems.remove(item);
        order.carts.addAll(item.carts);
        calculateMainAmount();
        itemListScrollToBottom();
        updateGuestNames();
        update();
      }
    } else {
      PopupDialog.showErrorMessage('Unable to cancel. Check already paid!');
    }
  }

  //****** create  SPLIT ORDER NEW   ******
  splitOrderAddPackagingCost(int index) {
    splitAmountChecks.splitAmounts[index].packagingCost =
        BaseController.to.restaurantDetails?.restaurant.packagingCost.cost ?? 0;
    listOfSpitChecksByItems = PosRepo.calculateSplitChecks(
      listOfSpitChecksByItems,
      customMaintenanceFee:
          mainOrder.maintenanceFee / listOfSpitChecksByItems.length,
    );
    update();
  }

  // ****** remove Split Order ******
  splitOrderRemovePackagingCost(int index) {
    listOfSpitChecksByItems[index].packagingCost = 0;
    listOfSpitChecksByItems = PosRepo.calculateSplitChecks(
      listOfSpitChecksByItems,
      customMaintenanceFee:
          mainOrder.maintenanceFee / listOfSpitChecksByItems.length,
    );
    update();
  }

  CartModel? pickedItem;
  OrderModel? pickedReceipt;
  List<OrderModel> listOfSpitChecksByItems = [];
  createNewReceipt() {
    // all split amount is pending(unpaid)
    if (splitAmountChecks.splitAmounts.isNotEmpty &&
        splitAmountChecks.splitAmounts.every((item) => item.payment == null)) {
      PopupDialog.customDialog(
        width: 600,
        child: PopupDialog.permissionDialog(
          titleStyle: Get.theme.textTheme.headlineSmall,
          Get.theme,
          onSubmit: () async {
            PopupDialog.showLoadingDialog();
            bool isReset = await resetSplitChecks();
            PopupDialog.closeLoadingDialog();
            if (isReset) {
              Get.back();
            }
          },
          title: "Split Check is in progress.\nConfirm Reset?",
        ),
      );
      return;
    }
    // one or more split amount is paid
    if (splitAmountChecks.splitAmounts.isNotEmpty &&
        splitAmountChecks.splitAmounts.any(
          (item) => item.payment is PaymentModel,
        )) {
      PopupDialog.showErrorMessage('One or more Split Checks already settled');
      return;
    }
    if (listOfSpitChecksByItems.length >= 20) {
      PopupDialog.showErrorMessage('Maximum amount of order has been created!');
      return;
    }
    isSplitByAmount = false;
    listOfSpitChecksByItems.add(
      OrderModel(
        guestName: 'Guest ${listOfSpitChecksByItems.length + 1}',
        orderId: "${mainOrder.orderId}-SC${listOfSpitChecksByItems.length + 1}",
        orderType: order.orderType,
        table: mainOrder.table ?? '',
        tableName: mainOrder.tableName,
        payment: null,
        employee: mainOrder.employee,
        numberOfPeople: mainOrder.numberOfPeople,
        paymentStatus: 'UNPAID',
        orderStatus: 'CONFIRMED',
        packagingCost: mainOrder.packagingCost,
        createdAt: mainOrder.createdAt,
        updatedAt: mainOrder.updatedAt,
        gratuityPercentage: mainOrder.gratuityPercentage,
      ),
    );
    updateGuestNames();
    splitChecksScrollToBottom();
    listOfSpitChecksByItems = PosRepo.calculateSplitChecks(
      listOfSpitChecksByItems,
      customMaintenanceFee:
          mainOrder.maintenanceFee / listOfSpitChecksByItems.length,
    );
    update();
  }

  void updateGuestNames() {
    int guestCounter = 1;
    for (var check in listOfSpitChecksByItems) {
      if (check.guestName.startsWith('Guest ')) {
        check.guestName = 'Guest $guestCounter';
      }
      guestCounter++;
    }
  }

  void onItemSelect(CartModel item, OrderModel receipt) {
    if (pickedItem != item) {
      pickedItem = item;
      pickedReceipt = receipt;
    } else if (pickedItem == item) {
      pickedItem = null;
      pickedReceipt = null;
    }
    update();
  }

  // ***** move Item To Receipt and calculation splite price *****
  void moveItemToReceipt(OrderModel target) {
    if (pickedItem != null && pickedReceipt != null) {
      pickedReceipt!.carts.remove(pickedItem);
      kLogger.e("pickedItem and pickedReceipt");
      target.carts.add(pickedItem!);
      calculateMainAmount();
      pickedItem = null;
      pickedReceipt = null;
    }
    update();
  }

  // ****** calculate Main Amount ******
  calculateMainAmount() {
    order = PosRepo.recalculateOrderPrice(order);
    // kLogger.e(order.totalOrderAmount);
    // kLogger.e(order.payment?.toJson());
    listOfSpitChecksByItems = PosRepo.calculateSplitChecks(
      listOfSpitChecksByItems,
      customMaintenanceFee:
          mainOrder.maintenanceFee / listOfSpitChecksByItems.length,
    );
  }

  // ****** breakdownItems ******
  void breakdownItems() {
    List<CartModel> dividedItems = [];
    if (pickedItem != null) {
      if (pickedItem!.quantity > 1) {
        for (int i = 0; i < pickedItem!.quantity; i++) {
          dividedItems.add(
            CartModel(
              id: pickedItem!.id,
              itemId: pickedItem!.itemId,
              name: pickedItem!.name,
              price: pickedItem!.price,
              quantity: 1,
              discount: Discount(),
            ),
          );
        }
      } else {
        dividedItems.add(pickedItem!);
        PopupDialog.showErrorMessage(
          "This item cannot be divided further. To Split a Single item, select 'Divide Items'",
        );
      }

      order.carts.removeWhere((element) => element == pickedItem);
      order.carts.addAll(dividedItems);
    } else {
      for (var item in order.carts) {
        if (item.quantity > 1) {
          for (int i = 0; i < item.quantity; i++) {
            dividedItems.add(
              CartModel(
                itemId: item.itemId,
                discount: Discount(),
                id: item.id,
                name: item.name,
                price: item.price,
                quantity: 1,
              ),
            );
          }
        } else {
          dividedItems.add(item);
        }
      }
      order.carts.clear();
      order.carts.addAll(dividedItems);
    }
    update();
  }

  // ***** item can be 1, 1/2, 1/3, 1/4 *****
  void divideItems(int divideBy) {
    List<CartModel> items = [pickedItem!];
    List<CartModel> dividedItems = [];

    for (var item in items) {
      CartModel it = item;
      for (int i = 0; i < divideBy; i++) {
        dividedItems.add(
          it.copyWith(
            price: it.price,
            quantity: it.quantity / divideBy,
            itemType: it.itemType,
          ),
        );
      }

      order.carts.remove(pickedItem!);
      order.carts.addAll(dividedItems);
      itemListScrollToBottom();
    }
    update();
  }

  // *****  save Split Checks To Main Order *****
  Future<void> saveSplitChecksToMainOrder() async {
    if (isSplitByAmount) {
      // Split By Amount
      mainOrder.splitAmounts = splitAmountChecks.splitAmounts;
      await paySplitAmount();
      DineInOrderController.to.clearOrderField();
    }
    if (!isSplitByAmount) {
      //SPLIT ORDERS
      await SplitRepo.newSplitOrder(
        orderId: mainOrder.id,
        splitOrders: listOfSpitChecksByItems,
        restOfItems: listOfSpitChecksByItems.isEmpty ? [] : order.carts,
      );
    }

    PosController.to.update();
    // DataUpdateHelper.allGetApiCall();
  }

  Future splitOrderPayment(int index, PaymentModel payment) async {
    listOfSpitChecksByItems[index].payment = payment;
    listOfSpitChecksByItems[index].paymentStatus = "PAID";
    // kLogger.e(listOfSpitChecksByItems[index].payment?.toJson());
    // kLogger.e(index);
    PopupDialog.showLoadingDialog();
    bool isUpdate = await SplitRepo.newSplitOrder(
      orderId: mainOrder.id,
      splitOrders: listOfSpitChecksByItems,
      restOfItems: order.carts,
    );
    PopupDialog.closeLoadingDialog();
    if (isUpdate) {
      mainOrder = PosController.to.myOrder;
      order = mainOrder.copyWith(carts: mainOrder.splitOrderCarts);

      // split order
      listOfSpitChecksByItems = mainOrder.splitOrders;
      calculateMainAmount();
      Get.back();
      update();
    }
  }

  // ****** reset Split Checks ******
  Future<bool> resetSplitChecks() async {
    if ((mainOrder.splitAmounts.every((item) => item.payment == null)) &&
        (order.splitAmounts.every((item) => item.payment == null)) &&
        (splitAmountChecks.splitAmounts.every(
          (item) => item.payment == null,
        )) &&
        (listOfSpitChecksByItems.every((item) => item.payment == null))) {
      //
      mainOrder.carts = List.from(mainCartItems);
      order.carts = List.from(mainCartItems);
      calculateMainAmount();
      listOfSpitChecksByItems.clear();
      isSplitByAmount = false;
      splitAmountChecks.splitAmounts.clear();
      pickedItem = null;

      PopupDialog.showLoadingDialog();
      await SplitRepo.clearSplitData(PosController.to.myOrder.id);
      PopupDialog.closeLoadingDialog();
      update();
      return true;
    } else {
      PopupDialog.showErrorMessage('One or more Split Checks already paid');
      return false;
    }
  }

  // ***** scroll list to end ******
  final ScrollController itemListScrollController = ScrollController();
  void itemListScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      itemListScrollController.animateTo(
        itemListScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ******* scroll split checks to end *******
  final ScrollController splitChecksScrollController = ScrollController();
  void splitChecksScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      splitChecksScrollController.animateTo(
        splitChecksScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ******* API call *******
  bool isPostingSplitAmount = false;
  Future<bool> paySplitAmount() async {
    isPostingSplitAmount = true;
    update();

    bool isSuccess = await SplitRepo.splitAmount(
      orderId: mainOrder.id,
      splitAmount: splitAmountChecks,
    );

    isPostingSplitAmount = false;
    update();

    return isSuccess;
  }

  @override
  void onInit() {
    mainOrder = PosController.to.myOrder;

    if (mainOrder.splitOrderCarts.isEmpty && mainOrder.splitOrders.isEmpty) {
      // For split amount or new split
      order = mainOrder.copyWith();
      if (mainOrder.splitAmounts.isNotEmpty) {
        isSplitByAmount = true;
        splitAmountChecks.splitAmounts.addAll(mainOrder.splitAmounts);
      }
    } else {
      // Only for split order
      // main order
      order = mainOrder.copyWith(carts: mainOrder.splitOrderCarts);
      // split order
      listOfSpitChecksByItems = mainOrder.splitOrders;
      isSplitByAmount = false;
      calculateMainAmount();
    }
    totalAmountTEC.text = mainOrder.totalOrderAmount.toStringAsFixed(2);
    super.onInit();
  }
}
