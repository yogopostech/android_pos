import 'package:flutter/material.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:get/get.dart';

import '../controllers/dine_in_order_controller.dart';

class OrderTableHeader extends StatelessWidget {
  const OrderTableHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    const double titleFontSize = 13;
    const double gap = 2;
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            width: 2,
            color: theme.colorScheme.surface,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      margin: const EdgeInsets.only(bottom: 28),
      child: Obx(() {
        return Row(
          children: [
            const SizedBox(
                width: 50,
                child: MyCustomText(
                  'No',
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(width: gap),
            const Expanded(
                child: Center(
              child: MyCustomText(
                'Order No.',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            )),
            const SizedBox(width: gap),
            const Expanded(
                child: Center(
              child: MyCustomText(
                'Server',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            )),
            if (DineInOrderController.to.selectedOrderType=="DINE_IN") ...{
              const SizedBox(width: gap),
              const Expanded(
                  child: Center(
                child: MyCustomText(
                  'Table',
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              )),
            },
            // const SizedBox(width: gap),
            const SizedBox(
                width: 200,
                child: Center(
                  child: MyCustomText(
                    'OPT',
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                )),
            // const SizedBox(width: gap),
            const SizedBox(
                width: 200,
                child: Center(
                  child: MyCustomText(
                    'OCT',
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                )),
            // const SizedBox(width: gap),
            const Expanded(
                child: Center(
              child: MyCustomText(
                'Order Type',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            )),
            const SizedBox(width: gap),
            const Expanded(
                child: Center(
              child: MyCustomText(
                'Payment Method',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            )),
            const SizedBox(width: gap),
            const Expanded(
                flex: 2,
                child: Center(
                  child: MyCustomText(
                    'Order Status',
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                )),
            const SizedBox(width: gap),
            const Expanded(
                child: Center(
              child: MyCustomText(
                'Tip',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            )),
            const SizedBox(width: gap),
            const Expanded(
                child: Center(
              child: MyCustomText(
                'Discount',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            )),
            const SizedBox(width: gap),
            const Expanded(
                child: Center(
              child: MyCustomText(
                'GST',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            )),
            const SizedBox(width: gap),
            const Expanded(
                child: Center(
              child: MyCustomText(
                'PST',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            )),
            const SizedBox(width: gap),
            const Expanded(
                child: Center(
              child: MyCustomText(
                'Gratuity',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            )),
            const SizedBox(width: gap),
            const Expanded(
                child: Center(
              child: MyCustomText(
                'Rounded',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            )),
            if (DineInOrderController.to.selectedOrderType=="TAKEOUT") ...{
              const SizedBox(width: gap),
              Expanded(
                  child: Center(
                child: MyCustomText(
                  '${BaseController.to.restaurantDetails?.restaurant.packagingCost.title}',
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              )),
            },
            const SizedBox(width: gap),
            const Expanded(
                child: Center(
              child: MyCustomText(
                'Refund',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            )),
            const SizedBox(width: gap),
            const Expanded(
                child: Center(
              child: MyCustomText(
                'Recall',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            )),
            const SizedBox(width: gap),
            const Expanded(
                child: Center(
              child: MyCustomText(
                'Subtotal',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            )),
            const SizedBox(width: gap),
            const Expanded(
                child: Center(
              child: MyCustomText(
                'Paid Amount',
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            )),
            const SizedBox(width: gap),
            const SizedBox(
                width: 100,
                child: Center(
                  child: MyCustomText(
                    'Actions',
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                )),
          ],
        );
      }),
    );
  }
}
