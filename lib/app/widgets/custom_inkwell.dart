// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';

class CustomInkWell extends StatelessWidget {
  const CustomInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongTap,
  });

  final Widget child;
  final Function()? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              BaseController.to.playTapSound();
              onTap!();
            },
      onDoubleTap: onDoubleTap,
      onLongPress: onLongTap,
      child: child,
    );
  }
}
