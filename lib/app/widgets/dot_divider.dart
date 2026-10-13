import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DotDivider extends StatelessWidget {
  final double? width;
  final double? height;
  final double? gap;
  final double? thickness;
  final int? dotQuantity;
  final Color? color;

  const DotDivider(
      {super.key,
      this.width,
      this.height,
      this.thickness,
      this.dotQuantity,
      this.color,
      this.gap});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height ?? 4.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(dotQuantity ?? 100, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: gap ?? 2.0.r),
            child: Container(
              width: width ?? 4.0.r,
              height: thickness ?? 1.5,
              decoration: BoxDecoration(
                color: color ?? theme.textTheme.bodyLarge?.color,
                // shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}
