import 'dart:math';

/// UUID v4 generator — extra package lage na.
/// Chaile `uuid` package o use korte paro: Uuid().v4()
class IdempotencyKey {
  static final Random _rng = Random.secure();

  static String generate() {
    final b = List<int>.generate(16, (_) => _rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40; // version 4
    b[8] = (b[8] & 0x3f) | 0x80; // variant

    String hex(int s, int e) => b
        .sublist(s, e)
        .map((x) => x.toRadixString(16).padLeft(2, '0'))
        .join();

    return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
  }
}