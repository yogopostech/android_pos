import 'package:yogo_pos/app/modules/auth/controllers/auth_controller.dart';
import 'package:yogo_pos/app/modules/pos/controllers/orders_controller.dart';
import 'package:yogo_pos/app/modules/pos/delivery/controllers/delivery_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/controllers/dine_in_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/table_mapping_managment_controller.dart';
import 'package:yogo_pos/app/modules/pos/onlineOrder/controllers/online_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/controllers/order_controller.dart';
import 'package:yogo_pos/app/modules/setting/controllers/general_controller.dart';
import 'package:yogo_pos/app/modules/setting/controllers/printers_controller.dart';
import 'package:yogo_pos/app/modules/setting/controllers/setting_controller.dart';
import 'package:yogo_pos/app/modules/setting/controllers/weighing_scale_controller.dart';
import 'package:get/get.dart';

import '../controllers/pos_controller.dart';
import '../takeout/controllers/takeout_controller.dart';

class PosBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PosController>(PosController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<DineInController>(DineInController(), permanent: true);
    Get.put<TableMappingController>(TableMappingController(), permanent: true);
    Get.put<DineInOrderController>(DineInOrderController(), permanent: true);
    Get.put<OrdersController>(OrdersController(), permanent: true);
    Get.put<OrderController>(OrderController(), permanent: true);
    Get.put<TakeOutController>(TakeOutController(), permanent: true);
    Get.put<DeliveryController>(DeliveryController(), permanent: true);
    Get.put<OnlineOrderController>(OnlineOrderController(), permanent: true);

    //settings
    Get.put(SettingController(), permanent: true);
    Get.put(WeighingScaleController(), permanent: true);
    Get.put(PrintersController(), permanent: true);
    Get.put(GeneralController(), permanent: true);
  }
}
