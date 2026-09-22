import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/utils/dotted_bottom_border_painter.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';

class LogTab extends StatelessWidget {
  const LogTab({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      children: List.generate(5, (index) {
        return CustomPaint(
          painter: DottedBottomBorderPainter(
              color: theme.dividerColor, dashSpace: 4),
          child: SizedBox(
            // padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 15,
                      child: Text(
                        "12",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: Text(
                        'Updated Status',
                        style: theme.textTheme.titleMedium,
                      ),
                    )
                  ],
                ),
                8.height,
                Text(
                  'Updated from ready to complete',
                  style: theme.textTheme.bodyMedium,
                ),
                8.height,
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: theme.cardColor),
                      child: Text(
                        '12/12/23, 12:12pm',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: theme.cardColor),
                      child: Text(
                        'abc@gmail.com',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  ],
                ),
                12.height
              ],
            ),
          ),
        ).marginOnly(bottom: 10);
      }),
    );
  }
}
