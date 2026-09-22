import 'package:flutter/widgets.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/models/meta_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/modules/pos/repo/order_repo.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/duration_extension.dart';
import 'package:yogo_pos/app/utils/extension/formatted_phone.dart';
import 'package:yogo_pos/app/utils/extension/string_manipulation_extension.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/order_status_model.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class DineInOrderController extends GetxController {
  static DineInOrderController get to => Get.find();

  RxString query = ''.obs;

  bool dineIn = BaseController.to.restaurantDetails?.restaurant.dineIn ?? false;

  TextEditingController search = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController serverStartDate = TextEditingController();
  TextEditingController serverEndDate = TextEditingController();
  late List<String> orderTypeList = OrderRepo.myOrderTypes();
  late String? selectedOrderType = OrderRepo.myOrderTypes().isNotEmpty
      ? OrderRepo.myOrderTypes().first
      : null;
  String selectedOrderStatus = '';

  int orderStatusActiveIndex = -1;
  List<OrderStatusModel> orderStatusList = [];
  getOrderStatus({String? startDate, String? endDate}) async {
    Map<String, dynamic>? queryParameters = {
      "orderType": checkOrderType(selectedOrderType),
      if (startDate != null) "startDate": startDate,
      if (endDate != null) "endDate": endDate,
      if (selectedOrderType == "ONLINE" || selectedOrderType == "TAKEOUT")
        "takeoutType": selectedOrderType == "TAKEOUT"
            ? "WALK_IN"
            : selectedOrderType,
    };
    try {
      var res = await BaseController.to.apiService.makeGetRequest(
        URLS.orderStatus,
        queryParameters: queryParameters,
      );
      if (res.statusCode == 200) {
        orderStatusList.assignAll(
          (res.data["data"] as List)
              .map((e) => OrderStatusModel.fromJson(e))
              .toList(),
        );
        update();
      }
    } catch (e) {
      kLogger.e('Error from %%%% OrderStatus %%%% => $e');
    }
  }

  String? checkOrderType(String? orderType) {
    switch (orderType) {
      case "ONLINE":
        return "TAKEOUT";
      case "TAKEOUT":
        return "TAKEOUT";
      case "DINE_IN":
        return "DINE_IN";
      case "DELIVERY":
        return "DELIVERY";
      default:
        return null;
    }
  }

  MetaModel? pagination;
  List<OrderModel> orderList = [];
  getAllOrders({
    String? orderStatus,
    String? startDate,
    String? endDate,
    String? page,
    String? limit = "10",
    String? search,
  }) async {
    Map<String, dynamic>? queryParameters = {
      //
      if (orderStatus != null) "orderStatus": orderStatus,
      "orderType": checkOrderType(selectedOrderType),
      if (startDate != null) "startDate": startDate,
      if (endDate != null) "endDate": endDate,
      if (page != null) "page": page,
      if (limit != null) "limit": limit,
      if (search != null) "search": search,
      if (selectedOrderType == "ONLINE" || selectedOrderType == "TAKEOUT")
        "takeoutType": selectedOrderType == "TAKEOUT"
            ? "WALK_IN"
            : selectedOrderType,
    };
    try {
      var res = await BaseController.to.apiService.makeGetRequest(
        URLS.orders,
        queryParameters: queryParameters,
      );
      if (res.statusCode == 200) {
        orderList.assignAll(
          (res.data["data"] as List)
              .map((e) => OrderModel.fromJson(e))
              .toList(),
        );
        pagination = MetaModel.fromJson(res.data["meta"]);
        update();
      }
      // kLogger.e(res.data["meta"]);
      // kLogger.e(pagination?.total);
    } catch (e) {
      kLogger.e('Error from %%%% OrderStatus %%%% => $e');
    }
  }

  // Export
  List<OrderModel> orderListForExport = [];
  getAllOrdersForExport({
    String? orderStatus,
    String? startDate,
    String? endDate,
    String? page,
    String? search,
  }) async {
    Map<String, dynamic>? queryParameters = {
      if (orderStatus != null) "orderStatus": orderStatus,
      "orderType": checkOrderType(selectedOrderType),
      if (startDate != null) "startDate": startDate,
      if (endDate != null) "endDate": endDate,
      if (page != null) "page": page,
      "limit": pagination?.total == null ? "20" : "${pagination?.total}",
      if (search != null) "search": search,
      if (selectedOrderType == "ONLINE" || selectedOrderType == "TAKEOUT")
        "takeoutType": selectedOrderType == "TAKEOUT"
            ? "WALK_IN"
            : selectedOrderType,
    };
    try {
      var res = await BaseController.to.apiService.makeGetRequest(
        URLS.orders,
        queryParameters: queryParameters,
      );
      if (res.statusCode == 200) {
        orderListForExport.assignAll(
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

  clearOrderField() {
    endDate.clear();
    startDate.clear();
    serverEndDate.clear();
    serverStartDate.clear();
    search.clear();
    orderStatusActiveIndex = -1;
    selectedOrderStatus = "";
    selectedOrderType = OrderRepo.myOrderTypes().isNotEmpty
        ? OrderRepo.myOrderTypes().first
        : "";
    update();
  }

  // ! ===== export Excel =====
  void createExcelFile(List<OrderModel> orders) async {
    // Create a new Excel document
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Orders';

    // Add the header row
    int rowIndex = 1;
    int columnIndex = 1;

    final headers = [
      'No.',
      'Token No.',
      'Check No.',
      'Check Type',
      'Check Status',
      'Table No.',
      'Address',
      'Employee Name',
      'Guest Name',
      'Total Guest',
      'Phone Number',
      'OPT',
      'OCT',
      'AOT',
      'Notes',
      'Takeout Type',
      'Pay. Pro.',
      'Pay. Type',
      '${BaseController.to.restaurantDetails?.restaurant.packagingCost.title}',
      'Discount',
      'Gratuity',
      'GST',
      'PST',
      'PST2',
      'Service Fee',
      'Delivery Fee',
      'Subtotal',
      'Tip',
      'Rounded',
      'Total Amount',
    ];

    for (var header in headers) {
      sheet.getRangeByIndex(rowIndex, columnIndex).setText(header);
      columnIndex++;
    }

    // Add data rows
    for (int i = 0; i < orders.length; i++) {
      var order = orders[i];
      rowIndex++;
      columnIndex = 1;

      final rowData = [
        i + 1, // Integer
        order.tokenId, // String
        order.orderId, // String
        order.orderType.replaceAll("_", "-"), // String
        order.orderStatus.toLowerCase() == "canceled"
            ? "Cancelled"
            : order.orderStatus,
        order.tableName.orNA(), // String
        MyFunc.orNA(order.delivery?.address),
        MyFunc.orNA(order.employee?.firstName.toUpperCase()), // String
        order.guestName, // String
        order.numberOfPeople, // Integer
        order.guestPhoneNumber.toFormattedPhone(), // String
        order.createdAt.toStringAsSecondaryFormat(), // String
        order.updatedAt.toStringAsSecondaryFormat(), // String
        order.updatedAt!
            .difference(order.createdAt!)
            .formatDateDifference(), // String
        order.notes.orNA(), // String
        order.takeOutType?.replaceAll("_", "-").orNA(), // String
        order.payment?.providerName.toCapitalizeEachWord(), // String
        order.payment?.methods.isNotEmpty == true
            ? order.payment!.methods.join(', ').replaceAll('_', ' ')
            : order.payment?.method.isNotEmpty == true
            ? order.payment!.method
            : "N/A", // String

        order.packagingCost, // Double
        order.totalDiscount, // Double
        order.totalGratuity, // Double
        order.totalGst, // Double
        order.totalPst, // Double
        order.totalPst2, // Double
        order.maintenanceFee, // Double
        order.deliveryFee, // Double
        order.subTotal, // Double
        order.tip, // Double
        order.extraAmount ?? order.payment?.extraAmount ?? 0,
        order.totalOrderAmount, // Double
      ];

      for (var cellData in rowData) {
        final cell = sheet.getRangeByIndex(rowIndex, columnIndex);

        // Check the data type and set the value accordingly
        if (cellData is int) {
          cell.setNumber(cellData.toDouble()); // Set integer as a number
        } else if (cellData is double) {
          cell.setNumber(cellData); // Set double as a number
        } else if (cellData is String) {
          cell.setText(cellData); // Set string as text
        } else {
          cell.setText(
            '',
          ); // Default to an empty string for null or unsupported types
        }

        columnIndex++;
      }
    }

    // Save the Excel file
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    Directory? directory = await getDownloadsDirectory();
    if (directory != null) {
      String fileName = getUniqueFileName(directory.path, "orders.xlsx");
      String outputPath = "${directory.path}\\$fileName";

      File(outputPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);

      PopupDialog.showSuccessDialog("Excel file created successfully!");
    } else {
      PopupDialog.animatedDialog(
        isErr: true,
        title: "Could not find the Downloads directory.",
      );
    }
  }

  // Function to find a unique filename
  String getUniqueFileName(String dir, String baseFileName) {
    int count = 1;
    String fileName = baseFileName;
    String filePath = "$dir\\$fileName";

    while (File(filePath).existsSync()) {
      fileName = "orders_${count++}.xlsx";
      filePath = "$dir\\$fileName";
    }
    return fileName;
  }

  initOrder() {
    Future.delayed(const Duration(seconds: 5), () {
      getOrderStatus(
        // orderType:
        //     (selectedOrderType == "ONLINE" ? "TAKEOUT" : selectedOrderType),
        // takeoutType: (selectedOrderType == "TAKEOUT"
        //     ? "WALK_IN"
        //     : selectedOrderType == "ONLINE"
        //         ? "ONLINE"
        //         : null),
      );
      getAllOrders(
        // orderType:
        //     (selectedOrderType == "ONLINE" ? "TAKEOUT" : selectedOrderType),
        // takeoutType: (selectedOrderType == "TAKEOUT"
        //     ? "WALK_IN"
        //     : selectedOrderType == "ONLINE"
        //         ? "ONLINE"
        //         : null),
      );
    });
  }

  onChangeOrderStatus(int index) async {
    selectedOrderType = orderTypeList[index];
    PopupDialog.showLoadingDialog();
    await getAllOrders(
      // orderType:
      //     (selectedOrderType == "ONLINE" ? "TAKEOUT" : selectedOrderType),
      // takeoutType: (selectedOrderType == "TAKEOUT"
      //     ? "WALK_IN"
      //     : selectedOrderType == "ONLINE"
      //         ? "ONLINE"
      //         : null),
      endDate: serverEndDate.text.isEmpty ? null : serverEndDate.text,
      startDate: serverStartDate.text.isEmpty ? null : serverStartDate.text,
      orderStatus: selectedOrderStatus.isEmpty ? null : selectedOrderStatus,
      search: search.text.isEmpty ? null : search.text,
    );
    await getOrderStatus(
      endDate: serverEndDate.text.isEmpty ? null : serverEndDate.text,
      startDate: serverStartDate.text.isEmpty ? null : serverStartDate.text,
    );
    PopupDialog.closeLoadingDialog();

    update();
  }

  @override
  void onInit() {
    debounce(query, (String value) {
      getAllOrders(
        endDate: serverEndDate.text.isEmpty ? null : serverEndDate.text,
        startDate: serverStartDate.text.isEmpty ? null : serverStartDate.text,
        orderStatus: selectedOrderStatus.isEmpty ? null : selectedOrderStatus,
        search: value.isEmpty ? null : value,
      );
    }, time: Duration(seconds: 1));
    // search.addListener(() {
    //   query.value = search.text;
    // });
    initOrder();

    super.onInit();
  }
}
