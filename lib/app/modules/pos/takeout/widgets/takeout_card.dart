import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';

class TakeoutCard extends StatelessWidget {
  final Function()? onTap;
  final OrderModel order;
  const TakeoutCard({super.key, this.onTap, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 170,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: order.paymentStatus == "PAID"
              ? StaticColors.greenColor
              : StaticColors.yellowColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // guest name
            Row(
              children: [
                Expanded(
                  child: MyCustomText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    MyFunc.capitalizeEachWord(s: order.guestName),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                MyCustomText(
                  "\$${order.totalOrderAmount.toStringAsFixed(2)}",
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(height: 4),
            Visibility(
              visible: order.guestPhoneNumber.isNotEmpty,
              child: MyCustomText(
                "# ${order.guestPhoneNumber}",
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ).marginOnly(bottom: 6),
            ),
            Text.rich(
              maxLines: 1,
              TextSpan(
                text: "Date: ",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: order.createdAt != null
                        ? DateFormat('MMM dd, yyyy;  hh:mm a')
                            .format(order.createdAt!.toTimeZone())
                        : "",
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            MyCustomText(
              "Check ID: ${order.orderId}",
              fontSize: 16,
              color: Colors.white,
            ),
            MyCustomText(
              "Token ID: ${order.tokenId}",
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ).marginSymmetric(vertical: 4),

            // guest phone number

            Visibility(
              visible: order.notes.isNotEmpty,
              child: Text.rich(
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                TextSpan(
                  text: "Notes: ",
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: Colors.white),
                  children: [
                    TextSpan(
                      // text: loremIpsum(words: 60),
                      text: order.notes,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
