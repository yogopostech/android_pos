extension IdFormatter on String {
  String toFormattedId() {
    if (length != 12) return this; // avoid crash if invalid

    final part1 = substring(0, 4);
    final part2 = substring(4, 8);
    final part3 = substring(8, 12);

    return "$part1-$part2-$part3";
  }
}
