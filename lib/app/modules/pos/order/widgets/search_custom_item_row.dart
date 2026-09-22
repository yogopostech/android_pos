import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/widgets/custom_order_dialog_options.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/models/restaurant_model.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/my_reg_exp.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:get/get.dart';
import '../../../../widgets/custom_btn.dart';
import '../../../../widgets/custom_textfield.dart';

class SearchAndCustomItemRow extends GetView<PosController> {
  const SearchAndCustomItemRow({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final bool isCategoryWithItems =
        BaseController.to.posDisplayMode == PosDisplayMode.categoryWithItems;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GetBuilder<PosController>(
            builder: (context) {
              List<String> filter = controller.productList
                  .map((product) => product.itemType.toLowerCase())
                  .toSet()
                  .toList();
              // ! item type
              return Visibility(
                visible: isCategoryWithItems ? false : context.isItemsShow,
                replacement: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      (BaseController
                                  .to
                                  .restaurantDetails
                                  ?.restaurant
                                  .groceriesMeat ??
                              false)
                          ? context.categoryTypeList.length
                          : context.categoryTypeList.length - 1,
                      (index) {
                        var data = context.categoryTypeList[index];
                        return PrimaryBtn(
                          onPressed: () {
                            context.categoryTypeActiveIndex = index;
                            context.itemCayegoryActiveIndex = -1;
                            context.productList.assignAll(
                              context.mainProductList,
                            );
                            context.productsForShow.assignAll(
                              context.productList,
                            );
                            context.filterCategoriesByMainCategory();

                            context.update();
                          },
                          color: data.color,
                          borderWidth: 2,
                          text: data.title.toUpperCase(),
                          isOutline: context.categoryTypeActiveIndex == index
                              ? true
                              : false,
                          textColor: Colors.white,
                          borderColor: StaticColors.blueColor,
                        ).marginOnly(right: 12);
                      },
                    ),
                  ),
                ),
                // child: SizedBox(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(filter.length, (index) {
                      String data = filter[index];
                      return PrimaryBtn(
                        onPressed: () {
                          context.itemTypeActiveIndex = index;
                          context.findProductsBytype(data);
                        },
                        borderWidth: 2,
                        color: MyFunc.getColorItemType(data),
                        isOutline: context.itemTypeActiveIndex == index
                            ? true
                            : false,
                        text: data.toUpperCase(),
                        borderColor: StaticColors.blueColor,
                        textColor: Colors.white,
                      ).marginOnly(right: 12);
                    }),
                  ),
                ),
              );
            },
          ),
        ),
        // custom
        // const Spacer(),
        SizedBox(
          width: 150,
          child: PrimaryBtn(
            onPressed: () {
              PopupDialog.customDialog(child: const CustomOrderDialogOptions());
            },
            color: StaticColors.blueColor,
            text: 'Custom'.toUpperCase(),
            textColor: Colors.white,
          ),
        ).marginOnly(right: 12, left: 12), // search
        SizedBox(
          width: 250,
          child: GetBuilder<PosController>(
            builder: (context) {
              return CustomTextField(
                allowRegex: CommonRegexPatterns.alphanumericWithSpaceAndLength(
                  200,
                ),
                controller: controller.searchController,
                focusNode: controller.searchFocusNode,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                hintText: 'Search item',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                onChange: (value) {
                  context.findProductsByName(value);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
