// table_managment_view.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import '../../../../services/controller/base_controller.dart';
import '../../../../widgets/popup_dialogs.dart';
import '../../controllers/pos_controller.dart';
import '../../dine-in/views/order_details_view.dart';
import '../controllers/table_mapping_managment_controller.dart';
import '../models/table_mapping_management_model.dart';

class TableManagmentView extends GetView<TableMappingController> {
  final bool isScrollable;
  final bool isTransferItems;
  final bool isMainPage;
  final bool isPOSPage;
  final bool isUpdateView;

  const TableManagmentView({
    required this.isScrollable,
    this.isMainPage = false,
    this.isTransferItems = false,
    this.isPOSPage = false,
    this.isUpdateView = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double dialogHeight = Get.height * 0.8;
    final double dialogWidth = Get.width * 0.8;
    TableMappingController.to.getMappingALlTables();
    return Material(
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============ CATEGORY FILTER BAR (TOP) ============
              Container(
                height: 80,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() {
                    // final categories = <String, TableCategory>{};
                    // for (var table in controller.tables) {
                    //   categories[table.tableCategory.id] = table.tableCategory;
                    // }

                    return Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _buildHorizontalCategoryButton(
                              label: "All Tables",
                              isSelected:
                                  controller.selectedCategoryId.value.isEmpty,
                              onTap: controller.selectAllTables,
                              context: context),
                        ),
                        ...DineInController.to.tableCategoryList.map((cat) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _buildHorizontalCategoryButton(
                                label: cat.name,
                                isSelected:
                                    controller.selectedCategoryId.value ==
                                        cat.id,
                                onTap: () => controller.selectCategory(cat.id),
                                context: context),
                          );
                        }),
                      ],
                    );
                  }),
                ),
              ),
              Container(
                height: 2,
                width: 1180,
                color: Colors.white,
              ),
              SizedBox(
                height: 10,
              ),
              // ============ FLOOR PLAN (BOTTOM) ============
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Obx(() {
                      double maxW = constraints.maxWidth;
                      double maxH = constraints.maxHeight;
                      List<Widget> tableWidgets = [];

                      for (var table in controller.tables) {
                        final theta = table.angle * pi / 180;
                        final w = table.width;
                        final h = table.height;

                        final corners = [
                          Offset(-w / 2, -h / 2),
                          Offset(w / 2, -h / 2),
                          Offset(-w / 2, h / 2),
                          Offset(w / 2, h / 2),
                        ];

                        double minX = double.infinity, minY = double.infinity;
                        double maxX = -double.infinity, maxY = -double.infinity;

                        for (var c in corners) {
                          final rx = c.dx * cos(theta) + c.dy * sin(theta);
                          final ry = -c.dx * sin(theta) + c.dy * cos(theta);
                          minX = min(minX, rx);
                          minY = min(minY, ry);
                          maxX = max(maxX, rx);
                          maxY = max(maxY, ry);
                        }

                        final rotW = maxX - minX;
                        final rotH = maxY - minY;

                        final right = table.left + rotW;
                        final bottom = table.top + rotH;
                        maxW = max(maxW, right + 50);
                        maxH = max(maxH, bottom + 50);

                        final pos = _getAdjustedPosition(table, maxW, maxH);

                        tableWidgets.add(
                          Positioned(
                            left: pos.dx,
                            top: pos.dy,
                            child: GestureDetector(
                              onTap: () => _handleTableTap(table),
                              onDoubleTap: () => _handleDoubleTap(table),
                              onLongPressStart: (details) {
                                if (table.tableAvailability == "AVAILABLE" ||
                                    table.tableAvailability == "HOLD_TABLES") {
                                  BaseController.to.playTapSound();
                                  final newStatus =
                                      table.tableAvailability == "HOLD_TABLES"
                                          ? "AVAILABLE"
                                          : "HOLD_TABLES";
                                  controller.onChangeTableStatus(
                                      id: table.id, status: newStatus);
                                }
                              },
                              child: Transform.rotate(
                                angle: table.angle * (pi / 180),
                                alignment: Alignment.center,
                                child: _buildTable(table),
                              ),
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SizedBox(
                            width: maxW,
                            height: maxH,
                            child: Stack(children: tableWidgets),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCategoryButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: SizedBox(
        width: 150,
        height: 60,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? StaticColors.blueColor : Colors.grey[300],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: isSelected ? 6 : 2,
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }


  // TABLE BUILDER
  Widget _buildTable(TableMappingModel table) {
    if (table.tableType == 'arc') return _buildArcTable(table);
    if (table.tableType == 'circle') return _buildCircleTable(table);
    return _buildRectangleTable(table);
  }

  Widget _buildRectangleTable(TableMappingModel table) {
    return Container(
      width: table.width,
      height: table.height,
      decoration: BoxDecoration(
        color: controller.getTableColor(table),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1))
        ],
      ),
      child: _buildContent(table),
    );
  }

  Widget _buildCircleTable(TableMappingModel table) {
    return Container(
      width: table.width,
      height: table.height,
      decoration: BoxDecoration(
        color: controller.getTableColor(table),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1))
        ],
      ),
      child: _buildContent(table),
    );
  }

  Widget _buildArcTable(TableMappingModel table) {
    return SizedBox(
      width: table.width,
      height: table.height,
      child: ClipPath(
        clipper: table.arcType == 'topLeft'
            ? TopLeftArcClipper()
            : TopRightArcClipper(),
        child: Container(
          decoration: BoxDecoration(
            color: controller.getTableColor(table),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 3, offset: Offset(1, 1))
            ],
          ),
          child: _buildContent(table),
        ),
      ),
    );
  }

  Widget _buildContent(TableMappingModel table) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyCustomText(table.tableName,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)
              .marginOnly(bottom: 4),
          MyCustomText('Seats: ${table.tableCapacity}',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)
              .marginOnly(bottom: 4),
          Visibility(
            visible: table.currentOrder != null,
            child: MyCustomText(
                '\$${table.currentOrder?.totalOrderAmount.toStringAsFixed(2) ?? '0.00'}',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ],
      ),
    );
  }

  // POSITION ADJUSTMENT
  Offset _getAdjustedPosition(
      TableMappingModel table, double canvasW, double canvasH) {
    final theta = table.angle * pi / 180;
    final w = table.width;
    final h = table.height;

    final corners = [
      Offset(-w / 2, -h / 2),
      Offset(w / 2, -h / 2),
      Offset(-w / 2, h / 2),
      Offset(w / 2, h / 2),
    ];

    double minX = double.infinity, minY = double.infinity;
    for (var c in corners) {
      final rx = c.dx * cos(theta) + c.dy * sin(theta);
      final ry = -c.dx * sin(theta) + c.dy * cos(theta);
      minX = min(minX, rx);
      minY = min(minY, ry);
    }

    final centerX = table.left - minX;
    final centerY = table.top - minY;
    return Offset(centerX - w / 2, centerY - h / 2);
  }

  // TAP HANDLERS
  void _handleTableTap(TableMappingModel table) {
    BaseController.to.playTapSound();

    // AVAILABLE TABLE
    if (table.tableAvailability == "AVAILABLE") {
      if (isPOSPage) {
        PosController.to.updateTableName1(table, isUpdateView: isUpdateView);
        Get.back();
        return;
      }
      if (isMainPage) {
        Get.back();
        PosController.to.orderType = "DINE_IN";
        PosController.to.clearCartList();
        PosController.to.updateTableName1(table);
        PosController.to.onchangePage(0);
        PosController.to.changeFocusToGuest();
      }
    }

    // BOOKING TABLE
    else if (table.tableAvailability == "BOOKING" &&
        table.currentOrder != null) {
      if (isPOSPage && !isUpdateView) {
        PosController.to.isUpdateView = true;
        PosController.to.orderType = "DINE_IN";
        PosController.to
            .setTakeOutTypeIndexAndValue(table.currentOrder!.takeOutType ?? "");
        PosController.to.guestController.text =
            table.currentOrder!.numberOfPeople.toString();
        PosController.to.tableController.text = table.currentOrder!.tableName;
        PosController.to.guestNameController.text =
            table.currentOrder!.guestName;
        PosController.to.guestPhoneController.text =
            table.currentOrder!.guestPhoneNumber;
        PosController.to.onReadOnlyAllCartTextField();
        PosController.to.myOrder = table.currentOrder!;
        Get.back();
        PosController.to.cartListScrollToBottom();
      } else if (isPOSPage && isUpdateView) {
        PopupDialog.animatedDialog(
          isErr: true,
          width: 500,
          title: "Cannot Change Table as ${table.tableName} has ongoing order",
        );
      } else if (isMainPage) {
        PosController.to.myOrder = table.currentOrder!;
        Get.to(() => const OrderDetailsView());
      }
    }
  }

  void _handleDoubleTap(TableMappingModel table) {
    if (table.tableAvailability == "AVAILABLE" ||
        table.tableAvailability == "HOLD_TABLES") {
      final newStatus = table.tableAvailability == "HOLD_TABLES"
          ? "AVAILABLE"
          : "HOLD_TABLES";
      controller.onChangeTableStatus(id: table.id, status: newStatus);
    }
  }
}

// CLIPPERS
class TopLeftArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..arcToPoint(Offset(size.width, 0),
          radius: Radius.elliptical(size.width, size.height), clockwise: true)
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}

class TopRightArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..arcToPoint(Offset(0, 0),
          radius: Radius.elliptical(size.width, size.height), clockwise: false)
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}
