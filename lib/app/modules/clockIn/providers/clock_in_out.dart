// import 'dart:async';

// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/utils/urls.dart';

// part 'clock_in_out.g.dart'; // <- tomar actual file name onujayi change koro

// /// ClockInOut notifier (Riverpod annotation / code-gen).
// ///
// /// State = `int?`
// ///   - `null`  => not clocked in (idle / clocked out)
// ///   - `>= 0`  => clocked in, value is the elapsed seconds (counts up per second)
// @riverpod
// class ClockInOut extends _$ClockInOut {
//   Timer? _timer;

//   @override
//   int? build() {
//     ref.onDispose(_stopTimer); // cancel timer on dispose to avoid leaks
//     return null; // initially null
//   }

//   bool get isClockedIn => state != null;

//   /// Clock IN.
//   ///
//   /// [seconds] == 0 (default) => FRESH clock in => makes the server API call.
//   /// [seconds] > 0            => RESUME (app restart/reopen) => no API call,
//   ///                            just restores the local timer.
//   Future<void> clockIn({int seconds = 0}) async {
//     final isResume = seconds > 0;

//     if (!isResume) {
//       // Fresh clock in — send request to the server
//       var res = await BaseController.to.apiService.makePostRequest(
//         URLS.clockIn,
//         {},
//       );

//       // If not 201, clock in failed — keep state null, don't start the timer
//       if (res.statusCode != 201) {
//         return;
//       }

//       // Persist the returned employee data on successful clock in
//       await BaseController.to.setEmployeeData(res.data["data"]["employee"]);
//     }

//     state = seconds < 0 ? 0 : seconds;
//     _startTimer();
//   }

//   /// Clock OUT.
//   ///
//   /// [isClockout] `false` (default) => no API call, but stops the timer
//   ///                                   and sets state to null.
//   /// [isClockout] `true`  => sends the clock out request. On 200, stops the
//   ///                         timer and sets null. If not 200, nothing changes
//   ///                         (server still considers the user clocked in).
//   Future<void> clockOut({bool isClockout = false}) async {
//     if (isClockout) {
//       var res = await BaseController.to.apiService.makePostRequest(
//         URLS.clockOut,
//         {"clockId": BaseController.to.employeeData?.activeClock?.id ?? ""},
//       );

//       // If not 200, clock out failed — leave timer/state untouched
//       if (res.statusCode != 200) {
//         return;
//       }
//     }

//     // isClockout == false, or API returned 200 — either way, stop + null
//     _stopTimer();
//     state = null;
//   }

//   // ---------- internal helpers ----------

//   void _startTimer() {
//     _stopTimer(); // avoid duplicate timers
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       final current = state;
//       if (current == null) {
//         _stopTimer();
//         return;
//       }
//       state = current + 1;
//     });
//   }

//   void _stopTimer() {
//     _timer?.cancel();
//     _timer = null;
//   }
// }

// /// Lightweight bool provider — use when you only need "is clocked in or not".
// @riverpod
// bool isClockedIn(Ref ref) {
//   return ref.watch(clockInOutProvider) != null;
// }

// /// Formats the elapsed time as an HH:MM:SS string.
// @riverpod
// String clockDurationText(Ref ref) {
//   final seconds = ref.watch(clockInOutProvider);
//   if (seconds == null) return '00:00:00';
//   final h = (seconds ~/ 3600).toString().padLeft(2, '0');
//   final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
//   final s = (seconds % 60).toString().padLeft(2, '0');
//   return '$h:$m:$s';
// }

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

part 'clock_in_out.g.dart'; // <- change to match your actual file name

/// ClockInOut notifier (Riverpod annotation / code-gen).
///
/// State = `int?`
///   - `null`  => not clocked in (idle / clocked out)
///   - `>= 0`  => clocked in, value is the elapsed seconds (counts up per second)
@riverpod
class ClockInOut extends _$ClockInOut {
  Timer? _timer;

  @override
  int? build() {
    ref.onDispose(_stopTimer); // cancel timer on dispose to avoid leaks
    return null; // initially null
  }

  bool get isClockedIn => state != null;

  /// Clock IN.
  ///
  /// [seconds] == 0 (default) => FRESH clock in => makes the server API call.
  /// [seconds] > 0            => RESUME (app restart/reopen) => no API call.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> clockIn({int seconds = 0}) async {
    final isResume = seconds > 0;

    if (!isResume) {
      try {
        // Fresh clock in — send request to the server
        var res = await BaseController.to.apiService.makePostRequest(
          URLS.clockIn,
          {},
        );

        // If not 201, clock in failed — show message, keep state null
        if (res.statusCode != 201) {
          PopupDialog.showErrorMessage(
            res.data?["message"] ?? "Clock in failed. Please try again.",
          );
          return false;
        }

        // Persist the returned employee data on successful clock in
        await BaseController.to.setEmployeeData(res.data["data"]["employee"]);
      } catch (e) {
        PopupDialog.showErrorMessage("Clock in failed. Please try again.");
        return false;
      }
    }

    state = seconds < 0 ? 0 : seconds;
    _startTimer();
    return true;
  }

  /// Clock OUT.
  ///
  /// [isClockout] `false` (default) => no API call, but stops the timer
  ///                                   and sets state to null.
  /// [isClockout] `true`  => sends the clock out request. On 200, stops the
  ///                         timer and sets null. If not 200, nothing changes.
  ///
  /// Returns `true` on success, `false` on failure.
  Future<bool> clockOut({bool isClockout = false}) async {
    if (isClockout) {
      try {
        var res = await BaseController.to.apiService.makePostRequest(
          URLS.clockOut,
          {"clockId": BaseController.to.employeeData?.activeClock?.id ?? ""},
        );

        // If not 200, clock out failed — show message, leave state untouched
        if (res.statusCode != 200) {
          PopupDialog.showErrorMessage(
            res.data?["message"] ?? "Clock out failed. Please try again.",
          );
          return false;
        }
      } catch (e) {
        PopupDialog.showErrorMessage("Clock out failed. Please try again.");
        return false;
      }
    }

    // isClockout == false, or API returned 200 — either way, stop + null
    _stopTimer();
    state = null;
    return true;
  }

  // ---------- internal helpers ----------

  void _startTimer() {
    _stopTimer(); // avoid duplicate timers
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (current == null) {
        _stopTimer();
        return;
      }
      state = current + 1;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Lightweight bool provider — use when you only need "is clocked in or not".
@riverpod
bool isClockedIn(Ref ref) {
  return ref.watch(clockInOutProvider) != null;
}

/// Formats the elapsed time as an HH:MM:SS string.
@riverpod
String clockDurationText(Ref ref) {
  final seconds = ref.watch(clockInOutProvider);
  if (seconds == null) return '00:00:00';
  final h = (seconds ~/ 3600).toString().padLeft(2, '0');
  final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}
