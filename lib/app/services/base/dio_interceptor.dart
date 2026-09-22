import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import 'package:yogo_pos/app/routes/app_pages.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';

import 'preferences.dart';

class DioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = Preferences.accessToken;
    final branchToken = Preferences.branchToken;
    final stationId = Preferences.stationId;
    final appVersion = BaseController.to.packageInfo?.version ?? '1.0.0';
    if (kDebugMode) {
      kLogger.i('DioInterceptor onRequest called');
    }

    if (branchToken.isNotEmpty) {
      // options.headers['access-token'] =token;
      options.headers['restauranttoken'] = 'Bearer $branchToken';
    }
    if (stationId.isNotEmpty) {
      options.headers['X-Station-ID'] = stationId;
    }

    /// add token to header if user is logged in

    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['X-App-Version'] = appVersion;

    /// set options
    options.validateStatus = (_) => true;
    options.receiveDataWhenStatusError = true;
    options.responseType = ResponseType.json;

    if (kDebugMode) {
      kLogger.e('URL: ${options.method} ${options.uri}');
      kLogger.i("Header: ${options.headers}");
      kLogger.i("Body: ${options.data}");
      kLogger.i("QueryParameters ${options.queryParameters}");
      if (options.data is FormData) {
        final formData = options.data as FormData;
        for (var element in formData.files) {
          kLogger.i("${element.key}:::${element.value.filename}");
        }
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.statusCode == 200) {
      final token = response.data['token'];
      if (token != null && token is String) {
        Preferences.accessToken = token;
      }
    } else if (response.statusCode == 498) {
      await BaseController.to.logout();
      getx.Get.offAllNamed(Routes.SIGN_IN);
    }
    // if (kDebugMode) {
    //   kLogger.i('Response: ${response.statusCode} ${response.statusMessage}');
    //   kLogger.i(response.data);
    // }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      kLogger.e('Error: ${err.message}');
    }
    super.onError(err, handler);
  }
}
