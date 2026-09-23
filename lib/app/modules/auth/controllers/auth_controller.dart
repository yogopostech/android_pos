import 'dart:async';
import 'package:yogo_pos/app/modules/clockIn/providers/clock_in_out.dart';
import 'package:yogo_pos/app/modules/clockIn/widgets/clock_in_dialog.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/repo/pos_repo.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/elavon-cws/providers/cws_credentials_provider.dart';
import 'package:yogo_pos/app/routes/app_pages.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/main.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  //splash screen
  RxBool isShowSplashScreen = true.obs;
  void hideSplashScreen() {
    Timer(const Duration(milliseconds: 2500), () {
      isShowSplashScreen.value = false;
    });
  }

  //Hide Password pad on inactivity
  Timer? inactivityTimer;
  void startInactivityTimer() {
    inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick > 5) {
        toggleStartup(true);
      }
    });
  }

  //startup logo screen
  RxBool isStartup = true.obs;
  void toggleStartup(bool value) {
    isStartup.value = value;
    if (!value) {
      inactivityTimer?.cancel();
      startInactivityTimer();
    } else {
      inactivityTimer?.cancel();
      password.value = "";
    }
  }

  RxString password = "".obs;
  RxInt passwordLength = 6.obs;
  List<String> numberList = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "*",
    "0",
    "*",
  ];

  // **** Login *****

  void login() async {
    if (password.value.isEmpty) return;

    try {
      PopupDialog.showLoadingDialog();
      final data = {"loginPin": int.tryParse(password.value)};
      if (data["loginPin"] == null) {
        PopupDialog.closeLoadingDialog();
        PopupDialog.showErrorMessage("Invalid PIN format.");
        return;
      }

      final res = await BaseController.to.apiService.makePostRequest(
        URLS.employeeLogin,
        data,
      );
      PopupDialog.closeLoadingDialog();

      if (res.statusCode == 200 && res.data["data"] != null) {
        //auth code
        print(res.data["data"]["employee"].toString());
        password.value = "";
        Preferences.accessToken = res.data["data"]["accessToken"];
        await BaseController.to.setEmployeeData(res.data["data"]["employee"]);
        BaseController.to.isEntryView = true;
        // clockIn logic
        // if ((BaseController.to.employeeData?.allowClockInOut ?? false) &&
        //     BaseController.to.employeeData?.activeClock == null) {
        //   // If the restaurant allows clock in/out or the employee is not clocked in, navigate to the clock in screen
        //   Get.toNamed(Routes.CLOCK_IN);
        // } else {
        if ((BaseController.to.restaurantDetails?.employeeClockInOut ??
                false) &&
            (BaseController.to.employeeData?.allowClockInOut ?? false) &&
            BaseController.to.employeeData?.activeClock == null) {
          Future.delayed(Duration(seconds: 3), () {
            PopupDialog.customDialog2(
              barrierDismissible: false,
              width: 550,
              child: const ClockInDialog(),
            );
          });
        } else if ((BaseController.to.restaurantDetails?.employeeClockInOut ??
                false) &&
            (BaseController.to.employeeData?.allowClockInOut ?? false)) {
          final time = MyFunc.calculateSecondsFrom(
            BaseController.to.employeeData?.activeClock?.clockIn,
          );
          providerContainer
              .read(clockInOutProvider.notifier)
              .clockIn(seconds: time);
        }

        Get.offAllNamed(Routes.POS);
        await BaseController.to.getRestaurantsDetailsFromAPI();
        // ConfigController.to.getPrinters();
        PosController.to.orderTypeList = PosRepo.getOrderType();
        PosController.to.clearCartList();
        PosController.to.isItemsShow = false;
        if (PosController.to.orderTypeList.isNotEmpty) {
          PosController.to.orderType = PosController.to.orderTypeList.first;
        }
        PosController.to.onFocusGuestName();
        

        //auth code
        // clockIn logic
        // if (BaseController.to.employeeData?.activeClock == null) {
        //   Get.offAllNamed(Routes.CLOCK_IN);
        // } else {
        //   if (!Get.isRegistered<ClockInController>()) {
        //     Get.put(ClockInController(), permanent: true);
        //   }
        //   final time = BaseController.to.employeeData?.activeClock?.clockIn;
        //   BaseController.to.clockInSeconds = MyFunc.calculateSecondsFrom(time);
        //   BaseController.to.update();
        //   ClockInController.to.startclockIn();
        // }
        // clockIn logic
      } else if (res.statusCode == 500) {
        PopupDialog.showErrorMessage("Server Error");
      } else {
        PopupDialog.showErrorMessage(res.data["message"] ?? "Login failed.");
      }
    } catch (e, stack) {
      kLogger.e('Error from %%%% login %%%% => $e\n$stack');
      PopupDialog.closeLoadingDialog();
      PopupDialog.showErrorMessage("An error occurred during login.");
    }
  }

  removePassword() {
    if (password.value.isNotEmpty) {
      password.value = password.value.substring(0, password.value.length - 1);
    }
  }

  addPassword(String characterToAdd) {
    if (password.value.length < 6) {
      password.value += characterToAdd;
      // kLogger.e(password.value);
    }
  }

  @override
  void onInit() {
    hideSplashScreen();
    super.onInit();
  }
}
