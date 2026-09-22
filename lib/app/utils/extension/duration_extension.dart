extension NullableDurationFormatting on Duration? {
  String formatDateDifference() {
    if (this == null) {
      return "No difference"; // Handle null case
    }

    int days = this!.inDays;
    int hours = this!.inHours % 24;
    int minutes = this!.inMinutes % 60;

    return '$days:$hours:$minutes';
  }
}
