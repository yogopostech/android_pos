import 'package:yogo_pos/app/services/base/preferences.dart';

import '../../modules/pos/order/models/order_model.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

extension CombineItems on List<CartModel> {
  List<CartModel> combineItems({bool isCustomerRecipt = false}) {
    final Map<String, CartModel> combinedItems = {};

    for (final item in this) {
      final itemKey = _detectUniqueItem(item, isCustomerRecipt);

      if (combinedItems.containsKey(itemKey)) {
        combinedItems[itemKey] = combinedItems[itemKey]!.copyWith(
          quantity: combinedItems[itemKey]!.quantity + item.quantity,
          price: combinedItems[itemKey]!.price + (item.price * item.quantity),
          weight:
              combinedItems[itemKey]!.weight + (item.weight * item.quantity),
        );
      } else {
        combinedItems[itemKey] = item.copyWith(
          price: item.price * item.quantity,
          weight: item.weight * item.quantity,
        );
      }
    }

    return combinedItems.values.toList();
  }

  String _detectUniqueItem(CartModel item, bool isCustomerRecipt) {
    final variationNames = item.variationOptions
        .map((variation) => variation.name)
        .join('_');
    if (isCustomerRecipt) {
      return '${item.name}_${item.kitchenNote}_${variationNames}_${item.weight}';
    } else {
      final modifiersString = item.modifiers.join('_');

      return '${item.name}_${item.kitchenNote}_${variationNames}_${modifiersString}_${item.weight}';
    }
  }
}

extension DateTimeExtensions on DateTime {
  DateTime toTimeZone() {
    // Convert to UTC
    DateTime nowUtc = toUtc();

    // Get the preferred timezone or default to "America/Belize"
    String myZone = Preferences.myTimeZone.isNotEmpty == true
        ? Preferences.myTimeZone
        : "America/Belize";

    // Retrieve the location for the timezone
    tz.Location location;
    try {
      location = tz.getLocation(myZone);
    } catch (e) {
      // Fallback to "America/Belize" if the timezone is invalid
      location = tz.getLocation("America/Belize");
    }

    // Convert UTC DateTime to the specified timezone
    tz.TZDateTime time = tz.TZDateTime.from(nowUtc, location);

    return time;
  }
}

extension DateTimeFormatter on DateTime? {
  String toStringAsPrimaryFormat() {
    if (this == null) {
      return "";
    }
    try {
      var myZone = Preferences.myTimeZone;
      if (myZone.isEmpty) {
        myZone = "America/Belize";
      }
      final detroitTimeZone = tz.getLocation(myZone);
      final utcDateTime = tz.TZDateTime.from(this!, detroitTimeZone);
      return DateFormat('MMM dd,yy hh:mm a').format(utcDateTime);
    } catch (e) {
      return "";
    }
  }

  String toStringAsSecondaryFormat() {
    if (this == null) {
      return "";
    }
    try {
      var myZone = Preferences.myTimeZone;
      if (myZone.isEmpty) {
        myZone = "America/Belize";
      }
      final detroitTimeZone = tz.getLocation(myZone);
      DateTime utcDateTime = tz.TZDateTime.from(this!, detroitTimeZone);
      return DateFormat('MMM dd, hh:mm a').format(utcDateTime);
    } catch (e) {
      return "";
    }
  }

  String toFormattedDate() {
    if (this == null) return "";

    try {
      var myZone = Preferences.myTimeZone;
      if (myZone.isEmpty) {
        myZone = "America/Belize";
      }

      final timeZoneLocation = tz.getLocation(myZone);
      final convertedDate = tz.TZDateTime.from(this!, timeZoneLocation);

      return DateFormat('MMM dd').format(convertedDate); // Only Date
    } catch (e) {
      return "";
    }
  }

  String daysDifferenceFromNow() {
    if (this == null) {
      return "";
    }
    try {
      var myZone = Preferences.myTimeZone;
      if (myZone.isEmpty) {
        myZone = "America/Belize";
      }
      final timeZone = tz.getLocation(myZone);
      DateTime localDateTime = tz.TZDateTime.from(this!, timeZone);
      DateTime now = tz.TZDateTime.now(timeZone);
      Duration difference = now.difference(localDateTime);
      int days = difference.inDays;
      int hours = difference.inHours % 24;
      int minutes = difference.inMinutes % 60;
      if (days == 0 && hours == 0 && minutes == 0) {
        return "Just now";
      } else if (days == 0 && hours == 0) {
        return "$minutes min${minutes > 1 ? 's.' : '.'} ago";
      } else if (days == 0) {
        return "$hours hour${hours > 1 ? 's' : ''} ago";
      } else {
        return "$days day${days > 1 ? 's' : ''} ago";
      }
    } catch (e) {
      return "";
    }
  }
}
