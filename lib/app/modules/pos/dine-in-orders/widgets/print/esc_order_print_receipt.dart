import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/utils/extension/formatted_phone.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/extension/discount_extention.dart';
import 'package:yogo_pos/app/utils/extension/string_manipulation_extension.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/utils/receipt.dart';
import 'package:yogo_pos/app/widgets/const.dart';

Uint8List escOrderPrintReceipt({
  bool isCustomerCopy = true,
  bool isOpenDrawer = false,
  required OrderModel order,
}) {
  BaseController baseController = Get.find<BaseController>();
  Receipt receipt = Receipt();
  // StarReceipt receipt = StarReceipt();
  receipt
      // Restaurant Name
      .text(
        (baseController.restaurantDetails?.restaurant.name ?? "").toUpperCase(),
        fontSize: 2,
        fontWeight: FontWeight.bold,
        align: Align.center,
      )
      .space()
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
        'Phone: ${MyFunc.stringNullCheck(baseController.restaurantDetails?.restaurant.phone.toFormattedPhone())}',
        align: Align.center,
        fontWeight: FontWeight.bold,
      )
      .separator()
      // Check Number
      .text('Check# ${order.orderId}', fontWeight: FontWeight.bold)
      .text(
        "Order Place: ${DateFormat('MMM dd,hh:mm a').format(order.createdAt == null ? DateTime.now() : order.createdAt!.toTimeZone())}",
        fontWeight: FontWeight.bold,
        align: Align.left,
      );
  // .flexRow(
  //   children: [
  //     Col.flex('Check# ${order.orderId}', fontWeight: FontWeight.bold),
  //     Col.flex(
  //       "Order Place: ${DateFormat('MMM dd,hh:mm a').format(order.createdAt!.toTimeZone())}",
  //       fontWeight: FontWeight.bold,
  //       align: Align.right,
  //     ),
  //   ],
  // );
  // .text(
  //   'Check# ${order.orderId}',
  //   fontWeight: FontWeight.bold,
  // )

  // // Date and Time
  // .text(
  //   DateFormat('MMM dd,hh:mm a')
  //       .format((order.updatedAt ?? DateTime.now()).toTimeZone()),
  //   fontWeight: FontWeight.bold,
  // );

  // Server and Order Type Row
  receipt.flexRow(
    children: [
      Col.flex(
        'Server:${MyFunc.stringNullCheck(order.employee?.firstName.toUpperCase())}',
        fontWeight: FontWeight.bold,
      ),
      Col.flex(
        "${order.orderType.replaceAll('_', ' ')}: ${order.orderType != "TAKEOUT" ? MyFunc.stringNullCheck(order.tableName) : "${order.takeOutType?.replaceAll('_', ' ')}"}",
        align: Align.right,
        fontWeight: FontWeight.bold,
      ),
    ],
  );

  // Guest and Total Guests Row
  List<Col> guestRowChildren = [
    Col.flex(
      'Guest:${MyFunc.stringNullCheck(order.guestName.toUpperCase())}',
      fontWeight: FontWeight.normal,
      fontSize: 2,
      fontType: FontType.fontB,
    ),
  ];
  if (order.orderType == "DINE_IN") {
    guestRowChildren.add(
      Col.flex('Total Guests:${order.numberOfPeople}', align: Align.right),
    );
  }
  receipt.flexRow(children: guestRowChildren);

  // Phone Number
  if (order.guestPhoneNumber.isNotEmpty) {
    receipt.text(
      'Phone #:${order.guestPhoneNumber.toFormattedPhone()}',
      fontWeight: FontWeight.normal,
      fontSize: 2,
      fontType: FontType.fontB,
    );
  }

  // Token Number
  if (order.tokenId.isNotEmpty) {
    receipt.text('Token# ${order.tokenId}');
  }

  // Pickup Time
  if ((order.orderType == "TAKEOUT" && order.takeOutType == "ONLINE") ||
      order.orderType == "DELIVERY") {
    receipt.text(
      '${order.orderType == "DELIVERY" ? "Delivery" : "Pickup"}:${order.estimatedDate.toFormattedDate()} ${order.estimatedTime.isEmpty ? "" : ", ${order.estimatedTime}"}',
    );
  }

  // Notes
  if (order.notes.isNotEmpty) {
    receipt.text(
      'Notes:${order.notes.toCapitalizeEachWord()}',
      fontWeight: FontWeight.bold,
      maxLines: 5,
      fontSize: 2,
    );
  }

  // Delivery Information
  if (order.delivery != null && order.orderType == "DELIVERY") {
    if (order.delivery?.address.isNotEmpty ?? false) {
      receipt.text(
        'Delivery: ${order.delivery?.address}',
        maxLines: 5,
        fontWeight: FontWeight.normal,
        fontSize: 2,
        fontType: FontType.fontB,
      );
    }
    if (order.delivery?.additionalDetails.isNotEmpty ?? false) {
      receipt.text(
        'Additional Details:${order.delivery?.additionalDetails}',
        maxLines: 5,
      );
    }
  }

  receipt.space();

  // Item Header
  receipt.flexRow(
    children: [
      Col.fixed('Qty', width: 4, fontWeight: FontWeight.bold),
      Col.flex('Item', fontWeight: FontWeight.bold),
      Col.fixed(
        'Amt.',
        width: 8,
        fontWeight: FontWeight.bold,
        align: Align.right,
      ),
    ],
  );

  receipt.pattern('-');

  // Items
  for (var data in order.carts.combineItems(isCustomerRecipt: true)) {
    receipt.flexRow(
      children: [
        Col.fixed('${data.quantity}', fontWeight: FontWeight.bold, width: 4),
        Col.flex(
          data.itemType == "weighing scale"
              ? "${data.name.toUpperCase()}(${data.weight}LB)"
              : data.name.toUpperCase(),
          fontWeight: FontWeight.bold,
        ),
        Col.fixed(
          '\$${data.price.toStringAsFixed(2)}',
          width: 8,
          align: Align.right,
          fontWeight: FontWeight.bold,
        ),
      ],
    );

    // Item Discount
    if (data.discount.value > 0) {
      receipt.text('  Discount: ${data.discount.displayValue}');
    }
  }

  // Total Calculation Section
  receipt.pattern('-');

  // Sub Total
  receipt.flexRow(
    children: [
      Col.flex('Sub Total', fontWeight: FontWeight.bold),
      Col.fixed(
        '\$${order.subTotal.toStringAsFixed(2)}',
        width: 10,
        fontWeight: FontWeight.bold,
        align: Align.right,
      ),
    ],
  );
  receipt.pattern('.');
  if (order.totalDiscount > 0) {
    receipt.flexRow(
      children: [
        Col.flex('Discount', fontWeight: FontWeight.bold),
        Col.fixed(
          '(-) \$${order.totalDiscount.toStringAsFixed(2)}',
          width: 10,
          fontWeight: FontWeight.bold,
          align: Align.right,
        ),
      ],
    );
    receipt.pattern('.');
  }

  // GST
  if (order.totalGst > 0) {
    receipt.flexRow(
      children: [
        Col.flex(
          'GST ${baseController.restaurantDetails?.businessProfile.gstNumber ?? 0}%',
          fontWeight: FontWeight.bold,
        ),
        Col.fixed(
          '\$${order.totalGst.toStringAsFixed(2)}',
          width: 10,
          fontWeight: FontWeight.bold,
          align: Align.right,
        ),
      ],
    );
    receipt.pattern('.');
  }

  // PST
  if (order.totalPst > 0) {
    receipt.flexRow(
      children: [
        Col.flex(
          'PST ${baseController.restaurantDetails?.businessProfile.pstNumber ?? 0}%',
          fontWeight: FontWeight.bold,
        ),
        Col.fixed(
          '\$${order.totalPst.toStringAsFixed(2)}',
          width: 10,
          fontWeight: FontWeight.bold,
          align: Align.right,
        ),
      ],
    );
    receipt.pattern('.');
  }

  // PST2
  if (order.totalPst2 > 0) {
    receipt.flexRow(
      children: [
        Col.flex(
          'PST2 ${baseController.restaurantDetails?.businessProfile.pstNumber2 ?? 0}%',
          fontWeight: FontWeight.bold,
        ),
        Col.fixed(
          '\$${order.totalPst2.toStringAsFixed(2)}',
          width: 10,
          fontWeight: FontWeight.bold,
          align: Align.right,
        ),
      ],
    );
    receipt.pattern('.');
  }

  // Gratuity
  if (order.totalGratuity > 0) {
    receipt.flexRow(
      children: [
        Col.flex(
          "Gratuity ${order.gratuityPercentage ?? (baseController.restaurantDetails?.businessProfile.gratuity ?? 0)}% : ",
          fontWeight: FontWeight.bold,
        ),
        Col.fixed(
          '\$${order.totalGratuity.toStringAsFixed(2)}',
          width: 10,
          fontWeight: FontWeight.bold,
          align: Align.right,
        ),
      ],
    );
    receipt.pattern('.');
  }

  // Discount

  // Delivery Fee
  if (order.deliveryFee > 0) {
    receipt.flexRow(
      children: [
        Col.flex('Delivery Fee', fontWeight: FontWeight.bold),
        Col.fixed(
          '\$${order.deliveryFee.toStringAsFixed(2)}',
          width: 10,
          fontWeight: FontWeight.bold,
          align: Align.right,
        ),
      ],
    );
    receipt.pattern('.');
  }

  // Maintenance Fee
  if (order.maintenanceFee > 0) {
    receipt.flexRow(
      children: [
        Col.flex('Service Fee', fontWeight: FontWeight.bold),
        Col.fixed(
          '\$${order.maintenanceFee.toStringAsFixed(2)}',
          width: 10,
          fontWeight: FontWeight.bold,
          align: Align.right,
        ),
      ],
    );
    receipt.pattern('.');
  }

  // Packaging Cost
  if (order.packagingCost > 0) {
    receipt.flexRow(
      children: [
        Col.flex(
          '${BaseController.to.restaurantDetails?.restaurant.packagingCost.title}',
          fontWeight: FontWeight.bold,
        ),
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

  // Payment Details (only if PAID)
  if (order.paymentStatus == 'PAID') {
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
    // Paid by Card
    if ((order.payment?.cardPaidAmount ?? 0) > 0) {
      String cardMethod = order.payment?.cardType == ""
          ? order.payment?.methods.join(', ').replaceAll('_', ' ') ??
                "".toUpperCase()
          : order.payment?.cardType ?? "";
      receipt.flexRow(
        children: [
          Col.flex('Paid by $cardMethod', fontWeight: FontWeight.bold),
          Col.fixed(
            '\$${((order.payment?.cardPaidAmount ?? 0) + (order.payment?.cardTipAmount ?? 0)).toStringAsFixed(2)}',
            width: 10,
            fontWeight: FontWeight.bold,
            align: Align.right,
          ),
        ],
      );
      receipt.pattern('.');
    }

    // Paid by Cash
    if ((order.payment?.cashPaidAmount ?? 0) > 0) {
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
  receipt.flexRow(
    children: [
      Col.flex(
        "Total ${MyFunc.orderCondition(order)}",
        fontType: FontType.fontB,
        fontWeight: FontWeight.bold,
        fontSize: 2,
      ),
      Col.fixed(
        "\$${order.totalOrderAmount.toStringAsFixed(2)}",
        width: 12,
        fontType: FontType.fontB,
        align: Align.right,
        fontWeight: FontWeight.bold,
        fontSize: 2,
      ),
    ],
  );

  receipt.dotted();

  if (order.payment != null && (order.payment?.maskedPan.isNotEmpty ?? false)) {
    receipt.flexRow(
      children: [
        Col.flex('Card Number:', fontWeight: FontWeight.bold),
        Col.fixed(
          '${order.payment?.maskedPan}',
          width: 10,
          fontWeight: FontWeight.bold,
          align: Align.right,
        ),
      ],
    );
  }
  if (order.payment != null && (order.payment?.entryMode.isNotEmpty ?? false)) {
    receipt.flexRow(
      children: [
        Col.flex('Payment Method:', fontWeight: FontWeight.bold),
        Col.fixed(
          '${order.payment?.entryMode}',
          width: 10,
          fontWeight: FontWeight.bold,
          align: Align.right,
        ),
      ],
    );
  }
  if (order.payment != null &&
      (order.payment?.transactionId.isNotEmpty ?? false)) {
    receipt.flexRow(
      children: [
        Col.flex('Approval Code:', fontWeight: FontWeight.bold),
        Col.fixed(
          '${order.payment?.transactionId}',
          width: 10,
          fontWeight: FontWeight.bold,
          align: Align.right,
        ),
      ],
    );
    receipt.dotted();
  }

  // Copy Type and Payment Status
  String copyType = isCustomerCopy ? 'Customer Copy: ' : 'Merchant Copy: ';
  String paymentStatus = order.paymentStatus == "UNPAID"
      ? "UNPAID"
      : "${order.payment?.methods.join(', ').replaceAll('_', ' ') ?? ""} Sale";

  receipt
      .text(
        '$copyType$paymentStatus',
        fontWeight: FontWeight.bold,
        align: Align.center,
      )
      .dotted();

  // Thank You Message
  receipt
      .text(
        'Thank you for visiting ${baseController.restaurantDetails?.restaurant.name.toUpperCase()}',
        fontWeight: FontWeight.bold,
        align: Align.center,
        maxLines: 2,
      )
      .dotted();

  // Google Review
  receipt.text(
    'Please review us on Google',
    fontWeight: FontWeight.bold,
    align: Align.center,
  );

  // Powered By
  receipt.space().text(
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
