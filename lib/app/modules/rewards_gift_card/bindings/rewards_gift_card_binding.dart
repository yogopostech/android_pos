import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/controller/gift_card_controller.dart';


class RewardsGiftCardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RewardsGiftCardController>(() => RewardsGiftCardController());
  }
}
