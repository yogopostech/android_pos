/// Elavon Commerce Web Services (CWS) — Utility Functions
///
/// Request envelope builder, status/card/entry-mode labels, safe nested JSON
/// reads, compact log formatting, and log colouring for the dialog log area.
library;

import 'dart:convert';

import 'cws_constants.dart';

int _reqCounter = 0;

/// Unique per-request id.
String cwsRequestId() =>
    '${DateTime.now().millisecondsSinceEpoch}-${_reqCounter++}';

/// Build the shared CWS request envelope.
Map<String, dynamic> cwsBuildRequest({
  required String method,
  required String targetType,
  Map<String, dynamic> parameters = const {},
}) => {
  'method': method,
  'requestId': cwsRequestId(),
  'targetType': targetType,
  'version': kCwsVersion,
  'parameters': parameters,
};

/// Amount object CWS expects: { value: cents, currencyCode: ISO }.
/// Pass the tenant's ISO currency (from CwsCredentials.currencyCode).
Map<String, dynamic> cwsAmount(int cents, String currency) => {
  'value': cents,
  'currencyCode': currency,
};

/// Unique invoice number (maps to ssl_invoice_number). Certification requires
/// a unique value per sale. Alphanumeric, kept short (<= 25 chars).
String cwsInvoiceNumber([String prefix = 'YG']) =>
    '$prefix${DateTime.now().millisecondsSinceEpoch}';

/// Safely read a nested value by a list of keys. Returns null on any miss.
dynamic cwsReadPath(dynamic root, List<String> path) {
  dynamic cur = root;
  for (final k in path) {
    if (cur is Map && cur.containsKey(k)) {
      cur = cur[k];
    } else {
      return null;
    }
  }
  return cur;
}

/// Pull the object holding completed / chanId / eventQueue / requiredInformation
/// and the final transaction result. paymentGatewayConverge calls wrap it in
/// `data.paymentGatewayCommand`; api calls put fields directly under `data`.
Map<String, dynamic> cwsCommandOf(Map<String, dynamic> response) {
  final pgc = cwsReadPath(response, [CwsKey.data, CwsKey.command]);
  if (pgc is Map) return pgc.cast<String, dynamic>();
  final data = cwsReadPath(response, [CwsKey.data]);
  return data is Map ? data.cast<String, dynamic>() : <String, dynamic>{};
}

// ── Status label (approval + host status text) ──

String cwsStatusLabel(String? code) {
  final c = (code ?? '').toUpperCase();
  if (c.contains('APPROVE') || c == 'SUCCESS' || c == 'PARTIAL') return 'Approved';
  if (c.contains('DECLINE')) return 'Declined';
  if (c.contains('CANCEL')) return 'Cancelled';
  if (c.contains('TIMEOUT') || c.contains('TIMED')) return 'Timed Out';
  if (c.contains('ERROR') || c.contains('FAIL')) return 'Error';
  if (c.isEmpty) return 'Unknown';
  return code!;
}

bool cwsIsApproved(String? code) {
  final c = (code ?? '').toUpperCase();
  return c.contains('APPROVE') || c == 'SUCCESS' || c == 'PARTIAL';
}

// ── Card scheme normalisation ──

String cwsCardName(String? raw) {
  final c = (raw ?? '').toUpperCase().replaceAll(' ', '');
  return switch (c) {
    'VISA' => 'VISA',
    'MASTERCARD' || 'MC' || 'MASTER' => 'MASTERCARD',
    'AMEX' || 'AMERICANEXPRESS' => 'AMEX',
    'DISCOVER' => 'DISCOVER',
    'DINERS' || 'DINERSCLUB' => 'DINERS',
    'JCB' => 'JCB',
    'UNIONPAY' || 'CUP' => 'UNIONPAY',
    'DEBIT' || 'INTERAC' || 'INTERACDEBIT' => 'DEBIT_CARD',
    '' => 'OTHERS',
    _ => c,
  };
}

// ── Entry mode label ──

String cwsEntryModeLabel(String? raw) {
  final c = (raw ?? '').toUpperCase();
  return switch (c) {
    'SWIPE' || 'MAGSTRIPE' || 'MSR' => 'Swipe',
    'CHIP' || 'ICC' || 'CONTACT' || 'INSERT' => 'Chip',
    'CONTACTLESS' || 'NFC' || 'TAP' => 'Contactless',
    'MANUAL' || 'KEYED' || 'KEY' => 'Manual',
    'FALLBACK' => 'Chip Fallback Swipe',
    '' => 'Unknown',
    _ => raw!,
  };
}

// ── Compact JSON for logs (truncated) ──

String cwsCompact(Object? obj, {int max = 600}) {
  String s;
  try {
    s = jsonEncode(obj);
  } catch (_) {
    s = obj.toString();
  }
  if (s.length > max) s = '${s.substring(0, max)}…';
  return s;
}

/// Field-name fragments whose values must never appear in logs.
const List<String> _cwsSensitive = [
  'password', 'pin', 'secret', 'token', 'key', 'apikey', 'userid', 'user',
  'merchantid', 'vendor', 'credential', 'pan', 'cardnumber', 'account',
];

bool _cwsIsSensitive(String key) {
  final k = key.toLowerCase();
  return _cwsSensitive.any(k.contains);
}

/// Deep-copy a request map with sensitive values replaced by '***', so the
/// full request shape is visible in logs without leaking credentials/PAN.
Object? cwsMaskRequest(Object? node) {
  if (node is Map) {
    return node.map((k, v) => MapEntry(
          k.toString(),
          _cwsIsSensitive(k.toString()) ? '***' : cwsMaskRequest(v),
        ));
  }
  if (node is List) return node.map(cwsMaskRequest).toList();
  return node;
}

// ── Log colour for the dialog log area (matches TSI palette) ──

int cwsLogColor(String line) {
  if (line.contains('✓') || line.contains('APPROVED')) return 0xFF4EC9B0;
  if (line.contains('✗') || line.contains('DECLINED')) return 0xFFF48771;
  if (line.contains('→ TX') || line.contains('POST')) return 0xFF9CDCFE;
  if (line.contains('← RX')) return 0xFFDCDCAA;
  if (line.contains('poll') || line.contains('⋯')) return 0xFF808080;
  return 0xFFD4D4D4;
}