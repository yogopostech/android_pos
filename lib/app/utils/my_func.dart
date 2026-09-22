import 'dart:math';

import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/models/split_amount_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:timezone/timezone.dart' as tz;

class MyFunc {
  static Color productColor(String text) {
    if (text == "VEG") {
      return StaticColors.greenColor;
    } else if (text == "NON_VEG") {
      return const Color(0xffFD571A);
    } else {
      return StaticColors.purpleColor;
    }
  }

  static bool checkOpenDrawer(PaymentModel? payment) {
    if (payment == null) return false;

    if (payment.methods.contains("CASH") ||
        payment.methods.contains("CASH_AND_CARD") ||
        payment.methods.contains("CASH_AND_GIFT_CARD")) {
      return true;
    } else {
      return false;
    }
  }

  static String orderType(OrderModel order) {
    if (order.orderType == "DINE_IN" || order.orderType == "DELIVERY") {
      return order.orderType;
    } else if (order.orderType == "TAKEOUT") {
      if (order.takeOutType == "ONLINE") {
        return "ONLINE";
      } else {
        return "TAKEOUT";
      }
    } else {
      return "";
    }
  }

  static String modifyOrderStatus(String status) {
    return status == 'CANCELED' ? 'CANCELLED' : status;
  }

  static Color getTableColorWithStatus(String? status) {
    switch (status) {
      case "AVAILABLE":
        return const Color(0xff118A01); // Available
      // case "WALK-IN":
      //   return const Color(0xffF8931D);
      case "COOKING":
        return const Color.fromARGB(255, 255, 106, 52); // COOKING
      case "SERVING":
        return Color(0xffF8931D); // Serving
      case "ONLINE_BOOKING":
        return const Color(0xff006AFF); // Online Booking
      case "COMBINED_TABLES":
        return const Color(0xff6864D2); // Combined
      case "HOLD_TABLES":
        return const Color(0xffEA295E); // Combined
      default:
        return Color(0xffF8931D); // Hold
    }
  }

  static bool canGoSplitPage(OrderModel order) {
    // print(order.paymentStatus);
    // print(order.splitAmounts.length);
    // print(order.splitOrders.length);
    if (order.carts.isEmpty) return false;
    if (order.paymentStatus == "PAID" &&
        (order.splitAmounts.isEmpty && order.splitOrders.isEmpty)) {
      // print("Hide");
      return false;
    } else {
      // print("Show");
      return true;
    }
  }

  static String getStatusWithStatusCode(int? status) {
    switch (status) {
      case 1:
        return "Available"; // Available
      case 2:
        return "Booked"; // Booked
      case 3:
        return "UServing"; // UServing
      case 4:
        return "Online Booking"; // Online Booking
      case 5:
        return "Combined"; // Combined
      default:
        return "Hold"; // Hold
    }
  }

  static int generateRandomNumericId() {
    Random random = Random();
    int min = 100000;
    int max = 999999;
    return min + random.nextInt(max - min);
  }

  static String capitalize(String s) {
    var stringData = s.trim();
    if (stringData.isNotEmpty) {
      return stringData[0].toUpperCase() + s.substring(1).toLowerCase();
    } else {
      return "";
    }
  }

  // static String capitalizeEachWord({String? s}) {
  //   if (s != null && s.trim().isNotEmpty) {
  //     return s
  //         .trim()
  //         .split(RegExp(r'\s+'))
  //         .map(
  //           (word) => word.isNotEmpty
  //               ? word[0].toUpperCase() + word.substring(1).toLowerCase()
  //               : '',
  //         )
  //         .join(' ');
  //   }
  //   return "";
  // }
  static String capitalizeEachWord({String? s}) {
    if (s == null || s.trim().isEmpty) {
      return "";
    }

    return s
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) {
            return '';
          }

          final idx = word.indexOf(RegExp(r'\p{L}', unicode: true));

          if (idx == -1) {
            return word.toLowerCase();
          }

          return word.substring(0, idx) +
              word[idx].toUpperCase() +
              word.substring(idx + 1).toLowerCase();
        })
        .join(' ');
  }

  static int calculateSecondsFrom(DateTime? givenDate) {
    if (givenDate == null) {
      return 0;
    }
    try {
      // Get the current date and time in UTC
      DateTime now = DateTime.now().toUtc();

      // Calculate the difference in seconds
      int secondsDifference = now.difference(givenDate.toUtc()).inSeconds;

      return secondsDifference;
    } catch (e) {
      // Return 0 if there is an error
      return 0;
    }
  }

  static num yogoRound(num value) {
    num roundToNearest = 0.05;
    num roundedValue = (value / roundToNearest).round() * roundToNearest;
    return num.parse(roundedValue.toStringAsFixed(2));
  }

  static bool shouldShowTimeSheetReport() {
    debugPrint(
      "ZZZZ allowClockInOut: ${BaseController.to.employeeData?.allowClockInOut}, posTimeSheetReport: ${BaseController.to.employeeData?.posTimeSheetReport}",
    );
    if ((BaseController.to.employeeData?.allowClockInOut ?? false) &&
        (BaseController.to.employeeData?.posTimeSheetReport ?? false)) {
      return true;
    }
    return false;
  }

  static Future<pw.Font> loadCustomFont(String fontPath) async {
    final fontData = await rootBundle.load(fontPath);
    return pw.Font.ttf(fontData);
  }

  static Color getColorForCategory(String mainCategory) {
    switch (mainCategory.toLowerCase()) {
      case "food":
        return StaticColors.greenColor;
      case "drinks":
        return StaticColors.blueColor; // Booked
      case "dessert":
        return StaticColors.greenColor; // COOKING
      default:
        return StaticColors.orangeColor; // groceriesList
    }
  }

  static Color getColorItemType(String mainCategory) {
    switch (mainCategory.toLowerCase()) {
      case "veg":
        return StaticColors.greenColor;
      case "non veg":
        return StaticColors.yellowColor;
      case "drinks":
        return StaticColors.blueColor;
      case "liquor":
        return StaticColors.orangeColor;
      case "dessert":
        return StaticColors.greenColor;
      default:
        return StaticColors.blueColor; // as drinks
    }
  }

  static String stringNullCheck(String? value) {
    if (value == null || value.isEmpty) {
      return "N.A.";
    } else {
      return value;
    }
  }

  // String getAmPm(TimeOfDay time, BuildContext context) {
  //   final formattedTime = time.format(context);
  //   if (formattedTime.contains('AM')) {
  //     return 'AM';
  //   } else if (formattedTime.contains('PM')) {
  //     return 'PM';
  //   } else {
  //     return ''; // In case the format does not include AM/PM
  //   }
  // }
  String timeOfDayToString(TimeOfDay time, BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final formattedTime = localizations.formatTimeOfDay(
      time,
      alwaysUse24HourFormat: false,
    );
    return formattedTime.replaceAll(' ', '').toLowerCase();
  }

  static String orNA(String? value) {
    return (value == null || value.isEmpty) ? "N/A" : value;
  }

  static String orderCondition(dynamic order) {
    if (order is OrderModel || order is SplitAmount) {
      if (order.isVoid == true) {
        return "(VOIDED)";
      } else if (order.refund == true) {
        return "(REFUNDED)";
      } else if (order.payment != null) {
        return "(PAID)";
      } else {
        return "";
      }
    }
    return "";
  }

  static bool hasMatchingUpdatedCartId(OrderModel order, List<String> ids) {
    return order.carts.any((cart) => ids.contains(cart.id) && cart.isUpdated);
  }

  static String getTimeZoneAbbr(String timeZone) {
    final location = tz.getLocation(timeZone);
    final now = tz.TZDateTime.now(location);
    return now.timeZoneName; // "PST" / "PDT"
  }

  static String generateId(IdFor type) {
    final now = DateTime.now();

    // A = January, B = February, ...
    final monthLetter = String.fromCharCode('A'.codeUnitAt(0) + now.month - 1);

    // enum index → 1–7
    final typeNumber = type.index + 1;

    // Generate 10 random digits
    final rand = Random();
    final randomDigits = List.generate(10, (_) => rand.nextInt(10)).join();

    return "$monthLetter$typeNumber$randomDigits";
  }

  //getSplitCardType
  static String getSplitCardType(PaymentModel? payment) {
    if (payment == null) return "";

    if (payment.methods.contains("CASH_AND_CARD")) {
      return payment.cardType;
    } else {
      return payment.methods.join(', ').replaceAll('_', ' ');
    }
  }
}

enum IdFor {
  dineIn,
  takeout,
  online,
  delivery,
  oloReservation,
  moneris,
  stripe,
}
