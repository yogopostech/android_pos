/// CWS credentials provider (riverpod_annotation / codegen).
///
/// After editing, run:
///   dart run build_runner build --delete-conflicting-outputs
///
/// Loads the tenant's Converge credentials from the backend once, caches them
/// (keepAlive), applies them to CwsConfig, and warms up the gateway. The whole
/// app reuses this loaded config instead of re-fetching.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project-specific — adjust these import paths to your app:
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/urls.dart';

import '../models/cws_credentials.dart';
import '../services/cws_gateway.dart';
import 'cws_provider.dart';

part 'cws_credentials_provider.g.dart';

@Riverpod(keepAlive: true)
class CwsCredentialsConfig extends _$CwsCredentialsConfig {
  @override
  Future<CwsCredentials?> build() => _load();

  Future<CwsCredentials?> _load() async {
    final creds = await _fetch();

    if (creds != null && creds.isConfigured) {
      CwsGatewaySession.instance.reset(); // clear any previous tenant's gateway
      try {
        await ref
            .read(cwsPaymentProvider.notifier)
            .warmUp(creds); // await + try
      } catch (e, s) {
        debugPrint('[CWS] warmUp error: $e\n$s');
      }
    } else {
      debugPrint('[CWS] credentials missing/incomplete — CWS disabled');
    }
    return creds;
  }

  /// Force a reload (tenant/location switch or re-login).
  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<CwsCredentials?> _fetch() async {
    try {
      final res = await BaseController.to.apiService.makeGetRequest(
        URLS.converge,
      );
      final data = (res.data is Map) ? res.data['data'] : null;
      if (data is! Map) return null; // null / wrong shape -> CWS disabled
      return CwsCredentials.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      debugPrint('[CWS] credentials fetch failed: $e');
      return null; // network / parse error -> disabled, never crash
    }
  }
}

/// Convenience: is CWS usable for the current tenant?
@riverpod
bool cwsEnabled(Ref ref) {
  final cfg = ref.watch(cwsCredentialsConfigProvider).asData?.value;
  return cfg?.isConfigured ?? false;
}
