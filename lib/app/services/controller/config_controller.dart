import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/models/printer_model.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/utils/urls.dart';

class ConfigController extends GetxController {
  static ConfigController get to => Get.find();

  bool isOnline = true;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;

  bool isLightTheme = Preferences.isLight;

  // ! ++++++++++ Get Printers++++++++++
  List<PrinterModel> printers = [];
  List<PrinterModel> rowPrinters = [];
  List<String> printerTypes = [];
  String selectedPrinterType = "";

  // Future<void> getPrinters() async {
  //       if (BaseController.to.restaurantDetails?.printerSelectionMode !=
  //       "MULTIPLE") {
  //     return;
  //   }
  //   try {
  //     final res = await BaseController.to.apiService.makeGetRequest(
  //       URLS.printers,
  //     );
  //     debugPrint('Printers API Response: ${res.data}');

  //     if (res.statusCode != 200) return;

  //     // Parse and sort by priority
  //     rowPrinters =
  //         (res.data["data"] as List)
  //             .map((e) => PrinterModel.fromJson(e))
  //             .toList()
  //           ..sort((a, b) => a.priority.compareTo(b.priority));

  //     // Save counter printer connection
  //     Preferences.counterPrinter =
  //         rowPrinters
  //             .where((p) => p.isCounterPrinter)
  //             .firstOrNull
  //             ?.printerConnection ??
  //         "";

  //     // kLogger.i('Counter printer connection: ${Preferences.counterPrinter}');
  //     // Initialize printer types and selection
  //     _initializePrinterTypes();

  //     kLogger.i('Loaded ${rowPrinters.length} printers');
  //   } catch (e, st) {
  //     kLogger.e('Error loading printers', error: e, stackTrace: st);
  //   }
  // }

  void _initializePrinterTypes() {
    // Build available printer types (POS first, then OLO)
    printerTypes.clear();

    final hasPOS = rowPrinters.any((p) => p.printerType == 'POS');
    final hasOLO = rowPrinters.any((p) => p.printerType == 'OLO');

    if (hasPOS) printerTypes.add('POS');
    if (hasOLO) printerTypes.add('OLO');

    // Auto-select first available type (POS if available, otherwise OLO)
    if (printerTypes.isNotEmpty) {
      if (selectedPrinterType.isEmpty) {
        onSelectedPrinterType(printerTypes.first);
      } else {
        onSelectedPrinterType(selectedPrinterType);
      }
    }
  }

  // Public method - can be called from other pages
  void onSelectedPrinterType(String value) {
    selectedPrinterType = value;
    _filterPrintersByType(value);
  }

  void _filterPrintersByType(String type) {
    printers = rowPrinters.where((p) => p.printerType == type).toList();
    update();
  }


  void toggleTheme() {
    isLightTheme = !isLightTheme;
    Preferences.isLight = isLightTheme;
    // kLogger.e(Preferences.isLight);
    Get.changeThemeMode(isLightTheme ? ThemeMode.light : ThemeMode.dark);
  }

  void showNoInternetDialog() {
    if (!Get.isDialogOpen!) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: ConfigController.to.isLightTheme
              ? Theme.of(Get.context!).canvasColor
              : StaticColors.cartColor,
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          title: Row(
            children: const [
              Icon(Icons.wifi_off, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                "No Internet",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: const Text(
            "Please check your internet connection and try again.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (isOnline && Get.isDialogOpen!) {
                  Get.back();
                }
              },
              child: const Text("OK"),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  @override
  void onInit() {
    isLightTheme = Preferences.isLight;
    connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      result,
    ) {
      // print(result.toString());
      if (result.contains(ConnectivityResult.none)) {
        isOnline = false;
        update();
        showNoInternetDialog();
      } else {
        if (!isOnline) {
          isOnline = true;
          update();
          if (Get.isDialogOpen!) {
            Get.back();
          }
        }
      }
    });

    super.onInit();
  }
}
// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:yogo_pos/app/services/base/preferences.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';

// class ConfigController extends GetxController {
//   static ConfigController get to => Get.find();

//   // ================================================================
//   // State Management
//   // ================================================================
//   final _isOnline = true.obs;
//   bool get isOnline => _isOnline.value;

//   final _isLightTheme = Preferences.isLight.obs;
//   bool get isLightTheme => _isLightTheme.value;

//   final Connectivity _connectivity = Connectivity();
//   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

//   // ================================================================
//   // Theme Toggle
//   // ================================================================
//   void toggleTheme() {
//     _isLightTheme.value = !_isLightTheme.value;
//     Preferences.isLight = _isLightTheme.value;
//     Get.changeThemeMode(_isLightTheme.value ? ThemeMode.light : ThemeMode.dark);
//   }

//   // ================================================================
//   // Internet Connection Dialog
//   // ================================================================
//   void _showNoInternetDialog() {
//     if (Get.isDialogOpen == true) return;

//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         backgroundColor: _getDialogBackground(),
//         titlePadding: const EdgeInsets.all(24),
//         contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.red.withAlpha(26), // 10%
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.wifi_off_rounded,
//                 color: Colors.red,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(width: 16),
//             const Expanded(
//               child: Text(
//                 "No Internet",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Please check your internet connection and try again.",
//               style: TextStyle(
//                 fontSize: 15,
//                 height: 1.5,
//                 color: _getTextColor().withAlpha(179), // 70%
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Connection status indicator
//             Obx(() => _buildConnectionStatus()),
//           ],
//         ),
//         actions: [
//           SizedBox(
//             width: double.infinity,
//             height: 48,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 0,
//               ),
//               onPressed: () {
//                 if (_isOnline.value) {
//                   Get.back();
//                 }
//               },
//               child: const Text(
//                 "Retry",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       barrierDismissible: false,
//     );
//   }

//   // ================================================================
//   // Connection Status Widget
//   // ================================================================
//   Widget _buildConnectionStatus() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: (_isOnline.value ? Colors.green : Colors.red).withAlpha(26),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: (_isOnline.value ? Colors.green : Colors.red).withAlpha(51),
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             _isOnline.value ? Icons.wifi_rounded : Icons.wifi_off_rounded,
//             size: 16,
//             color: _isOnline.value ? Colors.green : Colors.red,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             _isOnline.value ? "Connected" : "Disconnected",
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: _isOnline.value ? Colors.green : Colors.red,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ================================================================
//   // Helper Methods
//   // ================================================================
//   Color _getDialogBackground() {
//     if (_isLightTheme.value) {
//       return Get.theme.colorScheme.surface;
//     }
//     return StaticColors.cartColor;
//   }

//   Color _getTextColor() {
//     return Get.theme.colorScheme.onSurface;
//   }

//   // ================================================================
//   // Connectivity Listener
//   // ================================================================
//   void _initConnectivityListener() {
//     _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
//       (List<ConnectivityResult> results) {
//         final hasNoConnection = results.contains(ConnectivityResult.none);

//         if (hasNoConnection && _isOnline.value) {
//           // Lost connection
//           _isOnline.value = false;
//           _showNoInternetDialog();
//         } else if (!hasNoConnection && !_isOnline.value) {
//           // Regained connection
//           _isOnline.value = true;
//           if (Get.isDialogOpen == true) {
//             Get.back();
//             _showReconnectedSnackbar();
//           }
//         }
//       },
//       onError: (error) {
//         debugPrint('❌ Connectivity error: $error');
//       },
//     );
//   }

//   // ================================================================
//   // Reconnected Snackbar
//   // ================================================================
//   void _showReconnectedSnackbar() {
//     Get.showSnackbar(
//       GetSnackBar(
//         backgroundColor: Colors.green,
//         icon: const Icon(
//           Icons.wifi_rounded,
//           color: Colors.white,
//           size: 28,
//         ),
//         messageText: const Text(
//           'Internet connection restored',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         duration: const Duration(seconds: 2),
//         margin: const EdgeInsets.all(16),
//         borderRadius: 12,
//         snackPosition: SnackPosition.TOP,
//         animationDuration: const Duration(milliseconds: 300),
//       ),
//     );
//   }

//   // ================================================================
//   // Lifecycle Methods
//   // ================================================================
//   @override
//   void onInit() {
//     super.onInit();
//     _isLightTheme.value = Preferences.isLight;
//     _initConnectivityListener();
//   }

//   @override
//   void onClose() {
//     _connectivitySubscription?.cancel();
//     super.onClose();
//   }
// }
