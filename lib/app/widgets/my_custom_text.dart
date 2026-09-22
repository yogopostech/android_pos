import 'package:flutter/material.dart';

class MyCustomText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final FontStyle? fontStyle;
  final double? height;
  final String? fontFamily;
  final TextDecoration? decoration;

  const MyCustomText(
    this.text, {
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.fontStyle,
    this.height,
    this.fontFamily,
    this.decoration,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: textAlign ?? TextAlign.start,
        overflow: overflow ?? TextOverflow.ellipsis,
        maxLines: maxLines,
        style: TextStyle(
            color: color ?? Theme.of(context).colorScheme.surface,
            fontSize: fontSize ?? 16,
            height: height ?? 1,
            fontWeight: fontWeight ?? FontWeight.w400,
            fontStyle: fontStyle ?? FontStyle.normal,
            fontFamily: fontFamily,
            decoration: decoration
        ),
      );
}
