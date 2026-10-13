import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Page gula je canvas e design kora hoyechilo tar logical size.
///
/// android_pos portrait e lock kora. Target 8.5" tablet (1200x1920 px,
/// ~240dpi => DPR 1.5) er logical size 800x1280, tai oi device e scale ~1.0.
///
/// Tune korte: UI aro CHOTO chaile ei size BARAN (jemon 840x1340),
/// aro BORO chaile KOMAN (jemon 760x1216). Onno kichu change lagbe na.
const Size kDesignSize = Size(800, 1280);

/// Font scaling resolver.
///
/// Pure proportional scale e choto font (12-14) porar ojoggo hoye jay.
/// Tai choto font kom shrink kore, boro font beshi:
///   sp = fontSize * s + (1 - s) * 8
/// Design size er screen e (s = 1) value hubohu same thake.
double dampedFontSize(num fontSize, ScreenUtil su) {
  final double s = math.min(su.scaleWidth, su.scaleHeight);
  return fontSize * s + (1 - s) * 8;
}

/// Button/tap area er minimum size (dp). Scale korar por er niche jabe na,
/// jate tablet e touch korte kosto na hoy.
const double kMinTouch = 40;

extension ScreenUtilMin on num {
  /// `.r` er motoi scale kore, kintu [min] er choto hoy na.
  /// Jemon `48.rMin(kMinTouch)` -> choto screen e 40, boro screen e 48+.
  double rMin(double min) => math.max(this.r, min);
}

/// Theme er text style gulo (titleMedium, bodyLarge...) o `.sp` er moto
/// eki formula te scale kore: size * s + (1 - s) * 8.
TextTheme scaleTextTheme(TextTheme t) {
  final double s = math.min(ScreenUtil().scaleWidth, ScreenUtil().scaleHeight);
  return t.apply(fontSizeFactor: s, fontSizeDelta: (1 - s) * 8);
}
