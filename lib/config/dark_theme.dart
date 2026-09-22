import 'package:flutter/material.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/config/fonts.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkTheme = ThemeData(
  // ***** Color *****
  primaryColor: const Color(0xfff65b1c),
  primaryColorDark: const Color(0xff0c0c0c),
  primaryColorLight: const Color(0xff118A00),
  canvasColor: const Color(0xff191919),
  cardColor: const Color(0xff2F2D31),
  disabledColor: const Color(0xffC4CACF),
  dividerColor: const Color(0xff5B636B),
  hintColor: const Color(0xffA0A3A9),
  focusColor: Colors.grey.shade700,
  highlightColor: const Color(0x000000ff),
  shadowColor: const Color(0x000000ff),
  splashColor: Colors.blueGrey.shade600,
  // scaffoldBackgroundColor: const Color(0xff0c0c0c),
  scaffoldBackgroundColor: Colors.black,
  secondaryHeaderColor: null,
  hoverColor: const Color(0x000000ff),
  unselectedWidgetColor: const Color(0xffEEEEEE),
  // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  colorScheme: const ColorScheme.dark(
    error: Color(0xffE7474B),
    surface: Color(0xffEDF2F7),
  ),

  // *****  Others Color *****
  // primarySwatch: MyFunc.createMaterialColor(const Color(0xff8A0051)),
  // colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
  //     .copyWith(background: const Color(0xffFFFFFF)),
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

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xff0274ff);
      }
      return const Color.fromARGB(255, 0, 0, 0);
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color.fromARGB(255, 66, 66, 66);
      }
      return Colors.white;
    }),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.hovered)) {
        return const Color.fromARGB(50, 223, 223, 223).withAlpha(26);
      }
      return Colors.transparent;
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color.fromARGB(50, 223, 223, 223).withAlpha(26);
      }
      return Colors.black;
    }),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  //  datePickerTheme
  datePickerTheme: DatePickerThemeData(
    backgroundColor: const Color(0xff2F2D31),
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
  tooltipTheme: TooltipThemeData(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
    ),
    textStyle: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
  ),
  //  timePickerTheme
  timePickerTheme: const TimePickerThemeData(
    backgroundColor: Color(0xff2F2D31),
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
  // *****  brightness *****
  // ****** Font Family ******
  fontFamily: Fonts.primary,
  // ****** Card Theme ******
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
  badgeTheme: const BadgeThemeData(
      offset: Offset(-16, 6),
      textColor: Colors.black,
      backgroundColor: Colors.white,
      padding: EdgeInsets.all(4),
      textStyle: TextStyle(fontWeight: FontWeight.w600)),
  // ****** Text Theme ******
  textTheme: GoogleFonts.robotoTextTheme(const TextTheme(
    //******  Label  ******
    labelLarge: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xffEDF2F7)),
    labelMedium: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xffEDF2F7)),
    labelSmall: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xffEDF2F7)),

    //******  Body  ******
    bodyLarge: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xffEDF2F7)),
    bodyMedium: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xffEDF2F7)),
    bodySmall: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Color(0xffEDF2F7)),
    //******  Title  ******
    titleLarge: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Color(0xffEDF2F7)),
    titleMedium: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Color(0xffEDF2F7)),
    titleSmall: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xffEDF2F7)),
    //******  HeadLine  ******
    headlineLarge: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: Color(0xffEDF2F7)),
    headlineMedium: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Color(0xffEDF2F7)),
    headlineSmall: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xffEDF2F7)),
    //******  Display  ******
    displayLarge: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 60,
        fontWeight: FontWeight.w700,
        color: Color(0xffEDF2F7)),
    displayMedium: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 55,
        fontWeight: FontWeight.w700,
        color: Color(0xffEDF2F7)),
    displaySmall: TextStyle(
        fontFamily: Fonts.primary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Color(0xffEDF2F7)),
  )),

  scrollbarTheme: ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(Colors.grey.shade800),
    trackColor: WidgetStateProperty.all(Colors.grey.shade500),
    crossAxisMargin: -12,
  ),
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade300,
    thickness: 2,
    space: 10,
  ),
  radioTheme: const RadioThemeData(
    fillColor: WidgetStatePropertyAll(
      Color(0xfff65b1c),
    ),
  ),
  dialogTheme: DialogThemeData(backgroundColor: const Color(0xffF9FAFD)),
  tabBarTheme: TabBarThemeData(indicatorColor: const Color(0x000000ff)),
);
