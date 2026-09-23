import 'package:yogo_pos/app/services/controller/base_controller.dart';

class OrderRepo {
  static List<String> myOrderTypes() {
    List<String> orderTypes = [];
    var dinein =
        BaseController.to.restaurantDetails?.restaurant.dineIn ?? false;
    var takeout =
        BaseController.to.restaurantDetails?.restaurant.takeout ?? false;
    // var online =
    //     BaseController.to.restaurantDetails?.restaurant.pickup ?? false;
    // var delivery =
    //     BaseController.to.restaurantDetails?.restaurant.posDelivery ?? false;

    if (takeout) orderTypes.add("TAKEOUT");
    if (dinein) orderTypes.add("DINE_IN");
    // if (online) orderTypes.add("ONLINE");
    // if (delivery) orderTypes.add("DELIVERY");

    // Add "ALL" if there are 2 or more items
    if (orderTypes.length >= 2) {
      orderTypes.insert(0, "ALL");
    }
    return orderTypes;
  }
}
