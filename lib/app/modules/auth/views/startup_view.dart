import 'package:flutter/material.dart';
import 'package:yogo_pos/app/routes/app_pages.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../services/controller/config_controller.dart';
import '../../../widgets/custom_inkwell.dart';

class StartupView extends StatelessWidget {
  const StartupView({
    super.key,
    required this.onTap,
    required this.isOnTop,
  });

  final VoidCallback onTap;
  final bool isOnTop;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    width: 225,
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
                      CustomInkWell(
                        onTap: ConfigController.to.toggleTheme,
                        child: SvgPicture.asset(
                          'assets/icons/theme.svg',
                          height: 55,
                          colorFilter: ColorFilter.mode(
                              ConfigController.to.isLightTheme
                                  ? Colors.black
                                  : Colors.white,
                              BlendMode.srcIn),
                        ),
                      ).marginOnly(right: 10),
                      GestureDetector(
                        onTap: () {
                          BaseController.to.playTapSound();
                          Preferences.clear();
                          Get.offAllNamed(Routes.SIGN_IN);
                        },
                        child: Container(
                          height: 55,
                          width: 55,
                          // padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                              color: StaticColors.redColor,
                              shape: BoxShape.circle),
                          child: const Icon(
                            color: Colors.white,
                            Icons.logout,
                            size: 33,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: AnimatedOpacity(
                  opacity: isOnTop ? 1.0 : 0.25,
                  duration: const Duration(milliseconds: 300),
                  child: Image.asset(
                    width: MediaQuery.sizeOf(context).width * 0.7,
                    "assets/images/splash/login_logo.png",
                  ),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MyCustomText(
                    'Version: 0.23.1',
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                  ),
                  // MyTime(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
