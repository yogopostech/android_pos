import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_order_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/extension/discount_extention.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/dot_divider.dart';
import 'package:yogo_pos/config/fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/utils/extension/formatted_phone.dart';
import '../../../../../widgets/const.dart';
import '../../../../../widgets/my_custom_text.dart';

class PrintOrderDialog extends StatelessWidget {
  final OrderModel order;
  const PrintOrderDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    BaseController baseController = Get.find<BaseController>();
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrimaryBtn(
              onPressed: () async {
                await PrintUtils().directPrint(
                  data: escOrderPrintReceipt(order: order),
                  printer: Preferences.counterPrinter,
                );
                Get.back();
              },
              text: " Customer Copy",
              textColor: Colors.white,
            ),
            const SizedBox(width: 6),
            PrimaryBtn(
              onPressed: () async {
                await PrintUtils().directPrint(
                  data: escOrderPrintReceipt(
                    isCustomerCopy: false,
                    order: order,
                  ),
                  printer: Preferences.counterPrinter,
                );
                Get.back();
              },
              text: " Merchant Copy",
              textColor: Colors.white,
            ),
          ],
        ),
        if (baseController.printImg != null) ...{
          const SizedBox(height: 16),
          Image.memory(baseController.printByteImgData!, width: 120),
          const SizedBox(height: 12),
        },

        _printText(
          (baseController.restaurantDetails?.restaurant.name ?? "")
              .toUpperCase(),
          fontSize: 36,
        ),
        const SizedBox(height: 14),
        _printText(
          (baseController.restaurantDetails?.restaurant.address ?? "")
              .replaceAll("_", "\n"),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        const SizedBox(height: 10),
        _printText(
          "Phone: ${baseController.restaurantDetails?.restaurant.phone.toFormattedPhone()}",
        ),
        const Divider(color: Colors.black, height: 18),
        Align(
          alignment: Alignment.topLeft,
          child: _printText("Check# ${order.orderId}"),
        ),

        Align(
          alignment: Alignment.topLeft,
          child: _printText(
            "Order Place: ${DateFormat('MMM dd,hh:mm a').format(order.createdAt!.toTimeZone())}",
            textAlign: TextAlign.left,
          ),
        ),
        // Row(
        //   children: [
        //     Expanded(child: ),
        //     const SizedBox(width: 6),
        //     Expanded(
        //         child: ),
        //   ],
        // ),
        Row(
          children: [
            Expanded(
              child: _printText(
                "Server:${MyFunc.stringNullCheck(order.employee?.firstName.toUpperCase())}",
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _printText(
                "${order.orderType.replaceAll('_', ' ')}: ${order.orderType != "TAKEOUT" ? MyFunc.stringNullCheck(order.tableName) : order.takeOutType?.replaceAll('_', ' ')}",
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: _printText(
                "Guest:${MyFunc.stringNullCheck(order.guestName)}",
                textAlign: TextAlign.left,
                fontWeight: FontWeight.w700,
                fontSize: 23,
              ),
            ),
            if (order.orderType != "TAKEOUT")
              _printText(
                "Total Guests:${order.numberOfPeople}",
                textAlign: TextAlign.right,
              ),
          ],
        ),
        if (order.guestPhoneNumber.isNotEmpty)
          Align(
            alignment: Alignment.topLeft,
            child: _printText(
              "Phone #: ${order.guestPhoneNumber.toFormattedPhone()}",
              textAlign: TextAlign.left,
              fontWeight: FontWeight.w700,
              fontSize: 23,
            ),
          ),
        if (order.tokenId.isNotEmpty)
          Align(
            alignment: Alignment.topLeft,
            child: _printText(
              "Token# ${order.tokenId}",
              textAlign: TextAlign.left,
            ),
          ),
        if ((order.orderType == "TAKEOUT" && order.takeOutType == "ONLINE") ||
            order.orderType == "DELIVERY")
          Align(
            alignment: Alignment.topLeft,
            child: _printText(
              '${order.orderType == "DELIVERY" ? "Delivery" : "Pickup"}:${order.estimatedDate.toFormattedDate()} ${order.estimatedTime.isEmpty ? "" : ", ${order.estimatedTime}"}',
              textAlign: TextAlign.left,
              maxLines: 100,
            ),
          ),
        if (order.notes.isNotEmpty)
          Align(
            alignment: Alignment.topLeft,
            child: _printText(
              "Notes: ${order.notes}",
              textAlign: TextAlign.left,
              maxLines: 100,
            ),
          ),
        if (order.delivery != null && order.orderType == "DELIVERY") ...[
          if (order.delivery?.address.isNotEmpty ?? false)
            Align(
              alignment: Alignment.topLeft,
              child: _printText(
                "Delivery Address: ${order.delivery?.address}",
                textAlign: TextAlign.left,
                maxLines: 5,

                fontWeight: FontWeight.w700,
                fontSize: 23,
              ),
            ),
          if (order.delivery?.additionalDetails.isNotEmpty ?? false)
            Align(
              alignment: Alignment.topLeft,
              child: _printText(
                "Additional Details: ${order.delivery?.additionalDetails}",
                textAlign: TextAlign.left,
                maxLines: 100,
              ),
            ),
        ],

        const SizedBox(height: 15),
        // !item header
        Row(
          children: [
            SizedBox(width: 50, child: _printText("Qty")),
            const SizedBox(width: 6),
            Expanded(child: _printText("Item")),
            const SizedBox(width: 6),
            _printText("Amt ", textAlign: TextAlign.right),
          ],
        ),
        const Divider(color: Colors.black, height: 18),
        // item
        // !item
        ...List.generate(
          order.carts.combineItems(isCustomerRecipt: true).length,
          (index) {
            var data = order.carts.combineItems()[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 50,
                  child: _printText(
                    "${data.quantity}",
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _printText(
                        (data.itemType == "weighing scale"
                                ? "${data.name}(${data.weight}LB)"
                                : data.name)
                            .toUpperCase(),
                        maxLines: 10,
                        textAlign: TextAlign.start,
                      ),
                      Visibility(
                        visible: data.discount.value > 0,
                        child: _printText(
                          "Discount: ${data.discount.displayValue}",
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _printText(
                  "\$${data.price.toStringAsFixed(2)}",
                  textAlign: TextAlign.start,
                ),
              ],
            ).marginOnly(bottom: 6);
          },
        ),

        const Divider(color: Colors.black, height: 18),
        // ! total calculation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _printText("Sub Total"),
            _printText("\$${order.subTotal.toStringAsFixed(2)}"),
          ],
        ),
        DotDivider(
          width: 2,
          height: 4,
          gap: 0,
          dotQuantity: 60,
          color: Colors.black,
        ),
        // ****** Discount ******
        Visibility(
          visible: order.totalDiscount > 0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _printText("Discount"),
                  _printText(
                    "(-)  \$${order.totalDiscount.toStringAsFixed(2)}",
                  ),
                ],
              ),
              DotDivider(
                width: 2,
                height: 4,
                gap: 0,
                dotQuantity: 60,
                color: Colors.black,
              ),
            ],
          ),
        ),
        //  ******  gst  *****
        Visibility(
          visible: order.totalGst > 0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _printText(
                    "GST ${BaseController.to.restaurantDetails?.businessProfile.gstNumber ?? 0}%",
                  ),
                  _printText("\$${order.totalGst.toStringAsFixed(2)}"),
                ],
              ),
              DotDivider(
                width: 2,
                height: 4,
                gap: 0,
                dotQuantity: 60,
                color: Colors.black,
              ),
            ],
          ),
        ),
        // ****** pst ******
        Visibility(
          visible: order.totalPst > 0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _printText(
                    "PST ${BaseController.to.restaurantDetails?.businessProfile.pstNumber ?? 0}%",
                  ),
                  _printText("\$${order.totalPst.toStringAsFixed(2)}"),
                ],
              ),
              DotDivider(
                width: 2,
                height: 4,
                gap: 0,
                dotQuantity: 60,
                color: Colors.black,
              ),
            ],
          ),
        ),
        // ****** pst 2******
        Visibility(
          visible: order.totalPst2 > 0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _printText(
                    "PST2 ${BaseController.to.restaurantDetails?.businessProfile.pstNumber2 ?? 0}%",
                  ),
                  _printText("\$${order.totalPst2.toStringAsFixed(2)}"),
                ],
              ),
              DotDivider(
                width: 2,
                height: 4,
                gap: 0,
                dotQuantity: 60,
                color: Colors.black,
              ),
            ],
          ),
        ),
        // ****** Gratuity ******
        Visibility(
          visible: order.totalGratuity > 0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _printText(
                    "Gratuity ${order.gratuityPercentage ?? (BaseController.to.restaurantDetails?.businessProfile.gratuity ?? 0)}% : ",
                  ),
                  _printText("\$${order.totalGratuity.toStringAsFixed(2)}"),
                ],
              ),
              DotDivider(
                width: 2,
                height: 4,
                gap: 0,
                dotQuantity: 60,
                color: Colors.black,
              ),
            ],
          ),
        ),
        // ****** Tip ******
        // Visibility(
        //   visible: order.tip > 0,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       _printText("Tip"),
        //       _printText("\$${order.tip.toStringAsFixed(2)}"),
        //     ],
        //   ),
        // ),

        // ****** delivery Free ******
        Visibility(
          visible: order.deliveryFee > 0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _printText("Delivery Fee"),
                  _printText("\$${order.deliveryFee.toStringAsFixed(2)}"),
                ],
              ),
              DotDivider(
                width: 2,
                height: 4,
                gap: 0,
                dotQuantity: 60,
                color: Colors.black,
              ),
            ],
          ),
        ),
        // ****** maintenanceFee ******
        Visibility(
          visible: order.maintenanceFee > 0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _printText("Service Fee"),
                  _printText("\$${order.maintenanceFee.toStringAsFixed(2)}"),
                ],
              ),
              DotDivider(
                width: 2,
                height: 4,
                gap: 0,
                dotQuantity: 60,
                color: Colors.black,
              ),
            ],
          ),
        ),
        // ****** packagingCost ******
        Visibility(
          visible: order.packagingCost > 0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _printText(
                    '${BaseController.to.restaurantDetails?.restaurant.packagingCost.title}',
                  ),
                  _printText("\$${order.packagingCost.toStringAsFixed(2)}"),
                ],
              ),
              DotDivider(
                width: 2,
                height: 4,
                gap: 0,
                dotQuantity: 60,
                color: Colors.black,
              ),
            ],
          ),
        ),
        // for payment
        if (order.paymentStatus == 'PAID') ...[
          // ! for tip (cash)
          if ((order.payment?.cashTipAmount ?? 0) > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _printText("Cash Tip"),
                _printText(
                  '\$${order.payment?.cashTipAmount.toStringAsFixed(2)}',
                ),
              ],
            ),
            DotDivider(
              width: 2,
              height: 4,
              gap: 0,
              dotQuantity: 60,
              color: Colors.black,
            ),
          ],
          // ! for tip (card)
          if ((order.payment?.cardTipAmount ?? 0) > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _printText("Card Tip"),
                _printText(
                  '\$${order.payment?.cardTipAmount.toStringAsFixed(2)}',
                ),
              ],
            ),
            DotDivider(
              width: 2,
              height: 4,
              gap: 0,
              dotQuantity: 60,
              color: Colors.black,
            ),
          ],

          // ! Total paid cash
          if ((order.payment?.cashPaidAmount ?? 0) > 0) ...[
            // if (order.payment?.method == 'CASH')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _printText("Paid by Cash"),
                _printText(
                  '\$${((order.payment?.cashPaidAmount ?? 0) + (order.payment?.change ?? 0) + (order.payment?.cashTipAmount ?? 0)).toStringAsFixed(2)}',
                ),
              ],
            ),
            DotDivider(
              width: 2,
              height: 4,
              gap: 0,
              dotQuantity: 60,
              color: Colors.black,
            ),
          ],

          // ! Total paid card
          if ((order.payment?.cardPaidAmount ?? 0) > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _printText(
                  'Paid by ${order.payment?.cardType == "" ? order.payment?.methods.join(', ').replaceAll('_', ' ') ?? "".toUpperCase() : order.payment?.cardType}',
                ),
                _printText(
                  '\$${((order.payment?.cardPaidAmount ?? 0) + (order.payment?.cardTipAmount ?? 0)).toStringAsFixed(2)}',
                ),
              ],
            ),
            DotDivider(
              width: 2,
              height: 4,
              gap: 0,
              dotQuantity: 60,
              color: Colors.black,
            ),
          ],
          // ! change
          if ((order.payment?.change ?? 0) > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _printText("Change"),
                _printText('\$${order.payment?.change.toStringAsFixed(2)}'),
              ],
            ),
            DotDivider(
              width: 2,
              height: 6,
              gap: 0,
              dotQuantity: 60,
              color: Colors.black,
            ),
          ],
        ],
        // ****** Total ******
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _printText("Total ${MyFunc.orderCondition(order)}", fontSize: 18),
            _printText(
              "\$${order.totalOrderAmount.toStringAsFixed(2)}",
              fontSize: 18,
            ),
          ],
        ),
        // !  end
        const Divider(color: Colors.black, height: 18),

        Visibility(
          visible:
              order.payment != null &&
              (order.payment?.maskedPan.isNotEmpty ?? false),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _printText("Card Number:", fontSize: 13),
              _printText('${order.payment?.maskedPan}', fontSize: 13),
            ],
          ).marginOnly(bottom: 5),
        ),
        Visibility(
          visible:
              order.payment != null &&
              (order.payment?.entryMode.isNotEmpty ?? false),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _printText("Payment Method:", fontSize: 13),
              _printText('${order.payment?.entryMode}', fontSize: 13),
            ],
          ).marginOnly(bottom: 5),
        ),
        Visibility(
          visible:
              order.payment != null &&
              (order.payment?.transactionId.isNotEmpty ?? false),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _printText("Approval Code:", fontSize: 13),
                  _printText('${order.payment?.transactionId}', fontSize: 13),
                ],
              ),
              const Divider(color: Colors.black, height: 18),
            ],
          ),
        ),

        _printText(
          "Customer Copy: ${order.paymentStatus == 'UNPAID' ? 'UNPAID' : '${order.payment?.methods.join(', ').replaceAll('_', ' ') ?? ""} Sale'}",
          fontSize: 13,
        ),
        const Divider(color: Colors.black, height: 18),
        _printText(
          "Thank you for visiting ${baseController.restaurantDetails?.restaurant.name.toUpperCase()}",
          fontSize: 13,
        ),
        const Divider(color: Colors.black, height: 18),
        _printText("Please review us on Google", fontSize: 13),
        // Divider(color: Colors.black, height: 18),
        // _printText("GST NUMBER: ${baseController.restaurantDetails?.}", fontSize: 13),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.center,
          child: _printText("Powered by ${Yogo.name}", fontSize: 10),
        ),
      ],
    );
  }

  MyCustomText _printText(
    String text, {
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.bold,
    TextAlign textAlign = TextAlign.start,
    int? maxLines,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) => MyCustomText(
    text,
    fontSize: fontSize,
    fontWeight: fontWeight,
    textAlign: textAlign,
    color: Colors.black,
    fontFamily: Fonts.secondary,
    fontStyle: fontStyle,
    maxLines: maxLines,
    decoration: decoration,
  );
}
