// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:get/get.dart';
// import 'package:yogo_pos/app/helper/app_helper.dart';
// import 'package:yogo_pos/app/modules/setting/controllers/caller_id_controller.dart';
// import 'package:yogo_pos/app/modules/setting/providers/serial_caller_id_service.dart';
// import 'package:yogo_pos/app/services/base/preferences.dart';
// import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/services/controller/config_controller.dart';
// import 'package:yogo_pos/app/services/models/restaurant_model.dart';
// import 'package:yogo_pos/app/utils/int_extensions.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

// class CallerId extends ConsumerWidget {
//   const CallerId({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ThemeData theme = Theme.of(context);
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Caller Id Type
//         GetBuilder<BaseController>(
//           builder: (bc) {
//             return Visibility(
//               visible: bc.allowCallerIdTypeChange,
//               replacement: Center(
//                 child: Text(
//                   "Caller Id disabled",
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: StaticColors.redColor,
//                   ),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Caller Id Type", style: theme.textTheme.titleLarge),
//                   8.height,
//                   SizedBox(
//                     width: 500,
//                     child: AbsorbPointer(
//                       absorbing:
//                           bc.restaurantDetails?.restaurant.callerIdType !=
//                           CallerIdType.both,
//                       child: DropdownSearch<CallerIdType>(
//                         items: (f, cs) => const [
//                           CallerIdType.typeOne,
//                           CallerIdType.typeTwo,
//                         ],
//                         selectedItem: bc.callerIdType,
//                         itemAsString: (item) => item.label,
//                         compareFn: (a, b) => a == b,
//                         popupProps: PopupProps.menu(
//                           fit: FlexFit.loose,
//                           itemBuilder: (context, item, isSelected, isDisabled) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 14,
//                               ),
//                               child: Text(
//                                 item.label,
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                         decoratorProps: DropDownDecoratorProps(
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(
//                                 color: Colors.grey.shade400,
//                                 width: 1,
//                               ),
//                             ),
//                           ),
//                           baseStyle: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         onSelected: (value) {
//                           if (value != null) {
//                             bc.callerIdType = value;
//                             Preferences.callerIdType = value;
//                             BaseController.to.update();
//                             AppHelper.restartApp();
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             );
//           },
//         ),

//         SizedBox(height: 12),
//         //! Type 2
//         GetBuilder<BaseController>(
//           builder: (bc) {
//             return Visibility(
//               visible:
//                   bc.allowCallerIdTypeChange &&
//                   bc.callerIdType == CallerIdType.typeTwo,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Obx(() {
//                     return _switch(
//                       theme: theme,
//                       value: BaseController.to.hasCallerId.value,
//                       onChanged: (value) {
//                         if (value) {
//                           PopupDialog.permissionDialog(
//                             title: "Enable Caller ID?",

//                             theme,
//                             onSubmit: () async {
//                               Preferences.hasCallerId = value;
//                               BaseController.to.hasCallerId.value = value;
//                               if (!value) {
//                                 ref
//                                     .read(
//                                       serialCallerIdServiceProvider.notifier,
//                                     )
//                                     .disconnect();
//                               }
//                               Get.back();
//                             },
//                           );
//                         } else {
//                           PopupDialog.permissionDialog(
//                             title: "Disable Caller ID?",

//                             theme,
//                             onSubmit: () async {
//                               Preferences.hasCallerId = value;
//                               BaseController.to.hasCallerId.value = value;
//                               if (!value) {
//                                 ref
//                                     .read(
//                                       serialCallerIdServiceProvider.notifier,
//                                     )
//                                     .disconnect();
//                               }
//                               Get.back();
//                             },
//                           );
//                         }
//                       },
//                       title: "Caller ID",
//                     );
//                   }),
//                   const SizedBox(height: 16),
//                   Obx(() {
//                     return Visibility(
//                       visible: BaseController.to.hasCallerId.value,
//                       child: _switch(
//                         theme: theme,
//                         value: BaseController.to.isCallerIdLocal.value,
//                         onChanged: (value) {
//                           if (value) {
//                             PopupDialog.permissionDialog(
//                               title: "Enable Local Caller ID?",

//                               theme,
//                               onSubmit: () async {
//                                 Preferences.isCallerIdLocal = value;
//                                 BaseController.to.isCallerIdLocal.value = value;
//                                 Get.back();
//                               },
//                             );
//                           } else {
//                             PopupDialog.permissionDialog(
//                               // title: "Enable Caller Id!",
//                               title: "Disable Local Caller ID?",
//                               theme,
//                               onSubmit: () async {
//                                 Preferences.isCallerIdLocal = value;
//                                 BaseController.to.isCallerIdLocal.value = value;
//                                 Get.back();
//                               },
//                             );
//                           }
//                         },
//                         title: "Local Caller ID",
//                       ),
//                     );
//                   }),
//                   const SizedBox(height: 16),
//                   Obx(() {
//                     return Visibility(
//                       visible: BaseController.to.hasCallerId.value,

//                       child: CallerIdSettingsWidget(),
//                     );
//                   }),
//                 ],
//               ),
//             );
//           },
//         ),

//         //! Type 1
//         GetBuilder<BaseController>(
//           builder: (bc) {
//             return Visibility(
//               visible:
//                   bc.allowCallerIdTypeChange &&
//                   bc.callerIdType == CallerIdType.typeOne,
//               child: Container(
//                 width: 500,
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: ConfigController.to.isLightTheme
//                         ? theme.cardColor
//                         : Colors.white.withAlpha(51),
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         border: Border(
//                           bottom: BorderSide(
//                             color: ConfigController.to.isLightTheme
//                                 ? theme.cardColor
//                                 : Colors.white.withAlpha(51),
//                           ),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Row(
//                               children: [
//                                 Text(
//                                   'Line 1 ',
//                                   style: theme.textTheme.titleSmall,
//                                 ),
//                                 GetBuilder<CallerIdController>(
//                                   builder: (context) {
//                                     return Text(
//                                       Preferences.callerPortL1.isNotEmpty
//                                           ? "(${context.callerPortL1})"
//                                           : "",
//                                       style: theme.textTheme.titleSmall
//                                           ?.copyWith(
//                                             fontWeight: FontWeight.w800,
//                                           ),
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           GetBuilder<CallerIdController>(
//                             builder: (context) {
//                               return Switch(
//                                 value: context.telePhoneL1,
//                                 onChanged: context.onChangeL1,
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Row(
//                               children: [
//                                 Text(
//                                   'Line 2 ',
//                                   style: theme.textTheme.titleSmall,
//                                 ),
//                                 GetBuilder<CallerIdController>(
//                                   builder: (context) {
//                                     return Text(
//                                       Preferences.callerPortL2.isNotEmpty
//                                           ? "(${context.callerPortL2})"
//                                           : "",
//                                       style: theme.textTheme.titleSmall
//                                           ?.copyWith(
//                                             fontWeight: FontWeight.w800,
//                                           ),
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           GetBuilder<CallerIdController>(
//                             builder: (context) {
//                               return Switch(
//                                 value: context.telePhoneL2,
//                                 onChanged: context.onChangeL2,
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

// class CallerIdSettingsWidget extends ConsumerWidget {
//   const CallerIdSettingsWidget({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final serviceState = ref.watch(serialCallerIdServiceProvider);
//     final service = ref.read(serialCallerIdServiceProvider.notifier);
//     // service.refreshPorts();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Status
//         Text(serviceState.statusMessage),

//         // Port dropdown
//         SizedBox(
//           width: 300,
//           child: DropdownButton<String>(
//             hint: Text(
//               serviceState.isListening
//                   ? Preferences.callerPortL1
//                   : 'Select COM Port',
//             ),
//             items: serviceState.availablePorts
//                 .map((p) => DropdownMenuItem(value: p, child: Text(p)))
//                 .toList(),
//             onChanged: serviceState.isListening
//                 ? null
//                 : (port) {
//                     if (port != null) {
//                       Preferences.callerPortL1 = port;
//                       service.connect(portName: port);
//                     }
//                   },
//           ),
//         ),

//         Row(
//           children: [
//             // Refresh ports
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: service.refreshPorts,
//             ),

//             // Connect / Disconnect
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: serviceState.isListening
//                     ? StaticColors.orangeColor
//                     : StaticColors.greenColor,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: serviceState.isListening
//                   ? () {
//                       Preferences.callerPortL1 = "";
//                       service.disconnect();
//                     }
//                   : null,
//               child: Text('Disconnect'),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// Widget _switch({
//   required ThemeData theme,
//   required bool value,
//   required Function(bool) onChanged,
//   required String title,
// }) {
//   return Container(
//     width: 500,
//     decoration: BoxDecoration(
//       border: Border.all(
//         color: ConfigController.to.isLightTheme
//             ? theme.cardColor
//             : Colors.white.withAlpha(51),
//       ),
//       borderRadius: BorderRadius.circular(8),
//     ),
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       child: Row(
//         children: [
//           Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
//           Switch(value: value, onChanged: onChanged),
//         ],
//       ),
//     ),
//   );
// }
