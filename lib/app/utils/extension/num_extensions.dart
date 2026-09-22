import 'package:decimal/decimal.dart';

extension NumExtensions on num {
  num toFixed2() => num.parse(toStringAsFixed(2));
  num toFixed(int value) => num.parse(toStringAsFixed(value));
}

extension NumToDecimal on num {
  String toCents() => (Decimal.parse(toStringAsFixed(2)) * Decimal.fromInt(100))
      .toBigInt()
      .toString();
  int toCentsInt() => (Decimal.parse(toStringAsFixed(2)) * Decimal.fromInt(100))
      .toBigInt()
      .toInt();
}
