import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yogo_pos/app/helper/app_helper.dart';
import 'package:yogo_pos/app/routes/app_pages.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/services/controller/socket_provider.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/widgets/title_bar.dart';
import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    // Get.put<SocketController>(SocketController(), permanent: true);
    return Consumer(
      builder: (context, ref, child) {
        ref.read(socketControllerProvider.notifier).connect();

        

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Column(
            children: [
              const TitleBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      // top bar
                      8.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            width: 150,
                            'assets/images/splash/yogo_logo.svg',
                            colorFilter: ColorFilter.mode(
                              ConfigController.to.isLightTheme
                                  ? Colors.black
                                  : Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          Row(
                            children: [
                              Consumer(
                                builder: (context, ref, child) {
                                  return GestureDetector(
                                    onTap: () async {
                                      //need disconnection with caller id

                                      BaseController.to.playTapSound();
                                      PopupDialog.permissionDialog(
                                        theme,
                                        onSubmit: () async {
                                       
                                          await BaseController.to.logout();
                                          Get.offAllNamed(Routes.SIGN_IN);
                                          AppHelper.restartApp();
                                        },
                                        title: "Logout ?",
                                      );
                                      // Preferences.clear();
                                    },
                                    child: Container(
                                      height: 55,
                                      width: 55,
                                      // padding: const EdgeInsets.all(20),
                                      decoration: const BoxDecoration(
                                        color: StaticColors.redColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        color: Colors.white,
                                        Icons.logout,
                                        size: 33,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      // body
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Container(
                                  padding: const EdgeInsets.only(left: 50),
                                  // color: Colors.red,
                                  alignment: Alignment.centerLeft,
                                  // child: ,
                                  child: Visibility(
                                    visible: ConfigController.to.isLightTheme,
                                    replacement: CachedNetworkImage(
                                      fit: BoxFit.fitHeight,
                                      // width: Get.width * .33,
                                      imageUrl:
                                          BaseController
                                              .to
                                              .restaurantDetails
                                              ?.restaurant
                                              .darkLogo ??
                                          "",
                                      placeholder: (context, url) =>
                                          const SizedBox(),
                                      errorWidget: (context, url, error) =>
                                          const SizedBox(),
                                    ),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.fitHeight,
                                      // width: Get.width * .33,
                                      imageUrl:
                                          BaseController
                                              .to
                                              .restaurantDetails
                                              ?.restaurant
                                              .lightLogo ??
                                          "",
                                      placeholder: (context, url) =>
                                          const SizedBox(),
                                      errorWidget: (context, url, error) =>
                                          const SizedBox(),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: FittedBox(
                                  child: Container(
                                    width: 400,
                                    alignment: Alignment.centerRight,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      // color: ConfigController.to.isLightTheme
                                      //     ? const Color(0xffEFEFEF)
                                      //     : const Color(0xff2A2A2A),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // password display
                                        _passwordDisplay(theme),
                                        const SizedBox(height: 4),
                                        // keybord area
                                        _customKeybord(theme),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      // bottom
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GetBuilder<BaseController>(
                            builder: (context) {
                              return MyCustomText(
                                'Version: ${BaseController.to.packageInfo?.version ?? '1.0.0'}',
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                              );
                            },
                          ),
                          25.width,
                          MyCustomText(
                            '© YOGO POS Entities- All rights reserved. Protected by copyright & patents.',
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                          // MyTime(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _passwordDisplay(ThemeData theme) {
    return Container(
      height: 100,
      width: 400,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        color: Colors.transparent,
        // color: ConfigController.to.isLightTheme
        //     ? theme.cardColor
        //     : theme.canvasColor,
        borderRadius: BorderRadius.circular(6),
        // border: Border.all(
        //   color: theme.colorScheme.surface,
        //   width: 1.75,
        // )
        // border: Border.all(
        //   color: const Color(0xffEBEBEB),
        //   width: .5,
        // ),
      ),
      child: Obx(
        () => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            controller.passwordLength.value,
            (index) => CircleAvatar(
              backgroundColor: index + 1 > controller.password.value.length
                  ? Colors.transparent
                  : theme.colorScheme.surface,
              radius: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _customKeybord(ThemeData theme) {
    return SizedBox(
      width: 400,
      child: StaggeredGrid.count(
        crossAxisCount: 3,
        mainAxisSpacing: 18,
        crossAxisSpacing: 0,
        children: List.generate(
          controller.numberList.length,
          (index) => SizedBox(
            width: 100,
            height: 100,
            child: ElevatedButton(
              onPressed: () {
                controller.toggleStartup(false);
                BaseController.to.playTapSound();
                if (controller.numberList.length - 1 == index) {
                  // log in
                  controller.login();
                } else if (controller.numberList[index] == "*") {
                  // remove number
                  controller.removePassword();
                } else {
                  // add number
                  controller.addPassword(controller.numberList[index]);
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                // ****** style ******
                textStyle: theme.textTheme.titleLarge?.copyWith(
                  color: StaticColors.redColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 36,
                ),
                backgroundColor: controller.numberList[index] == "*"
                    ? controller.numberList.length - 1 == index
                          ? const Color(0xff118A00)
                          : StaticColors.redColor
                    : ConfigController.to.isLightTheme
                    ? theme.cardColor
                    : theme.canvasColor,
                foregroundColor: theme.dividerColor,
                padding: EdgeInsets.zero,
                shape: CircleBorder(),
                // ****** Border color *******
                side: const BorderSide(color: Color(0xffEBEBEB), width: .5),
              ),
              child: controller.numberList[index] == "*"
                  ? controller.numberList.length - 1 == index
                        ? const FaIcon(
                            FontAwesomeIcons.check,
                            color: Colors.white,
                            size: 36,
                          )
                        : const FaIcon(
                            FontAwesomeIcons.deleteLeft,
                            color: Colors.white,
                            size: 36,
                          )
                  : MyCustomText(
                      controller.numberList[index],
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
