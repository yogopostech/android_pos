import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Page gula je canvas e design kora hoyechilo tar logical size.
/// HD (1280x720). Age chilo 1536x864 (1920x1080 monitor @125% scaling).
///
/// Samsung Galaxy Tab A7 Lite (landscape, immersive): 1340x800 px, DPR ~1.33
/// => logical ~1007x601, tai .r scale hoy ~0.79.
///
/// Tune korte: UI aro CHOTO chaile ei size BARAN (jemon 1536x864),
/// aro BORO chaile KOMAN (jemon 1152x648). Onno kichu change lagbe na.
const Size kDesignSize = Size(1280, 720);

/// Font scaling resolver.
///
/// Pure proportional scale (fontSize * 0.79) e choto font Tab e porar
/// ojoggo hoye jay. Tai choto font kom shrink hoy, boro font beshi:
///   sp = fontSize * s + (1 - s) * 8
/// Tab A7 Lite e: 12 -> 11.1, 16 -> 14.3, 22 -> 19.0, 40 -> 33.2.
/// Design size er screen e (s = 1) value hubohu same thake.
double dampedFontSize(num fontSize, ScreenUtil su) {
  final double s = math.min(su.scaleWidth, su.scaleHeight);
  return fontSize * s + (1 - s) * 8;
}

/// Button/tap area er minimum size (dp). Scale korar por er niche jabe na,
/// jate Tab e touch korte kosto na hoy.
const double kMinTouch = 40;

extension ScreenUtilMin on num {
  double rMin(double min) => math.max(r, min);
}

/// Theme er text style gulo (titleMedium, bodyLarge...) o `.sp` er moto
/// eki formula te scale kore: size * s + (1 - s) * 8.
TextTheme scaleTextTheme(TextTheme t) {
  final double s = math.min(ScreenUtil().scaleWidth, ScreenUtil().scaleHeight);
  return t.apply(fontSizeFactor: s, fontSizeDelta: (1 - s) * 8);
}
