import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';

class PaymentsController extends GetxController {
  static PaymentsController get to => Get.find();
  // bool isTerminal = Preferences.isTerminal;
  String terminalId = Preferences.terminalId;


  TextEditingController terminalIpController = TextEditingController();
  TextEditingController terminalPortController = TextEditingController();

  // fouse
  FocusNode terminalIpFocus = FocusNode();
  FocusNode terminalPortFocus = FocusNode();

  // set terminal ip
  void setTerminalIp(String value) {
    Preferences.terminalIp = value;
  }

  //set terminal port
  void setTerminalPort(int value) {
    Preferences.terminalPort = value;
  }

  void setTerminalId(String value) {
    Preferences.terminalId = value;
    terminalId = value;
  }



  @override
  void onReady() {
    terminalIpController.text = Preferences.terminalIp;
    terminalPortController.text = Preferences.terminalPort.toString();
    super.onReady();
  }

  @override
  void onClose() {
    terminalIpController.dispose();
    terminalPortController.dispose();
    terminalIpFocus.dispose();
    terminalPortFocus.dispose();
    super.onClose();
  }
}
