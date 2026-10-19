import 'package:uuid/uuid.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';

extension OrderModelExtensions on OrderModel {
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

  OrderModel replicateSelectedItemsByIds(
    List<String> selectedItemIds, {
    DateTime? stampedAt,
  }) {
    if (selectedItemIds.isNotEmpty) {
      // Replicated carts are new items: give them a fresh timestamp instead
      // of copying the original cart's createdAt.
      final ts = stampedAt ?? DateTime.now().toUtc();
      List<CartModel> updatedCarts = List.from(carts);

      var uuid = Uuid();
      for (final cart in carts) {
        if (selectedItemIds.contains(cart.id)) {
          var replicatedCart = cart.copyWith(
            id: uuid.v4(), // generate a new unique ID
            isUpdated: false,
            createdAt: ts,
            updatedAt: ts,
          );
          updatedCarts.add(replicatedCart);
        }
      }

      return copyWith(carts: updatedCarts);
    }
    return this;
  }
}
