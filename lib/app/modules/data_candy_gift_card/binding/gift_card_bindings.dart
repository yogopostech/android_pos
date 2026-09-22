import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/gift_card_controller.dart';

class GiftCardBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GiftCardController>(()=>GiftCardController());
  }

}