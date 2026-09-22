import 'package:geolocator/geolocator.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class LocationHelper {
  /// Returns distance in km (rounded up, min 1km). Shows error dialog if data is missing or invalid.
  static int? distanceInKm(double? latitude, double? longitude) {
    final deliveryData = BaseController.to.deliveryData;
    if (deliveryData == null) {
      PopupDialog.showErrorMessage("Unable to get delivery location data.");
      return null;
    }
    if (latitude == null || longitude == null) {
      PopupDialog.showErrorMessage("Invalid destination coordinates.");
      return null;
    }
    try {
      final meters = Geolocator.distanceBetween(
        deliveryData.latitude,
        deliveryData.longitude,
        latitude,
        longitude,
      );
      final km = meters / 1000.0;
      return km < 1 ? 1 : km.ceil();
    } catch (e, stack) {
      kLogger.e('Error in distanceInKm: $e\n$stack');
      PopupDialog.showErrorMessage("Failed to calculate distance.");
      return null;
    }
  }

  /// Calculates delivery fee. Returns null and shows error if not possible.
  static double? calculateDeliveryFee(
    double? latitude,
    double? longitude,
  ) {
    final deliveryData = BaseController.to.deliveryData;
    if (deliveryData == null) {
      PopupDialog.showErrorMessage("Delivery settings not found.");
      return null;
    }
    if (latitude == null || longitude == null) {
      PopupDialog.showErrorMessage("Invalid destination coordinates.");
      return null;
    }

    final distanceKm = distanceInKm(latitude, longitude);
    if (distanceKm == null) return null;

    if (distanceKm > deliveryData.maxDeliveryDistanceKm) {
      PopupDialog.showErrorMessage(
        "Delivery distance exceeds the maximum allowed (${deliveryData.maxDeliveryDistanceKm} km).",
      );
      return null;
    }

    return deliveryData.baseDeliveryFee + (deliveryData.perKmRate * distanceKm);
  }

  /// Checks if delivery is possible. Shows error if not.
  static bool isDeliveryPossible(
    double? latitude,
    double? longitude,
  ) {
    final deliveryData = BaseController.to.deliveryData;
    if (deliveryData == null) {
      PopupDialog.showErrorMessage("Delivery settings not found.");
      return false;
    }
    if (latitude == null || longitude == null) {
      PopupDialog.showErrorMessage("Invalid destination coordinates.");
      return false;
    }

    final distanceKm = distanceInKm(latitude, longitude);
    if (distanceKm == null) return false;

    if (distanceKm > deliveryData.maxDeliveryDistanceKm) {
      PopupDialog.showErrorMessage(
        "Delivery not possible: distance exceeds ${deliveryData.maxDeliveryDistanceKm} km.",
      );
      return false;
    }

    return true;
  }
}
