/// Ingenico Tetra TSI — Utility Functions
///
/// Status labels, card type names, byte formatting, tag parsing.
library;

import 'elavon_constants.dart';

// ── Status code → human-readable label ──

String elavonStatusLabel(String code) => switch (code) {
  '00' => 'Approved',
  '01' => 'Partial Approved',
  '10' => 'Declined',
  '11' => 'Communication Error',
  '12' => 'Cancelled',
  '13' => 'Timed Out',
  '14' => 'Not Completed',
  '15' => 'Batch Empty',
  '16' => 'Declined',
  '17' => 'Record Not Found',
  '18' => 'Already Voided',
  '30' => 'Invalid Parameter',
  '31' => 'Battery Low',
  '95' => 'Terminal Not Available',
  _ => 'Unknown',
};

// ── Card type code → name ──

String elavonCardTypeName(String? code) => switch (code) {
  '00' => 'DEBIT_CARD',
  '01' => 'VISA',
  '02' => 'MASTERCARD',
  '03' => 'AMEX',
  '04' => 'DINERS',
  '05' => 'DISCOVER',
  '06' => 'JCB',
  '07' => 'UNIONPAY',
  // '09' => 'GIFT CARD',
  // '10' => 'CASH',
  // '11' => 'UNIONPAY',
  // '12' => 'UNIONPAY',
  _ => 'OTHERS',
};

// ── Entry mode code → label ──

String elavonEntryModeLabel(String? code) => switch (code) {
  '0' => 'Swipe',
  '1' => 'Chip',
  '2' => 'Contactless',
  '3' => 'Manual',
  '4' => 'Chip Fallback Swipe',
  '5' => 'Chip Fallback Manual',
  '6' => 'Card Not Present',
  _ => 'Unknown',
};

// ── Tag code → short label (for debug logs) ──

String elavonTagLabel(String tag) => switch (tag) {
  '100' => 'TransType',
  '102' => 'Date',
  '103' => 'Time',
  '104' => 'Amount',
  '105' => 'Tip',
  '106' => 'Cashback',
  '107' => 'Surcharge',
  '109' => 'Total',
  '110' => 'Invoice',
  '112' => 'RefNum',
  '300' => 'CardType',
  '301' => 'CardDesc',
  '302' => 'PAN',
  '306' => 'EntryMode',
  '312' => 'CVM',
  '400' => 'AuthCode',
  '401' => 'HostCode',
  '402' => 'HostText',
  '406' => 'TraceNum',
  '409' => 'Balance',
  '412' => 'HostTransRef',
  '500' => 'Batch#',
  '600' => 'DEMO',
  '601' => 'TermID',
  '602' => 'MerchID',
  _ => '',
};

// ── Pretty-print raw bytes for debug logs ──

String elavonPrettyBytes(List<int> data) {
  final sb = StringBuffer();
  for (final b in data) {
    if (b == kFs) {
      sb.write('<FS>');
    } else if (b == kHb) {
      sb.write('<HB>');
    } else if (b >= 0x20 && b < 0x7F) {
      sb.writeCharCode(b);
    } else {
      sb.write('<0x${b.toRadixString(16).padLeft(2, '0')}>');
    }
  }
  return sb.toString();
}

// ── Split byte list on separator ──

List<List<int>> elavonSplitOn(List<int> data, int sep) {
  final result = <List<int>>[];
  var current = <int>[];
  for (final b in data) {
    if (b == sep) {
      if (current.isNotEmpty) result.add(current);
      current = [];
    } else {
      current.add(b);
    }
  }
  if (current.isNotEmpty) result.add(current);
  return result;
}

// ── Parse FS-separated tags from raw bytes into Map ──

Map<String, String> elavonParseTags(List<int> data) {
  final fields = <String, String>{};
  final parts = elavonSplitOn(data, kFs);
  for (final part in parts) {
    if (part.length < 3) continue;
    final tag = String.fromCharCodes(part.sublist(0, 3));
    final val = String.fromCharCodes(
      part.sublist(3).map((b) => b >= 0x20 && b < 0x7F ? b : 0x2E),
    );
    fields[tag] = val;
  }
  return fields;
}

// ── Log color for debug area ──

int elavonLogColor(String line) {
  if (line.contains('✓') || line.contains('APPROVED')) return 0xFF4EC9B0;
  if (line.contains('✗') || line.contains('DECLINED')) return 0xFFF48771;
  if (line.contains('→ TX') || line.contains('sending')) return 0xFF9CDCFE;
  if (line.contains('← RX')) return 0xFFDCDCAA;
  if (line.contains('♥')) return 0xFF808080;
  return 0xFFD4D4D4;
}
