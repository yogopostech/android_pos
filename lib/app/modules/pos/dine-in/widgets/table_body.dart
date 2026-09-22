import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import '../../../../utils/static_colors.dart';
import '../views/order_details_view.dart';

class TableBody extends GetView<DineInController> {
  final bool isScrollable;
  final bool isTransferItems;
  final bool isMainPage;
  final bool isPOSPage;
  final bool isUpdateView;
  const TableBody(
      {required this.isScrollable,
      this.isMainPage = false,
      this.isTransferItems = false,
      this.isPOSPage = false,
      this.isUpdateView = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        shrinkWrap: isScrollable ? false : true,
        physics: isScrollable
            ? const ScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: controller.tableCategoryList.length,
        itemBuilder: (contex, index) {
          var tables = controller.tableCategoryList[index].tables;
          return SizedBox(
            child: Column(
              children: [
                // header
                _title(controller.tableCategoryList[index].name),
                StaggeredGrid.count(
                  crossAxisCount: 10,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: List.generate(tables.length, (index) {
                    var table = tables[index];
                    return GestureDetector(
                      //onTap
                      onTap: () async {
                        BaseController.to.playTapSound();
                        // ! if table is avaiable
                        if (table.tableAvailability == "AVAILABLE") {
                          // for dine in
                          if (isMainPage) {
                            Get.back();
                            PosController.to.orderType = "DINE_IN";
                            PosController.to.clearCartList();
                            PosController.to.updateTableName(table);
                            PosController.to.onchangePage(0);
                            // PosController.to.onFocusGuestName();
                            PosController.to.changeFocusToGuest();
                          }
                          // for TransferItems
                          if (isTransferItems) {
                            PopupDialog.animatedDialog(
                                isErr: true,
                                width: 500,
                                title:
                                    "Cannot Transfer Items in ${table.tableAvailability} Table");
                          }
                          // for pos page
                          if (isPOSPage) {
                            debugPrint(
                                "isUpdateView===================> $isUpdateView");
                            PosController.to.updateTableName(table,
                                isUpdateView: isUpdateView);
                            Get.back();
                          }
                          // ! if table is BOOKING
                        } else if (table.tableAvailability == "BOOKING") {
                          // for dine-in
                          if (isMainPage) {
                            if (table.currentOrder != null) {
                              PosController.to.myOrder = table.currentOrder!;
                              PosController.to.selectedItemList.clear();
                              // PosController.to.isEditableItems = false;
                              Get.to(() => const OrderDetailsView());
                            } else {
                              PopupDialog.showErrorMessage(
                                  "The table is currently empty");
                            }
                          }
                          // for TransferItems
                          if (isTransferItems) {
                            PosController.to.transferItemsAllSelectedItems(
                                transferTableId: table.id,
                                selectedItemIds: PosController.to.selectedItemList
                                
                                
                                );
                          }
                          // for pos page
                          if (isPOSPage) {
                            // order view
                            
                            if (!PosController.to.isUpdateView) {
                              if (table.currentOrder != null) {
                                // order view
                                PosController.to.isUpdateView = true;
                                PosController.to.orderType = "DINE_IN";
                                PosController.to.setTakeOutTypeIndexAndValue(
                                    table.currentOrder!.takeOutType ?? "");
                                PosController.to.guestController.text = table
                                    .currentOrder!.numberOfPeople
                                    .toString();
                                PosController.to.tableController.text =
                                    table.currentOrder!.tableName;
                                PosController.to.guestNameController.text =
                                    table.currentOrder!.guestName;
                                PosController.to.guestPhoneController.text =
                                    table.currentOrder!.guestPhoneNumber;
                                // unable to edit
                                PosController.to.onReadOnlyAllCartTextField();
                                // order data set
                                PosController.to.myOrder = table.currentOrder!;
                                Get.back();
                                PosController.to.cartListScrollToBottom();
                              }
                            } else {
                              // updated view
                              PopupDialog.animatedDialog(
                                  isErr: true,
                                  width: 500,
                                  title:
                                      "Cannot Change Table as ${table.tableName} has ongoing order");
                            }
                          }
                        }
                      },
                      // for onDoubleTap
                      onDoubleTap: () {
                        if (table.tableAvailability == "AVAILABLE" ||
                            table.tableAvailability == "HOLD_TABLES") {
                          BaseController.to.playTapSound();
                          if (table.tableAvailability == "HOLD_TABLES") {
                            controller.onChangeTableStatus(
                                id: table.id, status: "AVAILABLE");
                          } else {
                            controller.onChangeTableStatus(
                                id: table.id, status: "HOLD_TABLES");
                          }
                        }
                      },
                      // onLongPressStart
                      onLongPressStart: (details) {
                        if (table.tableAvailability == "AVAILABLE") {
                          BaseController.to.playTapSound();
                          if (table.tableAvailability == "HOLD_TABLES") {
                            controller.onChangeTableStatus(
                                id: table.id, status: "AVAILABLE");
                          } else {
                            controller.onChangeTableStatus(
                                id: table.id, status: "HOLD_TABLES");
                          }
                        }
                      },
                      child: Container(
                        height: 110,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: MyFunc.getTableColorWithStatus(
                              table.tableAvailability),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: MyCustomText(
                                    table.tableName,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                MyCustomText(
                                  '${table.tableCapacity}',
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: MyCustomText(
                                table.currentOrder?.employee?.firstName ?? "",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: SizedBox(
                                height: 20,
                                child: Visibility(
                                  visible:
                                      table.currentOrder?.totalOrderAmount !=
                                          null,
                                  child: MyCustomText(
                                    "\$${table.currentOrder?.totalOrderAmount.toStringAsFixed(2)}",
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                )
              ],
            ),
          );
        },
      );
    });
  }

  Container _title(String title) {
    return Container(
      height: 35,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: StaticColors.blackLightColor,
      ),
      child: MyCustomText(
        title.toUpperCase(),
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}
