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

// import '../../moneries_response_table/controllers/table_reservations_controller.dart';
import '../controllers/moneris_response_table_controller.dart';
import '../widgets/moneris_response_table_widget.dart';

class MonerisResponseTableView extends GetView<MonerisResponseTableController> {
  const MonerisResponseTableView({super.key});
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
            title: const Text("Moneries Transaction Table")),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    readOnly: true,
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
                        if (date == null) return;
                        controller.startDate.text =
                            DateFormat('MM/dd/yyyy').format(date);
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
                    readOnly: true,
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
                        if (date == null) return;
                        controller.endDate.text =
                            DateFormat('MM/dd/yyyy').format(date);
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
                      controller.getTransactions();
                    },
                    text: "Show Data",
                  ),
                  12.width,
                  PrimaryBtn(
                    width: 280,
                    onPressed: () {
                      controller.clearDate();
                      controller.getTransactions();
                    },
                    text: "Clear",
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input Field
                  SizedBox(
                    width: 370,
                    child: CustomTextField(
                      hintText: "Search",
                      controller: controller.searchController,
                    ),
                  ),
                  SizedBox(width: 10),

                  // Search Button
                  PrimaryBtn(
                    width: 280,
                    color: StaticColors.greenColor,
                    onPressed: () {
                      controller.getTransactions();
                    },
                    text: "Search",
                  ),
                  // Expanded(child: Container()),
                  // Expanded(child: Container()),
                ],
              ),
            ),

            // table
            Expanded(
              child: GetBuilder<MonerisResponseTableController>(
                  builder: (context) {
                if (context.response == null) {
                  return const SizedBox();
                }

                if (context.response!.data.isEmpty) {
                  return const SizedBox();
                }
                final allTableData = controller.response!.data
                    .expand((purchase) => purchase.receipt.data.response)
                    .toList();

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: MonerisResponseTableWidget(
                    tables: allTableData,
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GetBuilder<MonerisResponseTableController>(
                      builder: (controller) {
                    return CustomPagination(
                      numOfPages: controller.response?.meta.totalPages ?? 0,
                      selectedPage: controller.response?.meta.currentPage ?? 0,
                      pagesVisible: 5,
                      onPageChanged: (page) async {
                        debugPrint("data is coming");
                        await controller.getTransactions(page: page.toString());
                        debugPrint("data is coming");
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
