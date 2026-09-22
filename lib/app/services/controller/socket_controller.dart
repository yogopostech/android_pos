// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:toastification/toastification.dart';
// import 'package:yogo_pos/app/helper/app_helper.dart';
// import 'package:yogo_pos/app/helper/data_update_helper.dart';
// import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
// import 'package:yogo_pos/app/modules/pos/delivery/controllers/delivery_controller.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_order_print_receipt.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_table_reservation_print_receipt.dart';
// import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/kitchen_print.dart';
// import 'package:yogo_pos/app/modules/pos/onlineOrder/controllers/online_order_controller.dart';
// import 'package:yogo_pos/app/modules/pos/tableReservations/models/table_reservations_model.dart';
// import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';
// import 'package:yogo_pos/app/modules/setting/repo/incoming_call_dialog.dart';
// import 'package:yogo_pos/app/services/base/preferences.dart';
// import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/utils/logger.dart';
// import 'package:yogo_pos/app/utils/print_utils.dart';
// import 'package:yogo_pos/app/utils/urls.dart';
// import 'package:yogo_pos/app/widgets/moneris_dialog.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
// import 'package:yogo_pos/app/widgets/search_check_dialog.dart';

// import '../../modules/pos/order/models/order_model.dart';

// enum SocketEvent {
//   tableBooking('tableBooking'),
//   onlineOrderPlaced('onlineOrderPlaced'),
//   deliveryOrderPlaced('deliveryOrderPlaced'),
//   deviceDisconnect('deviceDisconnect'),
//   monerisPayment('monerisPayment'),
//   callBroadcast('callBroadcast');

//   final String value;
//   const SocketEvent(this.value);
// }

// class SocketController extends GetxController {
//   IO.Socket? _socket;

//   void connect() {
//     HttpOverrides.global = MyHttpOverrides();
//     _socket = IO.io(URLS.socketServer, <String, dynamic>{
//       "transports": ["websocket"],
//       "autoConnect": false,
//     });

//     _socket!.connect();

//     _socket!.onConnect((_) {
//       BaseController.to.onChangeSocketConnection(true);
//       _socket?.emit("register", {
//         "userId": BaseController.to.restaurantDetails?.id ?? "",
//         "stationId": Preferences.stationId,
//       });
//       if (kDebugMode) {
//         kLogger.i("✅ Connected to Socket.IO Server:${_socket?.id}");
//         kLogger.i("Restaurant: ${BaseController.to.restaurantDetails?.id}");
//         kLogger.i("Station: ${Preferences.stationId}");
//       }
//     });
//     // tableBooking Event
//     _socket!.on("tableBooking", (data) async {
//       if (kDebugMode) {
//         kLogger.i("tableBooking Placed: $data");
//       }

//       dynamic tableBookingData;
//       Function? callback;

//       // Extract data and callback
//       if (data is List && data.isNotEmpty) {
//         tableBookingData = data[0];
//         if (data.length > 1 && data[1] is Function) {
//           callback = data[1] as Function;
//         }
//       } else {
//         tableBookingData = data;
//       }

//       try {
//         // Parse order
//         Reservations reservationData = Reservations.fromJson(tableBookingData);

//         // Notification Sound
//         if (Preferences.isNotificationSound) {
//           BaseController.to.playNotificationSound();
//         }

//         // Show notification
//         toastification.show(
//           title: const Text("Table Reservation Received", maxLines: 1),
//           description: Text(
//             "Reservation Id #${reservationData.tableBookId}",
//             maxLines: 4,
//           ),
//           type: ToastificationType.info,
//           autoCloseDuration: const Duration(seconds: 5),
//         );

//         // Todo : add toggle btn
//         // if (Preferences.isOloPrint) {

//         // }
//         await _reservationDataPrint(reservationData);
//         // Send SUCCESS callback to backend
//         callback?.call({"status": "SUCCESS"});

//         if (kDebugMode) {
//           kLogger.i(
//             "✅ Table Reservation Sent SUCCESS acknowledgment#${reservationData.tableBookId}",
//           );
//         }
//       } catch (e) {
//         PopupDialog.showErrorMessage(
//           "Table Reservation data format is not correct",
//         );
//         if (kDebugMode) {
//           kLogger.e('Error from %%%% Table Reservation data format %%%%=> $e');
//         }

//         // Send ERROR callback to backend
//         callback?.call({"status": "ERROR", "message": e.toString()});

//         if (kDebugMode) {
//           kLogger.e("❌ Sent ERROR acknowledgment for online order");
//         }
//       }
//     });

//     // Online Order Event
//     _socket!.on("onlineOrderPlaced", (data) {
//       if (kDebugMode) {
//         kLogger.i("Online Order Placed: $data");
//       }

//       dynamic orderData;
//       Function? callback;

//       // Extract data and callback
//       if (data is List && data.isNotEmpty) {
//         orderData = data[0];
//         if (data.length > 1 && data[1] is Function) {
//           callback = data[1] as Function;
//         }
//       } else {
//         orderData = data;
//       }

//       try {
//         // Parse order
//         OrderModel order = OrderModel.fromJson(orderData);

//         // Notification Sound
//         if (Preferences.isNotificationSound) {
//           BaseController.to.playNotificationSound();
//         }

//         // Show notification
//         toastification.show(
//           title: const Text("Online Order Received", maxLines: 1),
//           description: Text(
//             "Order #${order.orderId} - Amount: \$${order.totalOrderAmount.toStringAsFixed(2)}",
//             maxLines: 4,
//           ),
//           type: ToastificationType.info,
//           autoCloseDuration: const Duration(seconds: 5),
//         );

//         // Print the order
//         if (Preferences.isOloPrint) {
//           kitchenPrint(order);
//         }
//         if (Preferences.oloCustomerReceipt) {
//           var printData = escOrderPrintReceipt(order: order);
//           PrintUtils().directPrint(
//             data: printData,
//             printer: Preferences.counterPrinter,
//           );
//         }

//         // Get orders
//         if (Get.currentRoute != '/auth') {
//           OnlineOrderController.to.getOrders();
//         }

//         // Send SUCCESS callback to backend
//         callback?.call({"status": "SUCCESS"});

//         if (kDebugMode) {
//           kLogger.i(
//             "✅ Sent SUCCESS acknowledgment for online order #${order.orderId}",
//           );
//         }
//       } catch (e) {
//         PopupDialog.showErrorMessage("OLO data format is not correct");
//         if (kDebugMode) {
//           kLogger.e('Error from %%%% online order data format %%%% => $e');
//         }

//         // Send ERROR callback to backend
//         callback?.call({"status": "ERROR", "message": e.toString()});

//         if (kDebugMode) {
//           kLogger.e("❌ Sent ERROR acknowledgment for online order");
//         }
//       }
//     });

//     // Delivery Order Event
//     _socket!.on("deliveryOrderPlaced", (data) {
//       if (kDebugMode) {
//         kLogger.i("Delivery Order Placed: $data");
//       }

//       dynamic orderData;
//       Function? callback;

//       // Extract data and callback
//       if (data is List && data.isNotEmpty) {
//         orderData = data[0];
//         if (data.length > 1 && data[1] is Function) {
//           callback = data[1] as Function;
//         }
//       } else {
//         orderData = data;
//       }

//       try {
//         // Parse order
//         OrderModel order = OrderModel.fromJson(orderData);

//         // Notification Sound
//         if (Preferences.isNotificationSound) {
//           BaseController.to.playNotificationSound();
//         }

//         // Show notification
//         toastification.show(
//           title: const Text("Delivery Order Received", maxLines: 1),
//           description: Text(
//             "Order #${order.orderId} - Amount: \$${order.totalOrderAmount.toStringAsFixed(2)}",
//             maxLines: 4,
//           ),
//           type: ToastificationType.info,
//           autoCloseDuration: const Duration(seconds: 5),
//         );

//         // kitchen Print
//         if (Preferences.isDeliveryOrderPrint) {
//           kitchenPrint(order);
//         }
//         // Customer Receipt

//         if (Preferences.deliveryCustomerReceipt) {
//           var printData = escOrderPrintReceipt(order: order);
//           PrintUtils().directPrint(
//             data: printData,
//             printer: Preferences.counterPrinter,
//           );
//         }

//         // Get orders
//         if (Get.currentRoute != '/auth') {
//           DeliveryController.to.getOrders();
//         }

//         // Send SUCCESS callback to backend
//         callback?.call({"status": "SUCCESS"});

//         if (kDebugMode) {
//           kLogger.i(
//             "✅ Sent SUCCESS acknowledgment for delivery order #${order.orderId}",
//           );
//         }
//       } catch (e) {
//         PopupDialog.showErrorMessage("Delivery data format is not correct");
//         if (kDebugMode) {
//           kLogger.e('Error from %%%% Delivery order data format %%%% => $e');
//         }

//         // Send ERROR callback to backend
//         callback?.call({"status": "ERROR", "message": e.toString()});

//         if (kDebugMode) {
//           kLogger.e("❌ Sent ERROR acknowledgment for delivery order");
//         }
//       }
//     });

//     // Device Disconnect Event
//     _socket!.on("deviceDisconnect", (data) {
//       Function? callback;

//       // Extract data and callback
//       if (data is List && data.isNotEmpty) {
//         if (data.length > 1 && data[1] is Function) {
//           callback = data[1] as Function;
//         }
//       }

//       if (kDebugMode) {
//         kLogger.w("⚠️ Device disconnect event received");
//       }

//       // Send SUCCESS callback before exiting
//       callback?.call({"status": "SUCCESS"});

//       AppHelper.exitApp();
//     });

//     // Moneris Payment Event
//     _socket!.on("monerisPayment", (data) {
//       dynamic paymentData;
//       Function? callback;

//       // Extract data and callback
//       if (data is List && data.isNotEmpty) {
//         paymentData = data[0];
//         if (data.length > 1 && data[1] is Function) {
//           callback = data[1] as Function;
//         }
//       } else {
//         paymentData = data;
//       }

//       try {
//         String status = paymentData['status'] ?? 'unknown';
//         String message = paymentData['message'] ?? 'unknown';
//         OrderModel? order = paymentData['order'] != null
//             ? OrderModel.fromJson(paymentData['order'])
//             : null;
//         debugPrint('Moneris payment status: $status');
//         if (order != null) {
//           debugPrint(
//             "Moneris Payment - Order status : ${order.orderStatus}, Amount: ${order.totalOrderAmount}",
//           );
//         } else {
//           debugPrint("Moneris Payment - No order data received.");
//         }
//         if (status == 'processing') {
//           debugPrint('Moneris payment is processing...');

//           // PopupDialog.showLoadingDialog();
//         } else if (status == 'success') {
//           PosController.to.clearCartList();
//           Get.back();
//           monerisDialog(
//             status: PurchaseDialogStatus.success,
//             message: message,
//             order: order,
//           );
//         } else if (status == 'failed') {
//           PosController.to.myOrder.payment = null;
//           Get.back();
//           monerisDialog(status: PurchaseDialogStatus.error, message: message);
//         } else if (status == 'error') {
//           PosController.to.myOrder.payment = null;
//           Get.back();
//           monerisDialog(status: PurchaseDialogStatus.error, message: message);
//         } else {
//           PosController.to.myOrder.payment = null;
//           Get.back();
//           monerisDialog(status: PurchaseDialogStatus.error, message: message);
//         }

//         if (Get.currentRoute != '/auth') {
//           DataUpdateHelper.getDataByCheckType(type: order?.orderType);
//         }

//         debugPrint("Moneris Payment Update: $paymentData");

//         // Send SUCCESS callback to backend
//         callback?.call({"status": "SUCCESS"});

//         if (kDebugMode) {
//           kLogger.i("✅ Sent SUCCESS acknowledgment for Moneris payment");
//         }
//       } catch (e) {
//         if (kDebugMode) {
//           kLogger.e('Error processing Moneris payment: $e');
//         }

//         // Send ERROR callback to backend
//         callback?.call({"status": "ERROR", "message": e.toString()});

//         if (kDebugMode) {
//           kLogger.e("❌ Sent ERROR acknowledgment for Moneris payment");
//         }
//       }
//     });

//     // callBroadcast Event
//     _socket!.on("callBroadcast", (data) {
//       if (kDebugMode) {
//         kLogger.e("Caller id data: $data");
//       }

//       final callerData = CallerIdData.fromJson(data);
//       if (Get.currentRoute == "/auth" || Get.currentRoute == "/login") {
//         // showDialog(
//         //   context: Get.context!,
//         //   barrierDismissible: true,
//         //   builder: (_) => CallerInfoDialog(callerData: callerData),
//         // );
//       } else {
//         if (Get.isRegistered<PosController>()) {
          
         
//         } else {
//           debugPrint(
//             '[CallerID] PosController not ready — skipping guest assign',
//           );
//         }
//       }
//     });
    
    
//     _socket!.onDisconnect((_) {
//       BaseController.to.onChangeSocketConnection(false);
//       kLogger.e("❌ Disconnected from Server");
//     });

//     _socket!.onError((err) {
//       BaseController.to.onChangeSocketConnection(false);
//       kLogger.e("Error: $err");
//     });
//   }

//   void disconnect() {
//     try {
//       _socket?.disconnect();
//       _socket?.close();
//       BaseController.to.onChangeSocketConnection(false);
//       kLogger.i("🛑 Disconnected from Socket.IO Server");
//     } catch (e, stack) {
//       BaseController.to.onChangeSocketConnection(false);
//       kLogger.e("❌ Error during socket disconnect: $e\n$stack");
//     }
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     connect();
//   }

//   @override
//   void onClose() {
//     disconnect();
//     super.onClose();
//   }
// }

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     final client = super.createHttpClient(context);
//     client.badCertificateCallback =
//         (X509Certificate cert, String host, int port) => true;
//     return client;
//   }
// }

// Future _reservationDataPrint(Reservations reservationData) async {
//   // todo:print
//   var printData = escTableReservationReceipt(data: reservationData);
//   PrintUtils().directPrint(
//     data: printData,
//     printer: Preferences.kitchenPrinter,
//   );
// }
