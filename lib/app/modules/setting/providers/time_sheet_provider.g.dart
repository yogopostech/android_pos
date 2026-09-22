// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_sheet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimeSheet)
final timeSheetProvider = TimeSheetProvider._();

final class TimeSheetProvider
    extends $AsyncNotifierProvider<TimeSheet, TimeSheetState> {
  TimeSheetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timeSheetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timeSheetHash();

  @$internal
  @override
  TimeSheet create() => TimeSheet();
}

String _$timeSheetHash() => r'21fd59c48b6407346ed56054d24dc89d4e3ed811';

abstract class _$TimeSheet extends $AsyncNotifier<TimeSheetState> {
  FutureOr<TimeSheetState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TimeSheetState>, TimeSheetState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TimeSheetState>, TimeSheetState>,
              AsyncValue<TimeSheetState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
