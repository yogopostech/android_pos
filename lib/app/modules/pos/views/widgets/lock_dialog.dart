// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/services/controller/config_controller.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';
// import 'package:yogo_pos/app/widgets/my_custom_text.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';

// class LockDialog extends StatefulWidget {
//   const LockDialog({super.key});

//   @override
//   State<LockDialog> createState() => _LockDialogState();
// }

// class _LockDialogState extends State<LockDialog> {
//   String _password = "";
//   final String? _pin = BaseController.to.employeeData?.accessPin.toString();
//   final int _passwordLength = 6;
//   final List<String> _numberList = [
//     "1",
//     "2",
//     "3",
//     "4",
//     "5",
//     "6",
//     "7",
//     "8",
//     "9",
//     "*",
//     "0",
//     "*",
//   ];
//   _matchingPassword() {
//     // kLogger.e(_password);
//     // kLogger.i(_pin);
//     if (_password.length > 3 && (_pin != null && _pin == _password)) {
//       BaseController.to.isEntryView = true;
//       Get.back();
//     }
//   }

//   _removePassword() {
//     if (_password.isNotEmpty) {
//       _password = _password.substring(0, _password.length - 1);
//       setState(() {});
//     }
//   }

//   _addPassword(String characterToAdd) {
//     if (_password.length < 6) {
//       _password += characterToAdd;
//       setState(() {});
//       // kLogger.e(password.value);
//     }
//   }

//   Timer? _timer; // Declare the Timer

//   @override
//   void initState() {
//     super.initState();
//     _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
//       BaseController.to.startInactivityTimer();
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel(); // Cancel the Timer
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     return Center(
//       child: SizedBox(
//         height: double.infinity,
//         width: double.infinity,
//         child: Material(
//           elevation: 3,
//           // dialog color
//           shadowColor: Colors.transparent,
//           // backgraund color
//           color: ConfigController.to.isLightTheme
//               ? Colors.black12.withAlpha(102)
//               : StaticColors.cartColor.withAlpha(204),
//           // border radius
//           borderRadius: BorderRadius.circular(6),

//           /// SpinningLines
//           child: Padding(
//             padding: const EdgeInsets.only(left: 20, right: 26, bottom: 20),
//             child: Center(
//               child: InkWell(
//                   onTap: () {
//                     Get.back();
//                   },
//                   child: SizedBox(
//                     width: 400,
//                     // decoration: BoxDecoration(
//                     //     color: ConfigController.to.isLightTheme
//                     //         ? const Color(0xffEFEFEF)
//                     //         : const Color(0xff2A2A2A),
//                     //     borderRadius: BorderRadius.circular(8)),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // password display
//                         _passwordDisplay(theme),
//                         const SizedBox(height: 4),
//                         // keybord area
//                         _customKeybord(theme),
//                       ],
//                     ),
//                   )),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _passwordDisplay(ThemeData theme) {
//     return Container(
//       height: 100,
//       width: 400,
//       padding: const EdgeInsets.symmetric(horizontal: 26),
//       decoration: BoxDecoration(
//         color: ConfigController.to.isLightTheme
//             ? theme.cardColor
//             : theme.canvasColor,
//         borderRadius: BorderRadius.circular(8),
//         // border: Border.all(
//         //   color: theme.colorScheme.surface,
//         //   width: 1.75,
//         // )
//         border: Border.all(
//           color: const Color(0xffEBEBEB),
//           width: .5,
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: List.generate(
//             _passwordLength,
//             (index) => CircleAvatar(
//                   backgroundColor: index + 1 > _password.length
//                       ? Colors.transparent
//                       : theme.colorScheme.surface,
//                   radius: 10,
//                 )),
//       ),
//     );
//   }

//   Widget _customKeybord(ThemeData theme) {
//     return SizedBox(
//       width: 400,
//       child: StaggeredGrid.count(
//         crossAxisCount: 3,
//         mainAxisSpacing: 3,
//         crossAxisSpacing: 3,
//         children: List.generate(
//             _numberList.length,
//             (index) => SizedBox(
//                   width: 100,
//                   height: 100,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // controller.toggleStartup(false);
//                       // BaseController.to.playTapSound();
//                       if (_numberList.length - 1 == index) {
//                         // PopupDialog.showErrorMessage("Incorrect password");
//                         // log in
//                       } else if (_numberList[index] == "*") {
//                         // remove number
//                         _removePassword();
//                       } else {
//                         // add number
//                         _addPassword(_numberList[index]);
//                         _matchingPassword();
//                       }
//                       setState(() {});
//                     },
//                     style: ElevatedButton.styleFrom(
//                       elevation: 0,
//                       // ****** style ******
//                       textStyle: theme.textTheme.titleLarge?.copyWith(
//                           color: Colors.red,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 36),
//                       backgroundColor: _numberList[index] == "*"
//                           ? _numberList.length - 1 == index
//                               ? const Color(0xff118A00)
//                               : StaticColors.redColor
//                           : ConfigController.to.isLightTheme
//                               ? theme.cardColor
//                               : theme.canvasColor,
//                       foregroundColor: theme.dividerColor,
//                       padding: EdgeInsets.zero,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       // ****** Border color *******
//                       side: const BorderSide(
//                         color: Color(0xffEBEBEB),
//                         width: .5,
//                       ),
//                     ),
//                     child: _numberList[index] == "*"
//                         ? _numberList.length - 1 == index
//                             ? const FaIcon(FontAwesomeIcons.check,
//                                 color: Colors.white, size: 36)
//                             : const FaIcon(FontAwesomeIcons.deleteLeft,
//                                 color: Colors.white, size: 36)
//                         : MyCustomText(
//                             _numberList[index],
//                             fontSize: 40,
//                             fontWeight: FontWeight.w500,
//                           ),
//                   ),
//                 )),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/clockIn/providers/clock_in_out.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';

class ClockInDialog extends ConsumerWidget {
  const ClockInDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      width: 420,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Icon ----
          Icon(
            Icons.access_time_filled_rounded,
            size: 56,
            color: StaticColors.greenColor,
          ),
          const SizedBox(height: 16),

          // ---- Title ----
          Text(
            "Clock In?",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // ---- Message ----
          Text(
            "You are not clocked in. Clock in now to start your shift, "
            "or skip to continue without clocking in.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ConfigController.to.isLightTheme
                  ? Colors.grey.shade600
                  : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 28),

          // ---- Bottom buttons ----
          Row(
            children: [
              // Skip
              Expanded(
                child: PrimaryBtn(
                  height: 56,
                  onPressed: () {
                    Get.back(result: false);
                  },
                  text: 'SKIP',
                  textColor: Colors.white,
                  color: StaticColors.blueColor,
                ),
              ),
              const SizedBox(width: 14),
              // Clock In
              Expanded(
                child: PrimaryBtn(
                  height: 56,
                  onPressed: () async {
                    final ok =
                        await ref.read(clockInOutProvider.notifier).clockIn();
                    // Success — close dialog and report back.
                    // Failure — stay open; the provider already showed a toast.
                    if (ok) {
                      Get.back(result: true);
                    }
                  },
                  text: 'CLOCK IN',
                  textColor: Colors.white,
                  color: StaticColors.greenColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}