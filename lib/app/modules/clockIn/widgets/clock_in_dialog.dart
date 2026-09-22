import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/auth/controllers/auth_controller.dart';
import 'package:yogo_pos/app/modules/clockIn/providers/clock_in_out.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/routes/app_pages.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class ClockInDialog extends ConsumerWidget {
  final String? title;
  final String? subTitle;

  const ClockInDialog({super.key, this.subTitle, this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final clockedIn = ref.watch(isClockedInProvider);

    return Container(
      padding: const EdgeInsets.only(top: 0, left: 24, right: 24, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Icon ----
          Icon(
            Icons.access_time_filled_rounded,
            size: 77,
            color: StaticColors.greenColor,
          ),
          const SizedBox(height: 16),

          // ---- Title ----
          Text(
            title ?? (clockedIn ? "Clock Out?" : "Clock In?"),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 40,
            ),
          ),
          const SizedBox(height: 18),
          // ---- Message ----
          Text(
            subTitle ??
                (clockedIn
                    ? "You are Clocked In. Clock out and end your shift\n or skip to continue."
                    : "You are not clocked in. Clock in now to start your shift,\n or skip to continue."),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 18,
              color: ConfigController.to.isLightTheme
                  ? Colors.grey.shade600
                  : Colors.white.withAlpha(155),
            ),
          ),
          const SizedBox(height: 28),

          // ---- Bottom buttons ----
          Row(
            children: [
              // Clock In
              Expanded(
                child: PrimaryBtn(
                  height: 65,
                  onPressed: () async {
                    final notifier = ref.read(clockInOutProvider.notifier);
                    if (clockedIn) {
                      // ---- CLOCK OUT (server) ----
                      PopupDialog.showLoadingDialog();
                      final ok = await notifier.clockOut(isClockout: true);
                      PopupDialog.closeLoadingDialog();
                      if (!ok) {
                        // failed — toast already shown, stay clocked in
                        Get.back(); // close the permission dialog
                        return;
                      }

                      // success — close dialog, tear down session, navigate
                      Get.back();
                      AuthController.to.isShowSplashScreen.value = false;
                      Get.delete<PosController>(force: true);
                      Preferences.removeItem(Preferences.ACCESS_TOKEN);
                      Preferences.removeItem(Preferences.USER_INFO);
                      BaseController.to.employeeData = null;
                      Get.offAndToNamed(Routes.AUTH);
                    } else {
                      PopupDialog.showLoadingDialog();
                      final ok = await ref
                          .read(clockInOutProvider.notifier)
                          .clockIn();
                      PopupDialog.closeLoadingDialog();
                      if (ok) {
                        Get.back(result: true);
                      }
                    }
                  },
                  text: clockedIn ? 'CLOCK OUT' : 'CLOCK IN',
                  textColor: Colors.white,
                  color: StaticColors.greenColor,
                  fontWeight: FontWeight.w900,
                  textMaxSize: 29,
                  textMinSize: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Skip
              Expanded(
                child: PrimaryBtn(
                  height: 65,
                  onPressed: () {
                    Get.back(result: false);
                  },
                  text: 'SKIP',
                  textColor: Colors.white,
                  color: StaticColors.blueColor,
                  fontWeight: FontWeight.w900,
                  textMaxSize: 29,
                  textMinSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
