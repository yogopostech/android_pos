import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/utils/extension/formatted_phone.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/receipt.dart';

Uint8List escKitchenPrintReceipt({
  required OrderModel order,
  bool isCheckCanceled = false,
  bool isShowItems = true,
  String? title,
  bool isItemsCanceled = false,
}) {
  Receipt receipt = Receipt();

  receipt
      .space(3)
      .text(
        'Guest:${MyFunc.capitalize(order.guestName)}',
        fontSize: 2,
        fontWeight: FontWeight.bold,
      )
      .text(
        "Order Place: ${DateFormat('hh:mm a').format(order.createdAt!.toTimeZone())}",
        fontSize: 2,
        fontWeight: FontWeight.bold,
      );
  // .flexRow(
  //   children: [
  //     Col.flex(
  //       'Guest:${MyFunc.capitalize(order.guestName)}',
  //       fontSize: 2,
  //       fontWeight: FontWeight.bold,
  //     ),
  //     Col.flex(
  //       DateFormat('hh:mm a').format(order.createdAt!.toTimeZone()),
  //       fontSize: 2,
  //       fontWeight: FontWeight.bold,
  //       align: Align.right,
  //     ),
  //   ],
  // );
  // Guest name
  // .text(
  //   'Guest:${MyFunc.capitalize(order.guestName)}',
  //   fontSize: 2,
  //   fontWeight: FontWeight.bold,
  // );

  // Phone number
  receipt
      .text(
        'Phone #:${order.guestPhoneNumber.toFormattedPhone()}',
        fontType: FontType.fontB,
        fontSize: 2,
      )
      .text(
        'Server:${order.employee != null ? order.employee?.firstName.toUpperCase() : "OLO"}',
        fontWeight: FontWeight.bold,
        align: Align.left,
      );

  // Estimated time (for TAKEOUT ONLINE or DELIVERY)
  if ((order.orderType == "TAKEOUT" && order.takeOutType == "ONLINE") ||
      order.orderType == "DELIVERY") {
    receipt.text(
      '${order.orderType == "DELIVERY" ? "Delivery" : "Pickup"}:${order.estimatedDate.toFormattedDate()} ${order.estimatedTime.isEmpty ? "" : ", ${order.estimatedTime}"}',
    );
  }

  // Notes
  if (order.notes.isNotEmpty) {
    receipt.space().text(
      'Notes:${order.notes}',
      fontWeight: FontWeight.bold,
      maxLines: 5,
      fontSize: 2,
    );
  }

  // Delivery information
  if (order.delivery != null && order.orderType == "DELIVERY") {
    if (order.delivery?.address.isNotEmpty ?? false) {
      receipt.space().text(
        'Delivery: ${order.delivery?.address}',
        fontSize: 2,
        fontType: FontType.fontB,
        maxLines: 5,
      );
    }
    if (order.delivery?.additionalDetails.isNotEmpty ?? false) {
      receipt.space().text(
        'Additional Details:${order.delivery?.additionalDetails}',
        fontWeight: FontWeight.bold,
        maxLines: 5,
      );
    }
  }
  // Spacing and divider
  receipt.separator();

  // Order type headers
  if (order.orderType == "TAKEOUT" && order.takeOutType == "ONLINE") {
    receipt.text(
      '**** ${order.takeOutType} ****',
      fontSize: 2,
      fontWeight: FontWeight.bold,
      align: Align.center,
    );
  }

  receipt.text(
    '**** ${order.orderType.replaceAll("_", "-")} ****',
    fontSize: 2,
    fontWeight: FontWeight.bold,
    align: Align.center,
  );

  if (order.orderType == "DINE_IN") {
    receipt.text(
      '**** ${order.tableName} ****',
      fontSize: 2,
      fontWeight: FontWeight.bold,
      align: Align.center,
    );
  }

  receipt.separator();

  // Check canceled message
  if (isCheckCanceled) {
    receipt
        .text(
          '*** ${title?.toUpperCase() ?? 'Check CANCELLED'.toUpperCase()} ***',
          fontSize: 2,
          fontWeight: FontWeight.bold,
          align: Align.center,
        )
        .separator();
  }

  // Items
  if (isShowItems) {
    for (var data in order.carts.combineItems()) {
      var itemName = data.isCustomProduct ? "${data.name}(CUSTOM)" : data.name;
      // Item quantity and name
      // 1st item without space, then add space for next items
      // if (data == order.carts.first) {
      //   receipt.space();
      // }
      receipt.flexRow(
        children: [
          Col.fixed(
            '${data.quantity}',
            width: 4,
            fontSize: 2,
            // fontWeight: FontWeight.bold,
          ),
          Col.fixed("", width: 1),
          Col.flex(
            (data.itemType == "weighing scale"
                    ? " $itemName (${data.weight}LB)"
                    : itemName)
                .toUpperCase(),

            fontSize: 2,
            // fontWeight: FontWeight.bold,
          ),
        ],
      );
      // Variation options
      if (data.variationOptions.isNotEmpty) {
        for (int i = 0; i < data.variationOptions.length; i++) {
          final optionData = data.variationOptions[i];
          receipt.text(
            "${optionData.quantity} x ${MyFunc.capitalizeEachWord(s: optionData.name)}",
            fontSize: 2,
            lMargin: 2,
            // fontWeight: FontWeight.bold,
          );
        }
      }
      // Modifiers
      if (data.modifiers.isNotEmpty) {
        receipt.space();
        for (var modifier in data.modifiers) {
          receipt.text(
            modifier.toUpperCase(),
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            fontSize: 2,
          );
        }
      }
      // Kitchen notes
      if (data.kitchenNote.isNotEmpty) {
        receipt.space().text(
          "NOTE: ${data.kitchenNote.toUpperCase()}",
          fontWeight: FontWeight.bold,
          fontSize: 2,
        );
      }

      // Item separator
      receipt.dashed();
    }
  }
  receipt.space().text(
    'Token# ${order.tokenId}',
    fontSize: 2,
    align: Align.center,
    fontWeight: FontWeight.bold,
  );
  receipt.space(2).cut();
  return receipt.bytes;
}
