import 'package:dio/dio.dart';
import 'dart:io';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';
import 'package:yogo_pos/app/helper/security_check.dart';
import 'package:yogo_pos/app/modules/setting/controllers/payments_controller.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yogo_pos/config/dark_theme.dart';
import 'package:yogo_pos/config/light_theme.dart';
import 'package:get/get.dart';
import 'app/services/base/api_service.dart';
import 'app/services/base/dio_interceptor.dart';
import 'app/services/base/preferences.dart';
import 'app/services/bindings/base_binding.dart';
import 'app/routes/app_pages.dart';

late final ProviderContainer providerContainer;

Future<void> main() async {
  // Main app instance
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// Shared Preferences
  await Preferences.init();
  Preferences.removeItem(Preferences.ACCESS_TOKEN);
  Preferences.removeItem(Preferences.USER_INFO);
  if (Preferences.stationId.isEmpty) {
    Preferences.stationId = Uuid().v4();
  }
  // Set device id
  if (Preferences.deviceId.isEmpty) {
    Preferences.deviceId = Uuid().v4();
  }

  providerContainer = ProviderContainer();

  // if (!kDebugMode) {
  //   bool isAllow = await SecurityCheck.isAllow();
  //   if (!isAllow) {
  //     exit(0);
  //   }
  // }

  tz.initializeTimeZones();

  /// mobile orientation off
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  /// Status bar hide
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );

  /// Initialize the dioflutter
  final dio = Dio();
  // ignore: deprecated_member_use
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
  // Initialize the dio instance
  dio.interceptors.add(DioInterceptor());

  /// Add the dio instance to the api service
  final apiService = ApiService(dio: dio);
  Get.put(BaseController(apiService: apiService), permanent: true);
  Get.put(ConfigController(), permanent: true);
  //  Get.put(ClockInController(), permanent: true);
  Get.put(PaymentsController(), permanent: true);
  FlutterNativeSplash.remove();
  runApp(
    UncontrolledProviderScope(
      container: providerContainer,
      child: MyApp(apiService: apiService),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final ApiService apiService;
  const MyApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,

        themeMode: ConfigController.to.isLightTheme
            ? ThemeMode.light
            : ThemeMode.dark,
        theme: lightTheme,
        darkTheme: darkTheme,
        initialBinding: BaseBinding(apiService: apiService),
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );
  }
}
