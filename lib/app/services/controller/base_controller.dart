import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/models/employee_model.dart';
import 'package:yogo_pos/app/services/base/base_model.dart';
import 'package:yogo_pos/app/services/models/delivery_model.dart';
import 'package:yogo_pos/app/services/models/restaurant_model.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import '../base/api_service.dart';
import '../base/preferences.dart';
import '../models/restaurant_details_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

class BaseController extends GetxController {
  static BaseController get to => Get.find();
  int clockInSeconds = 0;
  bool isSocketConnected = false;
  final ApiService apiService;
  BaseController({required this.apiService});
  EmployeeModel? employeeData;
  RestaurantDetailsModel? restaurantDetails;
  bool hybridPaymen = false;
  bool posElavonTerminal = false;
  bool posMonerisTerminal = false;
  bool posElavonCws = false;
  bool allowCallerIdTypeChange = false;

  PosDisplayMode posDisplayMode = PosDisplayMode.itemsOnly;
  CallerIdType callerIdType = CallerIdType.typeOne;

  pw.MemoryImage? printImg;
  Uint8List? printByteImgData;

  bool get isFirstTime => Preferences.isFirstTime;
  set isFirstTime(bool isFirstTime) => Preferences.isFirstTime = isFirstTime;
  bool get isLoggedIn => Preferences.accessToken.isNotEmpty;
  set token(String token) => Preferences.accessToken = token;
  PackageInfo? packageInfo;

  getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    update();
  }

  // late List<Printer> prints;

  late DateTimeRange dateRange;

  //! +++++ Employee +++++
  setEmployeeData(Map<String, dynamic> userData) async {
    // Convert the Map to a JSON string
    String userDataJson = jsonEncode(userData);
    // Save the JSON string
    Preferences.user = userDataJson;
    await saveEmployeeData();
    update();
  }

  DateTime getReportMinDate() {
    final report = employeeData?.posSummaryReport;
    if (report == null || !report.enabled) {
      return DateTime(2025);
    }
    final now = DateTime.now();
    final months = switch (report.reportPeriod) {
      ReportPeriod.last3Months => 3,
      ReportPeriod.last6Months => 6,
      ReportPeriod.last12Months => 12,
    };
    final target = DateTime(now.year, now.month - months, 1);
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    return DateTime(
      target.year,
      target.month,
      now.day <= lastDay ? now.day : lastDay,
    );
  }

  //! +++++ has caller id +++++
  RxBool hasCallerId = false.obs;
  RxBool isCallerIdLocal = false.obs;
  bool hasNewCall = false;

  Future<EmployeeModel?> saveEmployeeData() async {
    // Get the JSON string
    String employeeJson = Preferences.user;

    if (employeeJson.isNotEmpty) {
      // Convert the JSON string back to an EmployeeModel
      Map<String, dynamic> employeeMap = jsonDecode(employeeJson);

      var employee = EmployeeModel.fromJson(employeeMap);
      employeeData = employee;

      // print("zzz${employee.toJson()}");
      return employee;
    }
    return null;
  }

  Future<void> onUpdateRestrurent(bool hybridPaymentOption) async {
    var data = {"hybridPaymentOption": hybridPaymentOption};
    PopupDialog.showLoadingDialog();
    var res = await BaseController.to.apiService.makePatchRequest(
      URLS.restrurentUpdate,
      data,
    );
    PopupDialog.closeLoadingDialog();
    if (res.statusCode == 200) {
      update();
      DataUpdateHelper.allGetApiCall();
    }
  }

  //! +++++ Restaurant Details +++++
  setRestaurantDetails(Map<String, dynamic> userData) async {
    // Convert the Map to a JSON string
    String userDataJson = jsonEncode(userData);
    // Save the JSON string
    Preferences.restaurantDetails = userDataJson;

    await getRestaurantDetails();

    update();
  }

  Future<RestaurantDetailsModel?> getRestaurantDetails() async {
    try {
      // Get the JSON string
      String stringData = Preferences.restaurantDetails;

      if (stringData.isNotEmpty) {
        // Convert the JSON string back to an EmployeeModel
        Map<String, dynamic> restaurantDetailsAsMap = jsonDecode(stringData);

        var restaurant = RestaurantDetailsModel.fromJson(
          restaurantDetailsAsMap,
        );

        restaurantDetails = restaurant;
        hybridPaymen = restaurant.restaurant.hybridPaymentOption;
        posElavonTerminal = restaurant.restaurant.posElavonTerminal;
        posMonerisTerminal = restaurant.restaurant.posMonerisTerminal;
        posElavonCws = restaurant.restaurant.posElavonCws;
        allowCallerIdTypeChange = restaurant.restaurant.allowCallerIdTypeChange;
        // display mode
        if (restaurant.restaurant.posCategoryDisplayMode !=
            PosDisplayMode.both) {
          posDisplayMode = restaurant.restaurant.posCategoryDisplayMode;
          Preferences.posDisplayMode = posDisplayMode;
        }
        // caller id type
        if (restaurant.restaurant.callerIdType != CallerIdType.both) {
          callerIdType = restaurant.restaurant.callerIdType;
          Preferences.callerIdType = callerIdType;
        }
        // debugPrint("XXX ${restaurant.restaurant.toJson()}");

        // set today date range
        dateRange = getTodayDateRange();

        loadPrintImg(restaurant.restaurant.printLogo);

        return restaurant;
      }
      return null;
    } catch (e) {
      kLogger.e(e);
      return null;
    }
  }

  loadPrintImg(String base64String) {
    if (base64String.isNotEmpty) {
      // Remove the prefix if it exists
      if (base64String.startsWith('data:image/png;base64,')) {
        base64String = base64String.replaceFirst('data:image/png;base64,', '');
      }
      try {
        Uint8List bytes = base64Decode(base64String);
        printByteImgData = bytes;
        printImg = pw.MemoryImage(bytes);
      } catch (e) {
        kLogger.e("Base64 string convert issue :$e");
        printImg == null;
        printByteImgData == null;
      }
    } else {
      printImg == null;
      printByteImgData == null;
      kLogger.e("Base64 string is empty or null");
    }
  }

  DeliveryModel? deliveryData;
  //! +++++ delivery +++++++
  setDeliveryData(Map<String, dynamic> userData) async {
    // Convert the Map to a JSON string
    String userDataJson = jsonEncode(userData);
    // Save the JSON string
    Preferences.deliveryData = userDataJson;
    await getDeliveryData();
    update();
  }

  Future<DeliveryModel?> getDeliveryData() async {
    // Get the JSON string
    String stringData = Preferences.deliveryData;

    if (stringData.isNotEmpty) {
      // Convert the JSON string back to an EmployeeModel
      Map<String, dynamic> deliveryDatasAsMap = jsonDecode(stringData);

      var delivery = DeliveryModel.fromJson(deliveryDatasAsMap);
      deliveryData = delivery;
      return delivery;
    }
    return null;
  }

  // Future<void> logout() async {
  //   await Preferences.removeItem(Preferences.KEY_IS_FIRST_TIME);
  //   await Preferences.removeItem(Preferences.ACCESS_TOKEN);
  //   await Preferences.removeItem(Preferences.BRANCH_TOKEN);
  //   await Preferences.removeItem(Preferences.CLOCK_IN_ID);
  //   await Preferences.removeItem(Preferences.IS_USER_SIGNIN);
  //   await Preferences.removeItem(Preferences.KEY_IS_ACTIVER_EXPERT);
  //   await Preferences.removeItem(Preferences.KEY_IS_LIGHT);
  //   // await Preferences.removeItem(Preferences.KITCHEN_PRINTER);
  //   // await Preferences.removeItem(Preferences.COUNTER_PRINTER);
  //   // await Preferences.removeItem(Preferences.BAR_PRINTER);
  //   await Preferences.removeItem(Preferences.WING_SCALE);
  //   await Preferences.removeItem(Preferences.USER_INFO);
  //   await Preferences.removeItem(Preferences.MY_TIME_ZONE);
  //   await Preferences.removeItem(Preferences.RESTAURANT_DETAILS);
  //   await Preferences.removeItem(Preferences.CASH_DRAWER_PORT);

  //   // Preferences.clear();
  // }
  Future<void> logout() async {
    try {
      // 🔑 List all preference keys to clear during logout
      const keysToClear = [
        Preferences.KEY_IS_FIRST_TIME,
        Preferences.ACCESS_TOKEN,
        Preferences.BRANCH_TOKEN,
        Preferences.CLOCK_IN_ID,
        Preferences.IS_USER_SIGNIN,
        Preferences.KEY_IS_ACTIVER_EXPERT,
        Preferences.KEY_IS_LIGHT,
        Preferences.WING_SCALE,
        Preferences.USER_INFO,
        Preferences.MY_TIME_ZONE,
        Preferences.RESTAURANT_DETAILS,
        Preferences.CASH_DRAWER_PORT,
        Preferences.BASE_URL,
        // Preferences.CALLER_PORT_1,
        // Preferences.CALLER_PORT_2,
        // Preferences.TELEPHONE_L1,
        // Preferences.TELEPHONE_L2,
        Preferences.PAPER_WIDTH,
        Preferences.OLO_PRINT,
        Preferences.DELIVERY_ORDER_PRINT,
        // Preferences.COUNTER_PRINTER,
        // Preferences.KITCHEN_PRINTER,
        Preferences.NOTIFICATION_SOUND,
        Preferences.CUSTOM_KEYBOARD,
        Preferences.KEYBOARD_SOUND,
        Preferences.IS_TERMINAL,
        // Preferences.TERMINAL_ID,
        Preferences.DELIVERY_DATA,
      ];

      // 🧹 Remove each key safely
      for (final key in keysToClear) {
        await Preferences.removeItem(key);
      }

      // 🧾 Optional: if you want a full reset instead of selective removal
      // await Preferences.clear();

      debugPrint(
        "✅ Logout successful — cleared ${keysToClear.length} preference keys.",
      );
    } catch (e, st) {
      debugPrint("❌ Error during logout: $e");
      debugPrint("$st");
    }
  }

  onChangeSocketConnection(bool value) {
    isSocketConnected = value;
    update();
  }

  void playTapSound() {
    // AudioPlayer().play(AssetSource('audio/tap_sound_1.mp3'));
  }
  void playNotificationSound() {
    AudioPlayer().play(AssetSource('audio/notification_4.mp3'));
  }

  void playKeybordSound() {
    AudioPlayer().play(AssetSource('audio/tap_sound_1.mp3'));
  }

  // for lock dialog
  Timer? inactivityTimer;
  bool isEntryView = false;
  int logOutTime = 5;

  void startInactivityTimer() {
    inactivityTimer?.cancel(); // Cancel any previous timer
    inactivityTimer = Timer(
      Duration(seconds: logOutTime),
      showInactivityDialog,
    );
    // isEntryView = false;
  }

  void resetInactivityTimer() {
    startInactivityTimer();
  }

  resetOutoutTimer() {
    Timer.periodic(Duration(seconds: logOutTime - 1), (Timer timer) {
      startInactivityTimer();
      kLogger.i(DateTime.now());
    });
  }

  void showInactivityDialog() {
    // Get.toNamed(Routes.AUTH);
    // if (isEntryView) {
    //   showDialog<void>(
    //     // Context
    //     context: Get.context!,
    //     // barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return const LockDialog();
    //     },
    //   );
    // }
  }
  //*** */ with time zone  ****
  // DateTimeRange getTodayDateRange() {
  //   final myZone = Preferences.myTimeZone;
  //   final location = tz.getLocation(myZone);
  //   final now = tz.TZDateTime.now(location);

  //   List<String> openingParts =
  //       restaurantDetails?.restaurant.openingTime.split(':') ?? ['06', '00'];
  //   List<String> closingParts =
  //       restaurantDetails?.restaurant.closingTime.split(':') ?? ['18', '00'];

  //   // Build directly in restaurant's timezone
  //   final start = tz.TZDateTime(
  //     location,
  //     now.year,
  //     now.month,
  //     now.day,
  //     int.parse(openingParts[0]),
  //     int.parse(openingParts[1]),
  //   );

  //   final end = tz.TZDateTime(
  //     location,
  //     now.year,
  //     now.month,
  //     now.day,
  //     int.parse(closingParts[0]),
  //     int.parse(closingParts[1]),
  //   );

  //   // Convert to local DateTime (strips TZ, keeps correct wall-clock time)
  //   return DateTimeRange(
  //     start: DateTime.fromMillisecondsSinceEpoch(start.millisecondsSinceEpoch),
  //     end: DateTime.fromMillisecondsSinceEpoch(end.millisecondsSinceEpoch),
  //   );
  // }

  //*** without time zone  ****/
  // DateTimeRange getTodayDateRange() {
  //   final now = DateTime.now();

  //   List<String> openingParts =
  //       restaurantDetails?.restaurant.openingTime.split(':') ?? ['06', '00'];
  //   List<String> closingParts =
  //       restaurantDetails?.restaurant.closingTime.split(':') ?? ['18', '00'];

  //   final start = DateTime(
  //     now.year,
  //     now.month,
  //     now.day,
  //     int.parse(openingParts[0]),
  //     int.parse(openingParts[1]),
  //   );

  //   final end = DateTime(
  //     now.year,
  //     now.month,
  //     now.day,
  //     int.parse(closingParts[0]),
  //     int.parse(closingParts[1]),
  //   );

  //   return DateTimeRange(start: start, end: end);
  // }

  DateTimeRange getTodayDateRange() {
    final now = DateTime.now();

    List<String> openingParts =
        restaurantDetails?.restaurant.openingTime.split(':') ?? ['06', '00'];
    List<String> closingParts =
        restaurantDetails?.restaurant.closingTime.split(':') ?? ['23', '59'];

    final openHour = int.parse(openingParts[0]);
    final openMin = int.parse(openingParts[1]);
    final closeHour = int.parse(closingParts[0]);
    final closeMin = int.parse(closingParts[1]);

    final start = DateTime(now.year, now.month, now.day, openHour, openMin);

    // Overnight check: closing
    final bool isOvernight =
        closeHour < openHour || (closeHour == openHour && closeMin <= openMin);

    final end = isOvernight
        ? DateTime(now.year, now.month, now.day + 1, closeHour, closeMin)
        : DateTime(now.year, now.month, now.day, closeHour, closeMin);
    if (kDebugMode) {
      debugPrint(
        '📅 getTodayDateRange:'
        '\n   openingTime : ${restaurantDetails?.restaurant.openingTime} → $start'
        '\n   closingTime : ${restaurantDetails?.restaurant.closingTime} → $end'
        '\n   isOvernight : $isOvernight'
        '\n   now         : $now'
        '\n   valid       : ${!start.isAfter(end)}',
      );
    }

    if (start.isAfter(end)) {
      if (kDebugMode) {
        debugPrint(
          '⛔ getTodayDateRange: start is after end — fallback to full day',
        );
      }
      final fallbackStart = DateTime(now.year, now.month, now.day, 0, 0);
      final fallbackEnd = DateTime(now.year, now.month, now.day, 23, 59);
      return DateTimeRange(start: fallbackStart, end: fallbackEnd);
    }

    return DateTimeRange(start: start, end: end);
  }

  getRestaurantsDetailsFromAPI() async {
    BaseModel res = await BaseController.to.apiService.makeGetRequest(
      URLS.restaurantsDetails,
    );
    if (res.statusCode == 200) {
      // set restaurant details
      await setRestaurantDetails(res.data["data"]);
      // set time zone
      Preferences.myTimeZone = res.data["data"]["businessProfile"]["timeZone"];
    } else {
      // if (res.statusCode == 404 || res.statusCode == 406)
      PopupDialog.showErrorMessage(res.data["message"]);
    }
  }


  @override
  void onInit() {
    hasCallerId.value = Preferences.hasCallerId;
    isCallerIdLocal.value = Preferences.isCallerIdLocal;
    posDisplayMode = Preferences.posDisplayMode;
    callerIdType = Preferences.callerIdType;
    getRestaurantDetails();
    getPackageInfo();
    super.onInit();
  }
}
