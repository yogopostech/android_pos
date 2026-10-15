// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:yogo_pos/app/modules/pos/order/models/discount_model.dart';
// import 'package:yogo_pos/app/modules/pos/repo/pos_repo.dart';
// import 'package:yogo_pos/app/utils/extension/num_extensions.dart';
// import 'package:get/get.dart';

// import '../../../../services/controller/base_controller.dart';
// import '../../../../utils/logger.dart';
// import '../../../../widgets/popup_dialogs.dart';
// import '../../controllers/pos_controller.dart';
// import '../../dine-in-orders/controllers/dine_in_order_controller.dart';
// import '../../order/models/order_model.dart';
// import '../../order/models/payment_model.dart';
// import '../models/split_amount_model.dart';
// import '../repo/split_repo.dart';

// class SplitOrderController extends GetxController {
//   static SplitOrderController get to => Get.find();
//   BaseController baseController = Get.find<BaseController>();
//   late final people =
//       baseController.restaurantDetails?.restaurant.gratuityPersonCount ?? 6;

//   OrderModel mainOrder = PosController.to.myOrder;
//   List<CartModel> mainCartItems = [];
//   OrderModel order = OrderModel();
//   bool isSplitByAmount = false;

//   //split by amount
//   TextEditingController noOfGuestTEC = TextEditingController();
//   TextEditingController totalAmountTEC = TextEditingController();
//   // int guestCounter = 1; //default guest name.
//   TextEditingController guestNameTEC = TextEditingController();

//   // update Guest Name
//   void updateGuestName(int index) {
//     bool isTrue = isSplitByAmount;
//     if (isTrue) {
//       splitAmountChecks.splitAmounts[index].guestName = guestNameTEC.text
//           .trim();
//     } else {
//       listOfSpitChecksByItems[index].guestName = guestNameTEC.text.trim();
//     }
//     update();
//     Get.back();
//     guestNameTEC.clear();
//   }

//   final GlobalKey<FormState> splitPayAmountFormKey = GlobalKey<FormState>();
//   TextEditingController splitPayAmountTEC = TextEditingController();

//   SplitAmountModel splitAmountChecks = SplitAmountModel(splitAmounts: []);
//   splitAmountRemovePackagingCost(int index) {
//     splitAmountChecks.splitAmounts[index].packagingCost = 0;
//     splitAmountChecks = PosRepo.calculateSplitAmounts(
//       splitAmountChecks.splitAmounts,
//     );
//     update();
//   }

//   num splitAmountPerGuest = 0;
//   // **** calculate Split Receipts *****
//   void calculateSplitReceipts() {
//     //amount only upto 2 decimal points
//     num splitAmount =
//         ((order.totalOrderAmount - order.packagingCost) /
//                 (int.tryParse(noOfGuestTEC.text) ?? 1))
//             .toFixed2();
//     var myTotal = splitAmount + order.packagingCost;
//     splitAmountChecks.splitAmounts = List.generate(
//       int.parse(noOfGuestTEC.text),
//       (index) {
//         return SplitAmount(
//           guestName: 'Guest ${index + 1}',
//           orderId: "${order.orderId}-SC${index + 1}",
//           packagingCost: order.packagingCost,
//           splitAmount: splitAmount,
//           total: myTotal,
//           payment: null,
//         );
//       },
//     );

//     if (splitAmountChecks.splitAmounts.isNotEmpty) {
//       isSplitByAmount = true;
//     } else {
//       isSplitByAmount = false;
//     }
//     noOfGuestTEC.clear();
//     update();
//   }

//   removeToListOfSelectedItems(OrderModel item) {
//     if (item.payment == null) {
//       if (listOfSpitChecksByItems.contains(item)) {
//         listOfSpitChecksByItems.remove(item);
//         order.carts.addAll(item.carts);
//         calculateMainAmount();
//         itemListScrollToBottom();
//         updateGuestNames();
//         update();
//       }
//     } else {
//       PopupDialog.showErrorMessage('Unable to cancel. Check already paid!');
//     }
//   }

//   //****** create  SPLIT ORDER NEW   ******
//   splitOrderAddPackagingCost(int index) {
//     splitAmountChecks.splitAmounts[index].packagingCost =
//         BaseController.to.restaurantDetails?.restaurant.packagingCost.cost ?? 0;
//     listOfSpitChecksByItems = PosRepo.calculateSplitChecks(
//       listOfSpitChecksByItems,
//       customMaintenanceFee:
//           mainOrder.maintenanceFee / listOfSpitChecksByItems.length,
//     );
//     update();
//   }

//   // ****** remove Split Order ******
//   splitOrderRemovePackagingCost(int index) {
//     listOfSpitChecksByItems[index].packagingCost = 0;
//     listOfSpitChecksByItems = PosRepo.calculateSplitChecks(
//       listOfSpitChecksByItems,
//       customMaintenanceFee:
//           mainOrder.maintenanceFee / listOfSpitChecksByItems.length,
//     );
//     update();
//   }

//   CartModel? pickedItem;
//   OrderModel? pickedReceipt;
//   List<OrderModel> listOfSpitChecksByItems = [];
//   createNewReceipt() {
//     // all split amount is pending(unpaid)
//     if (splitAmountChecks.splitAmounts.isNotEmpty &&
//         splitAmountChecks.splitAmounts.every((item) => item.payment == null)) {
//       PopupDialog.customDialog(
//         width: 600.r,
//         child: PopupDialog.permissionDialog(
//           titleStyle: Get.theme.textTheme.headlineSmall,
//           Get.theme,
//           onSubmit: () async {
//             PopupDialog.showLoadingDialog();
//             bool isReset = await resetSplitChecks();
//             PopupDialog.closeLoadingDialog();
//             if (isReset) {
//               Get.back();
//             }
//           },
//           title: "Split Check is in progress.\nConfirm Reset?",
//         ),
//       );
//       return;
//     }
//     // one or more split amount is paid
//     if (splitAmountChecks.splitAmounts.isNotEmpty &&
//         splitAmountChecks.splitAmounts.any(
//           (item) => item.payment is PaymentModel,
//         )) {
//       PopupDialog.showErrorMessage('One or more Split Checks already settled');
//       return;
//     }
//     if (listOfSpitChecksByItems.length >= 20) {
//       PopupDialog.showErrorMessage('Maximum amount of order has been created!');
//       return;
//     }
//     isSplitByAmount = false;
//     listOfSpitChecksByItems.add(
//       OrderModel(
//         guestName: 'Guest ${listOfSpitChecksByItems.length + 1}',
//         orderId: "${mainOrder.orderId}-SC${listOfSpitChecksByItems.length + 1}",
//         orderType: order.orderType,
//         table: mainOrder.table ?? '',
//         tableName: mainOrder.tableName,
//         payment: null,
//         employee: mainOrder.employee,
//         numberOfPeople: mainOrder.numberOfPeople,
//         paymentStatus: 'UNPAID',
//         orderStatus: 'CONFIRMED',
//         packagingCost: mainOrder.packagingCost,
//         createdAt: mainOrder.createdAt,
//         updatedAt: mainOrder.updatedAt,
//         gratuityPercentage: mainOrder.gratuityPercentage,
//       ),
//     );
//     updateGuestNames();
//     splitChecksScrollToBottom();
//     listOfSpitChecksByItems = PosRepo.calculateSplitChecks(
//       listOfSpitChecksByItems,
//       customMaintenanceFee:
//           mainOrder.maintenanceFee / listOfSpitChecksByItems.length,
//     );
//     update();
//   }

//   void updateGuestNames() {
//     int guestCounter = 1;
//     for (var check in listOfSpitChecksByItems) {
//       if (check.guestName.startsWith('Guest ')) {
//         check.guestName = 'Guest $guestCounter';
//       }
//       guestCounter++;
//     }
//   }

//   void onItemSelect(CartModel item, OrderModel receipt) {
//     if (pickedItem != item) {
//       pickedItem = item;
//       pickedReceipt = receipt;
//     } else if (pickedItem == item) {
//       pickedItem = null;
//       pickedReceipt = null;
//     }
//     update();
//   }

//   // ***** move Item To Receipt and calculation splite price *****
//   void moveItemToReceipt(OrderModel target) {
//     if (pickedItem != null && pickedReceipt != null) {
//       pickedReceipt!.carts.remove(pickedItem);
//       kLogger.e("pickedItem and pickedReceipt");
//       target.carts.add(pickedItem!);
//       calculateMainAmount();
//       pickedItem = null;
//       pickedReceipt = null;
//     }
//     update();
//   }

//   // ****** calculate Main Amount ******
//   calculateMainAmount() {
//     order = PosRepo.recalculateOrderPrice(order);
//     // kLogger.e(order.totalOrderAmount);
//     // kLogger.e(order.payment?.toJson());
//     listOfSpitChecksByItems = PosRepo.calculateSplitChecks(
//       listOfSpitChecksByItems,
//       customMaintenanceFee:
//           mainOrder.maintenanceFee / listOfSpitChecksByItems.length,
//     );
//   }

//   // ****** breakdownItems ******
//   void breakdownItems() {
//     List<CartModel> dividedItems = [];
//     if (pickedItem != null) {
//       if (pickedItem!.quantity > 1) {
//         for (int i = 0; i < pickedItem!.quantity; i++) {
//           dividedItems.add(
//             CartModel(
//               id: pickedItem!.id,
//               itemId: pickedItem!.itemId,
//               name: pickedItem!.name,
//               price: pickedItem!.price,
//               quantity: 1,
//               discount: Discount(),
//             ),
//           );
//         }
//       } else {
//         dividedItems.add(pickedItem!);
//         PopupDialog.showErrorMessage(
//           "This item cannot be divided further. To Split a Single item, select 'Divide Items'",
//         );
//       }

//       order.carts.removeWhere((element) => element == pickedItem);
//       order.carts.addAll(dividedItems);
//     } else {
//       for (var item in order.carts) {
//         if (item.quantity > 1) {
//           for (int i = 0; i < item.quantity; i++) {
//             dividedItems.add(
//               CartModel(
//                 itemId: item.itemId,
//                 discount: Discount(),
//                 id: item.id,
//                 name: item.name,
//                 price: item.price,
//                 quantity: 1,
//               ),
//             );
//           }
//         } else {
//           dividedItems.add(item);
//         }
//       }
//       order.carts.clear();
//       order.carts.addAll(dividedItems);
//     }
//     update();
//   }

//   // ***** item can be 1, 1/2, 1/3, 1/4 *****
//   void divideItems(int divideBy) {
//     List<CartModel> items = [pickedItem!];
//     List<CartModel> dividedItems = [];

//     for (var item in items) {
//       CartModel it = item;
//       for (int i = 0; i < divideBy; i++) {
//         dividedItems.add(
//           it.copyWith(
//             price: it.price,
//             quantity: it.quantity / divideBy,
//             itemType: it.itemType,
//           ),
//         );
//       }

//       order.carts.remove(pickedItem!);
//       order.carts.addAll(dividedItems);
//       itemListScrollToBottom();
//     }
//     update();
//   }

//   // *****  save Split Checks To Main Order *****
//   Future<void> saveSplitChecksToMainOrder() async {
//     if (isSplitByAmount) {
//       // Split By Amount
//       mainOrder.splitAmounts = splitAmountChecks.splitAmounts;
//       await paySplitAmount();
//       DineInOrderController.to.clearOrderField();
//     }
//     if (!isSplitByAmount) {
//       //SPLIT ORDERS
//       await SplitRepo.newSplitOrder(
//         orderId: mainOrder.id,
//         splitOrders: listOfSpitChecksByItems,
//         restOfItems: listOfSpitChecksByItems.isEmpty ? [] : order.carts,
//       );
//     }

//     PosController.to.update();
//     // DataUpdateHelper.allGetApiCall();
//   }

//   Future splitOrderPayment(int index, PaymentModel payment) async {
//     listOfSpitChecksByItems[index].payment = payment;
//     listOfSpitChecksByItems[index].paymentStatus = "PAID";
//     // kLogger.e(listOfSpitChecksByItems[index].payment?.toJson());
//     // kLogger.e(index);
//     PopupDialog.showLoadingDialog();
//     bool isUpdate = await SplitRepo.newSplitOrder(
//       orderId: mainOrder.id,
//       splitOrders: listOfSpitChecksByItems,
//       restOfItems: order.carts,
//     );
//     PopupDialog.closeLoadingDialog();
//     if (isUpdate) {
//       mainOrder = PosController.to.myOrder;
//       order = mainOrder.copyWith(carts: mainOrder.splitOrderCarts);

//       // split order
//       listOfSpitChecksByItems = mainOrder.splitOrders;
//       calculateMainAmount();
//       Get.back();
//       update();
//     }
//   }

//   // ****** reset Split Checks ******
//   Future<bool> resetSplitChecks() async {
//     if ((mainOrder.splitAmounts.every((item) => item.payment == null)) &&
//         (order.splitAmounts.every((item) => item.payment == null)) &&
//         (splitAmountChecks.splitAmounts.every(
//           (item) => item.payment == null,
//         )) &&
//         (listOfSpitChecksByItems.every((item) => item.payment == null))) {
//       //
//       mainOrder.carts = List.from(mainCartItems);
//       order.carts = List.from(mainCartItems);
//       calculateMainAmount();
//       listOfSpitChecksByItems.clear();
//       isSplitByAmount = false;
//       splitAmountChecks.splitAmounts.clear();
//       pickedItem = null;

//       PopupDialog.showLoadingDialog();
//       await SplitRepo.clearSplitData(PosController.to.myOrder.id);
//       PopupDialog.closeLoadingDialog();
//       update();
//       return true;
//     } else {
//       PopupDialog.showErrorMessage('One or more Split Checks already paid');
//       return false;
//     }
//   }

//   // ***** scroll list to end ******
//   final ScrollController itemListScrollController = ScrollController();
//   void itemListScrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       itemListScrollController.animateTo(
//         itemListScrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     });
//   }

//   // ******* scroll split checks to end *******
//   final ScrollController splitChecksScrollController = ScrollController();
//   void splitChecksScrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       splitChecksScrollController.animateTo(
//         splitChecksScrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     });
//   }

//   // ******* API call *******
//   bool isPostingSplitAmount = false;
//   Future<bool> paySplitAmount() async {
//     isPostingSplitAmount = true;
//     update();

//     bool isSuccess = await SplitRepo.splitAmount(
//       orderId: mainOrder.id,
//       splitAmount: splitAmountChecks,
//     );

//     isPostingSplitAmount = false;
//     update();

//     return isSuccess;
//   }

//   @override
//   void onInit() {
//     mainOrder = PosController.to.myOrder;

//     if (mainOrder.splitOrderCarts.isEmpty && mainOrder.splitOrders.isEmpty) {
//       // For split amount or new split
//       order = mainOrder.copyWith();
//       if (mainOrder.splitAmounts.isNotEmpty) {
//         isSplitByAmount = true;
//         splitAmountChecks.splitAmounts.addAll(mainOrder.splitAmounts);
//       }
//     } else {
//       // Only for split order
//       // main order
//       order = mainOrder.copyWith(carts: mainOrder.splitOrderCarts);
//       // split order
//       listOfSpitChecksByItems = mainOrder.splitOrders;
//       isSplitByAmount = false;
//       calculateMainAmount();
//     }
//     totalAmountTEC.text = mainOrder.totalOrderAmount.toStringAsFixed(2);
//     super.onInit();
//   }
// }
import 'package:flutter/material.dart';
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
    // FIX: khali input dile int.parse crash korto, 0 dile divide by zero hoto
    final int guests = int.tryParse(noOfGuestTEC.text.trim()) ?? 0;
    if (guests < 1) {
      isSplitByAmount = splitAmountChecks.splitAmounts.isNotEmpty;
      noOfGuestTEC.clear();
      update();
      return;
    }

    // FIX: integer cents-e bhag. Age toFixed2 kore protita guest-er amount
    // round hoto, tai $100 / 3 = 33.33 x 3 = 99.99 (1 cent harato).
    // Ekhon baki cent prothom guest-der 1 cent kore jay: 33.34, 33.33, 33.33
    final int amountCents =
        (order.totalOrderAmount - order.packagingCost).toCentsInt();
    final int packagingCents = order.packagingCost.toCentsInt();
    final int baseCents = amountCents ~/ guests;
    final int extraCents = amountCents - (baseCents * guests);

    splitAmountChecks.splitAmounts = List.generate(
      guests,
      (index) {
        final int shareCents = baseCents + (index < extraCents ? 1 : 0);
        return SplitAmount(
          guestName: 'Guest ${index + 1}',
          orderId: "${order.orderId}-SC${index + 1}",
          packagingCost: order.packagingCost,
          splitAmount: shareCents / 100,
          total: (shareCents + packagingCents) / 100,
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
        // FIX: purono selection clear. Na korle removed check-er item select thakto,
        // ar onno check-e tap korle item main + oi check dui jaygay thakto
        _clearPick();
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
    // FIX: age bhul list (splitAmountChecks) change hoto, split order-e packaging add hoto na
    listOfSpitChecksByItems[index].packagingCost =
        BaseController.to.restaurantDetails?.restaurant.packagingCost.cost ?? 0;
    _recalculateSplitChecks();
    update();
  }

  // ****** remove Split Order ******
  splitOrderRemovePackagingCost(int index) {
    listOfSpitChecksByItems[index].packagingCost = 0;
    _recalculateSplitChecks();
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
        // FIX: age length + 1 use hoto. SC1, SC2, SC3 theke SC1 remove kore
        // notun check banale abar SC3 hoto (duplicate orderId)
        orderId: "${mainOrder.orderId}-SC${_nextSplitCheckNumber()}",
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
    _recalculateSplitChecks();
    update();
  }

  /// Ekhon porjonto use hoyeche emon sobcheye boro -SC number + 1
  int _nextSplitCheckNumber() {
    int maxNo = 0;
    final pattern = RegExp(r'-SC(\d+)$');
    for (final check in listOfSpitChecksByItems) {
      final match = pattern.firstMatch(check.orderId);
      final no = int.tryParse(match?.group(1) ?? '') ?? 0;
      if (no > maxNo) maxNo = no;
    }
    return maxNo + 1;
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
      // FIX: item tokhon-i add hobe jokhon age source receipt theke sotti remove hoyeche.
      // Age remove fail korleo (purono selection) add hoye jeto, tai item duplicate hoto.
      final bool canMove =
          _isLiveReceipt(pickedReceipt) &&
          _isLiveReceipt(target) &&
          (identical(target, order) || target.payment == null) &&
          pickedReceipt!.carts.remove(pickedItem);
      if (canMove) {
        kLogger.e("pickedItem and pickedReceipt");
        target.carts.add(pickedItem!);
        calculateMainAmount();
      }
      _clearPick();
    }
    update();
  }

  // ****** calculate Main Amount ******
  calculateMainAmount() {
    order = PosRepo.recalculateOrderPrice(order);
    // kLogger.e(order.totalOrderAmount);
    // kLogger.e(order.payment?.toJson());
    _recalculateSplitChecks();
  }

  // ****** breakdownItems ******
  void breakdownItems() {
    if (pickedItem != null) {
      final List<CartModel>? dividedItems = _breakdownPieces(pickedItem!);
      if (dividedItems == null) {
        // selection rakha holo jate user sathe sathe 'Divide Items' chapte pare
        PopupDialog.showErrorMessage(
          "This item cannot be divided further. To Split a Single item, select 'Divide Items'",
        );
      } else {
        // FIX: age sobsomoy left MAIN receipt (order.carts)-e add hoto. Right side-er
        // item select korle original item check-ei theke jeto + left-e notun item add hoto,
        // tai quantity double hoto. Ekhon item jei receipt-e ache sekhanei bhange.
        if (_replacePickedWith(dividedItems)) {
          calculateMainAmount();
        }
        _clearPick();
      }
    } else {
      // kono item select na thakle MAIN receipt-er sob item bhange (ager moto)
      final List<CartModel> dividedItems = [];
      for (var item in order.carts) {
        dividedItems.addAll(_breakdownPieces(item) ?? [item]);
      }
      order.carts.clear();
      order.carts.addAll(dividedItems);
      calculateMainAmount();
    }
    update();
  }

  // ***** item can be 1, 1/2, 1/3, 1/4 *****
  void divideItems(int divideBy) {
    final CartModel? item = pickedItem;
    if (item == null || divideBy < 2) return;

    final List<CartModel> dividedItems = List.generate(
      divideBy,
      (_) => _cloneItem(item, quantity: item.quantity / divideBy),
    );

    // FIX: breakdown-er moto ekhaneo item jei receipt-e ache sekhanei bhag hoy
    if (_replacePickedWith(dividedItems)) {
      calculateMainAmount();
      itemListScrollToBottom();
    }
    _clearPick();
    update();
  }

  // ****** selection & item helpers ******
  void _clearPick() {
    pickedItem = null;
    pickedReceipt = null;
  }

  /// receipt-ta ki ekhono screen-e ache (left MAIN ba kono right SPLIT check)?
  /// Check remove ba payment-er por purono receipt object ar list-e thake na.
  bool _isLiveReceipt(OrderModel? receipt) {
    if (receipt == null) return false;
    return identical(receipt, order) ||
        listOfSpitChecksByItems.any((check) => identical(check, receipt));
  }

  /// Item-er puro copy: discount, discountAmount, kitchenNote, modifiers,
  /// variationOptions, printers, itemType sob thake.
  /// (Age breakdown notun CartModel banato, tai discount ar modifier harato.)
  CartModel _cloneItem(CartModel item, {required num quantity}) {
    return item.copyWith(
        quantity: quantity,
        printers: List.of(item.printers),
        variationOptions: List.of(item.variationOptions),
        modifiers: List.of(item.modifiers),
      )
      ..createdAt = item.createdAt
      ..updatedAt = item.updatedAt;
  }

  /// quantity 3 -> 1, 1, 1 ; quantity 2.5 -> 1, 1, 0.5 (mot quantity same thake).
  /// quantity 1 ba tar kom hole null (ar bhanga jay na).
  /// FIX: age `i < quantity` loop-e 1.5 theke 2 ta item hoto (quantity bere jeto).
  List<CartModel>? _breakdownPieces(CartModel item) {
    if (item.quantity <= 1) return null;
    final int whole = item.quantity.floor();
    final num rest = item.quantity - whole;
    return [
      for (int i = 0; i < whole; i++) _cloneItem(item, quantity: 1),
      if (rest > 0.000001) _cloneItem(item, quantity: rest),
    ];
  }

  /// Selected item-ke tar nijer receipt theke remove kore pieces gulo
  /// oi receipt-er sheshe add kore (ager moto list-er sheshe).
  /// Selection purono hole ba check paid hole kichui kore na.
  bool _replacePickedWith(List<CartModel> pieces) {
    final CartModel? item = pickedItem;
    final OrderModel? receipt = pickedReceipt;
    if (item == null ||
        receipt == null ||
        !_isLiveReceipt(receipt) ||
        (!identical(receipt, order) && receipt.payment != null)) {
      return false;
    }
    if (!receipt.carts.remove(item)) return false;
    receipt.carts.addAll(pieces);
    return true;
  }

  /// Split check-gulo abar calculate kore. Service fee integer cents-e bhag hoy:
  /// - paid check-er fee change hoy na (age notun check banale paid check-er total bodlato)
  /// - baki fee unpaid check-der moddhe bhag, baki cent prothom check-gulo 1 cent kore pay
  ///   (age fee / n round hoye $5 / 3 = 1.67 x 3 = 5.01 hoto)
  void _recalculateSplitChecks() {
    final List<OrderModel> checks = List.of(listOfSpitChecksByItems);
    final List<OrderModel> unpaid =
        checks.where((check) => check.payment == null).toList();

    int paidFeeCents = 0;
    for (final check in checks) {
      if (check.payment != null) {
        paidFeeCents += check.maintenanceFee.toCentsInt();
      }
    }
    int remainingCents = mainOrder.maintenanceFee.toCentsInt() - paidFeeCents;
    if (remainingCents < 0) remainingCents = 0;

    final int baseCents = unpaid.isEmpty ? 0 : remainingCents ~/ unpaid.length;
    final int extraCents = remainingCents - (baseCents * unpaid.length);

    listOfSpitChecksByItems = [
      for (final check in checks)
        if (check.payment != null)
          PosRepo.recalculateOrderPrice(check)
        else
          PosRepo.recalculateOrderPrice(
            check,
            customMaintenanceFee:
                (baseCents + (unpaid.indexOf(check) < extraCents ? 1 : 0)) /
                100,
          ),
    ];
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

  Future<bool> splitOrderPayment(int index, PaymentModel payment) async {
    final OrderModel check = listOfSpitChecksByItems[index];
    final String previousPaymentStatus = check.paymentStatus;
    check.payment = payment;
    check.paymentStatus = "PAID";
    // kLogger.e(listOfSpitChecksByItems[index].payment?.toJson());
    // kLogger.e(index);
    PopupDialog.showLoadingDialog();
    bool isUpdate = await SplitRepo.newSplitOrder(
      orderId: mainOrder.id,
      splitOrders: listOfSpitChecksByItems,
      restOfItems: order.carts,
    );
    PopupDialog.closeLoadingDialog();

    if (!isUpdate) {
      // FIX: order update fail korle payment object check-e theke jeto (PAID dekhato),
      // tai split reset kora jeto na. Server-e save hoyni, tai local-eo UNPAID kore dao.
      check.payment = null;
      check.paymentStatus = previousPaymentStatus;
      calculateMainAmount();
      update();
      _showPaymentNotSavedMessage(payment);
      return false;
    }

    if (isUpdate) {
      mainOrder = PosController.to.myOrder;
      order = _workingCopyOfMainOrder(mainOrder.splitOrderCarts);

      // split order
      listOfSpitChecksByItems = mainOrder.splitOrders;
      // FIX: list server theke notun object diye replace hoy, purono selection clear
      _clearPick();
      calculateMainAmount();
      Get.back();
      update();
    }
    return true;
  }

  /// Payment server-e save hoyni, check abar UNPAID.
  /// Sob payment type-e same short message; puro payment (Txn soho) log-e thake.
  void _showPaymentNotSavedMessage(PaymentModel payment) {
    kLogger.e(
      "Split payment not saved, reverted to UNPAID: ${payment.toJson()}",
    );
    PopupDialog.showErrorMessage(
      "Check not saved.",
      duration: const Duration(seconds: 4),
    );
  }

  // ****** reset Split Checks ******
  Future<bool> resetSplitChecks() async {
    if ((mainOrder.splitAmounts.every((item) => item.payment == null)) &&
        (order.splitAmounts.every((item) => item.payment == null)) &&
        (splitAmountChecks.splitAmounts.every(
          (item) => item.payment == null,
        )) &&
        (listOfSpitChecksByItems.every((item) => item.payment == null))) {
      // FIX: age local cart (mainCartItems diye, ja kokhono set hoto na = []) khali
      // kore tarpor API call hoto. API fail korle order-er sob item screen theke
      // (ar POS order theke) muche jeto. Ekhon age server clear, success hole local reset.
      PopupDialog.showLoadingDialog();
      final bool isCleared = await SplitRepo.clearSplitData(
        PosController.to.myOrder.id,
      );
      PopupDialog.closeLoadingDialog();
      if (!isCleared) {
        update();
        return false;
      }

      // clearSplitData mainOrder-ke server-er fresh order diye set kore
      mainCartItems = List.of(mainOrder.carts);
      order = _workingCopyOfMainOrder(mainOrder.carts);
      listOfSpitChecksByItems = [];
      isSplitByAmount = false;
      splitAmountChecks.splitAmounts.clear();
      _clearPick();
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

  /// Je split amount-gulor payment server-e save hoyeche (object identity diye).
  /// Payment dialog API call-er age-i `splitAmounts[i].payment` set kore dey,
  /// tai fail hole kon payment notun (save hoyni) seta ei set diye bojha jay.
  final Set<SplitAmount> _savedPaidSplitAmounts = Set.identity();

  void _markSplitAmountPaymentsSaved() {
    _savedPaidSplitAmounts
      ..clear()
      ..addAll(
        splitAmountChecks.splitAmounts.where((split) => split.payment != null),
      );
  }

  Future<bool> paySplitAmount() async {
    isPostingSplitAmount = true;
    update();

    bool isSuccess = await SplitRepo.splitAmount(
      orderId: mainOrder.id,
      splitAmount: splitAmountChecks,
    );

    if (isSuccess) {
      _markSplitAmountPaymentsSaved();
    } else {
      // FIX: fail hole notun payment object split amount-e theke jeto, tai reset
      // kora jeto na ("One or more Split Checks already paid"). Ekhon UNPAID kore dey.
      for (final split in splitAmountChecks.splitAmounts) {
        final PaymentModel? payment = split.payment;
        if (payment != null && !_savedPaidSplitAmounts.contains(split)) {
          split.payment = null;
          _showPaymentNotSavedMessage(payment);
        }
      }
    }

    isPostingSplitAmount = false;
    update();

    return isSuccess;
  }

  @override
  void onInit() {
    mainOrder = PosController.to.myOrder;

    mainCartItems = List.of(mainOrder.carts);

    if (mainOrder.splitOrderCarts.isEmpty && mainOrder.splitOrders.isEmpty) {
      // For split amount or new split
      order = _workingCopyOfMainOrder(mainOrder.carts);
      if (mainOrder.splitAmounts.isNotEmpty) {
        isSplitByAmount = true;
        splitAmountChecks.splitAmounts.addAll(mainOrder.splitAmounts);
        // server theke asa paid split amount gulo already saved
        _markSplitAmountPaymentsSaved();
      }
    } else {
      // Only for split order
      // main order
      order = _workingCopyOfMainOrder(mainOrder.splitOrderCarts);
      // split order
      listOfSpitChecksByItems = mainOrder.splitOrders;
      isSplitByAmount = false;
      calculateMainAmount();
    }
    totalAmountTEC.text = mainOrder.totalOrderAmount.toStringAsFixed(2);
    super.onInit();
  }

  /// Left MAIN receipt-er jonno working copy.
  /// FIX 1: carts-er alada list. Age copyWith() same list share korto, ar mainOrder
  ///        holo PosController.to.myOrder, tai item move/breakdown korle POS order-er
  ///        cart memory-te direct bodle jeto (save fail korle order bhanga thakto).
  /// FIX 2: OrderModel.copyWith gratuityPercentage drop kore, tai main receipt-e
  ///        order-er custom gratuity-r bodole default % diye calculate hoto.
  OrderModel _workingCopyOfMainOrder(List<CartModel> carts) {
    return mainOrder.copyWith(carts: List.of(carts))
      ..gratuityPercentage = mainOrder.gratuityPercentage;
  }
}
