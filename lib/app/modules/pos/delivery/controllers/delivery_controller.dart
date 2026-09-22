import 'package:yogo_pos/app/modules/pos/dine-in-orders/models/meta_model.dart';
import 'package:yogo_pos/app/modules/pos/onlineOrder/repo/online_order_repo.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DeliveryController extends GetxController {
  static DeliveryController get to => Get.find();

  int unseenUnpaidOrders = 0;
  int unseenOrders = 0;
  int unseenPaidOrders = 0;

  bool isUnPaidView = true;
  onChangePaidView(bool value) {
    isUnPaidView = value;
    update();
  }

  // !PAID
  List<OrderModel> paidDeliveryList = [];
  MetaModel? paidPagination;
  Future<void> getAllDeliveryPaidOrders({
    String paymentStatus = "PAID",
    String orderType = "DELIVERY",
    String? page,
    String? limit = "40",
    String? search,
  }) async {
    Map<String, dynamic>? queryParameters = {
      "day": "2",
      "orderType": orderType,
      "paymentStatus": paymentStatus,
      "startDate": DateFormat('yyyy-MM-dd').format(
          DateTime.now().subtract(const Duration(days: 2)).toTimeZone()),
      "endDate": DateFormat('yyyy-MM-dd').format(DateTime.now().toTimeZone()),
      if (page != null) "page": page,
      if (limit != null) "limit": limit,
      if (search != null) "search": search,
    };
    try {
      var res = await BaseController.to.apiService
          .makeGetRequest(URLS.orders, queryParameters: queryParameters);
      if (res.statusCode == 200) {
        paidDeliveryList.assignAll((res.data["data"] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList());
        paidPagination = MetaModel.fromJson(res.data["meta"]);
        unseenPaidOrders =
            paidDeliveryList.where((order) => order.orderSeen == false).length;
        unseenOrders = unseenUnpaidOrders + unseenPaidOrders;
        update();
      }
      // kLogger.e(res.data["meta"]);
      // kLogger.e(pagination?.total);
    } catch (e) {
      kLogger.e('Error from %%%% get All Delivery Paid Orders %%%% => $e');
    }
  }

  // ! UNPAID
  List<OrderModel> unPaidDeliveryList = [];
  MetaModel? unPaidPagination;
  Future<void> getAllDeliveryUnPaidOrders({
    String paymentStatus = "UNPAID",
    String orderType = "DELIVERY",
    String? page,
    String? limit = "40",
    String? search,
  }) async {
    //DateFormat('yyyy-MM-dd').format(date)
    Map<String, dynamic>? queryParameters = {
      "day": "2",
      "orderStatus": "CONFIRMED",
      "orderType": orderType,
      "paymentStatus": paymentStatus,
      "startDate": DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 2))),
      "endDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      if (page != null) "page": page,
      if (limit != null) "limit": limit,
      if (search != null) "search": search,
      // "takeoutType": "PHONE",
      // "takeoutType": "WALK_IN",
    };
    try {
      var res = await BaseController.to.apiService
          .makeGetRequest(URLS.orders, queryParameters: queryParameters);
      if (res.statusCode == 200) {
        unPaidDeliveryList.assignAll((res.data["data"] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList());
        unseenUnpaidOrders = unPaidDeliveryList
            .where((order) => order.orderSeen == false)
            .length;

        unseenOrders = unseenUnpaidOrders + unseenPaidOrders;
        unPaidPagination = MetaModel.fromJson(res.data["meta"]);
        update();
      }
      // kLogger.e(res.data["meta"]);
      // kLogger.e(pagination?.total);
    } catch (e) {
      kLogger.e('Error from %%%% get All Delivery UnPaid Orders %%%% => $e');
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

  Future<void> getOrders() async {
    await Future.wait([
      getAllDeliveryUnPaidOrders(),
      getAllDeliveryPaidOrders(),
    ]);
  }

  @override
  void onInit() {
    getAllDeliveryPaidOrders();
    getAllDeliveryUnPaidOrders();

    super.onInit();
  }
}
