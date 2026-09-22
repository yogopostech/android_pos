import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/controllers/dine_in_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/views/table_orders_list.dart';
import 'package:yogo_pos/app/modules/pos/views/widgets/top_menu.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/widgets/custom_pagination.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:get/get.dart';

class DineInOrderView extends GetView<DineInOrderController> {
  const DineInOrderView({super.key});
  @override
  Widget build(BuildContext context) {
    DineInOrderController.to.getOrderStatus();
    DineInOrderController.to.getAllOrders(
      orderStatus: DineInOrderController.to.selectedOrderStatus.isEmpty
          ? null
          : DineInOrderController.to.selectedOrderStatus,
    );
    return GetBuilder<DineInOrderController>(builder: (c) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Column(
          children: [
            const TopMenu(),
            const SizedBox(height: 16),
            const Expanded(
                child: SingleChildScrollView(
              child: TableOrdersList(),
            )),
            // pagination
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GetBuilder<DineInOrderController>(builder: (controller) {
                      var data = controller.pagination;
                      return CustomPagination(
                        numOfPages: data?.totalPages ?? 0,
                        selectedPage: data?.currentPage ?? 0,
                        pagesVisible: 5,
                        onPageChanged: (page) async {
                          BaseController.to.playTapSound();
                          PopupDialog.showLoadingDialog();
                          await controller.getAllOrders(
                            page: "$page",
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
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
