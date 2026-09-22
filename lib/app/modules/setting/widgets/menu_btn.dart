import 'package:flutter/material.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

class MenuBtn extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final bool isShow ;
  final Function()? onTap;
  const MenuBtn({
    super.key,
    required this.icon,
    required this.title,
    required this.isActive,
    required this.isShow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    if (!isShow) {
      return const SizedBox.shrink();
    }
    return  InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: isActive ? StaticColors.blueColor : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: isActive ? Colors.white : null),
            ),
          ],
        ),
      ),
    );
  }
}
