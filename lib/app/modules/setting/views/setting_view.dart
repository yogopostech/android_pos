import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/setting/widgets/menu_btn.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

import 'package:get/get.dart';
import 'package:yogo_pos/app/widgets/title_bar.dart';

import '../controllers/setting_controller.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          controller.menuIndex = 0;
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            const TitleBar(),
            Expanded(
              child: Scaffold(
                body: Row(
                  children: [
                    //menu
                    Container(
                      color: ConfigController.to.isLightTheme
                          ? theme.cardColor
                          : StaticColors.cartColor,
                      width: 300,
                      height: double.infinity,
                      child: Column(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Get.back(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.arrow_back, size: 32),
                                    // const SizedBox(width: 12),
                                    // Text(
                                    //   "Back",
                                    //   style: theme.textTheme.titleLarge,
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: GetBuilder<SettingController>(
                                builder: (controller) {
                                  // final bool isShowPaymentMenu =
                                  //     BaseController.to.posElavonTerminal ||
                                  //     BaseController.to.posMonerisTerminal;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(
                                      MyFunc.shouldShowTimeSheetReport()
                                          ? controller.menuList.length
                                          : controller.menuList.length - 1,
                                      (index) {
                                        return MenuBtn(
                                          // isShow: index == 1
                                          //     ? isShowPaymentMenu
                                          //     : true,
                                          isShow: true,
                                          icon: controller.menuList[index].icon,
                                          title:
                                              controller.menuList[index].title,
                                          isActive:
                                              controller.menuIndex == index
                                              ? true
                                              : false,
                                          onTap: () {
                                            controller.onChangeMenu(index);
                                          },
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // body
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        color: theme.scaffoldBackgroundColor,
                        height: double.infinity,
                        child: GetBuilder<SettingController>(
                          builder: (context) {
                            return controller
                                .menuList[controller.menuIndex]
                                .child;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
