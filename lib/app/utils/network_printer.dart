import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

/// Why a print failed. Drives the text and buttons of the error dialog.
enum PrinterErrorType {
  /// No IP / host saved for this printer.
  notConfigured,

  /// Nothing to send.
  emptyData,

  /// Printer did not answer in time (off, wrong IP, other subnet).
  timeout,

  /// Host answered but refused the connection (wrong port, printer busy).
  connectionRefused,

  /// Connected, but sending the bytes failed (cable pulled, printer reset).
  sendFailed,

  /// Anything else.
  unknown;

  /// Retrying can help for network problems, not for bad setup/data.
  bool get isRetryable =>
      this != PrinterErrorType.notConfigured &&
      this != PrinterErrorType.emptyData;

  String get title => switch (this) {
    PrinterErrorType.notConfigured => 'Printer Not Set Up',
    PrinterErrorType.emptyData => 'Nothing to Print',
    PrinterErrorType.timeout => 'Printer Not Responding',
    PrinterErrorType.connectionRefused => 'Printer Refused Connection',
    PrinterErrorType.sendFailed => 'Print Interrupted',
    PrinterErrorType.unknown => 'Printer Not Connected',
  };

  String get hint => switch (this) {
    PrinterErrorType.notConfigured =>
      'Add the printer IP address in Settings → Printers.',
    PrinterErrorType.emptyData => 'The receipt was empty, nothing was sent.',
    PrinterErrorType.timeout =>
      'Check the printer is ON and connected to the same network.',
    PrinterErrorType.connectionRefused =>
      'Check the printer IP/port. The printer may be busy — try again.',
    PrinterErrorType.sendFailed =>
      'Connection dropped while printing. Check cable/paper and retry.',
    PrinterErrorType.unknown => 'Check the printer and try again.',
  };
}

class PrinterException implements Exception {
  final PrinterErrorType type;
  final String message;
  final Object? cause;

  const PrinterException(this.type, this.message, [this.cause]);

  /// Short technical detail for the dialog / logs.
  String get details => cause == null ? message : '$message ($cause)';

  @override
  String toString() => 'PrinterException(${type.name}): $details';
}

/// Raw TCP (port 9100) printer — works for ESC/POS and Star Line Mode bytes.
class NetworkPrinter {
  final String ip;
  final int port;
  final Duration timeout;

  NetworkPrinter({
    required this.ip,
    this.port = 9100,
    this.timeout = const Duration(seconds: 5),
  });

  /// Most thermal printers accept only ONE TCP connection at a time. When the
  /// POS, the socket listener and a kitchen ticket print together, the second
  /// connect gets refused. Jobs to the same host:port are chained here so they
  /// run one after another.
  static final Map<String, Future<void>> _queues = {};

  String get _key => '${ip.trim()}:$port';

  /// Sends [data] to the printer.
  ///
  /// Completes normally when all bytes were flushed.
  /// Throws [PrinterException] on any failure — never returns silently.
  Future<void> print(Uint8List data) {
    final previous = _queues[_key] ?? Future<void>.value();
    final job = previous
        .catchError((_) {}) // a failed earlier job must not block this one
        .then((_) => _send(data));

    final tail = job.catchError((_) {});
    _queues[_key] = tail;
    tail.whenComplete(() {
      if (identical(_queues[_key], tail)) _queues.remove(_key);
    });

    return job;
  }

  Future<void> _send(Uint8List data) async {
    final host = ip.trim();
    if (host.isEmpty) {
      throw const PrinterException(
        PrinterErrorType.notConfigured,
        'Printer IP address is not configured',
      );
    }
    if (data.isEmpty) {
      throw const PrinterException(
        PrinterErrorType.emptyData,
        'Data is empty, nothing to print',
      );
    }

    Socket socket;
    try {
      socket = await Socket.connect(host, port, timeout: timeout);
    } on SocketException catch (e) {
      throw PrinterException(_typeFor(e), 'Cannot connect to $host:$port', e.message);
    } on TimeoutException catch (e) {
      throw PrinterException(
        PrinterErrorType.timeout,
        'Connection to $host:$port timed out',
        e.message,
      );
    } catch (e) {
      throw PrinterException(
        PrinterErrorType.unknown,
        'Unexpected error connecting to $host:$port',
        e,
      );
    }

    try {
      socket.add(data);
      await socket.flush().timeout(timeout);
    } on TimeoutException catch (e) {
      throw PrinterException(
        PrinterErrorType.sendFailed,
        'Printer $host:$port stopped accepting data',
        e.message,
      );
    } on SocketException catch (e) {
      throw PrinterException(
        PrinterErrorType.sendFailed,
        'Failed to send data to $host:$port',
        e.message,
      );
    } catch (e) {
      throw PrinterException(
        PrinterErrorType.sendFailed,
        'Unexpected error while printing to $host:$port',
        e,
      );
    } finally {
      try {
        await socket.close();
      } catch (_) {
        // Closing a socket the printer already dropped must not turn a
        // successful print into a failure.
      }
      socket.destroy();
    }
  }

  static PrinterErrorType _typeFor(SocketException e) {
    final code = e.osError?.errorCode;
    final msg = '${e.message} ${e.osError?.message ?? ''}'.toLowerCase();

    // Windows: 10061 refused, 10060 timed out, 10065/10051 unreachable.
    // Linux/Android: 111 refused, 110 timed out, 113/101 unreachable.
    if (code == 10061 || code == 111 || msg.contains('refused')) {
      return PrinterErrorType.connectionRefused;
    }
    if (code == 10060 ||
        code == 110 ||
        code == 10065 ||
        code == 10051 ||
        code == 113 ||
        code == 101 ||
        msg.contains('timed out') ||
        msg.contains('unreachable')) {
      return PrinterErrorType.timeout;
    }
    return PrinterErrorType.unknown;
  }
}
