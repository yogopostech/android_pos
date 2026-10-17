import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

class CallerInfoDialog extends ConsumerWidget {
  const CallerInfoDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = ConfigController.to.isLightTheme;
    final theme = Theme.of(context);
    final textColor = isLight ? Colors.black : Colors.white;
    // final subColor = isLight
    //     ? Colors.black.withAlpha(150)
    //     : Colors.white.withAlpha(170);

    // final activeCalls = ref.watch(callerIdProvider).activeCalls;

    return Dialog(
      backgroundColor: isLight ? theme.canvasColor : StaticColors.cartColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 480,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: StaticColors.blueColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.phone_in_talk_outlined,
                      color: StaticColors.blueColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Incoming Call',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
              
                  // ── Close Button ─────────────────────────────────────
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(8),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: isLight
                              ? Colors.black.withAlpha(10)
                              : Colors.white.withAlpha(15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.close_rounded,
                            color: isLight
                                ? Colors.black.withAlpha(150)
                                : Colors.white.withAlpha(180),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Divider(
                color: isLight
                    ? Colors.black.withAlpha(20)
                    : Colors.white.withAlpha(30),
                height: 1,
              ),
              const SizedBox(height: 14),

              // ── Call List ────────────────────────────────────────────
             
            ],
          ),
        ),
      ),
    );
  }
}

// ── Caller Item ───────────────────────────────────────────────────────────────
// class _CallerItem extends StatelessWidget {
//   final int index;
//   final CallerIdData data;
//   final bool isLight;
//   final Color textColor;
//   final Color subColor;

//   const _CallerItem({
//     required this.index,
//     required this.data,
//     required this.isLight,
//     required this.textColor,
//     required this.subColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isLight ? Colors.black.withAlpha(6) : Colors.white.withAlpha(8),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: isLight
//               ? Colors.black.withAlpha(18)
//               : Colors.white.withAlpha(20),
//         ),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       child: Row(
//         children: [
//           // ── Index number ─────────────────────────────────────────
//           Container(
//             width: 40,
//             height: 40,

//             alignment: Alignment.center,
//             child: Text(
//               '$index.',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),

//           // // ── Line badge ───────────────────────────────────────────
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.green.withAlpha(30),
//               borderRadius: BorderRadius.circular(6),
//               border: Border.all(color: Colors.green.withAlpha(80)),
//             ),
//             child: Text(
//               'Line ${data.lineNumber}',
//               style: const TextStyle(
//                 color: Colors.green,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),

//           // ── Phone icon ───────────────────────────────────────────
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: StaticColors.blueColor.withAlpha(25),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(
//               Icons.phone_in_talk_outlined,
//               color: StaticColors.blueColor,
//               size: 22,
//             ),
//           ),
//           const SizedBox(width: 10),

//           // ── Name + phone + status ────────────────────────────────
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         data.displayName,
//                         style: TextStyle(
//                           color: textColor,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   data.displayPhone,
//                   style: TextStyle(color: subColor, fontSize: 16),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   DateFormat(
//                     'MMM dd, hh:mm a',
//                   ).format(data.receivedAt.toLocal()),
//                   style: TextStyle(color: subColor, fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// 