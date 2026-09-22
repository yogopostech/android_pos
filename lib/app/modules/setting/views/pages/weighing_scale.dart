// import 'package:dropdown_textfield/dropdown_textfield.dart';
// import 'package:flutter/material.dart';
// import 'package:yogo_pos/app/helper/app_helper.dart';

// import 'package:yogo_pos/app/modules/setting/controllers/weighing_scale_controller.dart';
// import 'package:yogo_pos/app/widgets/custom_textfield.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
// import 'package:flutter_libserialport/flutter_libserialport.dart';
// import 'package:get/get.dart';

// class WeighingScale extends GetView<WeighingScaleController> {
//   const WeighingScale({super.key});

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     controller.availablePorts.value = SerialPort.availablePorts;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Weighing Scale Serial Port',
//           style: theme.textTheme.titleLarge,
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           width: 500,
//           child: Obx(() {
//             return CustomSearchTextField(
//               hintText: controller.serialPort.value.isEmpty
//                   ? "Select Weighing Scale"
//                   : controller.serialPort.value,
//               dropDownList:
//                   List.generate(controller.availablePorts.length, (index) {
//                 return DropDownValueModel(
//                   value: controller.availablePorts[index],
//                   name: controller.availablePorts[index],
//                 );
//               }),
//               onChanged: (value) {
//                 controller.onChangeSerialPort(value);
//                 PopupDialog.permissionDialog(theme, onSubmit: () {
//                   AppHelper.restartApp();
//                 }, title: "Reset application?");
//               },
//             );
//           }),
//         ),
//       ],
//     );
//   }
// }
