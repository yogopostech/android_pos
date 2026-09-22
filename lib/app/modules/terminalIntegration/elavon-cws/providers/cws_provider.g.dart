// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cws_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CwsPayment)
final cwsPaymentProvider = CwsPaymentProvider._();

final class CwsPaymentProvider extends $NotifierProvider<CwsPayment, CwsState> {
  CwsPaymentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cwsPaymentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cwsPaymentHash();

  @$internal
  @override
  CwsPayment create() => CwsPayment();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CwsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CwsState>(value),
    );
  }
}

String _$cwsPaymentHash() => r'd7df56431a107082b52c9c2d2945a9e8b73fee15';

abstract class _$CwsPayment extends $Notifier<CwsState> {
  CwsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CwsState, CwsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CwsState, CwsState>,
              CwsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
