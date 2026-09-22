import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/pos/onlineOrder/controllers/online_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/utils/extension/string_manipulation_extension.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';


class OnlineOrderStatus extends GetView<OnlineOrderController> {
  final OrderModel order;
  const OnlineOrderStatus(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'Change Status',
          style: theme.textTheme.titleLarge,
        ),
        const Divider(
          height: 10,
        ),
        ...List.generate(controller.orderType.length, (index) {
          return PrimaryBtn(
            onPressed: () {
              controller.updateOrder(order.id,
                  orderStatus: controller.orderType[index]);
            },
            width: double.infinity,
            text: controller.orderType[index].toCapitalize(),
            textColor:
                order.orderStatus == controller.orderType[index].toUpperCase()
                    ? Colors.white
                    : Colors.black,
            color:
                order.orderStatus == controller.orderType[index].toUpperCase()
                    ? StaticColors.orangeColor
                    : Colors.transparent,
            // textColor: ,
          );
        })
      ],
    );
  }
}
