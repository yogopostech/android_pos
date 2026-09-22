import 'dart:io';
import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/setting/models/settings_menu_model.dart';
import 'package:yogo_pos/app/modules/setting/views/pages/caller_id.dart';
import 'package:yogo_pos/app/modules/setting/views/pages/general.dart';
import 'package:yogo_pos/app/modules/setting/views/pages/payments.dart';
import 'package:yogo_pos/app/modules/setting/views/pages/printers.dart';
import 'package:yogo_pos/app/modules/setting/views/pages/services.dart';
import 'package:yogo_pos/app/modules/setting/views/pages/time_sheet_report.dart';
import 'package:yogo_pos/app/modules/setting/views/pages/weighing_scale.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/setting/widgets/datacandy_screen.dart';

class SettingController extends GetxController {
  static SettingController get to => Get.find();
  int menuIndex = 0;
  List<SettingsMenuModel> menuList = [
    SettingsMenuModel(
      child: const Printers(),
      icon: Icons.print,
      title: "Printers",
    ),
    SettingsMenuModel(
      child: const Payments(),
      icon: Icons.payment,
      title: "Payment Terminal",
    ),
    // SettingsMenuModel(
    //   child: const CallerId(),
    //   icon: Icons.call,
    //   title: "Caller ID",
    // ),

    // SettingsMenuModel(
    //   child: const WeighingScale(),
    //   icon: Icons.scale_sharp,
    //   title: "Weighing Scale",
    // ),
    SettingsMenuModel(
      child: const Services(),
      icon: Icons.design_services_outlined,
      title: "Modules",
    ),

    SettingsMenuModel(
      child: const General(),
      icon: Icons.settings,
      title: "General",
    ),

    SettingsMenuModel(
      child: const UpdateDatCandyGiftCardView1(),
      icon: Icons.credit_card,
      title: "Gift Card",
    ),

    //? must be last item in the list
    //? if need to remove this item, remove the code in the view as well
    SettingsMenuModel(
      child: const TimeSheetReport(),
      icon: Icons.access_time,
      title: "Times Sheets",
    ),
    // SettingsMenuModel(
    //     child: const About(), icon: Icons.info_rounded, title: "About"),
  ];
  // change menu
  onChangeMenu(int index) {
    menuIndex = index;
    update();
  }

  void closeApp() {
    exit(0); // Closes the app immediately.
  }
}
