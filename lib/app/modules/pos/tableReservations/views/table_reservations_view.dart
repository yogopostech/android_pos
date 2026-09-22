import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_pagination.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/title_bar.dart';

import '../controllers/table_reservations_controller.dart';
import '../widgets/reservations_table.dart';

class TableReservationsView extends GetView<TableReservationsController> {
  const TableReservationsView({super.key});
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const TitleBar(),
        toolbarHeight: 30,
      ),
      body: Scaffold(
        appBar: AppBar(
            backgroundColor: ConfigController.to.isLightTheme
                ? theme.cardColor
                : StaticColors.cartColor,
            title: const Text("Table Reservations")),
        body: Column(
          children: [
            // search area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: CustomTextField(
                    controller: controller.startDate,
                    extraLabel: 'Start Date',
                    hintText: 'mm/dd/yyyy',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.surface),
                    onTap: () {
                      BaseController.to.playTapSound();
                      FocusScope.of(context).requestFocus(FocusNode());
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now().toTimeZone(),
                        firstDate: DateTime(2010, 1),
                        lastDate: DateTime(2050, 12),
                      ).then((date) {
                        controller.startDate.text =
                            DateFormat('MM/dd/yyyy').format(date!);
                        controller.serverStartDate.text =
                            DateFormat('yyyy-MM-dd').format(date);
                      });
                    },
                  )),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                      child: CustomTextField(
                    controller: controller.endDate,
                    extraLabel: 'End Date',
                    hintText: 'mm/dd/yyyy',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.surface),
                    onTap: () {
                      BaseController.to.playTapSound();
                      FocusScope.of(context).requestFocus(FocusNode());
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now().toTimeZone(),
                        firstDate: DateTime(2010, 1),
                        lastDate: DateTime(2050, 12),
                      ).then((date) {
                        controller.endDate.text =
                            DateFormat('MM/dd/yyyy').format(date!);
                        controller.serverEndDate.text =
                            DateFormat('yyyy-MM-dd').format(date);
                        // TablesController.to.updateEndDate(date);
                      });
                    },
                  )),
                  const SizedBox(
                    width: 12,
                  ),
                  PrimaryBtn(
                    width: 280,
                    color: StaticColors.greenColor,
                    onPressed: () {
                      controller.getReservations();
                    },
                    text: "Search",
                  ),
                  12.width,
                  PrimaryBtn(
                    width: 280,
                    onPressed: () {
                      controller.clearDate();
                      controller.getReservations();
                    },
                    text: "Clear",
                  )
                ],
              ),
            ),
            // table
            Expanded(
              child: SingleChildScrollView(
                child:
                    GetBuilder<TableReservationsController>(builder: (context) {
                  if (context.tableReservations == null) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: TableReservationsWidget(
                      tables: context.tableReservations?.data ?? [],
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GetBuilder<TableReservationsController>(
                      builder: (controller) {
                    return CustomPagination(
                      numOfPages:
                          controller.tableReservations?.meta?.totalPages ?? 0,
                      selectedPage:
                          controller.tableReservations?.meta?.currentPage ?? 0,
                      pagesVisible: 5,
                      onPageChanged: (page) async {
                        if (page is int) {
                          BaseController.to.playTapSound();
                          controller.getReservations(page: page.toString());
                        }

                        // PopupDialog.showLoadingDialog();
                        // await controller.getAllOrders(
                        //     page: "$page",
                        //     endDate: controller.serverEndDate.text.isEmpty
                        //         ? null
                        //         : controller.serverEndDate.text,
                        //     startDate: controller.serverStartDate.text.isEmpty
                        //         ? null
                        //         : controller.serverStartDate.text,
                        //     orderStatus:
                        //         controller.selectedOrderStatus.isEmpty
                        //             ? null
                        //             : controller.selectedOrderStatus,
                        //     search: controller.search.text.isEmpty
                        //         ? null
                        //         : controller.search.text,
                        //     orderType: controller.isdineInSelected.value
                        //         ? "DINE_IN"
                        //         : "TAKEOUT",
                        //     takeoutType: controller.isdineInSelected.value
                        //         ? null
                        //         : controller.takeOutType.value.toUpperCase());
                        // PopupDialog.closeLoadingDialog();
                      },
                    );
                  })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
