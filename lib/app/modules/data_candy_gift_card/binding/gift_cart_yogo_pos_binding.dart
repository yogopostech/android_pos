import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/yogopos_gift_card_controller.dart';


class GiftCardYogoPosBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => GiftCardYogoPosController());
  }

}