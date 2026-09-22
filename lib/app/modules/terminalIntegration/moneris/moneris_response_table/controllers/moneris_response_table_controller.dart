import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/moneris/moneris_response_table/models/moneris_response_model.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
// import '../models/table_reservations_model.dart';
import '../repo/moneris_response_table_repo.dart';

class MonerisResponseTableController extends GetxController {
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController serverStartDate = TextEditingController();
  TextEditingController serverEndDate = TextEditingController();
  TextEditingController searchController = TextEditingController();

  // Response? tableReservations;
  //  List<MonerisPurchaseModel> response = [];
  MonerisResponseModel? response;
  getTransactions({
    String? page,
  }) async {
    PopupDialog.showLoadingDialog();
    response = await MonerisResponseTableRepo.getTableBooks(
      limit: "200",
      startDate: serverStartDate.text.isEmpty ? null : serverStartDate.text,
      endDate: serverEndDate.text.isEmpty ? null : serverEndDate.text,
      search:
          searchController.text.isEmpty ? null : searchController.text.trim(),
    );

    // print("response is ......... $response");
    PopupDialog.closeLoadingDialog();
    update();
  }

  clearDate() {
    startDate.clear();
    endDate.clear();
    serverStartDate.clear();
    serverEndDate.clear();
  }

  @override
  void onClose() {
    startDate.dispose();
    endDate.dispose();
    serverStartDate.dispose();
    serverEndDate.dispose();
    super.dispose();
  }

  @override
  void onReady() {
    getTransactions();
    super.onReady();
  }
}
