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
                appBar: AppBar(
                  backgroundColor: ConfigController.to.isLightTheme
                      ? theme.cardColor
                      : StaticColors.cartColor,
                  title: GetBuilder<SettingController>(
                    builder: (context) {
                      return Text(context.menuList[context.menuIndex].title);
                    },
                  ),
                  // backgroundColor: (ConfigController.to.isLightTheme
                  //     ? theme.canvasColor
                  //     : StaticColors.cartColor),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, size: 36),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  // ! colour theme
                  // actions: [
                  //   Container(
                  //     height: 45,
                  //     width: 45,
                  //     margin: const EdgeInsets.only(right: 12),
                  //     decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: !ConfigController.to.isLightTheme
                  //             ? Colors.black
                  //             : Colors.white),
                  //     child: CustomInkWell(
                  //       onTap: ConfigController.to.toggleTheme,
                  //       child: SvgPicture.asset(
                  //         'assets/icons/theme.svg',
                  //         // height: 55,
                  //         colorFilter: ColorFilter.mode(
                  //             ConfigController.to.isLightTheme
                  //                 ? Colors.black
                  //                 : Colors.white,
                  //             BlendMode.srcIn),
                  //       ),
                  //     ),
                  //   ),
                  // ],
                ),
                body: Row(
                  children: [
                    //menu
                    Container(
                      color: ConfigController.to.isLightTheme
                          ? theme.cardColor
                          : StaticColors.cartColor,
                      width: 300,
                      height: double.infinity,
                      child: SingleChildScrollView(
                        child: GetBuilder<SettingController>(
                          builder: (controller) {
                            // final bool isShowPaymentMenu =
                            //     BaseController.to.posElavonTerminal ||
                            //     BaseController.to.posMonerisTerminal;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    title: controller.menuList[index].title,
                                    isActive: controller.menuIndex == index
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
