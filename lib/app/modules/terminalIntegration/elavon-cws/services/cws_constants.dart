library;

// ── Transport ──
const String kCwsScheme = 'https'; // CWS listens over TLS
const String kCwsDefaultHost = '127.0.0.1'; // IPv4 loopback (avoids ::1 on Windows)
const int kCwsDefaultPort = 9790;
const String kCwsPath = '/rest/command'; // fixed endpoint path
const String kCwsVersion = '1.0';

// ── Timing (Elavon recommends >= 750ms polling) ──
const Duration kCwsPollInterval = Duration(milliseconds: 750);
const Duration kCwsOverallTimeout = Duration(seconds: 150);
const Duration kCwsHttpTimeout = Duration(seconds: 30);

// ── Methods ──
abstract final class CwsMethod {
  static const String getEnvironmentInfo = 'getEnvironmentInfo';
  static const String openPaymentGateway = 'openPaymentGateway';
  static const String startPaymentTransaction = 'startPaymentTransaction';
  static const String getPaymentTransactionStatus = 'getPaymentTransactionStatus';
  static const String continuePaymentTransaction = 'continuePaymentTransaction';
  static const String searchPaymentTransaction = 'searchPaymentTransaction';
  static const String tipAdjust = 'tipAdjust';
  // card reader
  static const String setDeviceConnectionConfiguration = 'setDeviceConnectionConfiguration';
  static const String startCardReadersSearch = 'startCardReadersSearch';
  static const String getCardReadersSearchStatus = 'getCardReadersSearchStatus';
}

// ── Target types ──
abstract final class CwsTarget {
  static const String paymentGateway = 'paymentGatewayConverge';
  static const String cardReader = 'cardReader';
  static const String printer = 'printer';
  static const String api = 'api';
}

// ── Transaction types (ECR -> gateway) ──
abstract final class CwsTxnType {
  static const String sale = 'SALE';
  static const String refund = 'REFUND'; // CONFIRM exact enum string
  static const String voidTxn = 'VOID'; // CONFIRM exact enum string
  static const String preAuth = 'PRE_AUTH';
  static const String balanceInquiry = 'BALANCE_INQUIRY';
}

// ── Tender types ──
abstract final class CwsTender {
  static const String card = 'CARD';
}

// ── requiredInformation keys the terminal can raise mid-transaction ──
abstract final class CwsRequiredInfo {
  static const String emvAppSelection = 'EmvApplicationSelectionRequired';
  static const String dccConfirmation = 'RequireDccConfirmation';
  static const String signature = 'SignatureRequired';
  static const String voiceReferral = 'VoiceReferral';
}

// ── DCC decisions ──
abstract final class CwsDcc {
  static const String accept = 'Accept';
  static const String reject = 'Reject';
  static const String cancel = 'Cancel';
}

// ── JSON paths in responses (defensive parsing keys) ──
abstract final class CwsKey {
  static const String data = 'data';
  static const String statusDetails = 'statusDetails';
  static const String command = 'paymentGatewayCommand'; // wrapper for converge calls
  static const String paymentGatewayId = 'paymentGatewayId'; // CONFIRM exact location
  static const String completed = 'completed';
  static const String chanId = 'chanId';
  static const String eventQueue = 'eventQueue';
  static const String requiredInformation = 'requiredInformation';
  static const String emvAppList = 'emvApplicationSelectionList'; // CONFIRM
}

/// App-level transport & behaviour config. NOT per-tenant credentials —
/// those live in CwsCredentials and the credentials provider.
abstract final class CwsConfig {
  static String host = kCwsDefaultHost;
  static int port = kCwsDefaultPort;
  static String logLevel = 'DEBUG';
  // static String logLevel = 'INFO';
  static String vendorAppName = 'YOGO POS';
  static String vendorAppVersion = '1.0.0';

  /// Card reader search preference (setDeviceConnectionConfiguration).
  /// Change connectionTypes to ['IP'] if the terminal is networked.
  static List<String> readerProviderTypes = ['INGENICO_RBA_UPP'];
  static List<String> readerConnectionTypes = ['USB'];

  /// Card-present indicator sent on every sale.
  static bool partialApprovalAllowed = true;

  /// DEBUG ONLY: when true, request bodies are logged with real values instead
  /// of '***'. NEVER leave true in production — it leaks credentials/PAN.
  static bool unmaskLogs = true;

  /// Any additional openPaymentGateway params not covered by CwsCredentials.
  static Map<String, dynamic> extraCredentials = <String, dynamic>{};
}