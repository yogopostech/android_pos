import 'package:flutter/material.dart';

class KeyModel {
  final String value;
  final double width;
  final double height;
  final Color bgColor;
  final Color bgDarkColor;
  final Color textColor;
  final Color textDarkColor;
  KeyModel({
    required this.value,
    this.width = 87,
    this.height = 80,
    this.bgColor = Colors.white,
    this.bgDarkColor = const Color(0xff363636),
    this.textColor = const Color.fromARGB(255, 34, 34, 34),
    this.textDarkColor = const Color(0xffBABABA),
  });
}
