
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/models/table_mapping_management_model.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

import '../../../../services/controller/base_controller.dart';
import '../../../../utils/static_colors.dart';

class TableMappingController extends GetxController {
  static TableMappingController get to => Get.find();

  final RxList<TableMappingModel> tables = <TableMappingModel>[].obs;
  final RxString selectedCategoryId = ''.obs;

  @override
  void onInit() {
    getMappingALlTables();
    super.onInit();
  }

  void selectCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
  }

  void selectAllTables() {
    selectedCategoryId.value = '';
  }

  Color getTableColor1(TableMappingModel table) {
    final isSelected = selectedCategoryId.value.isEmpty ||
        table.tableCategory.id == selectedCategoryId.value;

    if (isSelected) {
      return _getStatusColor(table.tableAvailability);
    } else {
      return const Color(0xFF9CA3AF); // grey
    }
  }
  Color getTableColor(TableMappingModel table) {

    if (table.tableAvailability == "BOOKING") {
      return _getStatusColor("BOOKING"); // yellow/orange
    }


    final isSelected = selectedCategoryId.value.isEmpty ||
        table.tableCategory.id == selectedCategoryId.value;

    if (isSelected) {
      return _getStatusColor(table.tableAvailability);
    } else {
      return const Color(0xFF9CA3AF); // grey
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'HOLD_TABLES':
        return  OrderColors.hold; // pink
      case 'BOOKING':
        return OrderColors.booked; // yellow/orange
      case 'AVAILABLE':
        return OrderColors.available; // green
      default:
        return const Color(0xff9CA3AF); // grey
    }
  }

  Future<void> getMappingALlTables() async {
    try {
      var res = await BaseController.to.apiService.makeGetRequest(URLS.tableHold);
      if (res.statusCode == 200) {
        List<dynamic> list = res.data['data'];
        tables.value = list
            .map((json) => TableMappingModel.fromJson(json))
            .toList();
      } else {
        PopupDialog.showErrorMessage(res.data['message']);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> onChangeTableStatus({required String id, required String status}) async {
    Map<String, dynamic> data = {"tableAvailability": status};
    PopupDialog.showLoadingDialog();
    var res = await BaseController.to.apiService.makePatchRequest("${URLS.tableHold}/$id", data);
    PopupDialog.closeLoadingDialog();
    if (res.statusCode == 200) {
      getMappingALlTables();
    }
  }
}
