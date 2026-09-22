// import 'package:flutter/material.dart';
// import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
// import 'package:yogo_pos/app/utils/my_func.dart';
// import 'package:yogo_pos/app/widgets/custom_btn.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:get/get.dart';

// class ThreeColumCategoryBody extends GetView<PosController> {
//   const ThreeColumCategoryBody({super.key});

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     return SingleChildScrollView(
//       child: GetBuilder<PosController>(
//         builder: (controller) {
//           return StaggeredGrid.count(
//             crossAxisCount: 1,
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
//                   // controller.drinkItemTypeActiveIndex = 0;
//                   controller.findProductsByCategoryId(
//                     controller.categoryList[index].id,
//                   );
//                   controller.currentCategoryType =
//                       controller.categoryList[index].mainCategory;
//                   PosController.to.changeItemsView();
//                 },
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
