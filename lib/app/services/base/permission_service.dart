import 'dart:io';

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// One permission the app asks for before it starts.
///
/// [isRequired] false means the app still opens without it.
/// [minSdk] / [maxSdk] limit the ask to the Android versions that need it —
/// e.g. NEARBY_WIFI_DEVICES only exists from Android 13 (SDK 33).
class AppPermission {
  final Permission permission;
  final String label;
  final String reason;
  final IconData icon;
  final bool isRequired;
  final int? minSdk;
  final int? maxSdk;

  const AppPermission({
    required this.permission,
    required this.label,
    required this.reason,
    this.icon = Icons.verified_user_outlined,
    this.isRequired = true,
    this.minSdk,
    this.maxSdk,
  });
}

/// A permission plus where it currently stands on this device.
class AppPermissionStatus {
  final AppPermission item;
  final bool granted;
  final bool permanentlyDenied;

  const AppPermissionStatus({
    required this.item,
    required this.granted,
    required this.permanentlyDenied,
  });
}

class PermissionService {
  PermissionService._();

  /// Android API level of this device. 0 on other platforms.
  static int androidSdk = 0;

  // ---------------------------------------------------------------------------
  // ADD NEW PERMISSIONS HERE — nothing else in the app has to change.
  // Remember to declare the matching <uses-permission> in AndroidManifest.xml,
  // otherwise the request comes back permanently denied.
  // ---------------------------------------------------------------------------
  static const List<AppPermission> permissions = [
    AppPermission(
      permission: Permission.locationWhenInUse,
      label: 'Location',
      reason:
          'Lets the terminal read the Wi-Fi network it is on, so printers and '
          'other POS terminals can be reached.',
      icon: Icons.wifi_find_outlined,
      minSdk: 23,
    ),
    AppPermission(
      permission: Permission.nearbyWifiDevices,
      label: 'Nearby devices',
      reason:
          'Required on Android 13 and newer to talk to printers and terminals '
          'on the local network.',
      icon: Icons.print_outlined,
      minSdk: 33,
    ),

    // --- Bluetooth printers / payment terminals: uncomment when used ---
    // AppPermission(
    //   permission: Permission.bluetoothScan,
    //   label: 'Bluetooth scan',
    //   reason: 'Finds Bluetooth printers and payment terminals.',
    //   icon: Icons.bluetooth_searching,
    //   minSdk: 31,
    // ),
    // AppPermission(
    //   permission: Permission.bluetoothConnect,
    //   label: 'Bluetooth connect',
    //   reason: 'Connects to Bluetooth printers and terminals.',
    //   icon: Icons.bluetooth_connected,
    //   minSdk: 31,
    // ),

    // --- Camera (barcode / QR scanning): uncomment when used ---
    // AppPermission(
    //   permission: Permission.camera,
    //   label: 'Camera',
    //   reason: 'Scans barcodes and QR codes.',
    //   icon: Icons.qr_code_scanner,
    //   isRequired: false,
    // ),
  ];

  /// Reads the Android API level. Call once, before the first permission check.
  static Future<void> init() async {
    if (!Platform.isAndroid) return;
    try {
      androidSdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    } catch (_) {
      androidSdk = 0;
    }
  }

  /// The permissions that apply to this device.
  static List<AppPermission> get applicable {
    if (!Platform.isAndroid) return const [];
    return permissions
        .where(
          (p) =>
              (p.minSdk == null || androidSdk >= p.minSdk!) &&
              (p.maxSdk == null || androidSdk <= p.maxSdk!),
        )
        .toList();
  }

  /// Every applicable permission with its current state — used by the gate
  /// screen so the user sees what is already done and what is left.
  static Future<List<AppPermissionStatus>> statuses() async {
    final result = <AppPermissionStatus>[];
    for (final item in applicable) {
      final status = await item.permission.status;
      result.add(
        AppPermissionStatus(
          item: item,
          granted: status.isGranted,
          permanentlyDenied: status.isPermanentlyDenied,
        ),
      );
    }
    return result;
  }

  /// Permissions still not granted. Optional ones are left out by default.
  static Future<List<AppPermission>> missing({bool requiredOnly = true}) async {
    final result = <AppPermission>[];
    for (final item in applicable) {
      if (requiredOnly && !item.isRequired) continue;
      if (!await item.permission.isGranted) result.add(item);
    }
    return result;
  }

  /// Asks for everything not granted yet and returns the ones still missing.
  /// A permission the user blocked for good is skipped — only the app settings
  /// screen can change it.
  static Future<List<AppPermission>> request() async {
    for (final item in applicable) {
      final status = await item.permission.status;
      if (status.isGranted || status.isPermanentlyDenied) continue;
      await item.permission.request();
    }
    return missing();
  }

  /// Asks for a single permission — used by the per-row button on the gate.
  static Future<void> requestOne(AppPermission item) async {
    final status = await item.permission.status;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }
    await item.permission.request();
  }

  /// True when at least one missing permission can only be fixed in Settings.
  static Future<bool> needsAppSettings() async {
    for (final item in await missing()) {
      if (await item.permission.isPermanentlyDenied) return true;
    }
    return false;
  }

  static Future<bool> openSettings() => openAppSettings();
}
