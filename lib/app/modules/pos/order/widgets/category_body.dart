import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

// class CategoryBody extends GetView<PosController> {
//   final int crossAxisCount;
//   const CategoryBody({super.key, required this.crossAxisCount});

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     return SingleChildScrollView(
//       child: GetBuilder<PosController>(
//         builder: (controller) {
//           return StaggeredGrid.count(
//             crossAxisCount: crossAxisCount,
//             mainAxisSpacing: 12,
//             crossAxisSpacing: 12,
//             children: List.generate(
//               controller.categoryList.length,
//               (index) => PrimaryBtn(
//                 padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
//                 textMaxSize: 17,
//                 textMinSize: 12,
//                 height: 80,
//                 maxLines: 3,
//                 onPressed: () {
//                   controller.itemTypeActiveIndex = 0;
//                   controller.itemCayegoryActiveIndex = index;
//                   controller.findProductsByCategoryId(
//                     controller.categoryList[index].id,
//                   );
//                   controller.currentCategoryType =
//                       controller.categoryList[index].mainCategory;
//                   PosController.to.changeItemsView();
//                 },
//                 isOutline: true,
//                 borderColor: controller.itemCayegoryActiveIndex == index
//                     ? StaticColors.blueColor
//                     : Colors.transparent,
//                 borderWidth: 2,
//                 color: MyFunc.getColorForCategory(
//                   controller.categoryList[index].mainCategory,
//                 ),
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 text: controller.categoryList[index].title.toUpperCase(),
//               ),
//             ),
//           ).marginOnly(bottom: controller.categoryList.isNotEmpty ? 12 : 0);
//         },
//       ),
//     );
//   }
// }
class CategoryBody extends StatefulWidget {
  final int crossAxisCount;
  final EdgeInsetsGeometry? padding;
  const CategoryBody({super.key, required this.crossAxisCount, this.padding});

  @override
  State<CategoryBody> createState() => _CategoryBodyState();
}

class _CategoryBodyState extends State<CategoryBody> {
  final PosController controller = Get.find<PosController>();


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          theme.textTheme.bodyLarge?.color!.withAlpha(100),
        ),
        trackColor: WidgetStateProperty.all(theme.cardColor),
        trackBorderColor: WidgetStateProperty.all(Colors.transparent),
        thickness: WidgetStateProperty.all(6),
        radius: const Radius.circular(8),
        thumbVisibility: WidgetStateProperty.all(true),
        trackVisibility: WidgetStateProperty.all(true),
      ),
      child: Scrollbar(
        controller: controller.categoryScrollController,
        child: SingleChildScrollView(
          padding: widget.padding,
          controller: controller.categoryScrollController,
          child: GetBuilder<PosController>(
            builder: (controller) {
              return StaggeredGrid.count(
                crossAxisCount: widget.crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: List.generate(
                  controller.categoryList.length,
                  (index) => PrimaryBtn(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 6,
                    ),
                    textMaxSize: 17,
                    textMinSize: 12,
                    height: 80,
                    maxLines: 3,
                    onPressed: () {
                      controller.itemTypeActiveIndex = 0;
                      controller.itemCayegoryActiveIndex = index;
                      controller.findProductsByCategoryId(
                        controller.categoryList[index].id,
                      );
                      controller.currentCategoryType =
                          controller.categoryList[index].mainCategory;
                      PosController.to.changeItemsView();
                    },
                    isOutline: true,
                    borderColor: controller.itemCayegoryActiveIndex == index
                        ? StaticColors.blueColor
                        : Colors.transparent,
                    borderWidth: 2,
                    color: MyFunc.getColorForCategory(
                      controller.categoryList[index].mainCategory,
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    text: controller.categoryList[index].title.toUpperCase(),
                  ),
                ),
              ).marginOnly(bottom: controller.categoryList.isNotEmpty ? 12 : 0);
            },
          ),
        ),
      ),
    );
  }
}
