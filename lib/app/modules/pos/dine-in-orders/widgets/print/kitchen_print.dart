import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_kitchen_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_table_change_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/services/models/printer_model.dart';
import 'package:yogo_pos/app/utils/extension/order_extention.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

Future<void> kitchenPrint(
  OrderModel order, {
  bool isCheckCanceled = false,
  bool isShowItems = true,
  String? title,
  bool isItemsCanceled = false,
  bool multiPrintAllow = true,
  bool showSuccessMSG = false,
  bool isTableChange = false,
  int? receipt, // New parameter to override printer receipts
}) async {
  await kitchenPrint2(
      order,
      isCheckCanceled: isCheckCanceled,
      isShowItems: isShowItems,
      title: title,
      isItemsCanceled: isItemsCanceled,
      multiPrintAllow: multiPrintAllow,
      showSuccessMSG: showSuccessMSG,
      isTableChange: isTableChange,
      receipt: receipt,
    );
  // bool isMultiPrintAllow =
  //     BaseController.to.restaurantDetails?.printerSelectionMode == "MULTIPLE";
  // if (isMultiPrintAllow) {
  //   await kitchenPrint1(
  //     order,
  //     isCheckCanceled: isCheckCanceled,
  //     isShowItems: isShowItems,
  //     title: title,
  //     isItemsCanceled: isItemsCanceled,
  //     multiPrintAllow: multiPrintAllow,
  //     showSuccessMSG: showSuccessMSG,
  //     isTableChange: isTableChange,
  //     receipt: receipt,
  //   );
  // } else {
  //   await kitchenPrint2(
  //     order,
  //     isCheckCanceled: isCheckCanceled,
  //     isShowItems: isShowItems,
  //     title: title,
  //     isItemsCanceled: isItemsCanceled,
  //     multiPrintAllow: multiPrintAllow,
  //     showSuccessMSG: showSuccessMSG,
  //     isTableChange: isTableChange,
  //     receipt: receipt,
  //   );
  // }
}

// Future<void> kitchenPrint1(
//   OrderModel order, {
//   bool isCheckCanceled = false,
//   bool isShowItems = true,
//   String? title,
//   bool isItemsCanceled = false,
//   bool multiPrintAllow = true,
//   bool showSuccessMSG = false,
//   bool isTableChange = false,
//   int? receipt,
// }) async {
//   try {
//     final bool posCombinePrint =
//         BaseController.to.restaurantDetails?.restaurant.posCombinePrint ??
//         false;

//     debugPrint("posCombinePrint: $posCombinePrint");
//     debugPrint(
//       "Order Type: ${order.orderType}, TakeOut Type: ${order.takeOutType}",
//     );
//     if (receipt != null) {
//       debugPrint("Receipt override: $receipt copies");
//     }

//     final List<PrinterModel> allPrinters = ConfigController.to.rowPrinters;

//     if (allPrinters.isEmpty) {
//       kLogger.e('Kitchen Print Error: No printers configured in system');
//       PopupDialog.showErrorMessage("No printers configured.");
//       return;
//     }

//     debugPrint("Total printers found: ${allPrinters.length}");

//     final bool isOnlineOrder =
//         (order.orderType == "TAKEOUT" && order.takeOutType == "ONLINE") ||
//         order.orderType == "DELIVERY";

//     final String requiredPrinterType = isOnlineOrder ? "OLO" : "POS";
//     final List<PrinterModel> availablePrinters = allPrinters
//         .where((p) => p.printerType == requiredPrinterType)
//         .toList();

//     debugPrint("Required printer type: $requiredPrinterType");
//     debugPrint(
//       "Available $requiredPrinterType printers: ${availablePrinters.length}",
//     );

//     if (availablePrinters.isEmpty) {
//       kLogger.e(
//         'Kitchen Print Error: No $requiredPrinterType printers configured for order type ${order.orderType}',
//       );
//       PopupDialog.showErrorMessage(
//         "No $requiredPrinterType printers configured.",
//       );
//       return;
//     }

//     final defaultPrinter = availablePrinters.firstWhere(
//       (p) => p.isCounterPrinter,
//       orElse: () => availablePrinters.first,
//     );

//     debugPrint(
//       "Default printer selected: ${defaultPrinter.name} (${defaultPrinter.printerType})",
//     );

//     if (posCombinePrint) {
//       debugPrint("Using combined print mode");

//       final int receiptCount = receipt ?? defaultPrinter.receipts;

//       if (receiptCount == 0) {
//         kLogger.w(
//           'Kitchen Print Warning: Receipt count is 0 for ${defaultPrinter.name}',
//         );
//         return;
//       }

//       try {
//         debugPrint("Generating receipt widget for combined print...");

//         final Uint8List receiptWidget = isTableChange
//             ? escTableChangePrintReceipt(
//                 order: order,
//                 oldTableName: title ?? '',
//               )
//             : escKitchenPrintReceipt(
//                 order: order,
//                 isCheckCanceled: isCheckCanceled,
//                 isShowItems: isShowItems,
//                 title: title,
//                 isItemsCanceled: isItemsCanceled,
//               );

//         debugPrint("Receipt widget generated successfully");

//         List<Future> allJobs = [];

//         for (int i = 0; i < receiptCount; i++) {
//           debugPrint(
//             "Adding print job ${i + 1} of $receiptCount for ${defaultPrinter.name}",
//           );
//           allJobs.add(
//             PrintUtils().directPrint(
//               data: receiptWidget,
//               printer: defaultPrinter.printerConnection,
//             ),
//           );
//         }

//         debugPrint(
//           "Sending ${allJobs.length} print jobs to ${defaultPrinter.name}...",
//         );
//         final results = await Future.wait(allJobs);
//         if (results.every((success) => success)) {
//           debugPrint("All print jobs completed successfully");
//           PopupDialog.showSuccessDialog("Print Sent");
//         } else {
//           final failed = results.where((s) => !s).length;
//           debugPrint("$failed of ${results.length} print jobs failed");
//           PopupDialog.showErrorMessage("$failed print job(s) failed");
//         }
//       } catch (e, stackTrace) {
//         kLogger.e('Error in combined print mode: $e\nStackTrace: $stackTrace');
//         PopupDialog.showErrorMessage("Combined Print Error: $e");
//         rethrow;
//       }
//       return;
//     }

//     if (order.carts.isEmpty) {
//       kLogger.w('Kitchen Print Warning: Order has no cart items');
//       return;
//     }

//     debugPrint(
//       "Using multi-printer mode with ${order.carts.length} cart items",
//     );

//     try {
//       Map<PrinterModel, List<CartModel>> printerGroups = {};

//       for (var cart in order.carts) {
//         debugPrint(
//           "Processing cart item: ${cart.name} (Printers: ${cart.printers.length})",
//         );

//         if (cart.printers.isEmpty) {
//           debugPrint("  -> Skipping item (no printer assigned)");
//           continue;
//         }

//         // FIX: per cart item এ unique printer set বানাও
//         // OLO order এ POS printer IDs match না করলে সবগুলো defaultPrinter এ
//         // fallback হয়, Set দিয়ে duplicate add আটকানো হচ্ছে
//         final Set<String> targetPrinterIds = {};
//         final Map<String, PrinterModel> resolvedPrinters = {};

//         for (var printerId in cart.printers) {
//           final printer = availablePrinters.firstWhereOrNull(
//             (p) => p.id == printerId,
//           );

//           if (printer != null) {
//             targetPrinterIds.add(printer.id);
//             resolvedPrinters[printer.id] = printer;
//           } else {
//             // Not found — fallback to default (Set ensures only added once)
//             kLogger.w(
//               'Printer ID $printerId not found in $requiredPrinterType printers, using default',
//             );
//             targetPrinterIds.add(defaultPrinter.id);
//             resolvedPrinters[defaultPrinter.id] = defaultPrinter;
//           }
//         }

//         for (var printerId in targetPrinterIds) {
//           final printer = resolvedPrinters[printerId]!;
//           debugPrint("  -> Assigned to printer: ${printer.name}");
//           printerGroups.putIfAbsent(printer, () => []).add(cart);
//         }
//       }

//       if (printerGroups.isEmpty) {
//         kLogger.w('Kitchen Print Warning: No printer groups created');
//         return;
//       }

//       debugPrint("Created ${printerGroups.length} printer groups:");
//       for (var entry in printerGroups.entries) {
//         debugPrint("  ${entry.key.name}: ${entry.value.length} items");
//       }

//       List<Future> allJobs = [];

//       for (var entry in printerGroups.entries) {
//         final printer = entry.key;
//         final cartItems = entry.value;

//         debugPrint(
//           "Processing printer group: ${printer.name} (${cartItems.length} items)",
//         );

//         final int receiptCount = receipt ?? printer.receipts;

//         if (receiptCount == 0) {
//           kLogger.w('Skipping printer ${printer.name} - receipt count is 0');
//           continue;
//         }

//         try {
//           final printerOrder = order.copyWith(carts: cartItems);

//           debugPrint("Generating receipt widget for ${printer.name}...");

//           final Uint8List receiptWidget = isTableChange
//               ? escTableChangePrintReceipt(
//                   order: printerOrder,
//                   oldTableName: title ?? '',
//                 )
//               : escKitchenPrintReceipt(
//                   order: printerOrder,
//                   isCheckCanceled: isCheckCanceled,
//                   isShowItems: isShowItems,
//                   title: title,
//                   isItemsCanceled: isItemsCanceled,
//                 );

//           debugPrint("Receipt widget generated for ${printer.name}");

//           for (int i = 0; i < receiptCount; i++) {
//             debugPrint(
//               "Adding print job ${i + 1} of $receiptCount for ${printer.name}",
//             );
//             allJobs.add(
//               PrintUtils().directPrint(
//                 data: receiptWidget,
//                 printer: printer.printerConnection,
//               ),
//             );
//           }
//         } catch (e, stackTrace) {
//           kLogger.e(
//             'Error generating receipt for printer ${printer.name}: $e\nStackTrace: $stackTrace',
//           );
//           PopupDialog.showErrorMessage("Error for printer ${printer.name}: $e");
//         }
//       }

//       if (allJobs.isEmpty) {
//         kLogger.w('Kitchen Print Warning: No print jobs created');
//         PopupDialog.showErrorMessage(
//           "No print jobs created. Check printer configurations.",
//         );
//         return;
//       }

//       debugPrint(
//         "Sending ${allJobs.length} print jobs to ${printerGroups.length} printers...",
//       );
//       final results = await Future.wait(allJobs);
//       if (results.every((success) => success)) {
//         debugPrint("All print jobs completed successfully");
//         PopupDialog.showSuccessDialog("Print Sent");
//       } else {
//         final failed = results.where((s) => !s).length;
//         debugPrint("$failed of ${results.length} print jobs failed");
//         PopupDialog.showErrorMessage("$failed print job(s) failed");
//       }
//       debugPrint("All print jobs completed successfully");
//     } catch (e, stackTrace) {
//       kLogger.e('Error in multi-printer logic: $e\nStackTrace: $stackTrace');
//       PopupDialog.showErrorMessage("Multi-Printer Error: $e");
//       rethrow;
//     }
//   } catch (e, stackTrace) {
//     kLogger.e('Critical error in kitchenPrint: $e\nStackTrace: $stackTrace');
//     PopupDialog.showErrorMessage("Print Failed: $e");
//   }
// }

Future<void> kitchenPrint2(
  OrderModel order, {
  bool isCheckCanceled = false,
  bool isShowItems = true,
  String? title,
  bool isItemsCanceled = false,
  bool multiPrintAllow = true,
  bool showSuccessMSG = false,
  bool isTableChange = false,
  int? receipt,
}) async {
  final int numberOfReceipt =
      receipt ??
      (BaseController.to.restaurantDetails?.restaurant.numberOfReceipt ?? 1);
  final bool posCombinePrint =
      BaseController.to.restaurantDetails?.restaurant.posCombinePrint ?? false;

  debugPrint("posCombinePrint: $posCombinePrint");
  if (numberOfReceipt == 0) return;
  if ((order.orderType == "TAKEOUT" && order.takeOutType == "ONLINE") ||
      order.orderType == "DELIVERY" ||
      posCombinePrint) {
    final kitchenPrinter = Preferences.kitchenPrinter;

    for (int i = 0; i < numberOfReceipt; i++) {
      await PrintUtils().directPrint(
        data: escKitchenPrintReceipt(
          order: order,
          isCheckCanceled: isCheckCanceled,
          isShowItems: isShowItems,
          title: title,
          isItemsCanceled: isItemsCanceled,
        ),
        printer: kitchenPrinter,
      );
    }

    return;
  }

  final barPrinter = Preferences.counterPrinter;
  final kitchenPrinter = Preferences.kitchenPrinter;

  final barOrder = order.toBar();
  final kitchenOrder = order.toKitchen();

  // Skip if nothing to print
  if (barOrder.carts.isEmpty && kitchenOrder.carts.isEmpty) {
    debugPrint("No print jobs to run");
    return;
  }

  try {
    // Prepare widgets outside loop to reuse
    final Uint8List? barWidget = barOrder.carts.isNotEmpty
        ? isTableChange
              ? escTableChangePrintReceipt(
                  order: barOrder,
                  oldTableName: title ?? '',
                )
              : escKitchenPrintReceipt(
                  order: barOrder,
                  isCheckCanceled: isCheckCanceled,
                  isShowItems: isShowItems,
                  title: title,
                  isItemsCanceled: isItemsCanceled,
                )
        : null;

    final Uint8List? kitchenWidget = kitchenOrder.carts.isNotEmpty
        ? isTableChange
              ? escTableChangePrintReceipt(
                  order: kitchenOrder,
                  oldTableName: title ?? '',
                )
              : escKitchenPrintReceipt(
                  order: kitchenOrder,
                  isCheckCanceled: isCheckCanceled,
                  isShowItems: isShowItems,
                  title: title,
                  isItemsCanceled: isItemsCanceled,
                )
        : null;

    // Run all print jobs concurrently per receipt count
    List<Future> allJobs = [];

    for (int i = 0; i < numberOfReceipt; i++) {
      if (barWidget != null) {
        allJobs.add(
          PrintUtils().directPrint(data: barWidget, printer: barPrinter),
        );
      }
      if (kitchenWidget != null) {
        allJobs.add(
          PrintUtils().directPrint(
            data: kitchenWidget,
            printer: kitchenPrinter,
          ),
        );
      }
    }
    if (allJobs.isEmpty) {
      debugPrint("No print jobs to run");
      return;
    }

    final results = await Future.wait(allJobs);
    if (results.every((success) => success)) {
      debugPrint("All print jobs completed successfully");
      PopupDialog.showSuccessDialog("Print Sent");
    } else {
      final failed = results.where((s) => !s).length;
      debugPrint("$failed of ${results.length} print jobs failed");
      PopupDialog.showErrorMessage("$failed print job(s) failed");
    }
  } catch (e) {
    kLogger.e('Error printing receipt: $e');
    PopupDialog.showErrorMessage("Error printing receipt: $e");
  }
}
