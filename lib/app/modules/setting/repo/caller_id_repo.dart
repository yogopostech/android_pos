import 'package:flutter/foundation.dart';
import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/urls.dart';

class CallerIdRepo {
  static Future<bool> call(CallerIdData data) async {
    try {
      var res = await BaseController.to.apiService.makePostRequest(
        URLS.callerId,
        data.toJson(),
      );
      if (res.statusCode != 200) {
        kLogger.e('CallerID API ${res.statusCode}: ${res.data}');
        return false;
      }
      kLogger.i('CallerID API: Success');
      return true;
    } catch (e, stackTrace) {
      kLogger.e('CallerID API Error: $e\nStackTrace: $stackTrace');
      return false;
    }
  }

  static Future<bool> acceptCall(String id) async {
    try {
      var body = {'callStatus': CallStatus.accepted.value};
      var res = await BaseController.to.apiService.makePatchRequest(
        '${URLS.baseURL}/caller-id/$id',
        body,
      );
      debugPrint("caller res => ${res.data}");
      if (res.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      debugPrint('CallerID API Error: $e\nStackTrace: $stackTrace');
      return false;
    }
  }
}
