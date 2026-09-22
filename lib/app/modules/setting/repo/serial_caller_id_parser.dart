// import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';

// class SerialCallerIdParser {
//   static const _invalidPhones = {
//     'P',
//     'O',
//     'PRIVATE',
//     'OUT-OF-AREA',
//     'ANONYMOUS',
//     'UNKNOWN',
//     'UNAVAILABLE',
//   };

//   static const _invalidNames = {
//     'PRIVATE',
//     'OUT-OF-AREA',
//     'ANONYMOUS',
//     'UNAVAILABLE',
//     'UNKNOWN',
//   };

//   // ── Main parse method ──────────────────────────────────────────────────────
//   // Handles Whozz Calling? Deluxe actual serial output format:
//   // 01 I S 0276 G B3 09/26 11:28 AM 800-240-4637   CallerID.com
//   static CallerIdData? parse(String raw) {
//     if (raw.trim().isEmpty) return null;

//     // Primary pattern — matches actual Whozz Calling? Deluxe serial format
//     final pattern = RegExp(
//       r'(\d{2})\s+([IO])\s+([SE])\s+(\d{4})\s+([GB])\s+(\S+)\s+'
//       r'(\d{2}\/\d{2})\s+(\d{2}:\d{2})\s+([AP]M)\s+(\S+)\s*(.*)',
//     );

//     final match = pattern.firstMatch(raw.trim());
//     if (match != null) {
//       final lineNumber = match.group(1)!.trim();
//       final direction = match.group(2)!.trim();
//       final recordType = match.group(3)!.trim();
//       final duration = match.group(4)!.trim();
//       final checksum = match.group(5)!.trim();
//       final date = match.group(7)!.trim();
//       final time = '${match.group(8)!.trim()} ${match.group(9)!.trim()}';
//       final phone = _resolvePhone(match.group(10)!.trim());
//       final name = _resolveName(match.group(11)?.trim() ?? '');

//       return CallerIdData(
//         lineNumber: lineNumber,
//         direction: direction,
//         recordType: recordType,
//         duration: duration,
//         checksum: checksum,
//         date: date,
//         time: time,
//         phoneNumber: phone,
//         callerName: name,
//         rawData: raw,
//         receivedAt: DateTime.now(),
//       );
//     }

//     // Fallback if primary pattern does not match
//     return _parseFallback(raw);
//   }

//   // ── Fallback parser ────────────────────────────────────────────────────────
//   // Used when primary pattern does not match
//   // Extracts phone number from any line containing digits
//   static CallerIdData? _parseFallback(String raw) {
//     final cleaned = raw.replaceAll(RegExp(r'[^\x20-\x7E]'), '').trim();
//     if (cleaned.isEmpty) return null;

//     // Try to find a phone number (7 to 15 digits)
//     final phoneMatch = RegExp(r'(\d{7,15})').firstMatch(cleaned);
//     if (phoneMatch == null) return null;

//     final phone = _resolvePhone(phoneMatch.group(1)!);
//     if (phone == null) return null;

//     // Try to extract name — text after the phone number
//     String? name;
//     final afterPhone = cleaned.substring(phoneMatch.end).trim();
//     if (afterPhone.isNotEmpty) {
//       name = _resolveName(
//         afterPhone.replaceAll(RegExp(r'[^A-Za-z\s\.]'), '').trim(),
//       );
//     }

//     return CallerIdData(
//       lineNumber: '1',
//       direction: 'I',
//       recordType: 'S',
//       duration: '0000',
//       checksum: 'G',
//       date: '',
//       time: '',
//       phoneNumber: phone,
//       callerName: name,
//       rawData: raw,
//       receivedAt: DateTime.now(),
//     );
//   }

//   // ── Phone resolver ─────────────────────────────────────────────────────────
//   // Returns null for private/blocked/invalid numbers
//   static String? _resolvePhone(String v) {
//     final upper = v.trim().toUpperCase();
//     if (_invalidPhones.contains(upper)) return null;

//     // Remove all non-digit characters
//     final digits = v.replaceAll(RegExp(r'\D'), '');

//     // Must be at least 7 digits
//     if (digits.length < 7) return null;

//     // All zeros is invalid
//     if (digits.replaceAll('0', '').isEmpty) return null;

//     return digits;
//   }

//   // ── Name resolver ──────────────────────────────────────────────────────────
//   // Returns null for empty or known placeholder names
//   static String? _resolveName(String v) {
//     final trimmed = v.trim();
//     if (trimmed.isEmpty) return null;

//     final upper = trimmed.toUpperCase();
//     if (_invalidNames.contains(upper)) return trimmed;

//     // Must contain at least one letter
//     if (!RegExp(r'[A-Za-z]').hasMatch(trimmed)) return null;

//     return trimmed;
//   }
// }

import 'package:uuid/uuid.dart';
import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';

class SerialCallerIdParser {
  static const _invalidPhones = {
    'P',
    'O',
    'PRIVATE',
    'OUT-OF-AREA',
    'ANONYMOUS',
    'UNKNOWN',
    'UNAVAILABLE',
  };

  static const _invalidNames = {
    'PRIVATE',
    'OUT-OF-AREA',
    'ANONYMOUS',
    'UNAVAILABLE',
    'UNKNOWN',
  };

  // ── Main entry point ───────────────────────────────────────────────────────
  static CallerIdData? parse(String raw) {
    if (raw.trim().isEmpty) return null;

    // Format 1: Key-value (single line or multiline)
    // "DATE = 0427 TIME = 1230 NMBR = 2505551299 NAME = ZEE"
    // "DATE = 0427\r\nNMBR = 2505551299\r\nNAME = ZEE"
    if (raw.contains('NMBR') || raw.contains('DATE =')) {
      return _parseKeyValue(raw);
    }

    // Format 2: Whozz Calling? positional format
    // "01 I S 0000 G B3 09/26 11:28 AM 2505551299 ZEE"
    final whozzMatch = RegExp(
      r'(\d{2})\s+([IO])\s+([SE])\s+(\d{4})\s+([GB])\s+(\S+)\s+'
      r'(\d{2}\/\d{2})\s+(\d{2}:\d{2})\s+([AP]M)\s+(\S+)\s*(.*)',
    ).firstMatch(raw.trim());

    if (whozzMatch != null) {
      return CallerIdData(
        trackingId: const Uuid().v4(),
        lineNumber: whozzMatch.group(1)!.trim(),
        direction: whozzMatch.group(2)!.trim(),
        recordType: whozzMatch.group(3)!.trim(),
        duration: whozzMatch.group(4)!.trim(),
        checksum: whozzMatch.group(5)!.trim(),
        date: whozzMatch.group(7)!.trim(),
        time: '${whozzMatch.group(8)!.trim()} ${whozzMatch.group(9)!.trim()}',
        phoneNumber: _resolvePhone(whozzMatch.group(10)!.trim()),
        callerName: _resolveName(whozzMatch.group(11)?.trim() ?? ''),
        rawData: raw,
        receivedAt: DateTime.now(),
      );
    }

    // Format 3: Fallback — extract phone from any line
    return _parseFallback(raw);
  }

  // ── Format 1: Key-value parser ─────────────────────────────────────────────
  // Handles both:
  //   Single line: "DATE = 0427 TIME = 1230 NMBR = 2505551299 NAME = ZEE"
  //   Multi line:  "DATE = 0427\r\nNMBR = 2505551299\r\nNAME = ZEE"
  static CallerIdData? _parseKeyValue(String raw) {
    // NMBR
    final phone = _resolvePhone(
      RegExp(r'NMBR\s*=\s*(\S+)').firstMatch(raw)?.group(1)?.trim() ?? '',
    );
    if (phone == null) return null;

    // NAME — stop before next key or end of line
    final nameRaw =
        RegExp(
          r'NAME\s*=\s*([^\r\n]+?)(?:\s+(?:DATE|TIME|NMBR)\s*=|$)',
        ).firstMatch(raw)?.group(1)?.trim() ??
        RegExp(r'NAME\s*=\s*([^\r\n]+)').firstMatch(raw)?.group(1)?.trim() ??
        '';

    // DATE and TIME
    final date =
        RegExp(r'DATE\s*=\s*(\S+)').firstMatch(raw)?.group(1)?.trim() ?? '';
    final time =
        RegExp(r'TIME\s*=\s*(\S+)').firstMatch(raw)?.group(1)?.trim() ?? '';

    return CallerIdData(
      trackingId: const Uuid().v4(),
      lineNumber: '1',
      direction: 'I',
      recordType: 'S',
      duration: '0000',
      checksum: 'G',
      date: date,
      time: time,
      phoneNumber: phone,
      callerName: _resolveName(nameRaw),
      rawData: raw,
      receivedAt: DateTime.now(),
    );
  }

  // ── Format 3: Fallback ─────────────────────────────────────────────────────
  // Last resort — extract first valid phone number from raw string
  static CallerIdData? _parseFallback(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^\x20-\x7E]'), '').trim();
    if (cleaned.isEmpty) return null;

    final phoneMatch = RegExp(r'(\d{7,15})').firstMatch(cleaned);
    if (phoneMatch == null) return null;

    final phone = _resolvePhone(phoneMatch.group(1)!);
    if (phone == null) return null;

    // Name = letters only after phone number, exclude known keys
    String? name;
    final afterPhone = cleaned.substring(phoneMatch.end).trim();
    if (afterPhone.isNotEmpty) {
      // Remove key-value noise like "NAME =", "DATE ="
      final cleaned2 = afterPhone
          .replaceAll(RegExp(r'\b(NAME|DATE|TIME|NMBR)\s*=\s*'), '')
          .replaceAll(RegExp(r'[^A-Za-z\s]'), '')
          .trim();
      name = _resolveName(cleaned2);
    }

    return CallerIdData(
      trackingId: const Uuid().v4(),
      lineNumber: '1',
      direction: 'I',
      recordType: 'S',
      duration: '0000',
      checksum: 'G',
      date: '',
      time: '',
      phoneNumber: phone,
      callerName: name,
      rawData: raw,
      receivedAt: DateTime.now(),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static String? _resolvePhone(String v) {
    if (v.isEmpty) return null;
    if (_invalidPhones.contains(v.trim().toUpperCase())) return null;
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) return null;
    if (digits.replaceAll('0', '').isEmpty) return null;
    return digits;
  }

  static String? _resolveName(String v) {
    final trimmed = v.trim();
    if (trimmed.isEmpty) return null;
    if (_invalidNames.contains(trimmed.toUpperCase())) return trimmed;
    if (!RegExp(r'[A-Za-z]').hasMatch(trimmed)) return null;
    return trimmed;
  }
}
