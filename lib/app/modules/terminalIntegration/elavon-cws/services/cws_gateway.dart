/// Elavon Commerce Web Services (CWS) — Gateway Session
///
/// Holds the paymentGatewayId for the whole app session so it survives across
/// (autoDispose) transaction dialogs. Opened lazily on first use and reused;
/// reset on tenant switch or gateway expiry.
library;

class CwsGatewaySession {
  CwsGatewaySession._();
  static final CwsGatewaySession instance = CwsGatewaySession._();

  String? _gatewayId;
  Future<String?>? _opening; // dedupe concurrent opens

  String? get id => _gatewayId;
  bool get isOpen => _gatewayId != null;

  /// Returns the cached id, or opens once via [opener]. Concurrent callers
  /// share the same in-flight open.
  Future<String?> ensureOpen(Future<String?> Function() opener) {
    final cached = _gatewayId;
    if (cached != null) return Future.value(cached);

    return _opening ??= opener().then((id) {
      _gatewayId = id;
      _opening = null;
      return id;
    }).catchError((_) {
      _opening = null;
      return null;
    });
  }

  /// Drop the cached gateway. Call on tenant/location switch (credentials
  /// change) or when a call reports the gateway is invalid/expired.
  void reset() {
    _gatewayId = null;
    _opening = null;
  }
}