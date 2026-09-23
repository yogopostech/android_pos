import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:toastification/toastification.dart';
import 'package:yogo_pos/app/helper/app_helper.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/clockIn/providers/clock_in_out.dart';
import 'package:yogo_pos/app/modules/clockIn/widgets/clock_in_dialog.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/delivery/controllers/delivery_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_order_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_table_reservation_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/kitchen_print.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/models/employee_model.dart';
import 'package:yogo_pos/app/modules/pos/onlineOrder/controllers/online_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/tableReservations/models/table_reservations_model.dart';
import 'package:yogo_pos/app/modules/setting/providers/caller_id_notifier.dart';
import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';
import 'package:yogo_pos/app/modules/setting/repo/incoming_call_dialog.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/elavon-cws/providers/cws_credentials_provider.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/moneris_dialog.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:yogo_pos/app/widgets/search_check_dialog.dart';
import '../../modules/pos/order/models/order_model.dart';

part 'socket_provider.g.dart';

// ─────────────────────────────────────────────────
// Enum
// ─────────────────────────────────────────────────

enum SocketEvent {
  tableBooking('tableBooking'),
  onlineOrderPlaced('onlineOrderPlaced'),
  deliveryOrderPlaced('deliveryOrderPlaced'),
  deviceDisconnect('deviceDisconnect'),
  monerisPayment('monerisPayment'),
  callBroadcast('callBroadcast'),
  updateOrder('updateOrder'),
  elavonCWS('convergeConfigChanged'),
  updatePosElavonCws('updatePosElavonCws'),
  employeeAutoClockOut('employeeAutoClockOut');

  final String value;
  const SocketEvent(this.value);
}

// ─────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class SocketController extends _$SocketController {
  IO.Socket? _socket;

  @override
  void build() {
    // ✅ auto-connect
    // manually ref.read(socketControllerProvider.notifier).connect() call
    ref.onDispose(disconnect);
  }

  void connect() {
    // ✅ already connected থাকলে আর connect করবে না
    if (_socket != null && _socket!.connected) {
      kLogger.w("⚠️ Socket already connected — skipping");
      return;
    }

    HttpOverrides.global = MyHttpOverrides();
    _socket = IO.io(URLS.socketServer, <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });

    _socket!.connect();

    _socket!.onConnect(_onConnected);
    _socket!.onDisconnect((_) => _onDisconnected());
    _socket!.onError((err) => _onError(err));

    // _socket!.on(SocketEvent.tableBooking.value, _onTableBooking);
    // _socket!.on(SocketEvent.onlineOrderPlaced.value, _onOnlineOrder);
    // _socket!.on(SocketEvent.deliveryOrderPlaced.value, _onDeliveryOrder);
    _socket!.on(SocketEvent.deviceDisconnect.value, _onDeviceDisconnect);
    _socket!.on(SocketEvent.monerisPayment.value, _onMonerisPayment);
    _socket!.on(SocketEvent.updateOrder.value, _onUpdateOrder);
    _socket!.on(SocketEvent.elavonCWS.value, _onElavonCWS);
    _socket!.on(SocketEvent.updatePosElavonCws.value, _onUpdatePosElavonCws);
    _socket!.on(
      SocketEvent.employeeAutoClockOut.value,
      _onEmployeeAutoClockOut,
    );
    // _socket!.on("register_error", (e) {
    //   print("ZXZ $e");
    // });
  }

  void disconnect() {
    try {
      _socket?.disconnect();
      _socket?.close();
      BaseController.to.onChangeSocketConnection(false);
      kLogger.i("🛑 Disconnected from Socket.IO Server");
    } catch (e, stack) {
      BaseController.to.onChangeSocketConnection(false);
      kLogger.e("❌ Error during socket disconnect: $e\n$stack");
    }
  }

  // ─────────────────────────────────────────────────
  // Socket Lifecycle Handlers
  // ─────────────────────────────────────────────────

  void _onConnected(_) {
    BaseController.to.onChangeSocketConnection(true);
    _socket?.emit("register", {
      "userId": BaseController.to.restaurantDetails?.id ?? "",
      "stationId": Preferences.stationId,
    });
    if (kDebugMode) {
      kLogger.i("✅ Connected to Socket.IO Server: ${_socket?.id}");
      kLogger.i("Restaurant: ${BaseController.to.restaurantDetails?.id}");
      kLogger.i("Station: ${Preferences.stationId}");
    }
  }

  void _onDisconnected() {
    BaseController.to.onChangeSocketConnection(false);
    kLogger.e("❌ Disconnected from Server");
  }

  void _onError(dynamic err) {
    BaseController.to.onChangeSocketConnection(false);
    kLogger.e("Error: $err");
  }

  // ─────────────────────────────────────────────────
  // Event Handlers
  // ─────────────────────────────────────────────────

  Future<void> _onTableBooking(dynamic data) async {
    if (kDebugMode) kLogger.i("tableBooking Placed: $data");

    dynamic tableBookingData;
    Function? callback;

    if (data is List && data.isNotEmpty) {
      tableBookingData = data[0];
      if (data.length > 1 && data[1] is Function) {
        callback = data[1] as Function;
      }
    } else {
      tableBookingData = data;
    }
    callback?.call({"status": "SUCCESS"});

    try {
      final Reservations reservationData = Reservations.fromJson(
        tableBookingData,
      );

      if (Preferences.isNotificationSound) {
        BaseController.to.playNotificationSound();
      }

      toastification.show(
        title: const Text("Table Reservation Received", maxLines: 1),
        description: Text(
          "Reservation Id #${reservationData.tableBookId}",
          maxLines: 4,
        ),
        type: ToastificationType.info,
        autoCloseDuration: const Duration(seconds: 5),
      );

      await _reservationDataPrint(reservationData);

      if (kDebugMode) {
        kLogger.i(
          "✅ Table Reservation SUCCESS #${reservationData.tableBookId}",
        );
      }
    } catch (e) {
      PopupDialog.showErrorMessage(
        "Table Reservation data format is not correct",
      );
      if (kDebugMode) kLogger.e('Table Reservation format error => $e');
      // callback?.call({"status": "ERROR", "message": e.toString()});
      if (kDebugMode) {
        kLogger.e("❌ Sent ERROR acknowledgment for table booking");
      }
    }
  }

  void _onOnlineOrder(dynamic data) {
    if (kDebugMode) kLogger.i("Online Order Placed: $data");

    dynamic orderData;
    Function? callback;

    if (data is List && data.isNotEmpty) {
      orderData = data[0];
      if (data.length > 1 && data[1] is Function) {
        callback = data[1] as Function;
      }
    } else {
      orderData = data;
    }
    callback?.call({"status": "SUCCESS"});
    try {
      final OrderModel order = OrderModel.fromJson(orderData);

      if (Preferences.isNotificationSound) {
        BaseController.to.playNotificationSound();
      }

      toastification.show(
        title: const Text("Online Order Received", maxLines: 1),
        description: Text(
          "Order #${order.orderId} - Amount: \$${order.totalOrderAmount.toStringAsFixed(2)}",
          maxLines: 4,
        ),
        type: ToastificationType.info,
        autoCloseDuration: const Duration(seconds: 5),
      );

      if (Preferences.isOloPrint) kitchenPrint(order);
      if (Preferences.oloCustomerReceipt) {
        PrintUtils().directPrint(
          data: escOrderPrintReceipt(order: order),
          printer: Preferences.counterPrinter,
        );
      }

      if (Get.currentRoute != '/auth') OnlineOrderController.to.getOrders();

      callback?.call({"status": "SUCCESS"});
      if (kDebugMode) {
        kLogger.i("✅ Online order SUCCESS #${order.orderId}");
      }
    } catch (e) {
      PopupDialog.showErrorMessage("OLO data format is not correct");
      if (kDebugMode) kLogger.e('Online order format error => $e');
      // callback?.call({"status": "ERROR", "message": e.toString()});
      if (kDebugMode) kLogger.e("❌ Sent ERROR acknowledgment for online order");
    }
  }

  void _onDeliveryOrder(dynamic data) {
    dynamic orderData;
    Function? callback;

    if (data is List && data.isNotEmpty) {
      orderData = data[0];
      if (data.length > 1 && data[1] is Function) {
        callback = data[1] as Function;
      }
    } else {
      orderData = data;
    }
    callback?.call({"status": "SUCCESS"});
    try {
      final OrderModel order = OrderModel.fromJson(orderData);

      if (Preferences.isNotificationSound) {
        BaseController.to.playNotificationSound();
      }

      toastification.show(
        title: const Text("Delivery Order Received", maxLines: 1),
        description: Text(
          "Order #${order.orderId} - Amount: \$${order.totalOrderAmount.toStringAsFixed(2)}",
          maxLines: 4,
        ),
        type: ToastificationType.info,
        autoCloseDuration: const Duration(seconds: 5),
      );

      if (Preferences.isDeliveryOrderPrint) kitchenPrint(order);
      if (Preferences.deliveryCustomerReceipt) {
        PrintUtils().directPrint(
          data: escOrderPrintReceipt(order: order),
          printer: Preferences.counterPrinter,
        );
      }

      if (Get.currentRoute != '/auth') DeliveryController.to.getOrders();

      callback?.call({"status": "SUCCESS"});
      if (kDebugMode) {
        kLogger.i("✅ Delivery order SUCCESS #${order.orderId}");
      }
    } catch (e) {
      PopupDialog.showErrorMessage("Delivery data format is not correct");
      if (kDebugMode) kLogger.e('Delivery order format error => $e');
      // callback?.call({"status": "ERROR", "message": e.toString()});
      if (kDebugMode) {
        kLogger.e("❌ Sent ERROR acknowledgment for delivery order");
      }
    }
  }

  void _onDeviceDisconnect(dynamic data) {
    Function? callback;

    if (data is List && data.isNotEmpty) {
      if (data.length > 1 && data[1] is Function) {
        callback = data[1] as Function;
      }
    }

    if (kDebugMode) kLogger.w("⚠️ Device disconnect event received");

    callback?.call({"status": "SUCCESS"});
    AppHelper.exitApp();
  }

  void _onMonerisPayment(dynamic data) {
    if (kDebugMode) kLogger.i("Moneris event received: $data");
    dynamic paymentData;
    Function? callback;

    if (data is List && data.isNotEmpty) {
      paymentData = data[0];
      if (data.length > 1 && data[1] is Function) {
        callback = data[1] as Function;
      }
    } else {
      paymentData = data;
    }
    callback?.call({"status": "SUCCESS"});

    if (Get.isRegistered<PosController>()) {
      try {
        final String status = paymentData['status'] ?? 'unknown';
        final String message = paymentData['message'] ?? 'unknown';
        final OrderModel? order = paymentData['order'] != null
            ? OrderModel.fromJson(paymentData['order'])
            : null;

        debugPrint('Moneris payment status: $status');

        if (order != null) {
          debugPrint(
            "Moneris Payment - Order: ${order.orderStatus}, Amount: ${order.totalOrderAmount}",
          );
        } else {
          debugPrint("Moneris Payment - No order data received.");
        }

        if (status == 'processing') {
          debugPrint('Moneris payment is processing...');
        } else if (status == 'success') {
          PosController.to.clearCartList();
          Get.back();
          monerisDialog(
            status: PurchaseDialogStatus.success,
            message: message,
            order: order,
          );
        } else {
          // failed / error / unknown
          PosController.to.myOrder.payment = null;
          Get.back();
          monerisDialog(status: PurchaseDialogStatus.error, message: message);
        }

        if (Get.currentRoute != '/auth') {
          DataUpdateHelper.getDataByCheckType(type: order?.orderType);
        }

        debugPrint("Moneris Payment Update: $paymentData");

        if (kDebugMode) kLogger.i("✅ Moneris payment SUCCESS");
      } catch (e) {
        if (kDebugMode) kLogger.e('Moneris payment error: $e');
        // callback?.call({"status": "ERROR", "message": e.toString()});
        if (kDebugMode) {
          kLogger.e("❌ Sent ERROR acknowledgment for Moneris payment");
        }
      }
    } else {
      debugPrint('[MonerisPayment] PosController not ready — skipping');
    }
  }


  void _onUpdateOrder(dynamic data) {
    String orderType;
    Function? callback;

    if (data is List && data.isNotEmpty) {
      orderType = data[0];
      if (data.length > 1 && data[1] is Function) {
        callback = data[1] as Function;
      }
    } else {
      orderType = data;
    }
    callback?.call({"status": "SUCCESS"});
    if (Get.isRegistered<PosController>()) {
      DataUpdateHelper.getDataBySocket(orderType);
    }
  }

  void _onElavonCWS(dynamic data) {
    Function? callback;

    if (data is List && data.isNotEmpty) {
      if (data.length > 1 && data[1] is Function) {
        callback = data[1] as Function;
      }
    }

    if (kDebugMode) debugPrint("⚠️ Elavon CWS event received: $data");

    ref.read(cwsCredentialsConfigProvider.notifier).reload();
    callback?.call({"status": "SUCCESS"});
  }

  void _onUpdatePosElavonCws(dynamic data) {
    Function? callback;

    if (data is List && data.isNotEmpty) {
      if (data.length > 1 && data[1] is Function) {
        callback = data[1] as Function;
      }
    }

    if (kDebugMode) {
      debugPrint("⚠️ Update POS Elavon CWS event received: $data");
    }

    BaseController.to.getRestaurantsDetailsFromAPI();
    callback?.call({"status": "SUCCESS"});
  }

  /// Employee Auto Clock Out Event Handler
  void _onEmployeeAutoClockOut(dynamic data) async {
    dynamic employeeRowData;
    Function? callback;

    if (data is List && data.isNotEmpty) {
      employeeRowData = data[0];
      if (data.length > 1 && data[1] is Function) {
        callback = data[1] as Function;
      }
    } else {
      employeeRowData = data;
    }

    if (kDebugMode) {
      debugPrint("⚠️ Employee Auto Clock Out event received: $data");
    }
    callback?.call({"status": "SUCCESS"});

    try {
      EmployeeModel employeeData = EmployeeModel.fromJson(employeeRowData);
      if (BaseController.to.employeeData?.id == employeeData.id) {
        final notifier = ref.read(clockInOutProvider.notifier);
        await notifier.clockOut();

        // Show Clock In Dialog after auto clock out
        PopupDialog.customDialog2(
          barrierDismissible: false,
          width: 550,
          child: const ClockInDialog(
            title: "Auto Clock Out",
            subTitle:
                "You have been automatically clocked out due to inactivity. Please clock in again to continue.",
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) kLogger.e("Error in Employee Auto Clock Out event: $e");
    }
  }
}

// ─────────────────────────────────────────────────
// HTTP Override
// ─────────────────────────────────────────────────

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

// ─────────────────────────────────────────────────
// Print Helper
// ─────────────────────────────────────────────────

Future<void> _reservationDataPrint(Reservations reservationData) async {
  final printData = escTableReservationReceipt(data: reservationData);
  PrintUtils().directPrint(
    data: printData,
    printer: Preferences.kitchenPrinter,
  );
}
