import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import '../models/table_reservations_model.dart';
import '../repo/table_reservations_repo.dart';

class TableReservationsController extends GetxController {
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController serverStartDate = TextEditingController();
  TextEditingController serverEndDate = TextEditingController();

  TableReservationsModel? tableReservations;
  getReservations({
    String? page,
  }) async {
    PopupDialog.showLoadingDialog();
    tableReservations = await TableReservationsRepo.getTableBooks(
        startDate: serverStartDate.text.isEmpty ? null : serverStartDate.text,
        endDate: serverEndDate.text.isEmpty ? null : serverEndDate.text,
        page: page);
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
    getReservations();
    super.onReady();
  }
}
