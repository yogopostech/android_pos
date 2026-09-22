import 'package:geolocator/geolocator.dart';

class DeviceLocation {
  /// Gets the current device location after waiting for 10 seconds.
  static Future<Position?> getLocationWithDelay() async {
    await Future.delayed(const Duration(seconds: 10));
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return null;
    }
    return await Geolocator.getCurrentPosition();
  }
}
