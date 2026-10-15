import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/widgets/table_body.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/widgets/table_mapping_managment_view.dart';
import 'package:yogo_pos/app/modules/pos/views/widgets/top_menu.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/models/restaurant_model.dart';
import '../widgets/table_availability_header.dart';

class DineInView extends GetView<DineInController> {
  const DineInView({super.key});

  @override
  Widget build(BuildContext context) {
    DineInController.to.getTableCategories();
    return Padding(
      padding: EdgeInsets.only(left: 16.r, bottom: 16.r, right: 8.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TopMenu(),
          SizedBox(height: 16.r),
          TableAvailabilityHeader(),
          SizedBox(height: 12.0.r),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ! dine-in
                Expanded(
                  flex: 3,
                  child: GetBuilder<BaseController>(
                    builder: (bc) {
                      if (bc.posTableLayout == PosTableLayout.floorPlan) {
                        return TableManagmentView(
                          isScrollable: true,
                          isMainPage: true,
                        );
                      }
                      return TableBody(isScrollable: true, isMainPage: true);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
