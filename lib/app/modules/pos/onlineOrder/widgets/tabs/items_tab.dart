import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/dotted_bottom_border_painter.dart';
import 'package:yogo_pos/app/utils/extension/string_manipulation_extension.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';

class ItemsTab extends StatelessWidget {
  final OrderModel order;
  const ItemsTab(
    this.order, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        6.height,
        Text.rich(TextSpan(
            text: "NOTE: ",
            style: theme.textTheme.labelMedium,
            children: [
              TextSpan(
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontStyle: FontStyle.italic),
                  text: order.notes.toCapitalizeEachWord())
            ])),
        6.height,
        //header
        _row(
          theme,
          qty: "Qty",
          value: "Price",
          name: "Item",
          fontWeight: FontWeight.w700,
          verticalPadding: 4,
          dashSpace: 0,
        ),
        // items
        ...List.generate(order.carts.length, (index) {
          return _card(theme,
              card: order.carts[index],
              dashSpace: order.carts.length - 1 == index ? 0 : 5);
        }),
        // calculation
        _row(theme,
            name: "Subtotal : ",
            value: "\$${order.subTotal.toStringAsFixed(2)}",
            isDivider: false,
            verticalPadding: 3,
            fontWeight: FontWeight.w600),
        Visibility(
          visible: order.totalGst > 0,
          child: _row(theme,
              name:
                  "GST ${BaseController.to.restaurantDetails?.businessProfile.gstNumber ?? 0}% : ",
              value: "\$${order.totalGst.toStringAsFixed(2)}",
              isDivider: false,
              verticalPadding: 0,
              fontWeight: FontWeight.w600),
        ),
        Visibility(
          visible: order.totalGratuity > 0,
          child: _row(theme,
              name:
                  "Gratuity ${BaseController.to.restaurantDetails?.businessProfile.gratuity ?? 0}% : ",
              value: "\$${order.totalGratuity.toStringAsFixed(2)}",
              isDivider: false,
              verticalPadding: 0,
              fontWeight: FontWeight.w600),
        ),
        Visibility(
          visible: order.totalPst > 0,
          child: _row(theme,
              name:
                  "PST ${BaseController.to.restaurantDetails?.businessProfile.pstNumber ?? 0}% : ",
              value: "\$${order.totalPst.toStringAsFixed(2)}",
              isDivider: false,
              verticalPadding: 0,
              fontWeight: FontWeight.w600),
        ),
        Visibility(
          visible: order.totalPst2 > 0,
          child: _row(theme,
              name:
                  "PST2 ${BaseController.to.restaurantDetails?.businessProfile.pstNumber2 ?? 0}% : ",
              value: "\$${order.totalPst2.toStringAsFixed(2)}",
              isDivider: false,
              verticalPadding: 0,
              fontWeight: FontWeight.w600),
        ),
        Visibility(
          visible: order.tip > 0,
          child: _row(theme,
              name: "Tip : ",
              value: "\$${order.tip.toStringAsFixed(2)}",
              isDivider: false,
              verticalPadding: 0,
              fontWeight: FontWeight.w600),
        ),
        Visibility(
          visible: order.totalDiscount > 0,
          child: _row(theme,
              name: "Discount : ",
              value: "\$${order.totalDiscount.toStringAsFixed(2)}",
              isDivider: false,
              verticalPadding: 0,
              fontWeight: FontWeight.w600),
        ),
        Visibility(
          visible: order.packagingCost > 0,
          child: _row(theme,
              name:
                  "${(BaseController.to.restaurantDetails?.restaurant.packagingCost.title) ?? ""}: ",
              value: "\$${order.packagingCost.toStringAsFixed(2)}",
              isDivider: false,
              verticalPadding: 0,
              fontWeight: FontWeight.w600),
        ),
        // const Divider(
        //   thickness: .5,
        // ),8
        _row(theme,
            name: "Total : ",
            value: "\$ ${order.totalOrderAmount.toStringAsFixed(2)}",
            dashSpace: 0,
            isDivider: false,
            fontWeight: FontWeight.w900,
            fontSize: 18),
      ],
    );
  }

  Widget _row(ThemeData theme,
      {String? qty,
      required String value,
      String? name,
      double verticalPadding = 8,
      double dashSpace = 5,
      double? fontSize,
      bool isDivider = true,
      FontWeight? fontWeight}) {
    return CustomPaint(
      painter: DottedBottomBorderPainter(
          color: isDivider ? theme.dividerColor : Colors.transparent,
          dashSpace: dashSpace),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: Row(
          children: [
            if (qty != null)
              SizedBox(
                width: 60,
                child: Text(
                  qty,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: fontWeight, fontSize: fontSize),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? "",
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: fontWeight, fontSize: fontSize),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: fontWeight, fontSize: fontSize),
            )
          ],
        ),
      ),
    );
  }

  Widget _card(ThemeData theme,
      {required CartModel card,
      double verticalPadding = 8,
      double dashSpace = 5,
      bool isDivider = true,
      FontWeight? fontWeight}) {
    return CustomPaint(
      painter: DottedBottomBorderPainter(
          color: isDivider ? theme.dividerColor : Colors.transparent,
          dashSpace: dashSpace),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                card.quantity.toString(),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: fontWeight),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.name,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: fontWeight),
                  ),
                  // const SizedBox(height: 4),
                  ...List.generate(card.variationOptions.length, (index) {
                    var optionData = card.variationOptions[index];

                    return Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "${optionData.name.toCapitalizeEachWord()}: ",
                            style: theme.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "\$${optionData.price.toStringAsFixed(2)}",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    );
                  }),
                  //modifiers
                  const SizedBox(height: 4),
                  ...List.generate(card.modifiers.length, (index) {
                    return Row(
                      children: [
                        Flexible(
                          child: Text(
                            card.modifiers[index].trim().toUpperCase(),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ).marginOnly(right: 10);
                  }),
                ],
              ),
            ),
            Text(
              card.price.toStringAsFixed(2),
              style:
                  theme.textTheme.bodyMedium?.copyWith(fontWeight: fontWeight),
            )
          ],
        ),
      ),
    );
  }
}
