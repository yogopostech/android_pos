// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogo_pos/app/services/models/restaurant_model.dart';
import 'package:yogo_pos/app/utils/receipt.dart';

class Preferences {
  static late SharedPreferences preferences;

  static const String KEY_IS_FIRST_TIME = 'is_first_time';
  static const String ACCESS_TOKEN = 'access_token';
  static const String BRANCH_TOKEN = 'BranchToken';
  static const String CLOCK_IN_ID = 'Clock_in_id';
  static const String IS_USER_SIGNIN = 'is_user_signin';
  static const String KEY_IS_ACTIVER_EXPERT = 'is_active_Expert';
  static const String KEY_IS_LIGHT = 'is_light';
  static const String WING_SCALE = 'wing_scale';
  static const String USER_INFO = 'user_info';
  static const String MY_TIME_ZONE = 'my_time_zone';
  static const String RESTAURANT_DETAILS = "restaurant_details";
  static const String CASH_DRAWER_PORT = "cash_drawer_port";
  static const String BASE_URL = "base_url";
  // caller port
  static const String CALLER_PORT_1 = "caller_port_1";
  static const String CALLER_PORT_2 = "caller_port_2";
  // for Telephone Line
  static const String TELEPHONE_L1 = "telephone_l1";
  static const String TELEPHONE_L2 = "telephone_l2";
  static const String HAS_CALLER_ID = "has_caller_id";
  static const String IS_CALLER_ID_LOCAL = "is_caller_id_local";

  // printer
  static const String OLO_PRINT = "olo_print";
  static const String DELIVERY_ORDER_PRINT = "delivery_order_print";
  static const String COUNTER_PRINTER = 'counter_printer';
  static const String KITCHEN_PRINTER = 'kitchen_printer';

  static const String PRINTER_TYPE = 'printer_type';
  static const String BARCODE_TYPE = 'barcode_type';
  static const String DRAWER_PIN = 'drawer_pin';
  static const String PAPER_WIDTH = "paper_width";
  static const String SKIP_EMPTY_PRINTER = "skip_empty_printer";

  static const String OLO_CUSTOMER_RECEIPT = "olo_customer_receipt";
  static const String DELIVERY_CUSTOMER_RECEIPT = "delivery_customer_receipt";

  static const String TAKEOUT_CUSTOMER_RECEIPT = "takeout_customer_receipt";
  static const String DELIVERY_POS_CUSTOMER_RECEIPT =
      "delivery_pos_customer_receipt";

  // ======  Notification Sound ==========
  static const String NOTIFICATION_SOUND = "notification_sound";
  // ======  Custom Keyboard ==========
  static const String CUSTOM_KEYBOARD = "custom_keyboard";
  static const String KEYBOARD_SOUND = "keyboard_sound";
  // ====== Terminal ==========
  // id
  static const String IS_TERMINAL = "is_terminal";
  static const String TERMINAL_ID = "terminal_id";
  // ip and port
  static const String TERMINAL_IP = "terminal_ip";
  static const String TERMINAL_PORT = "terminal_port";

  // DeliveryData
  static const String DELIVERY_DATA = "delivery_data";
  // station id
  static const String STATION_ID = "station_id";
  // fire and logout
  static const String FIRE_AND_LOGOUT = "fire_and_logout";
  //
  static const String POS_DISPLAY_MODE = "pos_display_mode";
  static const String CALLER_ID_TYPE = 'CALLER_ID_TYPE';

  // device id
  static const String DEVICE_ID = "device_id";

  ///  ====== init pref ============
  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  /// is user signin
  static bool get isUserSignin => preferences.getBool(IS_USER_SIGNIN) ?? false;
  static set isUserSignin(bool value) =>
      preferences.setBool(IS_USER_SIGNIN, value);

  /// isFirstTime
  static bool get isFirstTime => preferences.getBool(KEY_IS_FIRST_TIME) ?? true;
  static set isFirstTime(bool value) =>
      preferences.setBool(KEY_IS_FIRST_TIME, value);

  /// ACCESS_TOKEN
  static String get accessToken => preferences.getString(ACCESS_TOKEN) ?? '';
  static set accessToken(String value) =>
      preferences.setString(ACCESS_TOKEN, value);

  /// BRANCH_TOKEN
  static String get branchToken => preferences.getString(BRANCH_TOKEN) ?? '';
  static set branchToken(String value) =>
      preferences.setString(BRANCH_TOKEN, value);

  // static String get barPrinter => preferences.getString(BAR_PRINTER) ?? '';
  // static set barPrinter(String? value) =>
  //     preferences.setString(BAR_PRINTER, value ?? '');

  // Wingscale
  static String get wingScale => preferences.getString(WING_SCALE) ?? '';
  static set wingScale(String? value) =>
      preferences.setString(WING_SCALE, value ?? '');
  // time zone
  static String get myTimeZone =>
      preferences.getString(MY_TIME_ZONE) ?? 'America/Belize';
  static set myTimeZone(String? value) =>
      preferences.setString(MY_TIME_ZONE, value ?? 'America/Belize');

  /// CLOCK_IN_ID
  static String get clockInId => preferences.getString(CLOCK_IN_ID) ?? '';
  static set clockInId(String value) =>
      preferences.setString(CLOCK_IN_ID, value);

  /// Cash drader port
  static String get cashDrawerPort =>
      preferences.getString(CASH_DRAWER_PORT) ?? '';
  static set cashDrawerPort(String value) =>
      preferences.setString(CASH_DRAWER_PORT, value);

  /// is light theme
  static bool get isLight =>
      preferences.getBool(KEY_IS_LIGHT) ?? ThemeMode.system == ThemeMode.light;
  static set isLight(bool value) => preferences.setBool(KEY_IS_LIGHT, value);

  /// olo print
  static bool get isOloPrint => preferences.getBool(OLO_PRINT) ?? true;
  static set isOloPrint(bool value) => preferences.setBool(OLO_PRINT, value);

  /// delivery order print
  static bool get isDeliveryOrderPrint =>
      preferences.getBool(DELIVERY_ORDER_PRINT) ?? true;
  static set isDeliveryOrderPrint(bool value) =>
      preferences.setBool(DELIVERY_ORDER_PRINT, value);
  //notification sound
  static bool get isNotificationSound =>
      preferences.getBool(NOTIFICATION_SOUND) ?? true;
  static set isNotificationSound(bool value) =>
      preferences.setBool(NOTIFICATION_SOUND, value);
  // printer
  static String get counterPrinter =>
      preferences.getString(COUNTER_PRINTER) ?? '';
  static set counterPrinter(String? value) =>
      preferences.setString(COUNTER_PRINTER, value ?? '');

  static String get kitchenPrinter =>
      preferences.getString(KITCHEN_PRINTER) ?? '';
  static set kitchenPrinter(String? value) =>
      preferences.setString(KITCHEN_PRINTER, value ?? '');

  /// user info
  static String get user => preferences.getString(USER_INFO) ?? '';
  static set user(String value) => preferences.setString(USER_INFO, value);

  ///  Restaurant Details
  static String get restaurantDetails =>
      preferences.getString(RESTAURANT_DETAILS) ?? '';
  static set restaurantDetails(String value) =>
      preferences.setString(RESTAURANT_DETAILS, value);

  ///  delivery Data
  static String get deliveryData => preferences.getString(DELIVERY_DATA) ?? '';
  static set deliveryData(String value) =>
      preferences.setString(DELIVERY_DATA, value);

  ///  base url
  static String get baseURL => preferences.getString(BASE_URL) ?? '';
  static set baseURL(String value) => preferences.setString(BASE_URL, value);

  ///  ***** caller Port ******
  // L1
  static String get callerPortL1 => preferences.getString(CALLER_PORT_1) ?? '';
  static set callerPortL1(String value) =>
      preferences.setString(CALLER_PORT_1, value);
  // L2
  static String get callerPortL2 => preferences.getString(CALLER_PORT_2) ?? '';
  static set callerPortL2(String value) =>
      preferences.setString(CALLER_PORT_2, value);
  // **** Telephone ****
  //l1
  static bool get telephoneL1 => preferences.getBool(TELEPHONE_L1) ?? false;
  static set telephoneL1(bool value) =>
      preferences.setBool(TELEPHONE_L1, value);
  //l2
  static bool get telephoneL2 => preferences.getBool(TELEPHONE_L2) ?? false;
  static set telephoneL2(bool value) =>
      preferences.setBool(TELEPHONE_L2, value);
  //printer
  // PrinterType
  static PrinterType get printerType =>
      PrinterType.values[preferences.getInt(PRINTER_TYPE) ?? 0];
  static set printerType(PrinterType value) =>
      preferences.setInt(PRINTER_TYPE, value.index);

  // BarcodeType
  static BarcodeType get barcodeType =>
      BarcodeType.values[preferences.getInt(BARCODE_TYPE) ?? 0];
  static set barcodeType(BarcodeType value) =>
      preferences.setInt(BARCODE_TYPE, value.index);

  //DrawerPin
  static DrawerPin get drawerPin =>
      DrawerPin.values[preferences.getInt(DRAWER_PIN) ?? 0];
  static set drawerPin(DrawerPin value) =>
      preferences.setInt(DRAWER_PIN, value.index);
  // SkipEmptyPrinter
  static bool get skipEmptyPrinter =>
      preferences.getBool(SKIP_EMPTY_PRINTER) ?? false;
  static set skipEmptyPrinter(bool value) =>
      preferences.setBool(SKIP_EMPTY_PRINTER, value);

  // 4. Paper Width (int)
  // static int get paperWidth => preferences.getInt(PAPER_WIDTH) ?? 48;
  // static set paperWidth(int value) => preferences.setInt(PAPER_WIDTH, value);

  static String get paperWidth => preferences.getString(PAPER_WIDTH) ?? "48";
  static set paperWidth(String value) =>
      preferences.setString(PAPER_WIDTH, value);
  // **** remove *****
  static Future removeItem(String key) async {
    await preferences.remove(key);
  }

  // ***** Custom Keyboard *****
  static bool get customKeyboard =>
      preferences.getBool(CUSTOM_KEYBOARD) ?? true;
  static set customKeyboard(bool value) =>
      preferences.setBool(CUSTOM_KEYBOARD, value);
  //  Keyboard Sound
  static bool get keyboardSound => preferences.getBool(KEYBOARD_SOUND) ?? false;
  static set keyboardSound(bool value) =>
      preferences.setBool(KEYBOARD_SOUND, value);
  // ***** terminal *****
  // isTerminal
  static bool get isTerminal => preferences.getBool(IS_TERMINAL) ?? true;
  static set isTerminal(bool value) => preferences.setBool(IS_TERMINAL, value);
  // terminalId
  static String get terminalId => preferences.getString(TERMINAL_ID) ?? "";
  static set terminalId(String value) =>
      preferences.setString(TERMINAL_ID, value);

  // terminalIp
  static String get terminalIp => preferences.getString(TERMINAL_IP) ?? "";
  static set terminalIp(String value) =>
      preferences.setString(TERMINAL_IP, value);
  // terminalPort
  static int get terminalPort => preferences.getInt(TERMINAL_PORT) ?? 12000;
  static set terminalPort(int value) =>
      preferences.setInt(TERMINAL_PORT, value);

  // ***** Station Id *****
  static String get stationId => preferences.getString(STATION_ID) ?? "";
  static set stationId(String value) =>
      preferences.setString(STATION_ID, value);
  // ***** Customer Receipt *****
  static bool get oloCustomerReceipt =>
      preferences.getBool(OLO_CUSTOMER_RECEIPT) ?? false;
  static set oloCustomerReceipt(bool value) =>
      preferences.setBool(OLO_CUSTOMER_RECEIPT, value);
  //delivery customer receipt
  static bool get deliveryCustomerReceipt =>
      preferences.getBool(DELIVERY_CUSTOMER_RECEIPT) ?? false;
  static set deliveryCustomerReceipt(bool value) =>
      preferences.setBool(DELIVERY_CUSTOMER_RECEIPT, value);
  //POS side
  static bool get deliveryPosCustomerReceipt =>
      preferences.getBool(DELIVERY_POS_CUSTOMER_RECEIPT) ?? false;
  static set deliveryPosCustomerReceipt(bool value) =>
      preferences.setBool(DELIVERY_POS_CUSTOMER_RECEIPT, value);
  //takeout side
  static bool get takeoutCustomerReceipt =>
      preferences.getBool(TAKEOUT_CUSTOMER_RECEIPT) ?? false;
  static set takeoutCustomerReceipt(bool value) =>
      preferences.setBool(TAKEOUT_CUSTOMER_RECEIPT, value);
  // fire and logout
  static bool get fireAndLogout =>
      preferences.getBool(FIRE_AND_LOGOUT) ?? false;
  static set fireAndLogout(bool value) =>
      preferences.setBool(FIRE_AND_LOGOUT, value);

  // has caller id
  static bool get hasCallerId => preferences.getBool(HAS_CALLER_ID) ?? false;
  static set hasCallerId(bool value) =>
      preferences.setBool(HAS_CALLER_ID, value);
  // is caller id local
  static bool get isCallerIdLocal =>
      preferences.getBool(IS_CALLER_ID_LOCAL) ?? false;
  static set isCallerIdLocal(bool value) =>
      preferences.setBool(IS_CALLER_ID_LOCAL, value);

  // ***** POS Category Display Mode *****
  static PosDisplayMode get posDisplayMode =>
      PosDisplayMode.values[preferences.getInt(POS_DISPLAY_MODE) ??
          PosDisplayMode.itemsOnly.index];
  static set posDisplayMode(PosDisplayMode value) =>
      preferences.setInt(POS_DISPLAY_MODE, value.index);
  // ***** POS caller Id Mode *****
  static CallerIdType get callerIdType {
    final v = preferences.getString(CALLER_ID_TYPE) ?? 'typeOne';
    return CallerIdType.values.firstWhere(
      (e) => e.name == v,
      orElse: () => CallerIdType.typeOne,
    );
  }

  // ***** Device Id *****
  static String get deviceId => preferences.getString(DEVICE_ID) ?? "";
  static set deviceId(String value) => preferences.setString(DEVICE_ID, value);

  static set callerIdType(CallerIdType value) {
    preferences.setString(CALLER_ID_TYPE, value.name);
  }

  // ***** Clear the SharedPreferences *****
  static void clear() {
    preferences.clear();
  }
}
