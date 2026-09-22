import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/views/order_details_view.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/widgets/table_availability_header.dart';
import 'package:yogo_pos/app/modules/pos/takeout/controllers/takeout_controller.dart';
import 'package:yogo_pos/app/modules/pos/takeout/widgets/takeout_card.dart';
import 'package:yogo_pos/app/modules/pos/views/widgets/top_menu.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';

import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_pagination.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class TakeOutView extends GetView<TakeOutController> {
  const TakeOutView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.isUnPaidView = true;
    controller.getAllTakeOutPaidOrders();
    controller.getAllTakeOutUnPaidOrders();
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        bottom: 16,
        right: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TopMenu(),
          const SizedBox(height: 16),
          // title
          SizedBox(
            // height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        BaseController.to.playTapSound();
                        controller.onChangePaidView(true);
                      },
                      child: GetBuilder<TakeOutController>(builder: (context) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  width: 2,
                                  color: context.isUnPaidView
                                      ? StaticColors.yellowColor
                                      : Colors.transparent)),
                          child: const ColorTextRow(
                            color: StaticColors.yellowColor,
                            text: 'Unpaid',
                          ),
                        );
                      }),
                    ),
                    InkWell(
                      onTap: () {
                        BaseController.to.playTapSound();
                        controller.onChangePaidView(false);
                      },
                      child: GetBuilder<TakeOutController>(builder: (context) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  width: 2,
                                  color: !context.isUnPaidView
                                      ? StaticColors.greenColor
                                      : Colors.transparent)),
                          child: const ColorTextRow(
                            color: StaticColors.greenColor,
                            text: 'Paid',
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                // for paied
                GetBuilder<TakeOutController>(builder: (context) {
                  return Visibility(
                    visible: !context.isUnPaidView,
                    // for paied
                    replacement:
                        GetBuilder<TakeOutController>(builder: (controller) {
                      var data = controller.unPaidPagination;
                      return CustomPagination(
                        numOfPages: data?.totalPages ?? 0,
                        selectedPage: data?.currentPage ?? 0,
                        pagesVisible: 5,
                        onPageChanged: (page) async {
                          BaseController.to.playTapSound();
                          PopupDialog.showLoadingDialog();
                          await controller.getAllTakeOutUnPaidOrders(
                              page: "$page");
                          PopupDialog.closeLoadingDialog();
                        },
                      );
                    }),
                    // for unpaied
                    child: GetBuilder<TakeOutController>(builder: (controller) {
                      var data = controller.paidPagination;
                      return CustomPagination(
                        numOfPages: data?.totalPages ?? 0,
                        selectedPage: data?.currentPage ?? 0,
                        pagesVisible: 5,
                        onPageChanged: (page) async {
                          BaseController.to.playTapSound();
                          PopupDialog.showLoadingDialog();
                          await controller.getAllTakeOutPaidOrders(
                              page: "$page");
                          PopupDialog.closeLoadingDialog();
                        },
                      );
                    }),
                  );
                })
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: SingleChildScrollView(
            child: GetBuilder<TakeOutController>(builder: (context) {
              return Visibility(
                visible: !controller.isUnPaidView,
                replacement: StaggeredGrid.count(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children:
                      List.generate(context.unPaidTakeOutList.length, (index) {
                    var order = context.unPaidTakeOutList[index];
                    return TakeoutCard(
                      order: order,
                      onTap: () {
                        BaseController.to.playTapSound();
                        PosController.to.myOrder = order;
                        // PosController.to.isEditableItems = false;
                        PosController.to.selectedItemList.clear();
                        Get.to(() => const OrderDetailsView());
                      },
                    );
                  }),
                ),
                child: StaggeredGrid.count(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children:
                      List.generate(context.paidTakeOutList.length, (index) {
                    var order = context.paidTakeOutList[index];
                    return TakeoutCard(
                      order: order,
                      onTap: () {
                        BaseController.to.playTapSound();
                        PosController.to.myOrder = order;
                        // PosController.to.isEditableItems = false;
                        PosController.to.selectedItemList.clear();
                        Get.to(() => const OrderDetailsView());
                      },
                    );
                  }),
                ),
              );
            }),
          )),
        ],
      ),
    );
  }
}
