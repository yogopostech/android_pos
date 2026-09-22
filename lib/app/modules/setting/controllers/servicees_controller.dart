import 'package:get/get.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import '../../../utils/urls.dart';

class ServicesController extends GetxController {
  static ServicesController get to => Get.find<ServicesController>();

  bool initPosDelivery =
      BaseController.to.restaurantDetails?.restaurant.posDelivery ?? false;
  bool initOloDelivery =
      BaseController.to.restaurantDetails?.restaurant.oloDelivery ?? false;
  bool initOloTakeOut =
      BaseController.to.restaurantDetails?.restaurant.pickup ?? false;

  Future<void> onUpdateRestrurent({
    bool? posDelivery,
    oloDelivery,
    oloTakeOut,
    hybridPaymentOption,
  }) async {
    if (posDelivery == null && oloDelivery == null && oloTakeOut == null) {
      return;
    }
    var data = {
      if (posDelivery != null) "posDelivery": posDelivery,
      if (oloDelivery != null) "oloDelivery": oloDelivery,
      if (oloTakeOut != null) "pickup": oloTakeOut,
      if (hybridPaymentOption != null)
        "hybridPaymentOption": hybridPaymentOption,
    };
    PopupDialog.showLoadingDialog();
    var res = await BaseController.to.apiService.makePatchRequest(
      URLS.restrurentUpdate,
      data,
    );
    kLogger.e(res.data);
    await BaseController.to.getRestaurantsDetailsFromAPI();
    PopupDialog.closeLoadingDialog();
    if (res.statusCode == 200) {
      // await BaseController.to.getRestaurantsDetailsFromAPI();
      initPosDelivery = posDelivery ?? initPosDelivery;
      initOloDelivery = oloDelivery ?? initOloDelivery;
      initOloTakeOut = oloTakeOut ?? initOloTakeOut;
      update();
    }
  }
}
