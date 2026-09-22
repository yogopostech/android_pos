import 'package:yogo_pos/app/helper/discount_type.dart';
import 'package:yogo_pos/app/modules/pos/order/models/discount_model.dart';

extension DiscountExtension on Discount? {
  String get displayValue {
    if (this == null) {
      return "\$0";
    } else if (this!.type == DiscountType.percentage) {
      return "${this!.value}%";
    } else {
      return "\$${this!.value}";
    }
  }
}
