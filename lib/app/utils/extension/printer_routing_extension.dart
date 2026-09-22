import 'package:flutter/foundation.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';

extension CartPrinterRouting on List<String> {
  /// POS order → removes OLO type printers, returns the rest.
  // List<String> toPosPrinter() {
  //   if (isEmpty) return [];
  //   final oloIds = ConfigController.to.rowPrinters
  //       .where((p) => p.printerType == "OLO")
  //       .map((p) => p.id)
  //       .toSet();
  //   return where((id) => !oloIds.contains(id)).toList();
  // }

  // /// OLO order → removes POS type printers, returns the rest.
  // List<String> toOLOPrinter() {
  //   if (isEmpty) return [];
  //   final posIds = ConfigController.to.rowPrinters
  //       .where((p) => p.printerType == "POS")
  //       .map((p) => p.id)
  //       .toSet();
  //   return where((id) => !posIds.contains(id)).toList();
  // }

  /// Auto-routes based on PosController.to.myorder type.
  // List<String> toRoutedPrinter() {
  //   var ids = PosController.to.myOrder.isOloOrder
  //       ? toOLOPrinter()
  //       : toPosPrinter();
  //   if (kDebugMode) {
  //     debugPrint("Routing printers for order type : $ids");
  //   }
  //   return ids;
  // }
}

/// Decides whether the order is OLO.
/// TAKEOUT + ONLINE  OR  DELIVERY + ONLINE  => OLO, everything else is POS.
extension OrderTypeRouting on OrderModel {
  bool get isOloOrder {
    final isOnline = takeOutType == "ONLINE";
    var myOrderType =
        isOnline && (orderType == "TAKEOUT" || orderType == "DELIVERY");
    if (kDebugMode) {
      debugPrint(
        "Takeout: $takeOutType, orderType: $orderType => isOloOrder: $myOrderType",
      );
    }
    return myOrderType;
  }
}
