import 'package:yogo_pos/app/helper/discount_type.dart';

class Discount {
  final DiscountType type;
  final num value;

  Discount({
     this.type=DiscountType.flat,
     this.value=0,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      type: DiscountTypeExtension.fromJson(json['type']),
      value: json['value'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'value': value,
    };
  }
}
