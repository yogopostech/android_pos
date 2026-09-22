// import 'package:uuid/uuid.dart';

// class CallerIdData {
//   final String trackingId; // 👈 নতুন
//   final String lineNumber;
//   final String direction;
//   final String recordType;
//   final String duration;
//   final String checksum;
//   final String date;
//   final String time;
//   final String rawData;
//   final DateTime receivedAt;
//   final String? phoneNumber;
//   final String? callerName;

//   const CallerIdData({
//     required this.trackingId, // 👈 নতুন
//     required this.lineNumber,
//     required this.direction,
//     required this.recordType,
//     required this.duration,
//     required this.checksum,
//     required this.date,
//     required this.time,
//     required this.rawData,
//     required this.receivedAt,
//     this.phoneNumber,
//     this.callerName,
//   });

//   // ── JSON ───────────────────────────────────────────────────────────────────
//   factory CallerIdData.fromJson(Map<String, dynamic> json) => CallerIdData(
//     // backend থেকে আসলে সেটা use করো, না আসলে নতুন generate করো
//     trackingId: json['trackingId'] as String? ?? const Uuid().v4(),
//     lineNumber: json['lineNumber'] as String? ?? '1',
//     direction: json['direction'] as String? ?? 'I',
//     recordType: json['recordType'] as String? ?? 'S',
//     duration: json['duration'] as String? ?? '0000',
//     checksum: json['checksum'] as String? ?? 'G',
//     date: json['date'] as String? ?? '',
//     time: json['time'] as String? ?? '',
//     rawData: json['rawData'] as String? ?? '',
//     receivedAt: json['receivedAt'] != null
//         ? DateTime.parse(json['receivedAt'] as String)
//         : DateTime.now(),
//     phoneNumber: json['phoneNumber'] as String?,
//     callerName: json['callerName'] as String?,
//   );

//   Map<String, dynamic> toJson() => {
//     'trackingId': trackingId, // 👈 নতুন
//     'lineNumber': lineNumber,
//     'direction': direction,
//     'recordType': recordType,
//     'duration': duration,
//     'checksum': checksum,
//     'date': date,
//     'time': time,
//     'rawData': rawData,
//     'receivedAt': receivedAt.toIso8601String(),
//     'phoneNumber': phoneNumber,
//     'callerName': callerName,
//     'displayPhone': displayPhone,
//     'displayName': displayName,
//     'isPrivate': isPrivate,
//     'isInboundStart': isInboundStart,
//   };

//   // ── Computed ───────────────────────────────────────────────────────────────
//   bool get isInboundStart =>
//       direction == 'I' && (recordType == 'S' || recordType == 'B');

//   bool get hasValidPhone =>
//       phoneNumber != null &&
//       phoneNumber!.trim().isNotEmpty &&
//       RegExp(r'^\d{7,15}$').hasMatch(phoneNumber!.trim());

//   bool get isPrivate => !hasValidPhone;
//   bool get canLookup => hasValidPhone;

//   String get displayPhone {
//     if (!hasValidPhone) return 'Unknown Number';
//     final d = phoneNumber!.replaceAll(RegExp(r'\D'), '');
//     if (d.length == 10) {
//       return '(${d.substring(0, 3)}) ${d.substring(3, 6)}-${d.substring(6)}';
//     }
//     if (d.length == 11 && d.startsWith('1')) {
//       final n = d.substring(1);
//       return '+1 (${n.substring(0, 3)}) ${n.substring(3, 6)}-${n.substring(6)}';
//     }
//     return d;
//   }

//   String get displayName {
//     final raw = callerName?.trim();
//     if (raw == null || raw.isEmpty) return 'Unknown Caller';
//     return raw
//         .split(RegExp(r'\s+'))
//         .where((w) => w.isNotEmpty)
//         .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
//         .join(' ');
//   }

//   @override
//   String toString() => 'CallerIdData(${toJson()})';
// }

import 'package:uuid/uuid.dart';

enum CallStatus {
  accepted('Accepted'),
  rejected('Rejected');

  const CallStatus(this.value);
  final String value;

  static CallStatus fromJson(String? raw) {
    if (raw == null) return CallStatus.rejected;
    return CallStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == raw.toLowerCase(),
      orElse: () => CallStatus.rejected,
    );
  }
}

class CallerIdData {
  final String id;
  final String trackingId;
  final String lineNumber;
  final String direction;
  final String recordType;
  final String duration;
  final String checksum;
  final String date;
  final String time;
  final String rawData;
  final DateTime receivedAt;
  final String? phoneNumber;
  final String? callerName;
  final CallStatus callStatus;

  const CallerIdData({
    this.id = '',
    required this.trackingId,
    required this.lineNumber,
    required this.direction,
    required this.recordType,
    required this.duration,
    required this.checksum,
    required this.date,
    required this.time,
    required this.rawData,
    required this.receivedAt,
    this.phoneNumber,
    this.callerName,
    this.callStatus = CallStatus.rejected,
  });

  factory CallerIdData.fromJson(Map<String, dynamic> json) => CallerIdData(
    id: json['id'] as String? ?? '',
    trackingId: json['trackingId'] as String? ?? const Uuid().v4(),
    lineNumber: json['lineNumber'] as String? ?? '1',
    direction: json['direction'] as String? ?? 'I',
    recordType: json['recordType'] as String? ?? 'S',
    duration: json['duration'] as String? ?? '0000',
    checksum: json['checksum'] as String? ?? 'G',
    date: json['date'] as String? ?? '',
    time: json['time'] as String? ?? '',
    rawData: json['rawData'] as String? ?? '',
    receivedAt: json['receivedAt'] != null
        ? DateTime.parse(json['receivedAt'] as String)
        : DateTime.now(),
    phoneNumber: json['phoneNumber'] as String?,
    callerName: json['callerName'] as String?,
    callStatus: CallStatus.fromJson(json['callStatus'] as String?),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'trackingId': trackingId,
    'lineNumber': lineNumber,
    'direction': direction,
    'recordType': recordType,
    'duration': duration,
    'checksum': checksum,
    'date': date,
    'time': time,
    'rawData': rawData,
    'receivedAt': receivedAt.toUtc().toIso8601String(),
    'phoneNumber': phoneNumber,
    'callerName': callerName,
    'callStatus': callStatus.value,
    'displayPhone': displayPhone,
    'displayName': displayName,
    'isPrivate': isPrivate,
    'isInboundStart': isInboundStart,
  };

  bool get isInboundStart =>
      direction == 'I' && (recordType == 'S' || recordType == 'B');

  bool get hasValidPhone =>
      phoneNumber != null &&
      phoneNumber!.trim().isNotEmpty &&
      RegExp(r'^\d{7,15}$').hasMatch(phoneNumber!.trim());

  bool get isPrivate => !hasValidPhone;
  bool get canLookup => hasValidPhone;

  String get displayPhone {
    if (!hasValidPhone) return 'Unknown Number';
    final d = phoneNumber!.replaceAll(RegExp(r'\D'), '');
    if (d.length == 10) {
      return '(${d.substring(0, 3)}) ${d.substring(3, 6)}-${d.substring(6)}';
    }
    if (d.length == 11 && d.startsWith('1')) {
      final n = d.substring(1);
      return '+1 (${n.substring(0, 3)}) ${n.substring(3, 6)}-${n.substring(6)}';
    }
    return d;
  }

  String get displayName {
    final raw = callerName?.trim();
    if (raw == null || raw.isEmpty) return 'Unknown Caller';
    return raw
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  String toString() => 'CallerIdData(${toJson()})';
}
