import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/gift_card_controller.dart';
import 'package:yogo_pos/app/modules/setting/controllers/caller_id_controller.dart';
import 'package:yogo_pos/app/modules/setting/controllers/printers_controller.dart';
import 'package:get/get.dart';

import '../controllers/payments_controller.dart';
import '../controllers/setting_controller.dart';
import '../controllers/weighing_scale_controller.dart';

class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SettingController(), permanent: true);

    Get.put(PrintersController(), permanent: true);
    Get.put(PaymentsController(), permanent: true);
    Get.put(GiftCardController(), permanent: true);
  }
}
