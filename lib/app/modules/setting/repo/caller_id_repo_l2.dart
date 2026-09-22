// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
// import 'package:yogo_pos/app/modules/setting/controllers/caller_id_controller.dart';
// import 'package:yogo_pos/app/services/base/preferences.dart';
// import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/utils/extension/my_extension.dart';
// import 'package:yogo_pos/app/utils/logger.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';
// import 'package:yogo_pos/app/widgets/custom_btn.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
// import 'package:flutter_libserialport/flutter_libserialport.dart';
// import 'package:get/get.dart';

// class CallerIdRepoL2 {
//   String selectedPort = Preferences.callerPortL2;
//   SerialPort? port;
//   Future<void> initSerialPort() async {
//     try {
//       port = SerialPort(selectedPort);
//       if (port != null && port!.isOpen == false) {
//         port?.openReadWrite();
//         port?.config = SerialPortConfig()
//           ..baudRate = 9600 // Match Caller ID device specs
//           ..bits = 7
//           ..stopBits = 1
//           ..parity = SerialPortParity.even
//           ..rts = SerialPortRts.off
//           ..cts = SerialPortCts.ignore
//           ..dsr = SerialPortDsr.ignore
//           ..dtr = SerialPortDtr.off
//           ..setFlowControl(SerialPortFlowControl.none);
//         PopupDialog.showSuccessDialog("L2 Serial port opened successfully.");

//         // Enable Caller ID
//         await sendATCommand("AT+VCID=1");

//         // Read data from the serial port
//         SerialPortReader reader = SerialPortReader(port!, timeout: 2000);
//         Stream upcomingData = reader.stream;

//         upcomingData.listen(
//           (data) {
//             try {
//               // Decode received bytes into a string
//               final decodedData = utf8.decode(data);
//               // kLogger.e('Data received: $decodedData');
//               // PopupDialog.showSuccessDialog("Data received: $decodedData");
//               // Extract Caller ID information (implement your parser)
//               if (decodedData.contains("NMBR")) {
//                 final callerInfo = parseAndFormatCallerInfo(decodedData);
//                 // ! show calling dialog
//                 onIncomingCall(callerInfo);
//                 // ! save the data
//                 CallerIdController.to.callerNameL2 = callerInfo["Name"] ?? "";
//                 CallerIdController.to.callerNumberL2 =
//                     callerInfo["Number"] ?? "";
//                 CallerIdController.to.update();
//               } else if (decodedData.contains("NO CARRIER")) {
//                 // Call has ended
//                 Get.back();
//               }
//             } catch (e) {
//               kLogger.e('Error processing data: $e');
//               PopupDialog.showErrorMessage('Error processing data: $e');
//             }
//           },
//           onError: (error) {
//             kLogger.e('Error in stream: $error');
//             PopupDialog.showErrorMessage('Error in stream: $error');
//           },
//         );
//       }
//     } catch (e) {
//       kLogger.e('Error initializing serial port: $e');
//       PopupDialog.showErrorMessage("Error initializing serial port: $e");
//     }
//   }

//   // formet caller data
//   Map<String, String> parseAndFormatCallerInfo(String rawData) {
//     final numberMatch = RegExp(r'NMBR\s*=\s*(\d+)').firstMatch(rawData);
//     final nameMatch = RegExp(r'NAME\s*=\s*(.+)').firstMatch(rawData);
//     // Extract individual components
//     final number = numberMatch?.group(1) ?? 'Unknown Number';
//     final name = nameMatch?.group(1) ?? 'Unknown Name';
//     // Return a formatted map
//     final now = DateTime.now().toTimeZone();
//     return {
//       'Date': DateFormat('MMM dd').format(now),
//       'Time': DateFormat('hh:mm a').format(now),
//       'Number': number,
//       'Name': name,
//     };
//   }

//   // Handle incoming call and show Caller ID info
//   Future<void> onIncomingCall(Map<String, String> callerInfo) async {
//     kLogger.i("Incoming call detected.");
//     ThemeData theme = Theme.of(Get.context!);
//     // Show dialog with caller info
//     PopupDialog.customDialog(
//         width: 500,
//         child: Column(
//           children: [
//             Text(
//               "Incoming Call",
//               style: theme.textTheme.displaySmall,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 10),
//             Text("Name: ${callerInfo['Name'] ?? ""}"),
//             Text("Number: ${callerInfo['Number'] ?? ""}"),
//             Text("Date: ${callerInfo['Date'] ?? ""}"),
//             Text("Time: ${callerInfo['Time'] ?? ""}"),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 PrimaryBtn(
//                   onPressed: () async {
//                     PosController.to.guestNameController.text =
//                         callerInfo['Name'] ?? "";
//                     PosController.to.guestPhoneController.text =
//                         callerInfo['Number'] ?? "";
//                     bool dineIn = BaseController
//                             .to.restaurantDetails?.restaurant.dineIn ??
//                         false;
//                     bool takeOut = BaseController
//                             .to.restaurantDetails?.restaurant.takeout ??
//                         false;

//                     if (dineIn && takeOut) {
//                       PosController.to.onChangeOrderType("TAKEOUT");
//                     }

//                     Get.back(); // Close the dialog
//                   },
//                   width: 120,
//                   height: 60,
//                   text: "Accept",
//                   textMaxSize: 35,
//                   textMinSize: 30,
//                   textColor: Colors.white,
//                   color: StaticColors.greenColor,
//                 ),
//                 const SizedBox(width: 24),
//                 PrimaryBtn(
//                     width: 120,
//                     height: 60,
//                     textMaxSize: 35,
//                     textMinSize: 30,
//                     textColor: Colors.white,
//                     color: StaticColors.redColor,
//                     onPressed: () async {
//                       await endCall();
//                       Get.back(); // Close the dialog
//                     },
//                     text: "Reject"),
//               ],
//             )
//           ],
//         ));
//   }

//   // Answer the call
//   Future<void> answerCall() async {
//     kLogger.i("Answering the call...");
//     await sendATCommand("ATA");
//   }

//   // End the call
//   Future<void> endCall() async {
//     kLogger.i("Ending the call...");
//     await sendATCommand("ATH");
//   }

//   // Send AT command to the modem
//   Future<void> sendATCommand(String command) async {
//     if (port != null && port!.isOpen) {
//       port!.write(Uint8List.fromList(utf8.encode("$command\r")));
//       kLogger.i("Sent command: $command");
//     } else {
//       PopupDialog.showErrorMessage(
//           "Serial port is not open.**Send AT Command**");
//     }
//   }

//   // Clean up the serial port connection
//   Future<void> dispose() async {
//     try {
//       port?.close();
//       PopupDialog.showErrorMessage("L2 Serial port closed.");
//     } catch (e) {
//       PopupDialog.showErrorMessage("Error closing serial port: $e");
//     }
//   }
// }
