// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import '../utils/static_colors.dart';

class PrimaryBtn extends StatelessWidget {
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final VoidCallback onPressed;
  final double? borderRadius;
  final double? height;
  final double? width;
  final double? borderWidth;
  final double? elevation;
  final String text;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;
  final bool isOutline;
  final bool isdisabled;
  final double textMaxSize;
  final double textMinSize;
  final int? maxLines;
  final FontWeight? fontWeight;

  const PrimaryBtn(
      {super.key,
      this.color,
      this.textColor,
      this.borderColor,
      required this.onPressed,
      this.borderRadius,
      required this.text,
      this.style,
      this.height,
      this.width,
      this.elevation,
      this.padding,
      this.isOutline = false,
      this.isdisabled = false,
      this.textMaxSize = 18,
      this.textMinSize = 14,
      this.maxLines,
      this.fontWeight,
      this.borderWidth});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SizedBox(
      height: height ?? 48,
      width: width,
      child: ElevatedButton(
        onPressed: () {
          if (!isdisabled) {
            BaseController.to.playTapSound();
            onPressed();
          }
        },
        style: ButtonStyle(
          // border raius

          elevation: WidgetStateProperty.resolveWith<double>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return isdisabled ? 0 : 0; // Elevation when hovered
            }
            return 0.0; // Normal elevation
          }),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            // if (states.contains(MaterialState.)) {
            //   return theme.disabledColor.withAlpha(153);
            // }
            return isdisabled ? color : color ?? theme.primaryColor;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            // if (states.contains(MaterialState.)) {
            //   return theme.disabledColor.withAlpha(153);
            // }
            return isdisabled
                ? textColor?.withAlpha(204)
                : textColor ?? Colors.white;
          }),
          padding: WidgetStateProperty.all(
            padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 6),
            ),
          ),
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (isOutline == true) {
              return BorderSide(
                color: borderColor ?? theme.colorScheme.surface,
                width: borderWidth ?? 1.5,
              );
            }
            return null;
          }),
          splashFactory: InkRipple.splashFactory,
          overlayColor:
              WidgetStateProperty.all(Colors.transparent), // Remove hover color
          mouseCursor: WidgetStateProperty.resolveWith<MouseCursor>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return isdisabled
                  ? SystemMouseCursors.noDrop
                  : SystemMouseCursors.click; // Change cursor when hovered
            }
            return SystemMouseCursors.basic; // Default cursor
          }), // Remove hover color
        ),
        child: AutoSizeText(
          text,
          maxLines: maxLines ?? 2, maxFontSize: textMaxSize,
          minFontSize: textMinSize,
          textAlign: TextAlign.center,
          style: style ??
              TextStyle(
                fontWeight: fontWeight,
                color: isdisabled
                    ? textColor ?? theme.colorScheme.surface.withAlpha(204)
                    : textColor ?? theme.colorScheme.surface,
              ),
          // overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class OutLineBtn extends StatelessWidget {
  final Color? color;
  final Color? textColor;
  final Widget child;
  final VoidCallback onPressed;
  final double? borderRadius;
  final double? height;
  final double? width;
  final double? elevation;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;
  final BorderSide? side;

  const OutLineBtn({
    super.key,
    this.color,
    this.textColor,
    required this.onPressed,
    this.borderRadius,
    this.style,
    this.height,
    this.width,
    this.elevation,
    this.padding,
    required this.child,
    this.side,
  });

  void playTapSound() {
    // AudioPlayer().play(AssetSource('audio/tap_sound_1.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return OutlinedButton(
      onPressed: () {
        playTapSound();
        onPressed();
      },
      style: OutlinedButton.styleFrom(
        elevation: elevation ?? 1,
        textStyle: style ?? theme.textTheme.labelLarge,
        // disabledBackgroundColor: kDisabledColor,
        // disabledForegroundColor: kDisabledTextColor,
        backgroundColor: color ?? Colors.transparent,
        foregroundColor: textColor ?? theme.primaryColorDark,
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
        ),
        // ****** Border color *******
        side: side ??
            BorderSide(
              color: theme.hintColor,
              width: 1,
            ),
      ),
      child: child,
    );
  }
}

class PrimaryBtnWithChild extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  final Color? textColor;
  final VoidCallback onPressed;
  final double? borderRadius;
  final double? height;
  final double? width;
  final double? elevation;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;
  final BorderSide? side;
  final bool isOutline;
  final AlignmentGeometry? alignment;

  const PrimaryBtnWithChild({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.textColor,
    required this.onPressed,
    this.borderRadius,
    this.style,
    this.height,
    this.width,
    this.elevation,
    this.padding,
    this.side,
    this.isOutline = false,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: () {
          BaseController.to.playTapSound();
          onPressed();
        },
        style: !isOutline
            ? ElevatedButton.styleFrom(
                elevation: elevation ?? 1,
                alignment: alignment,
                enabledMouseCursor: MouseCursor.uncontrolled,
                // textStyle: style ?? theme.textTheme.labelLarge,
                // disabledBackgroundColor: kDisabledColor,
                // disabledForegroundColor: kDisabledTextColor,
                backgroundColor: color ?? theme.primaryColor,
                foregroundColor: textColor ?? Colors.white,
                padding: padding ??
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 6),
                ),
                // ****** Border color *******
                side: side
                // const BorderSide(
                //   color: kPrimaryColor,
                //   width: 0,
                // ),
                )
            : ElevatedButton.styleFrom(
                enabledMouseCursor: MouseCursor.uncontrolled,
                elevation: 0,
                // textStyle: style ?? theme.textTheme.labelLarge,
                // disabledBackgroundColor: kDisabledColor,
                // disabledForegroundColor: kDisabledTextColor,
                backgroundColor: color ?? theme.scaffoldBackgroundColor,
                foregroundColor: borderColor ?? StaticColors.greenLightColor,
                // splashFactory: NoSplash.splashFactory,
                padding: padding ??
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 6),
                ),
                // ****** Border color *******
                side: side ??
                    BorderSide(
                      color: borderColor ?? theme.colorScheme.surface,
                      width: 1.75,
                    ),
              ),
        child: child,
      ),
    );
  }
}

// class OutLineBtn extends StatelessWidget {
//   final Color? backgroundColor;
//   final Widget child;
//   final Color? foregroundColor;
//   final VoidCallback? onPressed;
//   final double? borderRadius;
//   final EdgeInsetsGeometry? padding;
//   final double? height;
//   final double? width;
//   final TextStyle? textStyle;

//   const OutLineBtn(
//       {super.key,
//       this.backgroundColor,
//       this.foregroundColor,
//       this.onPressed,
//       this.borderRadius,
//       this.padding,
//       this.height,
//       this.width,
//       this.textStyle,
//       required this.child});

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     return SizedBox(
//       width: width,
//       height: height,
//       child: OutlinedButton(
//           style: OutlinedButton.styleFrom(
//             padding: padding ??
//                 const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//             foregroundColor: theme.primaryColor,
//             side:  BorderSide(width: 1, color: theme.dividerColor),
//             backgroundColor: backgroundColor ?? Colors.transparent,
//             disabledForegroundColor: Colors.white,
//             disabledBackgroundColor: theme.disabledColor,
//             textStyle: textStyle,
//             // shape: RoundedRectangleBorder(
//             //   borderRadius: BorderRadius.circular(
//             //       borderRadius ?? 16.r), // Change the border radius value
//             // ),
//           ),
//           onPressed: onPressed,
//           child: child),
//     );
//   }
// }

// class GradientBtn extends StatelessWidget {
//   const GradientBtn({
//     super.key,
//     required this.text,
//     this.onTap,
//   });

//   final String text;
//   final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 130,
//         padding: const EdgeInsets.symmetric(
//           vertical: 13,
//         ),
//         decoration: BoxDecoration(
//           gradient: onTap == null
//               ? const LinearGradient(
//                   colors: [
//                     Color(0xffC2C2C2),
//                     Color(0xffC2C2C2)
//                   ], // Define your gradient colors
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 )
//               : const LinearGradient(
//                   colors: [
//                     Color(0xff9F9F9F),
//                     Color(0xff9F9F9F)
//                   ], // Define your gradient colors
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//           borderRadius:
//               BorderRadius.circular(50), // Optional: Add border radius
//         ),
//         child: Center(
//           child: Text(
//             text,
//             style: theme.textTheme.labelMedium,
//           ),
//         ),
//       ),
//     );
//   }
// }
