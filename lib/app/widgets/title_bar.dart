import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/auth/widgets/my_time.dart';
import 'package:yogo_pos/app/modules/clockIn/providers/clock_in_out.dart';
import 'package:yogo_pos/app/modules/setting/providers/serial_caller_id_service.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/widgets/color_theme.dart';

class TitleBar extends ConsumerWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final callerIdState = ref.watch(serialCallerIdServiceProvider);
    return GetBuilder<BaseController>(
      builder: (controller) {
        String? userName = controller.employeeData?.firstName;
        return GestureDetector(
        
          child: Container(
            height: 36,
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //left
                16.width,
                Row(
                  children: [
                    MyTime(),
                    VerticalDivider(
                      color: Colors.black.withAlpha(123),
                      indent: 5,
                      endIndent: 5,
                      width: 18,
                    ),
                  ],
                ),

                Visibility(
                  visible: userName != null,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 3,
                        ),

                        child: Text(
                          "User: ${MyFunc.capitalizeEachWord(s: userName)}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.black.withAlpha(123),
                        indent: 5,
                        endIndent: 5,
                        width: 18,
                      ),

                      //for theme change
                      SwitchStyleThemeToggle(),

                      // GradientSwitchThemeToggle(),
                      VerticalDivider(
                        color: Colors.black.withAlpha(123),
                        indent: 5,
                        endIndent: 5,
                        width: 18,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 10.width,
                      Consumer(
                        builder: (context, ref, child) {
                          final timeText = ref.watch(clockDurationTextProvider);
                          final clockedIn = ref.watch(isClockedInProvider);

                          return Visibility(
                            visible: clockedIn,
                            child: Row(
                              children: [
                                Text(
                                  "Clock In: ",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  timeText,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                VerticalDivider(
                                  color: Colors.black.withAlpha(123),
                                  indent: 5,
                                  endIndent: 5,
                                  width: 18,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // notification sound
                      Visibility(
                        visible: Preferences.isNotificationSound,
                        replacement: const Icon(
                          Icons.notifications_off_outlined,
                          color: Colors.black,
                          size: 22,
                        ),
                        child: const Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.black,
                          size: 22,
                        ),
                      ),
                      // socket connection
                      Visibility(
                        visible: controller.isSocketConnected,
                        replacement: Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: Icon(
                            Icons.cloud_off,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                        child: Icon(
                          Icons.cloud_done,
                          color: Colors.green,
                          size: 22,
                        ),
                      ).marginOnly(left: 10),

                     
                    ],
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  // btn
  Widget _btn({Function()? onTap, required IconData icon}) {
    return Container(
      // color: Colors.grey.withAlpha(100),
      width: 35,
      height: double.infinity,
      alignment: Alignment.center,
      child: InkWell(
        onTap: onTap,
        child: Center(child: Icon(icon, color: Colors.black, size: 16)),
      ),
    );
  }
}
