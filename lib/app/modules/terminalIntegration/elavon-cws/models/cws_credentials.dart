/// Per-tenant Converge credentials/config — mirrors the backend API shape.
///
/// The backend sends `environment` ("DEMO" | "PROD") and `currency`
/// ("USA" | "CAD"); note "USA" is not an ISO code and is mapped to "USD".
library;

class CwsCredentials {
  final String merchantId;
  final String userId;
  final String vendorId;
  final String pin;
  final String environment; // "DEMO" | "PROD"
  final String currency; // "USA" | "CAD" (NOT ISO — see currencyCode)
  final String bmsUsername; // optional
  final String bmsPassword; // optional

  const CwsCredentials({
    required this.merchantId,
    required this.userId,
    required this.vendorId,
    required this.pin,
    required this.environment,
    required this.currency,
    this.bmsUsername = '',
    this.bmsPassword = '',
  });

  factory CwsCredentials.fromJson(Map<String, dynamic> j) => CwsCredentials(
    merchantId: (j['merchantId'] ?? '').toString().trim(),
    userId: (j['userId'] ?? '').toString().trim(),
    vendorId: (j['vendorId'] ?? '').toString().trim(),
    pin: (j['pin'] ?? '').toString().trim(),
    environment: (j['environment'] ?? 'DEMO').toString().trim().toUpperCase(),
    currency: (j['currency'] ?? 'CAD').toString().trim().toUpperCase(),
    bmsUsername: (j['bmsUsername'] ?? '').toString().trim(),
    bmsPassword: (j['bmsPassword'] ?? '').toString().trim(),
  );

  /// True when all required credentials are present. Used to gate CWS on/off
  /// for the tenant (the backend returns these only for CWS-enabled merchants).
  bool get isConfigured =>
      merchantId.isNotEmpty &&
      userId.isNotEmpty &&
      pin.isNotEmpty &&
      vendorId.isNotEmpty;

  bool get isDemo => environment != 'PROD';

  /// ISO 4217 currency code for amounts. The API sends "USA" for the US, which
  /// is not a valid currency code — it maps to "USD".
  String get currencyCode => switch (currency) {
    'USA' || 'US' || 'USD' => 'USD',
    'CAD' || 'CA' || 'CANADA' => 'CAD',
    _ => 'CAD',
  };

  @override
  String toString() =>
      'CwsCredentials(merchantId=$merchantId, env=$environment, '
      'currency=$currency→$currencyCode, configured=$isConfigured)';
}