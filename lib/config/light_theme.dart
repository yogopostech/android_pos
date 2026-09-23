import 'package:flutter/material.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/config/fonts.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  // ***** Color *****
  primaryColor: const Color(0xfff65b1c),
  primaryColorDark: const Color(0xff1C1917),
  primaryColorLight: const Color.fromARGB(255, 146, 255, 132),
  canvasColor: Colors.white,
  cardColor: const Color(0xffD7D3CC),
  disabledColor: const Color(0xffC4CACF),
  dividerColor: Colors.grey.shade300,
  hintColor: const Color.fromARGB(255, 128, 129, 133),
  focusColor: Colors.grey.shade200,
  highlightColor: const Color(0x000000ff),
  shadowColor: const Color(0x000000ff),
  splashColor: const Color.fromARGB(69, 50, 124, 242),
  scaffoldBackgroundColor: const Color(0xffEAE8E3),
  secondaryHeaderColor: null,
  applyElevationOverlayColor: false,
  hoverColor: const Color(0x000000ff),
  unselectedWidgetColor: const Color(0xffEEEEEE),
  // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  colorScheme: const ColorScheme.light(
    error: Colors.red,
    surface: Color(0xff0c0c0c),
    onSurface: Colors.white,
  ), // Primary color for buttons, etc.
  // *****  Others Color *****
  // primarySwatch: MyFunc.createMaterialColor(const Color(0xff8A0051)),
  // colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
  //     .copyWith(background: const Color(0xffFFFFFF)),

  // *****  brightness *****
  // brightness: Brightness.light,
  // primarySwatch
  primarySwatch: Colors.blue,
  // checkboxTheme
  checkboxTheme: CheckboxThemeData(
    checkColor: const WidgetStatePropertyAll(Colors.white),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return StaticColors.blueColor;
      }
      return Colors.grey;
    }),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.deepOrange, // Color of the cursor
    selectionColor: StaticColors.blueColor, // Highlight color
    selectionHandleColor: Colors.blue, // Handle color
  ),
  //Switch
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xff0274ff);
      }
      return Colors.black;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.black87.withAlpha(26);
      }
      return Colors.white;
    }),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.hovered)) {
        return const Color(0xff0274ff).withAlpha(26);
      }
      return Colors.transparent;
    }),
  ),
  iconTheme: const IconThemeData(color: Colors.black),
  //  datePickerTheme
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Colors.white,
    dividerColor: Colors.white,
    headerBackgroundColor: StaticColors.blueColor,
    headerForegroundColor: Colors.white,
    todayBackgroundColor:
        const WidgetStatePropertyAll(StaticColors.orangeColor),
    todayForegroundColor: const WidgetStatePropertyAll(Colors.white),
    rangeSelectionBackgroundColor: StaticColors.blueColor.withAlpha(51),
    rangeSelectionOverlayColor: const WidgetStatePropertyAll(Colors.green),
    // day Color
    dayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.black;
    }),
    dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return StaticColors.blueColor;
      }
      return Colors.transparent;
    }),
    // week day Style
    weekdayStyle:
        const TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
    yearStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
    // custom
    cancelButtonStyle: ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll(StaticColors.redColor),
      surfaceTintColor:
          WidgetStatePropertyAll(StaticColors.redColor.withAlpha(26)),
      overlayColor: WidgetStatePropertyAll(StaticColors.redColor.withAlpha(51)),
    ),
    confirmButtonStyle: ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll(StaticColors.blueColor),
      surfaceTintColor:
          WidgetStatePropertyAll(StaticColors.blueColor.withAlpha(26)),
      overlayColor:
          WidgetStatePropertyAll(StaticColors.blueColor.withAlpha(51)),
    ),
    yearForegroundColor: const WidgetStatePropertyAll(Colors.black),
    surfaceTintColor: StaticColors.blueColor,
  ),
//timePickerTheme
  timePickerTheme: const TimePickerThemeData(
    backgroundColor: Color.fromARGB(255, 189, 189, 189),
    hourMinuteColor: Colors.white,
    hourMinuteTextColor: Colors.black,
    dayPeriodTextColor: Colors.black,
    // dialHandColor: Colors.black,
    dialBackgroundColor: Colors.white,
    dialTextColor: Colors.black,
    dialHandColor: StaticColors.orangeColor,
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.black),
      hintStyle: TextStyle(color: Colors.black),
    ),
    dayPeriodTextStyle: TextStyle(color: Colors.black),
    helpTextStyle: TextStyle(color: Colors.black),
    hourMinuteTextStyle: TextStyle(color: Colors.black),
  ),
  // timePickerTheme: const TimePickerThemeData(
  //   backgroundColor: Colors.white,
  //   hourMinuteColor: Colors.black,
  //   hourMinuteTextColor: Colors.white,
  //   dayPeriodColor: Colors.black,
  //   dayPeriodTextColor: Colors.white,
  //   dialBackgroundColor: Colors.white,
  //   dialTextColor: Colors.black,
  //   dialHandColor: StaticColors.orangeColor,
  //   inputDecorationTheme: InputDecorationTheme(
  //     labelStyle: TextStyle(color: Colors.black),
  //     hintStyle: TextStyle(color: Colors.black),
  //   ),
  //   hourMinuteTextStyle: TextStyle(color: Colors.black),
  //   helpTextStyle: TextStyle(color: Colors.black),
  //   dayPeriodTextStyle: TextStyle(color: Colors.black),
  // ),

  // ****** Font Family ******
  // fontFamily: Fonts.primary,
  // ****** Card Theme ********
  cardTheme: CardThemeData(
      color: const Color(0xffF9FAFD),
      shadowColor: Colors.black,
      surfaceTintColor: null,
      margin: null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Adjust the radius as needed
      ),
      elevation: 1),
  //badge
  //badge
  badgeTheme: const BadgeThemeData(
      offset: Offset(-16, 6),
      textColor: Colors.black,
      backgroundColor: Colors.white,
      padding: EdgeInsets.all(4),
      textStyle: TextStyle(fontWeight: FontWeight.w600)),
  tooltipTheme: TooltipThemeData(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
    ),
    textStyle: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
  ),
  // ****** Text Theme ******
  textTheme: GoogleFonts.robotoTextTheme(
    const TextTheme(
      //******  Label  ******
      labelLarge: TextStyle(
          fontFamily: Fonts.primary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xff1E2022)),
      labelMedium: TextStyle(
          fontFamily: Fonts.primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xff1E2022)),
      labelSmall: TextStyle(
          fontFamily: Fonts.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xff1E2022)),

      //******  Body  ******
      bodyLarge: TextStyle(
          fontFamily: Fonts.primary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xff666666)),
      bodyMedium: TextStyle(
          fontFamily: Fonts.primary, fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(
          fontFamily: Fonts.primary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xff666666)),
      //******  Title  ******
      titleLarge: TextStyle(
          fontFamily: Fonts.primary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xff0C1C2C)),
      titleMedium: TextStyle(
          fontFamily: Fonts.primary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xff0C1C2C)),
      titleSmall: TextStyle(
          fontFamily: Fonts.primary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xff0C1C2C)),
      //******  HeadLine  ******
      headlineLarge: TextStyle(
          fontFamily: Fonts.primary,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Color(0xff0C1C2C)),
      headlineMedium: TextStyle(
          fontFamily: Fonts.primary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xff0C1C2C)),
      headlineSmall: TextStyle(
          fontFamily: Fonts.primary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xff0C1C2C)),
      //******  Display  ******
      displayLarge: TextStyle(
          fontFamily: Fonts.primary,
          fontSize: 60,
          fontWeight: FontWeight.w700,
          color: Color(0xff0C1C2C)),
      displayMedium: TextStyle(
          fontFamily: Fonts.primary,
          fontSize: 55,
          fontWeight: FontWeight.w700,
          color: Color(0xff0C1C2C)),
      displaySmall: TextStyle(
          fontFamily: Fonts.primary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xff0C1C2C)),
    ),
  ),

  scrollbarTheme: ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(Colors.grey.shade400),
    trackColor: WidgetStateProperty.all(Colors.grey.shade200),
    crossAxisMargin: -12,
  ),
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade300,
    thickness: 2,
    space: 10,
  ),
  radioTheme: const RadioThemeData(
    fillColor: WidgetStatePropertyAll(Color(0xfff65b1c)),
  ),
  dialogTheme: DialogThemeData(backgroundColor: const Color(0xffF9FAFD)),
  tabBarTheme: TabBarThemeData(indicatorColor: const Color(0x000000ff)),
);
