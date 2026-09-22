/// Elavon Commerce Web Services (CWS) — Integration Package
///
/// Semi-integrated flow over the local CWS service (HTTP + JSON, default
/// port 9790). Card data never touches the POS; CWS drives the Ingenico
/// terminal (e.g. Lane/3600) and returns the final result.
///
/// ```dart
/// import 'package:yogo_pos/.../cws/cws.dart';
///
/// // Purchase
/// cwsPurchaseDialog(amountCents: 2550, invoiceNum: 'T01');
///
/// // Void
/// cwsVoidDialog(transId: 'abc123');
///
/// // Refund
/// cwsRefundDialog(amountCents: 1000);
/// ```
///
/// Setup is automatic via the credentials provider — it fetches the tenant's
/// CwsCredentials from your API, caches them (single source of truth), and
/// warms up the gateway. Trigger it once after login:
/// ```dart
/// ref.read(cwsCredentialsConfigProvider);          // load + warm up
/// if (ref.watch(cwsEnabledProvider)) { /* show Pay by Card */ }
/// ```
/// On tenant/location switch:
/// ```dart
/// ref.read(cwsCredentialsConfigProvider.notifier).reload();
/// ```
/// The API's currency "USA" is mapped to the ISO code "USD" automatically.
library;

export 'services/cws_constants.dart';
export 'services/cws_utils.dart';
export 'services/cws_gateway.dart';
export 'models/cws_model.dart';
export 'models/cws_credentials.dart';
export 'providers/cws_provider.dart';
export 'providers/cws_credentials_provider.dart';
export 'views/cws_base_dialog.dart';
export 'views/cws_purchase_dialog.dart';
export 'views/cws_void_dialog.dart';
export 'views/cws_refund_dialog.dart';