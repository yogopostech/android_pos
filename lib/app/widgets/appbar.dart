import 'package:yogo_pos/app/modules/auth/controllers/auth_controller.dart';
import 'package:yogo_pos/app/modules/auth/views/auth_view.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLeading;
  final bool hasHomeButton;
  final bool hasButtonsRow;
  final bool hasLogoutBtn;
  final double? preferredHeight;
  final Color? backgroundColor;
  final bool centerTitle;
  final Widget? title;
  final Widget? leading;
  final bool isPrimary;
  final Function()? onLeading;

  const CustomAppBar({
    super.key,
    this.centerTitle = false,
    this.isLeading = true,
    this.hasHomeButton = true,
    this.hasLogoutBtn = true,
    this.preferredHeight,
    this.backgroundColor,
    this.hasButtonsRow = true,
    this.title,
    this.onLeading,
    this.leading,
    this.isPrimary = true,
  });
  // Specify the desired height of the AppBar
  @override
  Size get preferredSize =>
      Size.fromHeight(isPrimary == true ? preferredHeight ?? 65 : 60);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 24,
      elevation: 0,
      centerTitle: centerTitle,
      leadingWidth: 80,

      backgroundColor:
          backgroundColor ??
          (ConfigController.to.isLightTheme
              ? theme.canvasColor
              : StaticColors.cartColor),
      // foregroundColor: kTextColor,
      // titleTextStyle: kTitleLarge.copyWith(color: const Color(0xff2F2F2F)),
      // appbar leading
      leading: null,
      title: title,
      flexibleSpace: isPrimary
          ? SizedBox(
              // decoration: BoxDecoration(
              //     border: Border(bottom: BorderSide(color: theme.dividerColor))),
              width: double.infinity,
              child: Column(
                children: [
                  // topbar
                  _topBar(theme, context),
                  // Visibility(
                  //   visible: hasButtonsRow,
                  //   child: _buttons(theme),
                  // ),
                ],
              ),
            )
          : null,
    );
  }

  //** Buttons **
  Widget _topBar(ThemeData theme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              // theme
              Visibility(
                visible: hasLogoutBtn,
                child: PrimaryBtn(
                  width: 100,
                  onPressed: () {
                    Get.to(() => const AuthView());
                    AuthController.to.isShowSplashScreen.value = false;
                    BaseController.to.employeeData = null;
                  },
                  text: 'Logout',
                  textColor: Colors.white,
                  color: StaticColors.orangeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
