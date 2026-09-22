import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/controllers/dine_in_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/orders_table.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../utils/static_colors.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/my_custom_text.dart';

class TableOrdersList extends GetView<DineInOrderController> {
  const TableOrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GetBuilder<DineInOrderController>(
            builder: (controller) {
              return MyCustomText(
                '${controller.selectedOrderType?.replaceAll("_", "-")} Orders         ${controller.pagination?.total}',
                fontSize: 18,
                fontWeight: FontWeight.w800,
              );
            },
          ),
          const SizedBox(height: 24.0),
          _dateRange(context),
          const SizedBox(height: 24.0),
          _orderStatus(theme),
          const SizedBox(height: 24.0),
          _searchAndExportRow(),
          const SizedBox(height: 24.0),
          _orderTable(theme, context),
        ],
      ),
    );
  }

  Widget _orderTable(ThemeData theme, BuildContext context) {
    return Column(
      children: [
        GetBuilder<DineInOrderController>(
          builder: (context) {
            return OrdersTable(context.orderList);
          },
        ),
      ],
    );
  }

  Widget _searchAndExportRow() {
    return GetBuilder<DineInOrderController>(
      builder: (controller) {
        return Row(
          children: [
            SizedBox(
              width: 340,
              child: CustomTextField(
                controller: controller.search,
                hintText: 'Search by Guest Name & Phone / Check Number',
                onChange: (value) => controller.query.value = value,
                // onTap: () {
                //   if (Preferences.customKeyboard) {
                //     CustomKeyboard.open(
                //       keyboardType: KeyboardType.alphabet,
                //       initialValue: controller.search.text,
                //       regExp: RegExp(r'^.{0,50}$'),
                //       onChange: (value) {
                //         controller.search.text = value;
                //         controller.query.value = value;
                //       },
                //     );
                //   }
                // },
              ),
            ),
            const SizedBox(width: 12.0),
            PrimaryBtn(
              onPressed: () async {
                if (controller.search.text.isNotEmpty) {
                  PopupDialog.showLoadingDialog();
                  await controller.getAllOrders(
                    endDate: controller.serverEndDate.text.isEmpty
                        ? null
                        : controller.serverEndDate.text,
                    startDate: controller.serverStartDate.text.isEmpty
                        ? null
                        : controller.serverStartDate.text,
                    orderStatus: controller.selectedOrderStatus.isEmpty
                        ? null
                        : controller.selectedOrderStatus,
                    search: controller.search.text.isEmpty
                        ? null
                        : controller.search.text,
                  );
                  PopupDialog.closeLoadingDialog();
                } else {
                  PopupDialog.showErrorMessage("Search field is empty");
                }
              },
              text: 'Search',
              color: StaticColors.greenColor,
              textColor: Colors.white,
            ),
            const SizedBox(width: 12.0),
            ...List.generate(controller.orderTypeList.length, (index) {
              return PrimaryBtn(
                width: 100,
                onPressed: () async {
                  controller.onChangeOrderStatus(index);
                },
                text: controller.orderTypeList[index] != "ONLINE"
                    ? controller.orderTypeList[index].replaceAll("_", "-")
                    : "OLO",
                textColor: Colors.white,
                color: StaticColors.greenColor,
                borderColor:
                    controller.selectedOrderType ==
                        controller.orderTypeList[index]
                    ? StaticColors.blueColor
                    : Colors.transparent,
                isOutline: true,
                borderWidth: 2,
              ).marginOnly(right: 12);
            }),
          ],
        );
      },
    );
  }

  Widget _dateRange(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyCustomText(
          'Select date range',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 16.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Expanded(
            //   flex: 2,
            //   child: GetBuilder<TablesController>(builder: (c) {
            //     return MyDropdownBtn(
            //       data: c.branches,
            //       selectedValue: c.selectedBranch,
            //       onChanged: c.updateSelectedBranch,
            //     );
            //   }),
            // ),
            // const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: CustomTextField(
                controller: controller.startDate,
                extraLabel: 'Start Date',
                hintText: 'mm/dd/yyyy',
                readOnly: true,
                style: TextStyle(color: Theme.of(context).colorScheme.surface),
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
                    controller.startDate.text = DateFormat(
                      'MM/dd/yyyy',
                    ).format(date);
                    controller.serverStartDate.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(date);
                  });
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: CustomTextField(
                controller: controller.endDate,
                extraLabel: 'End Date',
                hintText: 'mm/dd/yyyy',
                readOnly: true,
                style: TextStyle(color: Theme.of(context).colorScheme.surface),
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
                    controller.endDate.text = DateFormat(
                      'MM/dd/yyyy',
                    ).format(date);
                    controller.serverEndDate.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(date);
                    // TablesController.to.updateEndDate(date);
                  });
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 1,
              child: PrimaryBtn(
                onPressed: () async {
                  controller.clearOrderField();
                  PopupDialog.showLoadingDialog();
                  await controller.getAllOrders();
                  await controller.getOrderStatus();
                  PopupDialog.closeLoadingDialog();
                },
                text: 'Clear',
                color: Colors.white,
                textColor: Colors.black87,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 1,
              child: PrimaryBtn(
                onPressed: () async {
                  if (controller.serverStartDate.text.isNotEmpty &&
                      controller.serverEndDate.text.isNotEmpty) {
                    PopupDialog.showLoadingDialog();
                    await controller.getAllOrders(
                      endDate: controller.serverEndDate.text.isEmpty
                          ? null
                          : controller.serverEndDate.text,
                      startDate: controller.serverStartDate.text.isEmpty
                          ? null
                          : controller.serverStartDate.text,
                      orderStatus: controller.selectedOrderStatus.isEmpty
                          ? null
                          : controller.selectedOrderStatus,
                      search: controller.search.text.isEmpty
                          ? null
                          : controller.search.text,
                    );
                    await controller.getOrderStatus(
                      endDate: controller.serverEndDate.text.isEmpty
                          ? null
                          : controller.serverEndDate.text,
                      startDate: controller.serverStartDate.text.isEmpty
                          ? null
                          : controller.serverStartDate.text,
                    );

                    PopupDialog.closeLoadingDialog();
                  } else {
                    PopupDialog.showErrorMessage(
                      "StartDate and EndDate are required",
                    );
                  }
                },
                text: 'Show Data',
                color: StaticColors.blueColor,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _orderStatus(ThemeData theme) {
    return GetBuilder<DineInOrderController>(
      builder: (controller) {
        return StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: List.generate(controller.orderStatusList.length, (index) {
            return InkWell(
              onTap: () async {
                BaseController.to.playTapSound();
                // controller.orderStatusActiveIndex = index;
                if (controller.orderStatusActiveIndex == index) {
                  controller.orderStatusActiveIndex = -1;
                  PopupDialog.showLoadingDialog();
                  await controller.getAllOrders(
                    endDate: controller.serverEndDate.text.isEmpty
                        ? null
                        : controller.serverEndDate.text,
                    startDate: controller.serverStartDate.text.isEmpty
                        ? null
                        : controller.serverStartDate.text,
                    orderStatus: null,
                    search: controller.search.text.isEmpty
                        ? null
                        : controller.search.text,
                  );
                  PopupDialog.closeLoadingDialog();
                  controller.selectedOrderStatus = "";
                } else {
                  controller.orderStatusActiveIndex = index;
                  controller.selectedOrderStatus = controller
                      .orderStatusList[index]
                      .status
                      .toUpperCase();
                  PopupDialog.showLoadingDialog();
                  await controller.getAllOrders(
                    endDate: controller.serverEndDate.text.isEmpty
                        ? null
                        : controller.serverEndDate.text,
                    startDate: controller.serverStartDate.text.isEmpty
                        ? null
                        : controller.serverStartDate.text,
                    orderStatus: controller.selectedOrderStatus.isEmpty
                        ? null
                        : controller.selectedOrderStatus,
                    search: controller.search.text.isEmpty
                        ? null
                        : controller.search.text,
                  );
                  PopupDialog.closeLoadingDialog();
                }
                kLogger.e(controller.selectedOrderStatus);
                // controller.orderStatusActiveIndex == index;
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: ConfigController.to.isLightTheme
                      ? Colors.black.withAlpha(33)
                      : theme.dividerColor.withAlpha(76),
                  border: controller.orderStatusActiveIndex == index
                      ? Border.all(color: StaticColors.blueColor)
                      : null,
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyCustomText(
                      controller.orderStatusList[index].status.toLowerCase() ==
                              "canceled"
                          ? "Cancelled"
                          : controller.orderStatusList[index].status,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    MyCustomText(
                      controller.orderStatusList[index].count.toString(),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
