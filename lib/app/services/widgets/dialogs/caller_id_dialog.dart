// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/widgets.dart';
// import 'package:yogo_pos/app/services/base/preferences.dart';
// import 'package:yogo_pos/app/utils/logger.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
// import 'package:flutter_libserialport/flutter_libserialport.dart';

// class CallerIdDialog extends StatefulWidget {
//   const CallerIdDialog({super.key});

//   @override
//   State<CallerIdDialog> createState() => _CallerIdDialogState();
// }

// class _CallerIdDialogState extends State<CallerIdDialog> {
//   String selectedPort = Preferences.callerPortL1;
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
//         PopupDialog.showSuccessDialog("Serial port opened successfully.");

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
//               PopupDialog.showSuccessDialog("Data received: $decodedData");
//               // Extract Caller ID information (implement your parser)
//               final callerInfo = parseCallerID(decodedData);

//               // Display or use the extracted Caller ID info
//               if (callerInfo != null) {
//                 PopupDialog.showSuccessDialog('Caller Info: $callerInfo');
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

// // Example: Parse Caller ID data (basic implementation, adjust for your device)
//   Map<String, String>? parseCallerID(String rawData) {
//     // Assuming the data contains caller info in a structured format
//     // Example format: "DATE:YYYY-MM-DD TIME:HH:MM NUMBER:1234567890 NAME:John Doe"
//     final match = RegExp(
//       r'DATE:(?<date>\d{4}-\d{2}-\d{2}) TIME:(?<time>\d{2}:\d{2}) NUMBER:(?<number>\d+) NAME:(?<name>.+)',
//     ).firstMatch(rawData);

//     if (match != null) {
//       return {
//         'date': match.namedGroup('date') ?? '',
//         'time': match.namedGroup('time') ?? '',
//         'number': match.namedGroup('number') ?? '',
//         'name': match.namedGroup('name') ?? '',
//       };
//     }
//     return null; // Return null if parsing fails
//   }

//   // Send AT command to the modem
//   Future<void> sendATCommand(String command) async {
//     if (port != null && port!.isOpen) {
//       port!.write(Uint8List.fromList(utf8.encode("$command\r")));
//       PopupDialog.showErrorMessage("Sent command: $command");
//     } else {
//       PopupDialog.showErrorMessage("Serial port is not open.");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     initSerialPort();
//   }

//   @override
//   void dispose() {
//     port?.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
