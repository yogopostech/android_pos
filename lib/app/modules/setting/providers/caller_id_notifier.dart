// import 'dart:async';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';
// import 'serial_caller_id_service.dart';

// part 'caller_id_notifier.g.dart';



// @Riverpod(keepAlive: true)
// Stream<CallerIdData> callerIdStream(Ref ref) {
//   return ref.read(serialCallerIdServiceProvider.notifier).callStream;
// }

// @Riverpod(keepAlive: true)
// Stream<String> callerIdRawStream(Ref ref) {
//   return ref.read(serialCallerIdServiceProvider.notifier).rawStream;
// }



// class CallerIdState {
//   final List<CallerIdData> activeCalls;
//   final bool isDialogOpen;

//   const CallerIdState({this.activeCalls = const [], this.isDialogOpen = false});

//   CallerIdState copyWith({
//     List<CallerIdData>? activeCalls,
//     bool? isDialogOpen,
//   }) => CallerIdState(
//     activeCalls: activeCalls ?? this.activeCalls,
//     isDialogOpen: isDialogOpen ?? this.isDialogOpen,
//   );
// }

// // ─────────────────────────────────────────────────
// // Notifier
// // ─────────────────────────────────────────────────

// @Riverpod(keepAlive: true)
// class CallerIdNotifier extends _$CallerIdNotifier {
//   String? _lastPhone;
//   DateTime? _lastTime;

//   @override
//   CallerIdState build() => const CallerIdState();

//   void setCallerData(CallerIdData data) {
//     if (_isDuplicate(data)) return;

//     if (state.isDialogOpen) {
//       state = state.copyWith(activeCalls: [...state.activeCalls, data]);
//     } else {
//       state = state.copyWith(activeCalls: [data], isDialogOpen: true);
//     }
//   }

//   void removeCall(CallerIdData data) {
//     final updated = state.activeCalls
//         .where((e) => e.trackingId != data.trackingId)
//         .toList();

//     state = state.copyWith(
//       activeCalls: updated,
//       isDialogOpen: updated.isNotEmpty,
//     );
//   }

//   void clearAll() {
//     state = const CallerIdState();
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
// }
