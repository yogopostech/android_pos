// loader_overlay.dart (ba kothao common e rakho)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

void showAppLoader() {
  if (Get.isDialogOpen ?? false) return;
  Get.dialog(
    const PopScope(
      canPop: false,
      child: Center(
        child: SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(StaticColors.orangeColor),
          ),
        ),
      ),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black54,
  );
}

void hideAppLoader() {
  if (Get.isDialogOpen ?? false) Get.back();
}
