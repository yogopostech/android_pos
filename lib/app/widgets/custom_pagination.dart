import 'package:flutter/material.dart';
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
      nextIcon: const Icon(
        Icons.arrow_forward_ios,
        color: StaticColors.blueColor,
        size: 14,
      ),
      previousIcon: const Icon(
        Icons.arrow_back_ios,
        color: StaticColors.blueColor,
        size: 14,
      ),
      activeTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      activeBtnStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(StaticColors.blueColor),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      inactiveBtnStyle: ButtonStyle(
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(38),
        )),
      ),
      inactiveTextStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: theme.textTheme.labelLarge?.color,
      ),
    );
  }
}
