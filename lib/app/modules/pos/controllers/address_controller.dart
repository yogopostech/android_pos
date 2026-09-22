import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/pos/repo/pos_repo.dart';
import 'package:yogo_pos/app/utils/logger.dart';

import '../order/models/address_model.dart';

class AddressController extends GetxController {
  static AddressController get to => Get.find();
  List<AddressModel> addresses = [];

  getAddress(String query) async {
    addresses = await PosRepo.fetchAddrassSuggestions(query);
    kLogger.e(addresses.length);
    update();
  }
}
