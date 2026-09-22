

import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/transaction_controller.dart';

class GiftCardTransactionBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(()=> TransactionController());

  }

}