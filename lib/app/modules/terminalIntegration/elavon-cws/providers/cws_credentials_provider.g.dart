// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cws_credentials_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CwsCredentialsConfig)
final cwsCredentialsConfigProvider = CwsCredentialsConfigProvider._();

final class CwsCredentialsConfigProvider
    extends $AsyncNotifierProvider<CwsCredentialsConfig, CwsCredentials?> {
  CwsCredentialsConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cwsCredentialsConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cwsCredentialsConfigHash();

  @$internal
  @override
  CwsCredentialsConfig create() => CwsCredentialsConfig();
}

String _$cwsCredentialsConfigHash() =>
    r'2adf53218d88f6a3d003c371ad6daf061ad2792f';

abstract class _$CwsCredentialsConfig extends $AsyncNotifier<CwsCredentials?> {
  FutureOr<CwsCredentials?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CwsCredentials?>, CwsCredentials?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CwsCredentials?>, CwsCredentials?>,
              AsyncValue<CwsCredentials?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Convenience: is CWS usable for the current tenant?

@ProviderFor(cwsEnabled)
final cwsEnabledProvider = CwsEnabledProvider._();

/// Convenience: is CWS usable for the current tenant?

final class CwsEnabledProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Convenience: is CWS usable for the current tenant?
  CwsEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cwsEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cwsEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return cwsEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$cwsEnabledHash() => r'9047b2b218320466bef5389328816cba6052e1f3';
