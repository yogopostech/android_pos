// import 'package:flutter/material.dart';
// import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
// import 'package:yogo_pos/app/modules/setting/repo/caller_id_repo_l1.dart';
// import 'package:yogo_pos/app/modules/setting/repo/caller_id_repo_l2.dart';
// import 'package:yogo_pos/app/services/base/preferences.dart';
// import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/services/models/restaurant_model.dart';
// import 'package:yogo_pos/app/services/widgets/dialogs/serial_port_list_for_caller_id_dialog.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
// import 'package:get/get.dart';

// class CallerIdController extends GetxController {
//   static CallerIdController get to => Get.find();
//   String callerNameL1 = "";
//   String callerNumberL1 = "";
//   String callerNameL2 = "";
//   String callerNumberL2 = "";
//   // calle
//   bool isCallingL1 = false;
//   bool isCallingL2 = false;

//   // L1 and L2 open or not
//   bool get telePhoneL1 => Preferences.telephoneL1;
//   bool get telePhoneL2 => Preferences.telephoneL2;
//   //caller  port
//   String get callerPortL1 => Preferences.callerPortL1;
//   String get callerPortL2 => Preferences.callerPortL2;

//   // has caller id

//   onChangeL1(bool value) {
//     if (value) {
//       PopupDialog.customDialog(
//         width: 500,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 22),
//           child: SerialPortListForCallerIdDialog(
//             selectPort: callerPortL1,
//             title: "Select Caller Port L1",
//             onPressed: (port) {
//               if (port != callerPortL2) {
//                 Preferences.callerPortL1 = port;
//                 update();
//                 Preferences.telephoneL1 = value;
//                 Get.back();
//                 // ! run caller_id func
//                 CallerIdRepoL1().initSerialPort();
//               } else {
//                 Get.back();
//                 PopupDialog.showErrorMessage("Already Selected By L2");
//               }
//             },
//           ),
//         ),
//       );
//     } else {
//       Preferences.telephoneL1 = value;
//       update();
//       // ! close caller_id func
//       CallerIdRepoL1().dispose();
//     }
//   }

//   onChangeL2(bool value) {
//     if (value) {
//       PopupDialog.customDialog(
//         width: 500,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 22),
//           child: SerialPortListForCallerIdDialog(
//             selectPort: callerPortL2,
//             title: "Select Caller Port L2",
//             onPressed: (port) {
//               if (port != callerPortL1) {
//                 Preferences.callerPortL2 = port;
//                 update();
//                 Preferences.telephoneL2 = value;
//                 Get.back();
//                 // ! run caller_id func
//                 CallerIdRepoL2().initSerialPort();
//               } else {
//                 Get.back();
//                 PopupDialog.showErrorMessage("Already Selected By L1");
//               }
//             },
//           ),
//         ),
//       );
//     } else {
//       Preferences.telephoneL2 = value;
//       update();
//       // ! close caller_id func
//       CallerIdRepoL2().dispose();
//     }
//   }

//   // set caller data for L1
//   void setCallerDataForL1() {
//     if (callerNumberL1.isNotEmpty) {
//       PosController.to.guestNameController.text = callerNameL1;
//       PosController.to.guestPhoneController.text = callerNumberL1;
//     }
//   }

//   // set caller data for L1
//   void setCallerDataForL2() {
//     if (callerNumberL2.isNotEmpty) {
//       PosController.to.guestNameController.text = callerNameL2;
//       PosController.to.guestPhoneController.text = callerNumberL2;
//     }
//   }

//   @override
//   void onReady() {
//     if (BaseController.to.allowCallerIdTypeChange &&
//         BaseController.to.callerIdType == CallerIdType.typeOne) {
//       if (telePhoneL1) {
//         CallerIdRepoL1().initSerialPort();
//       }
//       if (telePhoneL2) {
//         CallerIdRepoL2().initSerialPort();
//       }
//     }
//     super.onReady();
//   }
// }
