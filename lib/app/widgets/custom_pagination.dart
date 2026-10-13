import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:pagination_flutter/pagination.dart';

class CustomPagination extends StatelessWidget {
  final int numOfPages;
  final int selectedPage;
  final int pagesVisible;
  final Function onPageChanged;
  const CustomPagination(
      {super.key,
      required this.numOfPages,
      required this.selectedPage,
      required this.pagesVisible,
      required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Pagination(
      numOfPages: numOfPages,
      selectedPage: selectedPage,
      pagesVisible: 5,
      onPageChanged: onPageChanged,
      nextIcon: Icon(
        Icons.arrow_forward_ios,
        color: StaticColors.blueColor,
        size: 14.r,
      ),
      previousIcon: Icon(
        Icons.arrow_back_ios,
        color: StaticColors.blueColor,
        size: 14.r,
      ),
      activeTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
      ),
      activeBtnStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(StaticColors.blueColor),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
      ),
      inactiveBtnStyle: ButtonStyle(
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(38.r),
        )),
      ),
      inactiveTextStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: theme.textTheme.labelLarge?.color,
      ),
    );
  }
}
