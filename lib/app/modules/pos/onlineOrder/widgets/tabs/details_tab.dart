import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';

class DetailsTab extends StatelessWidget {
  final OrderModel order;
  const DetailsTab(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      children: [
        //order detailts
        _row(theme, title: "Type: ", value: order.takeOutType ?? ""),
        _row(theme,
            title: "Payment Method: ",
            value: order.oloPaymentType == "PAY LOCATION"
                ? "PAY AT LOCATION"
                : order.oloPaymentType),
        // _row(theme, title: "Payment Type: ", value: order.splitPaymentMethods.),
        _row(theme, title: "Payment Status: ", value: order.paymentStatus),
        _row(theme,
            title: "Placed: ",
            value: order.createdAt.toStringAsPrimaryFormat()),
        _row(theme, title: "Name: ", value: order.guestName.toUpperCase()),
        _row(theme, title: "E-mail: ", value: order.guestEmail),
        _row(theme, title: "Phone: ", value: order.guestPhoneNumber),
      ],
    );
  }

  Widget _row(ThemeData theme,
      {required String title, required String value, Color? valueColor}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.labelMedium?.copyWith(color: valueColor),
              )
            ],
          ),
        ),
        Divider(
          thickness: 1,
          color: theme.dividerColor,
          height: 10,
        ),
      ],
    );
  }
}
