import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';
import '../services/base/preferences.dart';

class RouteWlcomMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (Preferences.branchToken.isNotEmpty) {
      return const RouteSettings(name: Routes.AUTH);
    } else {
      return null;
    }
  }
}
