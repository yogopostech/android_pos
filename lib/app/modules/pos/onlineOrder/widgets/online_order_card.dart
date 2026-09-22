import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/views/order_details_view.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

import '../controllers/online_order_controller.dart';

import 'package:get/get.dart';

class OnlineOrderCard extends GetView<OnlineOrderController> {
  final OrderModel order;
  const OnlineOrderCard(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: () {
        PosController.to.myOrder = order;
        // PosController.to.isEditableItems = false;
        PosController.to.selectedItemList.clear();

        Get.to(() => const OrderDetailsView());
        // orderSeen
        if (order.orderSeen == false) {
          controller.onOrderSeen(order.id, orderSeen: true);
        }
      },
      // Double Tap and Long Press feature should be same
      // onDoubleTap: () {
      //   PosController.to.myOrder = order;
      //   // PosController.to.isEditableItems = false;
      //   PosController.to.selectedItemList.clear();

      //   Get.to(() => const OrderDetailsView());
      //   // orderSeen
      //   if (order.orderSeen == false) {
      //     controller.onOrderSeen(order.id, orderSeen: true);
      //   }

      //   // PopupDialog.customDialog(width: 300, child: OnlineOrderStatus(order));
      // },
      // onLongPress: () {
      //   PosController.to.myOrder = order;
      //   // PosController.to.isEditableItems = false;
      //   PosController.to.selectedItemList.clear();

      //   Get.to(() => const OrderDetailsView());
      //   // orderSeen
      //   if (order.orderSeen == false) {
      //     controller.onOrderSeen(order.id, orderSeen: true);
      //   }
      // },
      child: Container(
          height: 120,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
              color: order.orderSeen != false
                  ? const Color.fromARGB(48, 107, 107, 107)
                  : StaticColors.blueColor.withAlpha(50),
              border: Border(
                  bottom: BorderSide(color: theme.dividerColor, width: 1))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // icon area
              CircleAvatar(
                backgroundColor: controller.getStatusColor(order.orderStatus),
                radius: 15,
                child: const Icon(
                  Icons.business_center,
                  color: Colors.white,
                  size: 15,
                ),
              ),
              12.width,
              //leading area
              Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   '# ${order.orderId}',
                      //   style: theme.textTheme.titleSmall,
                      //   maxLines: 1,
                      // ),
                      Text(
                        'Name: ${MyFunc.capitalizeEachWord(s: order.guestName)}',
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                      ),
                       Text(
                        'Phone: ${order.guestPhoneNumber}',
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                      ),
                      Text(
                        'Token: ${order.tokenId}',
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                      ),
                      Text(
                        'Placed: ${order.createdAt.toStringAsSecondaryFormat()}',
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                      ),
                      Text(
                        "Pickup: ${order.estimatedDate.toFormattedDate()}, ${order.estimatedTime}",
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                      ),
                    ],
                  )),
              Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${order.totalOrderAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                      ),
                      const Spacer(),
                      //todo: need to dynamic
                      Text(
                        order.oloPaymentType == "PAY LOCATION"
                            ? "PAY AT LOCATION"
                            : order.oloPaymentType,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )),
            ],
          )),
    );
  }
}
