import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Page gula je canvas e design kora hoyechilo tar logical size.
/// (1920x1080 monitor @125% scaling = 1536x864.)
///
/// Samsung Galaxy Tab A7 Lite (landscape, immersive): 1340x800 px, DPR ~1.33
/// => logical ~1007x601, tai .r scale hoy ~0.66.
///
/// Tune korte: UI aro CHOTO chaile ei size BARAN (jemon 1680x945),
/// aro BORO chaile KOMAN (jemon 1440x810). Onno kichu change lagbe na.
const Size kDesignSize = Size(1536, 864);

/// Font scaling resolver.
///
/// Pure proportional scale (fontSize * 0.66) e 12-14 er font Tab e porar
/// ojoggo hoye jay. Tai choto font kom shrink hoy, boro font beshi:
///   sp = fontSize * s + (1 - s) * 8
/// Tab A7 Lite e: 12 -> 10.6, 16 -> 13.2, 22 -> 17.2, 40 -> 29.
/// Design size er screen e (s = 1) value hubohu same thake.
double dampedFontSize(num fontSize, ScreenUtil su) {
  final double s = math.min(su.scaleWidth, su.scaleHeight);
  return fontSize * s + (1 - s) * 8;
}

/// Button/tap area er minimum size (dp). Scale korar por er niche jabe na,
/// jate Tab e touch korte kosto na hoy.
const double kMinTouch = 40;

extension ScreenUtilMin on num {
  /// `.r` er motoi scale kore, kintu [min] er choto hoy na.
  /// Jemon `48.rMin(kMinTouch)` -> Tab e 40, boro screen e 48+.
  double rMin(double min) => math.max(this.r, min);
}

/// Theme er text style gulo (titleMedium, bodyLarge...) o `.sp` er moto
/// eki formula te scale kore: size * s + (1 - s) * 8.
TextTheme scaleTextTheme(TextTheme t) {
  final double s = math.min(ScreenUtil().scaleWidth, ScreenUtil().scaleHeight);
  return t.apply(fontSizeFactor: s, fontSizeDelta: (1 - s) * 8);
}
