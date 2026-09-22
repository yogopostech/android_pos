import 'package:uuid/uuid.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';

extension OrderModelExtensions on OrderModel {
  // This extension method converts the order to a bar order
  // OrderModel toBar() {
  //   final allowedItemTypes = {
  //     "liquor",
  //     "non alcoholic drinks",
  //     "drinks",
  //     "carbonated",
  //     "weighing scale"
  //   };

  //   return copyWith(
  //     carts: carts.where((cart) {
  //       return allowedItemTypes.contains(cart.itemType.toLowerCase());
  //     }).toList(),
  //   );
  // }

  // // This extension method converts the order to a kitchen order
  // OrderModel toKitchen() {
  //   final allowedItemTypes = {
  //     "dessert",
  //     "veg",
  //     "non veg",
  //     "food",
  //     "single item",
  //   };
  //   return copyWith(
  //     carts: carts.where((cart) {
  //       return allowedItemTypes.contains(cart.itemType.toLowerCase());
  //     }).toList(),
  //   );
  // }
  OrderModel toBar() {
    final bool isSkipEmptyPrinter = Preferences.skipEmptyPrinter;
    final allowedItemTypes = {
      "liquor",
      "non alcoholic drinks",
      "drinks",
      "carbonated",
      "weighing scale",
    };

    return copyWith(
      carts: carts.where((cart) {
        if (isSkipEmptyPrinter && cart.printers.isEmpty) return false;
        return allowedItemTypes.contains(cart.itemType.toLowerCase());
      }).toList(),
    );
  }

  // This extension method converts the order to a kitchen order
  OrderModel toKitchen() {
    final bool isSkipEmptyPrinter = Preferences.skipEmptyPrinter;
    final allowedItemTypes = {
      "dessert",
      "veg",
      "non veg",
      "food",
      "single item",
    };
    return copyWith(
      carts: carts.where((cart) {
        if (isSkipEmptyPrinter && cart.printers.isEmpty) return false;
        return allowedItemTypes.contains(cart.itemType.toLowerCase());
      }).toList(),
    );
  }

  // This extension method filters the carts that are not updated
  OrderModel toNonUpdate() {
    return copyWith(carts: carts.where((cart) => !cart.isUpdated).toList());
  }

  // This extension method filters the carts by indices
  // OrderModel filterCartsByIndices(List<int> indices) {
  //   final filteredCarts = indices.map((index) => carts[index]).toList();
  //   return copyWith(
  //     carts: filteredCarts,
  //   );
  // }
  OrderModel filterCartsByIds(List<String> ids) {
    final filteredCarts = carts.where((cart) => ids.contains(cart.id)).toList();

    return copyWith(carts: filteredCarts);
  }

  // This extension method removes selected items from the order
  OrderModel removeSelectedItemsByIds(List<String> selectedItemIds) {
    if (selectedItemIds.isEmpty) return this;

    // Remove carts whose id is in selectedItemIds
    final updatedCarts = carts
        .where((cart) => !selectedItemIds.contains(cart.id))
        .toList();

    return copyWith(carts: updatedCarts);
  }
  // This extension method replicates selected items by indices
  // OrderModel replicateSelectedItems(List<String> selectedItemList) {
  //   if (selectedItemList.isNotEmpty) {
  //     // Convert list of string indices to list of int indices
  //     var indicesToReplicate = selectedItemList.map((index) => int.parse(index)).toList();

  //     // Replicate items at specified indices
  //     List<CartModel> updatedCarts = List.from(carts);
  //     for (int index in indicesToReplicate) {
  //       if (index < updatedCarts.length) {
  //         updatedCarts.add(updatedCarts[index]);
  //       }
  //     }

  //     return copyWith(carts: updatedCarts);
  //   }
  //   return this;
  // }
  OrderModel replicateSelectedItemsByIds(List<String> selectedItemIds) {
    if (selectedItemIds.isNotEmpty) {
      List<CartModel> updatedCarts = List.from(carts);

      var uuid = Uuid();
      for (final cart in carts) {
        if (selectedItemIds.contains(cart.id)) {
          var replicatedCart = cart.copyWith(
            id: uuid.v4(), // generate a new unique ID
            isUpdated: false,
          );
          updatedCarts.add(replicatedCart);
        }
      }

      return copyWith(carts: updatedCarts);
    }
    return this;
  }

  // List<OrderModel> separateByPrinter() {
  //   // Group carts by printer
  //   final Map<String?, List<CartModel>> groupedCarts = {};
  //   for (var cart in carts) {
  //     groupedCarts.putIfAbsent(cart.printer, () => []).add(cart);
  //   }
  //   // Create a new OrderModel for each printer group
  //   return groupedCarts.entries.map((entry) {
  //     return copyWith(
  //       carts: entry.value,
  //     );
  //   }).toList();
  // }
}
