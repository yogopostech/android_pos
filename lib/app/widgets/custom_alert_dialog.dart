import 'package:flutter/material.dart';

void customAlertDialog({
  required BuildContext context,
  required Widget child,
  // EdgeInsetsGeometry? titlePadding,
  EdgeInsetsGeometry? contentPadding,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 50),
    pageBuilder: (context, anim1, anim2) {
      return const SizedBox();
    },
    transitionBuilder: (context, anim1, anim2, _) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.5, end: 1).animate(anim1),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.5, end: 1).animate(anim1),
          child: AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            // titlePadding: titlePadding ??
            //     const EdgeInsets.only(left: 0, top: 32, right: 0, bottom: 16),
            contentPadding: contentPadding ??
                const EdgeInsets.only(left: 16, top: 26, right: 16, bottom: 16),
            content: child,
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: const BorderSide(color: Colors.white, width: 1.25),
            ),
          ),
        ),
      );
    },
  );
}
