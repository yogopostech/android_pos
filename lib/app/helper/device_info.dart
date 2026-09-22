// import 'dart:io';

// import 'package:yogo_pos/app/utils/logger.dart';


// class DeviceInfo {
// static  Future<String?> getWindowsUUID() async {
//     try {
//       // Option 1: Try to get Machine GUID (most reliable for Windows)
//       String? machineGuid = await DeviceInfo.getWindowsMachineGuid();
//       if (machineGuid != null && machineGuid.isNotEmpty) {
//         return machineGuid;
//       }

//       // Option 2: Fallback to motherboard serial number
//       String? motherboardSerial = await DeviceInfo.getMotherboardSerial();
//       if (motherboardSerial != null && motherboardSerial.isNotEmpty) {
//         return motherboardSerial;
//       }

//       // Option 3: Fallback to Windows Product ID
//       String? productId = await DeviceInfo();
//       return productId;
//     } catch (e) {
//       kLogger.e("Error getting unique device ID: $e");
//       return null;
//     }
//   }
// }
