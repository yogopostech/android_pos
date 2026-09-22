import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/auth/controllers/auth_controller.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/routes/app_pages.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class AppHelper {
  static void restartApp() {
    if (!kDebugMode) {
      try {
        // Get the current executable's path
        final executable = Platform.resolvedExecutable;
        final arguments = Platform.executableArguments;
        // Relaunch the app
        Process.start(executable, arguments).then((_) {
          // Close the current instance
          exit(0);
        });
      } catch (e) {
        PopupDialog.showErrorMessage('Error while restarting app: $e');
      }
    }
  }

  static void exitApp() {
    if (!kDebugMode) {
      exit(0);
    }
  }

  static Future<void> logout() async {
    AuthController.to.isShowSplashScreen.value = false;
    Get.offAllNamed(Routes.AUTH);
    await Future.delayed(Duration(milliseconds: 1300), () {
      Get.delete<PosController>(force: true);
    });
  }
}
