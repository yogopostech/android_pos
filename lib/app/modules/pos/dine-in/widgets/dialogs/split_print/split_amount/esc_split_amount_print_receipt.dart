import 'dart:typed_data';

import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/utils/extension/formatted_phone.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/receipt.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/utils/star_receipt.dart';
import 'package:yogo_pos/app/widgets/const.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../controllers/split_order_controller.dart';
import '../../../../models/split_amount_model.dart';

Uint8List escSplitAmountPrintReceipt({
  bool isCustomerCopy = true,
  bool isOpenDrawer = false,
  required SplitAmount order,
}) {
  BaseController baseController = Get.find<BaseController>();
  Receipt receipt = Receipt();

  // Main order
  OrderModel mainOrder = SplitOrderController.to.mainOrder;

  // Logo/Header Image
  if (baseController.printImg != null) {
    // Note: Add image printing if needed
  }

  receipt
      // Restaurant Name
      .text(
        (baseController.restaurantDetails?.restaurant.name ?? "").toUpperCase(),
        fontSize: 2,
        fontWeight: FontWeight.bold,
        align: Align.center,
      )
      // Address
      .text(
        (baseController.restaurantDetails?.restaurant.address ?? "").replaceAll(
          "_",
          "\n",
        ),
        align: Align.center,
        fontWeight: FontWeight.bold,
      )
      // Phone
      .text(
        'Phone: ${baseController.restaurantDetails?.restaurant.phone.toFormattedPhone() ?? ""}',
        align: Align.center,
        fontWeight: FontWeight.bold,
      )
      .space()
      .dotted()
      .space()
      .text('Check:${order.orderId}', fontWeight: FontWeight.bold)
      .text(
        "Order Place: ${DateFormat('MMM dd,hh:mm a').format(mainOrder.createdAt!.toTimeZone())}",
        fontWeight: FontWeight.bold,
      );
  // Check Number and Date/Time Row
  // receipt.flexRow(
  //   children: [
  //     Col.flex('Check:${order.orderId}', fontWeight: FontWeight.bold),
  //     Col.flex(
  //       "Order Place: ${DateFormat('MMM dd,hh:mm a').format(mainOrder.createdAt!.toTimeZone())}",
  //       fontWeight: FontWeight.bold,
  //       align: Align.right,
  //     ),
  //   ],
  // );

  // Server and Order Type Row
  List<Col> serverRowChildren = [
    Col.flex('Server:${mainOrder.employee?.firstName.toUpperCase()}'),
  ];

  if (mainOrder.orderType != "TAKEOUT") {
    serverRowChildren.add(
      Col.flex(
        '${mainOrder.orderType.replaceAll('_', ' ')}:${mainOrder.tableName}',
        align: Align.right,
      ),
    );
  } else {
    serverRowChildren.add(
      Col.flex('Type: ${mainOrder.orderType}', align: Align.right),
    );
  }

  receipt.flexRow(children: serverRowChildren);

  // Guest and Number of Guests Row
  List<Col> guestRowChildren = [];

  if (order.guestName.isNotEmpty) {
    guestRowChildren.add(Col.flex('Guest:${order.guestName}'));
  }

  if (mainOrder.orderType != "TAKEOUT") {
    guestRowChildren.add(
      Col.flex(
        'No. of Guest:${mainOrder.numberOfPeople}',
        align: order.guestName.isNotEmpty ? Align.right : Align.left,
      ),
    );
  }

  if (guestRowChildren.isNotEmpty) {
    receipt.flexRow(children: guestRowChildren).tinySpace();
  }

  // Phone Number
  if (mainOrder.guestPhoneNumber.isNotEmpty) {
    receipt.text('Number:${mainOrder.guestPhoneNumber.toFormattedPhone()}');
  }

  // Token
  if (mainOrder.tokenId.isNotEmpty) {
    receipt.text('Token:${mainOrder.tokenId}');
  }

  receipt.space().dotted().space();

  // Total Amount
  receipt.flexRow(
    children: [
      Col.flex('Total Amount', fontWeight: FontWeight.bold),
      Col.fixed(
        '\$${(SplitOrderController.to.order.totalOrderAmount - SplitOrderController.to.order.packagingCost).toStringAsFixed(2)}',
        width: 10,
        fontWeight: FontWeight.bold,
        align: Align.right,
      ),
    ],
  );

  receipt.dotted();

  // Split Amount
  receipt.flexRow(
    children: [
      Col.flex('Split Amount', fontWeight: FontWeight.bold),
      Col.fixed(
        '\$${order.splitAmount.toStringAsFixed(2)}',
        width: 10,
        fontWeight: FontWeight.bold,
        align: Align.right,
      ),
    ],
  );

  receipt.dotted();

  // Packaging Cost
  if (order.packagingCost > 0) {
    receipt.flexRow(
      children: [
        Col.flex('Packaging Cost', fontWeight: FontWeight.bold),
        Col.fixed(
          '\$${order.packagingCost.toStringAsFixed(2)}',
          width: 10,
          fontWeight: FontWeight.bold,
          align: Align.right,
        ),
      ],
    );
    receipt.pattern('.');
  }

  // Payment Details
  if (order.payment != null) {
    // Cash Tip
    if ((order.payment?.cashTipAmount ?? 0) > 0) {
      receipt.flexRow(
        children: [
          Col.flex('Cash Tip', fontWeight: FontWeight.bold),
          Col.fixed(
            '\$${order.payment?.cashTipAmount.toStringAsFixed(2)}',
            width: 10,
            fontWeight: FontWeight.bold,
            align: Align.right,
          ),
        ],
      );
      receipt.pattern('.');
    }

    // Card Tip
    if ((order.payment?.cardTipAmount ?? 0) > 0) {
      receipt.flexRow(
        children: [
          Col.flex('Card Tip', fontWeight: FontWeight.bold),
          Col.fixed(
            '\$${order.payment?.cardTipAmount.toStringAsFixed(2)}',
            width: 10,
            fontWeight: FontWeight.bold,
            align: Align.right,
          ),
        ],
      );
      receipt.pattern('.');
    }

    // Paid by Cash
    if (order.payment?.methods.contains('CASH') ?? false) {
      receipt.flexRow(
        children: [
          Col.flex('Paid by Cash', fontWeight: FontWeight.bold),
          Col.fixed(
            '\$${((order.payment?.cashPaidAmount ?? 0) + (order.payment?.change ?? 0) + (order.payment?.cashTipAmount ?? 0)).toStringAsFixed(2)}',
            width: 10,
            fontWeight: FontWeight.bold,
            align: Align.right,
          ),
        ],
      );
      receipt.pattern('.');
    }

    // Change
    if ((order.payment?.change ?? 0) > 0) {
      receipt.flexRow(
        children: [
          Col.flex('Change', fontWeight: FontWeight.bold),
          Col.fixed(
            '\$${order.payment?.change.toStringAsFixed(2)}',
            width: 10,
            fontWeight: FontWeight.bold,
            align: Align.right,
          ),
        ],
      );
      receipt.pattern('.');
    }
  }

  // Total
  receipt.space();
  receipt.flexRow(
    children: [
      Col.flex(
        "Total ${MyFunc.orderCondition(order)}",
        fontSize: 2,
        fontWeight: FontWeight.bold,
      ),
      Col.fixed(
        "\$${(order.total + (order.payment?.cardTipAmount ?? 0) + (order.payment?.cashTipAmount ?? 0)).toStringAsFixed(2)}",
        width: 12,
        fontSize: 2,
        fontWeight: FontWeight.bold,
        align: Align.right,
      ),
    ],
  );

  receipt.space().dotted().space();

  // Copy Type and Payment Status
  String copyType = isCustomerCopy ? 'Customer Copy: ' : 'Merchant Copy: ';
  String paymentStatus = order.payment == null
      ? 'UNPAID'
      : '${order.payment?.methods.join(', ').replaceAll('_', ' ') ?? ""} Sale';

  receipt
      .text(
        '$copyType$paymentStatus',
        fontWeight: FontWeight.bold,
        align: Align.center,
      )
      .space()
      .dotted()
      .space();

  // Thank You Message
  receipt
      .text(
        'Thank you for visiting ${baseController.restaurantDetails?.restaurant.name.toUpperCase()}',
        fontWeight: FontWeight.bold,
        align: Align.center,
        maxLines: 2,
      )
      .space()
      .dotted()
      .space();

  // Google Review
  receipt.text(
    'Please review us on Google',
    fontWeight: FontWeight.bold,
    align: Align.center,
  );

  // Powered By
  receipt.tinySpace().text(
    'Powered by ${Yogo.name}',
    fontSize: 1,
    align: Align.center,
  );

  receipt.space(2).cut();
  if (isOpenDrawer) {
    receipt.openDrawer();
  }
  return receipt.bytes;
}
