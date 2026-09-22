import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/discount_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/modules/pos/order/widgets/variation.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'add_weighing_scale_cart_dialog.dart';

// class ProductBody extends GetView<PosController> {
//   final int crossAxisCount;
//   const ProductBody({super.key, required this.crossAxisCount});

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     return SingleChildScrollView(
//       child: GetBuilder<PosController>(
//         builder: (controller) {
//           return StaggeredGrid.count(
//             crossAxisCount: 3,
//             mainAxisSpacing: 12,
//             crossAxisSpacing: 12,
//             children: List.generate(controller.productsForShow.length, (index) {
//               var item = controller.productsForShow[index];
//               return PrimaryBtnWithChild(
//                 onPressed: () {
//                   PosController.to.clearModifier();
//                   controller.orderTotalPrice = item.price.toDouble();
//                   controller.resetModifierSelections();
//                   controller.checkHasVariations(item.variations);
//                   if (item.itemType == "weighing scale") {
//                     PopupDialog.customDialog(
//                       width: 550,
//                       child: AddWingScaleCartDialog(item: item),
//                     );
//                   } else if (controller.hasVariations) {
//                     PopupDialog.customDialog(
//                       hasScroll: true,
//                       width: MediaQuery.sizeOf(context).width * 0.8,
//                       child: Variation(
//                         item: item.copyWith(
//                           variations: item.variations
//                               .where((v) => v.posVariationOn == true)
//                               .toList(),
//                         ),
//                       ),
//                     );
//                   } else {
//                     var uuid = const Uuid();
//                     CartModel order = CartModel(
//                       id: uuid.v1(),
//                       itemId: item.id,
//                       name: item.name,
//                       description: item.description,
//                       price: item.price,
//                       itemType: item.itemType,
//                       discount: Discount(),
//                       quantity: PosController.to.orderQuantity,
//                       // isLiquor: int.parse(item.isLiquor.toString()),
//                       kitchenNote: '',
//                       discountAmount: 0,
//                       printers: item.printers,
//                     );
//                     //** Add item **
//                     PosController.to.onAddCartItem(order);
//                     FocusScope.of(context).unfocus();
//                   }
//                   controller.selectedItemList.clear();
//                 },
//                 isOutline: true,
//                 height: 90,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Align(
//                       alignment: Alignment.topRight,
//                       child: Text(
//                         item.price.toStringAsFixed(2),
//                         style: theme.textTheme.titleMedium,
//                         maxLines: 1,
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         item.name.toUpperCase(),
//                         // MyFunc.capitalizeEachWord(s: item.name),
//                         style: theme.textTheme.titleSmall,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           );
//         },
//       ),
//     );
//   }
// }

class ProductBody extends StatefulWidget {
  final int crossAxisCount;
  final EdgeInsetsGeometry? padding;
  const ProductBody({super.key, required this.crossAxisCount, this.padding});

  @override
  State<ProductBody> createState() => _ProductBodyState();
}

class _ProductBodyState extends State<ProductBody> {
  final PosController controller = Get.find<PosController>();

  @override
  void dispose() {
    // scrollController.dispose();
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
        controller: controller.itemScrollController,
        child: SingleChildScrollView(
          padding: widget.padding,
          controller: controller.itemScrollController,
          child: GetBuilder<PosController>(
            builder: (controller) {
              return StaggeredGrid.count(
                crossAxisCount: widget.crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: List.generate(controller.productsForShow.length, (
                  index,
                ) {
                  var item = controller.productsForShow[index];
                  return PrimaryBtnWithChild(
                    onPressed: () {
                      PosController.to.clearModifier();
                      controller.orderTotalPrice = item.price.toDouble();
                      controller.resetModifierSelections();
                      controller.checkHasVariations(item.variations);
                      if (item.itemType == "weighing scale") {
                        PopupDialog.customDialog(
                          width: 550,
                          child: AddWingScaleCartDialog(item: item),
                        );
                      } else if (controller.hasVariations) {
                        PopupDialog.customDialog(
                          hasScroll: true,
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          child: Variation(
                            item: item.copyWith(
                              variations: item.variations
                                  .where((v) => v.posVariationOn == true)
                                  .toList(),
                            ),
                          ),
                        );
                      } else {
                        var uuid = const Uuid();
                        CartModel order = CartModel(
                          id: uuid.v1(),
                          itemId: item.id,
                          name: item.name,
                          description: item.description,
                          price: item.price,
                          itemType: item.itemType,
                          discount: Discount(),
                          quantity: PosController.to.orderQuantity,
                          // isLiquor: int.parse(item.isLiquor.toString()),
                          kitchenNote: '',
                          discountAmount: 0,
                          printers: item.printers,
                        );
                        //** Add item **
                        PosController.to.onAddCartItem(order);
                        FocusScope.of(context).unfocus();
                      }
                      controller.selectedItemList.clear();
                    },
                    isOutline: true,
                    height: 90,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            item.price.toStringAsFixed(2),
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.name.toUpperCase(),
                            // MyFunc.capitalizeEachWord(s: item.name),
                            style: theme.textTheme.titleSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
