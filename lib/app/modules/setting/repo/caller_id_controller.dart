// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';
// import 'package:yogo_pos/app/modules/setting/repo/incoming_call_dialog.dart';
// import 'package:yogo_pos/app/modules/setting/repo/serial_caller_id_service.dart';

// class CallerIdController extends GetxController {
//   final SerialCallerIdService _service = Get.find<SerialCallerIdService>();

//   StreamSubscription<CallerIdData>? _subscription;

//   final currentCall = Rxn<CallerIdData>();
//   final callHistory = <CallerIdData>[].obs;

//   bool _dialogOpen = false;

//   // Duplicate guard
//   String? _lastPhone;
//   DateTime? _lastTime;

//   @override
//   void onInit() {
//     super.onInit();
//     _subscribe();
//   }

//   void _subscribe() {
//     _subscription = _service.callStream.listen((data) {
//       if (_isDuplicate(data)) {
//         print('[CallerID] Duplicate skipped');
//         return;
//       }
//       currentCall.value = data;
//       callHistory.insert(0, data);
//       if (callHistory.length > 50) callHistory.removeLast();
//       _showDialog(data);
//     });
//   }

//   bool _isDuplicate(CallerIdData data) {
//     final now = DateTime.now();
//     if (_lastPhone == data.phoneNumber &&
//         _lastTime != null &&
//         now.difference(_lastTime!).inSeconds < 10) {
//       return true;
//     }
//     _lastPhone = data.phoneNumber;
//     _lastTime = now;
//     return false;
//   }

//   void _showDialog(CallerIdData data) {
//     if (_dialogOpen) Get.back();
//     _dialogOpen = true;
//     Get.dialog(
//       IncomingCallDialog(callerData: data),
//       barrierDismissible: false,
//       barrierColor: Colors.black.withOpacity(0.4),
//     ).then((_) => _dialogOpen = false);
//   }

//   void dismissCurrentCall() {
//     currentCall.value = null;
//     if (_dialogOpen) Get.back();
//   }

//   @override
//   void onClose() {
//     _subscription?.cancel();
//     super.onClose();
//   }
// }
