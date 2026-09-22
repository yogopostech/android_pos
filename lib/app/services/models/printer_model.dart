import 'dart:convert';

import 'package:yogo_pos/app/utils/receipt.dart';

class PrinterModel {
  final String connection;
  final PrinterType printerType;
  final int paperWidth;
  final int port;

  const PrinterModel({
    this.connection = '',
    this.paperWidth = 48,
    this.printerType = PrinterType.escpos,
    this.port = 9100,
  });

  /// Host / IP without surrounding whitespace.
  String get host => connection.trim();

  /// True once a host has been set, i.e. the printer can actually be reached.
  bool get isConfigured => host.isNotEmpty;

  PrinterModel copyWith({
    String? connection,
    PrinterType? printerType,
    int? paperWidth,
    int? port,
  }) {
    return PrinterModel(
      connection: connection ?? this.connection,
      printerType: printerType ?? this.printerType,
      paperWidth: paperWidth ?? this.paperWidth,
      port: port ?? this.port,
    );
  }

  Map<String, dynamic> toJson() => {
    'connection': connection,
    'printerType': printerType.name,
    'paperWidth': paperWidth,
    'port': port,
  };

  factory PrinterModel.fromJson(Map<String, dynamic> json) => PrinterModel(
    connection: json['connection'] as String? ?? '',
    printerType: printerTypeFromName(json['printerType']),
    paperWidth: (json['paperWidth'] as num?)?.toInt() ?? 48,
    port: (json['port'] as num?)?.toInt() ?? 9100,
  );

  /// Encoded form kept in SharedPreferences.
  String encode() => jsonEncode(toJson());

  /// Returns null when [raw] is empty or is not a printer payload — e.g. a
  /// value written by an older build that stored a plain printer name.
  static PrinterModel? decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return PrinterModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  /// Accepts both the enum name ('escpos') and the label ('EPSON').
  static PrinterType printerTypeFromName(dynamic value) {
    for (final type in PrinterType.values) {
      if (type.name == value || type.label == value) return type;
    }
    return PrinterType.escpos;
  }

  @override
  String toString() =>
      'PrinterModel(connection: $connection, port: $port, '
      'printerType: ${printerType.name}, paperWidth: $paperWidth)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrinterModel &&
          other.connection == connection &&
          other.printerType == printerType &&
          other.paperWidth == paperWidth &&
          other.port == port;

  @override
  int get hashCode => Object.hash(connection, printerType, paperWidth, port);
}
