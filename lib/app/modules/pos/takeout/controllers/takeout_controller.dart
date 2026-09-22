import 'package:yogo_pos/app/modules/pos/dine-in-orders/models/meta_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TakeOutController extends GetxController {
  static TakeOutController get to => Get.find();

  bool isUnPaidView = true;
  onChangePaidView(bool value) {
    isUnPaidView = value;
    update();
  }

  // !PAID
  List<OrderModel> paidTakeOutList = [];
  MetaModel? paidPagination;
  getAllTakeOutPaidOrders({
    String paymentStatus = "PAID",
    // String orderType = "TAKEOUT",
    String? page,
    String? limit = "40",
    String? search,
  }) async {
    Map<String, dynamic>? queryParameters = {
      "day": "2",
      // "orderStatus": orderStatus,
      // "orderType": orderType,
      "paymentStatus": paymentStatus,
      "startDate": DateFormat('yyyy-MM-dd').format(
          DateTime.now().subtract(const Duration(days: 2)).toTimeZone()),
      "endDate": DateFormat('yyyy-MM-dd').format(DateTime.now().toTimeZone()),
      if (page != null) "page": page,
      if (limit != null) "limit": limit,
      if (search != null) "search": search,
      // "takeoutType": "PHONE",
      "takeoutType": "WALK_IN",
    };
    try {
      var res = await BaseController.to.apiService
          .makeGetRequest(URLS.takeoutOrders, queryParameters: queryParameters);
      if (res.statusCode == 200) {
        paidTakeOutList.assignAll((res.data["data"] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList());
        paidPagination = MetaModel.fromJson(res.data["meta"]);
        update();
      }
      // kLogger.e(res.data["meta"]);
      // kLogger.e(pagination?.total);
    } catch (e) {
      kLogger.e('Error from %%%% get All TakeOut Paid Orders %%%% => $e');
    }
  }

  // ! UNPAID
  List<OrderModel> unPaidTakeOutList = [];
  MetaModel? unPaidPagination;
  getAllTakeOutUnPaidOrders({
    // String orderStatus = "CONFIRMED",
    String paymentStatus = "UNPAID",
    // String orderType = "TAKEOUT",
    String? page,
    String? limit = "40",
    String? search,
  }) async {
    //DateFormat('yyyy-MM-dd').format(date)
    Map<String, dynamic>? queryParameters = {
      "day": "2",
      // "orderStatus": orderStatus,
      // "orderType": orderType,
      "paymentStatus": paymentStatus,
      "startDate": DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 2))),
      "endDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      if (page != null) "page": page,
      if (limit != null) "limit": limit,
      if (search != null) "search": search,
      // "takeoutType": "PHONE",
      "takeoutType": "WALK_IN",
    };
    try {
      var res = await BaseController.to.apiService
          .makeGetRequest(URLS.takeoutOrders, queryParameters: queryParameters);
      if (res.statusCode == 200) {
        unPaidTakeOutList.assignAll((res.data["data"] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList());
        unPaidPagination = MetaModel.fromJson(res.data["meta"]);
        update();
      }
      // kLogger.e(res.data["meta"]);
      // kLogger.e(pagination?.total);
    } catch (e) {
      kLogger.e('Error from %%%% get All TakeOut UnPaid Orders %%%% => $e');
    }
  }

  @override
  void onInit() {
    getAllTakeOutPaidOrders();
    getAllTakeOutUnPaidOrders();

    super.onInit();
  }
}
