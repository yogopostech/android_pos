import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/config/fonts.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/dot_divider.dart';
import 'package:get/get.dart';


class SummaryDialog extends StatefulWidget {
  final OrderModel order;
  const SummaryDialog({super.key, required this.order});

  @override
  State<SummaryDialog> createState() => _SummaryDialogState();
}

class _SummaryDialogState extends State<SummaryDialog> {
  bool isDineIn = true;

  toggleButtons(bool v) {
    setState(() {
      isDineIn = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrimaryBtn(
              onPressed: () async {
                toggleButtons(true);
              },
              color: StaticColors.greenColor,
              isOutline: isDineIn ? true : false,
              borderColor: StaticColors.orangeColor,
              width: 180,
              text: "Dine-in",
              textColor: Colors.white,
            ),
            const SizedBox(width: 6),
            PrimaryBtn(
              onPressed: () async {
                toggleButtons(false);
              },
              color: StaticColors.blueColor,
              isOutline: !isDineIn ? true : false,
              borderColor: StaticColors.orangeColor,
              width: 180,
              text: "TakeOut",
              textColor: Colors.white,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // ! My summary
        _mySummary(theme),

        PrimaryBtn(
          onPressed: () async {
            // final printerName =  Preferences.counterPrinter;
            // if (printerName.isNotEmpty) {
            //   await PrintUtils().directPrint(
            //       child: await summaryPrintReceipt(), printerName: printerName);
            //   Get.back();
            // }
          },
          text: "Print",
          width: 100,
          textColor: Colors.white,
        ).marginOnly(top: 22)
      ],
    );
  }
}

Widget _mySummary(ThemeData theme) {
  var labelLarge = theme.textTheme.labelLarge?.copyWith(
      fontFamily: Fonts.secondary, fontWeight: FontWeight.bold, fontSize: 15);
  return Column(
    children: [
      Text(
        "Check Summary For HAVELI",
        style: theme.textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
      Text(
        "08/10/2024      09:43:08 AM",
        style: labelLarge,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 22),
      Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "Check",
              style: labelLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 150,
            child: Text(
              "Total",
              style: labelLarge,
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Payments",
                style: labelLarge,
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
      Divider(
        color: theme.textTheme.bodyLarge?.color,
      ),
      const SizedBox(height: 12),
      // ! Item
      ...List.generate(9, (index) {
        // var data = order.carts[index];
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    "042342",
                    style: labelLarge,
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 100,
                  child: Text(
                    "\$ 23.3",
                    style: labelLarge,
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "MasterCard: \$1,072.41",
                        style: labelLarge,
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        "Tips: (\$1,000.00)",
                        style: labelLarge,
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                )
              ],
            ),
            Visibility(
              visible: 8 != index,
              child: const SizedBox(
                  // width: double.infinity,
                  child: DotDivider(
                height: 8,
                width: 6,
                dotQuantity: 30,
              )),
            ),
          ],
        );
      }),
      Divider(
        color: theme.textTheme.bodyLarge?.color,
        height: 18,
      ),
    ],
  );
}
