// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_in_out.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ClockInOut notifier (Riverpod annotation / code-gen).
///
/// State = `int?`
///   - `null`  => not clocked in (idle / clocked out)
///   - `>= 0`  => clocked in, value is the elapsed seconds (counts up per second)

@ProviderFor(ClockInOut)
final clockInOutProvider = ClockInOutProvider._();

/// ClockInOut notifier (Riverpod annotation / code-gen).
///
/// State = `int?`
///   - `null`  => not clocked in (idle / clocked out)
///   - `>= 0`  => clocked in, value is the elapsed seconds (counts up per second)
final class ClockInOutProvider extends $NotifierProvider<ClockInOut, int?> {
  /// ClockInOut notifier (Riverpod annotation / code-gen).
  ///
  /// State = `int?`
  ///   - `null`  => not clocked in (idle / clocked out)
  ///   - `>= 0`  => clocked in, value is the elapsed seconds (counts up per second)
  ClockInOutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockInOutProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockInOutHash();

  @$internal
  @override
  ClockInOut create() => ClockInOut();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$clockInOutHash() => r'af39df771bc9bff4d70bae978a99a41db6eb2b19';

/// ClockInOut notifier (Riverpod annotation / code-gen).
///
/// State = `int?`
///   - `null`  => not clocked in (idle / clocked out)
///   - `>= 0`  => clocked in, value is the elapsed seconds (counts up per second)

abstract class _$ClockInOut extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Lightweight bool provider — use when you only need "is clocked in or not".

@ProviderFor(isClockedIn)
final isClockedInProvider = IsClockedInProvider._();

/// Lightweight bool provider — use when you only need "is clocked in or not".

final class IsClockedInProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Lightweight bool provider — use when you only need "is clocked in or not".
  IsClockedInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isClockedInProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isClockedInHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isClockedIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isClockedInHash() => r'cd21c97d4e9f0124a671df7b5331e2865a70f590';

/// Formats the elapsed time as an HH:MM:SS string.

@ProviderFor(clockDurationText)
final clockDurationTextProvider = ClockDurationTextProvider._();

/// Formats the elapsed time as an HH:MM:SS string.

final class ClockDurationTextProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Formats the elapsed time as an HH:MM:SS string.
  ClockDurationTextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockDurationTextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockDurationTextHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return clockDurationText(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$clockDurationTextHash() => r'b050f53bbd5814b5d2ea69e9d13d78e33f882bed';
