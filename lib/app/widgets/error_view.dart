import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(
          FontAwesomeIcons.triangleExclamation,
          color: StaticColors.yellowColor,
          size: 38.r,
        ),
        SizedBox(height: 8.r),
        Text(
          'Select Category',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
