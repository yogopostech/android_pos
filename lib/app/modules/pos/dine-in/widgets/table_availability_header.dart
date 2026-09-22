import 'package:flutter/material.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import '../../../../widgets/my_custom_text.dart';

class TableAvailabilityHeader extends StatelessWidget {
  const TableAvailabilityHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const MyCustomText(
          ' Table Availability',
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(width: 10.0),
        ColorTextRow(
          color: MyFunc.getTableColorWithStatus("AVAILABLE"),
          text: 'Available'.toUpperCase(),
        ),
        ColorTextRow(
          color: MyFunc.getTableColorWithStatus("SERVING"),
          text: 'SERVING',
        ),
        ColorTextRow(
          color: MyFunc.getTableColorWithStatus("HOLD_TABLES"),
          text: 'Hold Tables'.toUpperCase(),
        ),
      ],
    );
  }
}

class ColorTextRow extends StatelessWidget {
  const ColorTextRow({
    super.key,
    required this.color,
    required this.text,
  });

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 8,
            backgroundColor: color,
          ),
          const SizedBox(width: 4.0),
          Text(
            text,
            style: theme.textTheme.titleSmall,
          )
          // MyCustomText(
          //   text,
          //   fontWeight: FontWeight.w500,
          // ),
        ],
      ),
    );
  }
}
