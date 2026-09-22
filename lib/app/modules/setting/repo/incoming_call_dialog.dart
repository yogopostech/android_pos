// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:get/get.dart';
// import 'package:yogo_pos/app/modules/setting/providers/caller_id_notifier.dart';
// import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';
// import 'package:yogo_pos/app/services/controller/config_controller.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';

// class CallerInfoDialog extends ConsumerWidget {
//   const CallerInfoDialog({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isLight = ConfigController.to.isLightTheme;
//     final theme = Theme.of(context);
//     final textColor = isLight ? Colors.black : Colors.white;
//     final subColor = isLight
//         ? Colors.black.withAlpha(150)
//         : Colors.white.withAlpha(170);

//     // ✅ Riverpod থেকে active calls
//     final activeCalls = ref.watch(callerIdProvider).activeCalls;
//     return Dialog(
//       backgroundColor: (ConfigController.to.isLightTheme
//           ? theme.canvasColor
//           : StaticColors.cartColor),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: SizedBox(
//         width: 420,
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // ── Header ───────────────────────────────────────────────────
//               Row(
//                 children: [
//                   Container(
//                     width: 44,
//                     height: 44,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF3BB2F6).withAlpha(30),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(
//                       Icons.phone_in_talk_outlined,
//                       color: Color(0xFF3BB2F6),
//                       size: 22,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Text(
//                     'Incoming Call',
//                     style: TextStyle(
//                       color: textColor,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const Spacer(),
//                   // Call count badge
//                   if (activeCalls.length > 1)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 5,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF3BB2F6).withAlpha(30),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: const Color(0xFF3BB2F6).withAlpha(80),
//                         ),
//                       ),
//                       child: Text(
//                         '${activeCalls.length} Calls',
//                         style: const TextStyle(
//                           color: Color(0xFF3BB2F6),
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),

//               const SizedBox(height: 14),
//               Divider(
//                 color: isLight
//                     ? Colors.black.withAlpha(20)
//                     : Colors.white.withAlpha(30),
//                 height: 1,
//               ),
//               const SizedBox(height: 14),

//               // ── Call List ─────────────────────────────────────────────────
//               ListView.separated(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: activeCalls.length,
//                 separatorBuilder: (_, __) => Divider(
//                   color: isLight
//                       ? Colors.black.withAlpha(15)
//                       : Colors.white.withAlpha(20),
//                   height: 20,
//                 ),
//                 itemBuilder: (context, index) {
//                   final callerData = activeCalls[index];
//                   return _CallerItem(
//                     callerData: callerData,
//                     textColor: textColor,
//                     subColor: subColor,
//                     isLight: isLight,
//                     onDismiss: () => ref
//                         .read(callerIdProvider.notifier)
//                         .removeCall(callerData),
//                   );
//                 },
//               ),

//               const SizedBox(height: 20),

//               // ── Dismiss All button ────────────────────────────────────────
//               SizedBox(
//                 width: double.infinity,
//                 child: TextButton(
//                   onPressed: () {
//                     Get.back();
//                   },
//                   style: TextButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     foregroundColor: StaticColors.blueColor,
//                     overlayColor: StaticColors.blueColor.withAlpha(30),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       side: BorderSide(
//                         color: isLight
//                             ? Colors.black.withAlpha(20)
//                             : Colors.white.withAlpha(30),
//                       ),
//                     ),
//                   ),
//                   child: Text(
//                     activeCalls.length > 1 ? 'Dismiss All' : 'Dismiss',
//                     style: TextStyle(color: subColor, fontSize: 14),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Single Caller Item ─────────────────────────────────────────────────────────

// class _CallerItem extends StatelessWidget {
//   final CallerIdData callerData;
//   final Color textColor;
//   final Color subColor;
//   final bool isLight;
//   final VoidCallback onDismiss;

//   const _CallerItem({
//     required this.callerData,
//     required this.textColor,
//     required this.subColor,
//     required this.isLight,
//     required this.onDismiss,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Line badge

//         // Name
//         Row(
//           children: [
//             Expanded(
//               child: _InfoRow(
//                 icon: Icons.person_outline,
//                 label: 'Name',
//                 value: callerData.displayName,
//                 textColor: textColor,
//                 subColor: subColor,
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                 color: Colors.green.withAlpha(30),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.green.withAlpha(80)),
//               ),
//               child: Text(
//                 'Line ${callerData.lineNumber}',
//                 style: const TextStyle(
//                   color: Colors.green,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),

//         // Phone
//         _InfoRow(
//           icon: Icons.phone_outlined,
//           label: 'Number',
//           value: callerData.displayPhone,
//           textColor: textColor,
//           subColor: subColor,
//         ),
//         const SizedBox(height: 8),

//         // Time
//         _InfoRow(
//           icon: Icons.access_time_outlined,
//           label: 'Time',
//           value: _formatTime(callerData.receivedAt),
//           textColor: textColor,
//           subColor: subColor,
//         ),

//         // Private badge
//         if (callerData.isPrivate) ...[
//           const SizedBox(height: 10),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.orange.withAlpha(30),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.orange.withAlpha(80)),
//             ),
//             child: const Text(
//               'Private / Blocked Number',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.orange,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   String _formatTime(DateTime dt) {
//     final h = dt.hour > 12
//         ? dt.hour - 12
//         : dt.hour == 0
//         ? 12
//         : dt.hour;
//     final m = dt.minute.toString().padLeft(2, '0');
//     final period = dt.hour >= 12 ? 'PM' : 'AM';
//     return '$h:$m $period';
//   }
// }

// // ── Info Row ───────────────────────────────────────────────────────────────────

// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color textColor;
//   final Color subColor;

//   const _InfoRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.textColor,
//     required this.subColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, size: 18, color: const Color(0xFF3BB2F6)),
//         const SizedBox(width: 10),
//         Text(
//           '$label:  ',
//           style: TextStyle(
//             fontSize: 14,
//             color: subColor,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               color: textColor,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/modules/setting/providers/caller_id_notifier.dart';
import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

class CallerInfoDialog extends ConsumerWidget {
  const CallerInfoDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = ConfigController.to.isLightTheme;
    final theme = Theme.of(context);
    final textColor = isLight ? Colors.black : Colors.white;
    final subColor = isLight
        ? Colors.black.withAlpha(150)
        : Colors.white.withAlpha(170);

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
class _CallerItem extends StatelessWidget {
  final int index;
  final CallerIdData data;
  final bool isLight;
  final Color textColor;
  final Color subColor;

  const _CallerItem({
    required this.index,
    required this.data,
    required this.isLight,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.black.withAlpha(6) : Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isLight
              ? Colors.black.withAlpha(18)
              : Colors.white.withAlpha(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // ── Index number ─────────────────────────────────────────
          Container(
            width: 40,
            height: 40,

            alignment: Alignment.center,
            child: Text(
              '$index.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // // ── Line badge ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.withAlpha(80)),
            ),
            child: Text(
              'Line ${data.lineNumber}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Phone icon ───────────────────────────────────────────
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: StaticColors.blueColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.phone_in_talk_outlined,
              color: StaticColors.blueColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),

          // ── Name + phone + status ────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.displayName,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  data.displayPhone,
                  style: TextStyle(color: subColor, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat(
                    'MMM dd, hh:mm a',
                  ).format(data.receivedAt.toLocal()),
                  style: TextStyle(color: subColor, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
