 enum DiscountType { percentage, flat }

extension DiscountTypeExtension on DiscountType {
  String toJson() {
    switch (this) {
      case DiscountType.percentage:
        return 'PERCENTAGE';
      case DiscountType.flat:
        return 'FLAT';
    }
  }

  static DiscountType fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'PERCENTAGE':
        return DiscountType.percentage;
      case 'FLAT':
        return DiscountType.flat;
      default:
        throw Exception('Unknown DiscountType: $value');
    }
  }
}
