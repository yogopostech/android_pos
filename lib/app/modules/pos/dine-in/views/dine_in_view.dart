import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/widgets/table_body.dart';
import 'package:yogo_pos/app/modules/pos/views/widgets/top_menu.dart';
import 'package:get/get.dart';
import '../widgets/table_availability_header.dart';

class DineInView extends GetView<DineInController> {
  const DineInView({super.key});

  @override
  Widget build(BuildContext context) {
    DineInController.to.getTableCategories();
    return Padding(
      padding: EdgeInsets.only(left: 16, bottom: 16, right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TopMenu(),
          SizedBox(height: 16),
          TableAvailabilityHeader(),
          SizedBox(height: 12.0),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ! dine-in
                Expanded(
                  flex: 3,
                  child: TableBody(
                    isScrollable: true,
                    isMainPage: true,
                  ),
                  // child: TableManagmentView(
                  //   isScrollable: true,
                  //   isMainPage: true,
                  // ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
