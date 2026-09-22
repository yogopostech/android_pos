// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elavon_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ElavonPayment)
final elavonPaymentProvider = ElavonPaymentProvider._();

final class ElavonPaymentProvider
    extends $NotifierProvider<ElavonPayment, ElavonState> {
  ElavonPaymentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'elavonPaymentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$elavonPaymentHash();

  @$internal
  @override
  ElavonPayment create() => ElavonPayment();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ElavonState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ElavonState>(value),
    );
  }
}

String _$elavonPaymentHash() => r'a35bf65440462a165c5c35e036867a4cd4ee245a';

abstract class _$ElavonPayment extends $Notifier<ElavonState> {
  ElavonState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ElavonState, ElavonState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ElavonState, ElavonState>,
              ElavonState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
