// lib/core/utils/string_extensions.dart  (path tomar moto rakho)

extension TitleCaseX on String {
  /// 'funds added successfully' -> 'Funds Added Successfully'
  /// Proti word er first char capital, baki char as-is.
  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
