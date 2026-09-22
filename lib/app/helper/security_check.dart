import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SecurityCheck {
  static Future<bool> isAllow() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo? info = await deviceInfo.androidInfo;
      String deviceId =Preferences.deviceId;
        
      String productId = info.device;
      String? wfiIP = await NetworkInfo().getWifiIP();

      final dio = Dio();
      // ignore: deprecated_member_use
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
      // data
      final data = {
        "deviceId": deviceId,
        "productId": productId,
        "networkId": wfiIP ?? "N/A",
      };
      kLogger.i(data);
      final response = await dio.post(URLS.securityCheck, data: data);
      kLogger.e(response.data);
      if (response.statusCode == 200) {
        if (response.data["data"]["isValid"] == true) return true;
      }
      return false;
    } catch (e) {
      kLogger.e(e);
      return false;
    }
  }
}