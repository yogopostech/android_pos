import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TerminalTestDialog2 extends StatefulWidget {
  const TerminalTestDialog2({
    super.key,
    this.host = '192.168.1.100',
    this.port = 12000,
  });

  final String host;
  final int port;

  @override
  State<TerminalTestDialog2> createState() => _TerminalTestDialog2State();
}

class _TerminalTestDialog2State extends State<TerminalTestDialog2> {
  final List<_LogEntry> _logs = [];
  final ScrollController _scrollCtrl = ScrollController();
  bool _isProcessing = false;
  Socket? _socket;

  static const int _fs = 0x1C;
  static const int _hb = 0x11; // heartbeat byte

  void _log(String msg, {LogLevel level = LogLevel.info}) {
    if (!mounted) return;
    setState(() {
      _logs.add(_LogEntry(time: DateTime.now(), message: msg, level: level));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearLogs() => setState(() => _logs.clear());

  Future<void> _processPurchase() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final completer = Completer<void>();
    Timer? idleTimer;

    void resetIdle() {
      idleTimer?.cancel();
      // If no data (including heartbeats) for 60s → give up
      idleTimer = Timer(const Duration(seconds: 60), () {
        if (!completer.isCompleted) {
          _log('✗ Idle timeout (60s no data)', level: LogLevel.error);
          completer.complete();
        }
      });
    }

    try {
      _log(
        'Connecting to ${widget.host}:${widget.port} ...',
        level: LogLevel.info,
      );
      _socket = await Socket.connect(
        widget.host,
        widget.port,
        timeout: const Duration(seconds: 5),
      );
      _log('✓ Connected', level: LogLevel.success);

      // Raw payload: 00<FS>0011000
      final payload = '00${String.fromCharCode(_fs)}0011000';
      final bytes = utf8.encode(payload);

      _log('→ TX: 00<FS>0011000  (${bytes.length} bytes)', level: LogLevel.tx);
      _log('→ Hex: ${_hex(bytes)}', level: LogLevel.tx);

      _socket!.add(bytes);
      await _socket!.flush();
      _log('✓ Sent — waiting for terminal response', level: LogLevel.success);

      resetIdle();

      final rxBuf = <int>[];

      _socket!.listen(
        (data) {
          resetIdle();

          for (final b in data) {
            // ── Heartbeat: MUST echo back immediately ──
            if (b == _hb) {
              _log('♥ Heartbeat → replying 0x11', level: LogLevel.heartbeat);
              _socket?.add([_hb]); // <-- THIS was the missing piece
              continue;
            }

            rxBuf.add(b);
          }

          // Once we have data that's not a heartbeat, try to parse it
          if (rxBuf.isNotEmpty) {
            _tryParseResponse(rxBuf);
          }
        },
        onError: (e) {
          _log('✗ Socket error: $e', level: LogLevel.error);
          if (!completer.isCompleted) completer.complete();
        },
        onDone: () {
          _log('Socket closed by terminal', level: LogLevel.info);
          if (!completer.isCompleted) completer.complete();
        },
        cancelOnError: false,
      );

      await completer.future;
    } catch (e) {
      _log('✗ Error: $e', level: LogLevel.error);
    } finally {
      idleTimer?.cancel();
      _socket?.destroy();
      _socket = null;
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _tryParseResponse(List<int> buf) {
    // Wait for at least status(2) + multi(1) = 3 bytes
    if (buf.length < 3) return;

    final hex = _hex(buf);
    _log('← RX (${buf.length} bytes): $hex', level: LogLevel.rx);

    try {
      final ascii = String.fromCharCodes(
        buf.map((b) => b >= 0x20 && b < 0x7F ? b : 0x2E),
      );
      _log('← ASCII: $ascii', level: LogLevel.rx);
    } catch (_) {}

    // Parse status code
    final status = String.fromCharCodes(buf.sublist(0, 2));
    final multi = String.fromCharCode(buf[2]);
    _log(
      '  Status: $status (${_statusLabel(status)})  Multi: $multi',
      level: status == '00' || status == '01'
          ? LogLevel.success
          : LogLevel.error,
    );

    // Receipt chunk — terminal waits for "990" before continuing
    if (status == '99') {
      _log('  Receipt chunk → sending 990', level: LogLevel.info);
      _socket?.add(utf8.encode('990'));
      _log('→ TX: 990 (print OK)', level: LogLevel.tx);
    }

    // Parse FS-separated tags
    if (buf.length > 3) {
      final rest = buf.sublist(3);
      final parts = _splitOn(rest, _fs);
      for (final part in parts) {
        if (part.length < 3) continue;
        final tag = String.fromCharCodes(part.sublist(0, 3));
        final val = String.fromCharCodes(
          part.sublist(3).map((b) => b >= 0x20 && b < 0x7F ? b : 0x2E),
        );
        _log('  [$tag ${_tagLabel(tag)}] = $val', level: LogLevel.info);
      }
    }

    buf.clear();
  }

  List<List<int>> _splitOn(List<int> data, int sep) {
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

  String _hex(List<int> data) =>
      data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

  String _statusLabel(String s) =>
      const {
        '00': 'Approved',
        '01': 'Partial Approved',
        '10': 'Declined',
        '11': 'Comm Error',
        '12': 'Cancelled',
        '13': 'Timed Out',
        '14': 'Not Completed',
        '15': 'Batch Empty',
        '16': 'Declined by Merchant',
        '17': 'Record Not Found',
        '18': 'Already Voided',
        '30': 'Invalid ECR Param',
        '31': 'Battery Low',
        '95': 'Terminal Not Available',
        '99': 'Receipt Data',
      }[s] ??
      '?';

  String _tagLabel(String tag) =>
      const {
        '100': 'TransType',
        '101': 'TransStatus',
        '102': 'Date',
        '103': 'Time',
        '104': 'Amount',
        '105': 'Tip',
        '106': 'Cashback',
        '107': 'Surcharge',
        '108': 'Tax',
        '109': 'Total',
        '110': 'Invoice',
        '112': 'RefNum',
        '118': 'ClerkID',
        '300': 'CardType',
        '301': 'CardDesc',
        '302': 'PAN',
        '306': 'EntryMode',
        '312': 'CVM',
        '400': 'AuthCode',
        '401': 'HostCode',
        '402': 'HostText',
        '404': 'RetrievalRef',
        '405': 'AmountDue',
        '409': 'Balance',
        '412': 'HostTransRef',
        '500': 'Batch#',
        '600': 'DEMO',
        '601': 'TermID',
        '602': 'MerchID',
      }[tag] ??
      '';

  @override
  void dispose() {
    _socket?.destroy();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (same UI as before, no changes needed)
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  const Icon(Icons.point_of_sale, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Terminal Test',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.host}:${widget.port}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isProcessing
                        ? null
                        : () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isProcessing ? null : _processPurchase,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        _isProcessing ? 'Processing...' : 'Process Purchase',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: _logs.isEmpty || _isProcessing
                        ? null
                        : _clearLogs,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Clear logs',
                  ),
                  IconButton.outlined(
                    onPressed: _logs.isEmpty ? null : _copyLogs,
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy logs',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? Center(
                        child: Text(
                          'Logs will appear here',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        itemCount: _logs.length,
                        itemBuilder: (_, i) => _buildLogLine(_logs[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogLine(_LogEntry entry) {
    final ts = entry.time;
    final timeStr =
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}.${ts.millisecond.toString().padLeft(3, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: '$timeStr ',
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextSpan(
              text: entry.message,
              style: TextStyle(color: entry.level.color),
            ),
          ],
        ),
      ),
    );
  }

  void _copyLogs() {
    final text = _logs
        .map((e) {
          final ts = e.time;
          final t =
              '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}';
          return '$t  ${e.message}';
        })
        .join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}




class TerminalTestDialog3 extends StatefulWidget {
  const TerminalTestDialog3({
    super.key,
    this.host = '192.168.1.100',
    this.port = 12000,
  });

  final String host;
  final int port;

  @override
  State<TerminalTestDialog3> createState() => _TerminalTestDialog3State();
}

class _TerminalTestDialog3State extends State<TerminalTestDialog3> {
  final List<_LogEntry> _logs = [];
  final ScrollController _scrollCtrl = ScrollController();
  bool _isProcessing = false;
  Socket? _socket;

  static const int _fs = 0x1C;
  static const int _hb = 0x11; // heartbeat byte

  void _log(String msg, {LogLevel level = LogLevel.info}) {
    if (!mounted) return;
    setState(() {
      _logs.add(_LogEntry(time: DateTime.now(), message: msg, level: level));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearLogs() => setState(() => _logs.clear());

  Future<void> _processPurchase() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final completer = Completer<void>();
    Timer? idleTimer;

    void resetIdle() {
      idleTimer?.cancel();
      // If no data (including heartbeats) for 60s → give up
      idleTimer = Timer(const Duration(seconds: 60), () {
        if (!completer.isCompleted) {
          _log('✗ Idle timeout (60s no data)', level: LogLevel.error);
          completer.complete();
        }
      });
    }

    try {
      _log(
        'Connecting to ${widget.host}:${widget.port} ...',
        level: LogLevel.info,
      );
      _socket = await Socket.connect(
        widget.host,
        widget.port,
        timeout: const Duration(seconds: 5),
      );
      _log('✓ Connected', level: LogLevel.success);

      // Raw payload: 00<FS>0011000
      // final payload = '00${String.fromCharCode(_fs)}0011000';
      final payload = '00${String.fromCharCode(_fs)}0011000${String.fromCharCode(_fs)}004100001';
      final bytes = utf8.encode(payload);

      _log('→ TX: 00<FS>0011000  (${bytes.length} bytes)', level: LogLevel.tx);
      _log('→ Hex: ${_hex(bytes)}', level: LogLevel.tx);

      _socket!.add(bytes);
      await _socket!.flush();
      _log('✓ Sent — waiting for terminal response', level: LogLevel.success);

      resetIdle();

      final rxBuf = <int>[];

      _socket!.listen(
        (data) {
          resetIdle();

          for (final b in data) {
            // ── Heartbeat: MUST echo back immediately ──
            if (b == _hb) {
              _log('♥ Heartbeat → replying 0x11', level: LogLevel.heartbeat);
              _socket?.add([_hb]); // <-- THIS was the missing piece
              continue;
            }

            rxBuf.add(b);
          }

          // Once we have data that's not a heartbeat, try to parse it
          if (rxBuf.isNotEmpty) {
            _tryParseResponse(rxBuf);
          }
        },
        onError: (e) {
          _log('✗ Socket error: $e', level: LogLevel.error);
          if (!completer.isCompleted) completer.complete();
        },
        onDone: () {
          _log('Socket closed by terminal', level: LogLevel.info);
          if (!completer.isCompleted) completer.complete();
        },
        cancelOnError: false,
      );

      await completer.future;
    } catch (e) {
      _log('✗ Error: $e', level: LogLevel.error);
    } finally {
      idleTimer?.cancel();
      _socket?.destroy();
      _socket = null;
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _tryParseResponse(List<int> buf) {
    // Wait for at least status(2) + multi(1) = 3 bytes
    if (buf.length < 3) return;

    final hex = _hex(buf);
    _log('← RX (${buf.length} bytes): $hex', level: LogLevel.rx);

    try {
      final ascii = String.fromCharCodes(
        buf.map((b) => b >= 0x20 && b < 0x7F ? b : 0x2E),
      );
      _log('← ASCII: $ascii', level: LogLevel.rx);
    } catch (_) {}

    // Parse status code
    final status = String.fromCharCodes(buf.sublist(0, 2));
    final multi = String.fromCharCode(buf[2]);
    _log(
      '  Status: $status (${_statusLabel(status)})  Multi: $multi',
      level: status == '00' || status == '01'
          ? LogLevel.success
          : LogLevel.error,
    );

    // Receipt chunk — terminal waits for "990" before continuing
    if (status == '99') {
      _log('  Receipt chunk → sending 990', level: LogLevel.info);
      _socket?.add(utf8.encode('990'));
      _log('→ TX: 990 (print OK)', level: LogLevel.tx);
    }

    // Parse FS-separated tags
    if (buf.length > 3) {
      final rest = buf.sublist(3);
      final parts = _splitOn(rest, _fs);
      for (final part in parts) {
        if (part.length < 3) continue;
        final tag = String.fromCharCodes(part.sublist(0, 3));
        final val = String.fromCharCodes(
          part.sublist(3).map((b) => b >= 0x20 && b < 0x7F ? b : 0x2E),
        );
        _log('  [$tag ${_tagLabel(tag)}] = $val', level: LogLevel.info);
      }
    }

    buf.clear();
  }

  List<List<int>> _splitOn(List<int> data, int sep) {
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

  String _hex(List<int> data) =>
      data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

  String _statusLabel(String s) =>
      const {
        '00': 'Approved',
        '01': 'Partial Approved',
        '10': 'Declined',
        '11': 'Comm Error',
        '12': 'Cancelled',
        '13': 'Timed Out',
        '14': 'Not Completed',
        '15': 'Batch Empty',
        '16': 'Declined by Merchant',
        '17': 'Record Not Found',
        '18': 'Already Voided',
        '30': 'Invalid ECR Param',
        '31': 'Battery Low',
        '95': 'Terminal Not Available',
        '99': 'Receipt Data',
      }[s] ??
      '?';

  String _tagLabel(String tag) =>
      const {
        '100': 'TransType',
        '101': 'TransStatus',
        '102': 'Date',
        '103': 'Time',
        '104': 'Amount',
        '105': 'Tip',
        '106': 'Cashback',
        '107': 'Surcharge',
        '108': 'Tax',
        '109': 'Total',
        '110': 'Invoice',
        '112': 'RefNum',
        '118': 'ClerkID',
        '300': 'CardType',
        '301': 'CardDesc',
        '302': 'PAN',
        '306': 'EntryMode',
        '312': 'CVM',
        '400': 'AuthCode',
        '401': 'HostCode',
        '402': 'HostText',
        '404': 'RetrievalRef',
        '405': 'AmountDue',
        '409': 'Balance',
        '412': 'HostTransRef',
        '500': 'Batch#',
        '600': 'DEMO',
        '601': 'TermID',
        '602': 'MerchID',
      }[tag] ??
      '';

  @override
  void dispose() {
    _socket?.destroy();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (same UI as before, no changes needed)
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  const Icon(Icons.point_of_sale, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Terminal Test',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.host}:${widget.port}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isProcessing
                        ? null
                        : () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isProcessing ? null : _processPurchase,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        _isProcessing ? 'Processing...' : 'Process Purchase',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: _logs.isEmpty || _isProcessing
                        ? null
                        : _clearLogs,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Clear logs',
                  ),
                  IconButton.outlined(
                    onPressed: _logs.isEmpty ? null : _copyLogs,
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy logs',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? Center(
                        child: Text(
                          'Logs will appear here',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        itemCount: _logs.length,
                        itemBuilder: (_, i) => _buildLogLine(_logs[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogLine(_LogEntry entry) {
    final ts = entry.time;
    final timeStr =
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}.${ts.millisecond.toString().padLeft(3, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: '$timeStr ',
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextSpan(
              text: entry.message,
              style: TextStyle(color: entry.level.color),
            ),
          ],
        ),
      ),
    );
  }

  void _copyLogs() {
    final text = _logs
        .map((e) {
          final ts = e.time;
          final t =
              '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}';
          return '$t  ${e.message}';
        })
        .join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}



class TerminalTestDialog4 extends StatefulWidget {
  const TerminalTestDialog4({
    super.key,
    this.host = '192.168.1.100',
    this.port = 12000,
  });

  final String host;
  final int port;

  @override
  State<TerminalTestDialog4> createState() => _TerminalTestDialog4State();
}

class _TerminalTestDialog4State extends State<TerminalTestDialog4> {
  final List<_LogEntry> _logs = [];
  final ScrollController _scrollCtrl = ScrollController();
  bool _isProcessing = false;
  Socket? _socket;

  static const int _fs = 0x1C;
  static const int _hb = 0x11; // heartbeat byte

  void _log(String msg, {LogLevel level = LogLevel.info}) {
    if (!mounted) return;
    setState(() {
      _logs.add(_LogEntry(time: DateTime.now(), message: msg, level: level));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearLogs() => setState(() => _logs.clear());

  Future<void> _processPurchase() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final completer = Completer<void>();
    Timer? idleTimer;

    void resetIdle() {
      idleTimer?.cancel();
      // If no data (including heartbeats) for 60s → give up
      idleTimer = Timer(const Duration(seconds: 60), () {
        if (!completer.isCompleted) {
          _log('✗ Idle timeout (60s no data)', level: LogLevel.error);
          completer.complete();
        }
      });
    }

    try {
      _log(
        'Connecting to ${widget.host}:${widget.port} ...',
        level: LogLevel.info,
      );
      _socket = await Socket.connect(
        widget.host,
        widget.port,
        timeout: const Duration(seconds: 5),
      );
      _log('✓ Connected', level: LogLevel.success);

      // Raw payload: 00<FS>0011000
      // final payload = '00${String.fromCharCode(_fs)}0011000';
      final payload = '00${String.fromCharCode(_fs)}0011000${String.fromCharCode(_fs)}003001${String.fromCharCode(_fs)}004100001';
      final bytes = utf8.encode(payload);

      _log('→ TX: 00<FS>0011000  (${bytes.length} bytes)', level: LogLevel.tx);
      _log('→ Hex: ${_hex(bytes)}', level: LogLevel.tx);

      _socket!.add(bytes);
      await _socket!.flush();
      _log('✓ Sent — waiting for terminal response', level: LogLevel.success);

      resetIdle();

      final rxBuf = <int>[];

      _socket!.listen(
        (data) {
          resetIdle();

          for (final b in data) {
            // ── Heartbeat: MUST echo back immediately ──
            if (b == _hb) {
              _log('♥ Heartbeat → replying 0x11', level: LogLevel.heartbeat);
              _socket?.add([_hb]); // <-- THIS was the missing piece
              continue;
            }

            rxBuf.add(b);
          }

          // Once we have data that's not a heartbeat, try to parse it
          if (rxBuf.isNotEmpty) {
            _tryParseResponse(rxBuf);
          }
        },
        onError: (e) {
          _log('✗ Socket error: $e', level: LogLevel.error);
          if (!completer.isCompleted) completer.complete();
        },
        onDone: () {
          _log('Socket closed by terminal', level: LogLevel.info);
          if (!completer.isCompleted) completer.complete();
        },
        cancelOnError: false,
      );

      await completer.future;
    } catch (e) {
      _log('✗ Error: $e', level: LogLevel.error);
    } finally {
      idleTimer?.cancel();
      _socket?.destroy();
      _socket = null;
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _tryParseResponse(List<int> buf) {
    // Wait for at least status(2) + multi(1) = 3 bytes
    if (buf.length < 3) return;

    final hex = _hex(buf);
    _log('← RX (${buf.length} bytes): $hex', level: LogLevel.rx);

    try {
      final ascii = String.fromCharCodes(
        buf.map((b) => b >= 0x20 && b < 0x7F ? b : 0x2E),
      );
      _log('← ASCII: $ascii', level: LogLevel.rx);
    } catch (_) {}

    // Parse status code
    final status = String.fromCharCodes(buf.sublist(0, 2));
    final multi = String.fromCharCode(buf[2]);
    _log(
      '  Status: $status (${_statusLabel(status)})  Multi: $multi',
      level: status == '00' || status == '01'
          ? LogLevel.success
          : LogLevel.error,
    );

    // Receipt chunk — terminal waits for "990" before continuing
    if (status == '99') {
      _log('  Receipt chunk → sending 990', level: LogLevel.info);
      _socket?.add(utf8.encode('990'));
      _log('→ TX: 990 (print OK)', level: LogLevel.tx);
    }

    // Parse FS-separated tags
    if (buf.length > 3) {
      final rest = buf.sublist(3);
      final parts = _splitOn(rest, _fs);
      for (final part in parts) {
        if (part.length < 3) continue;
        final tag = String.fromCharCodes(part.sublist(0, 3));
        final val = String.fromCharCodes(
          part.sublist(3).map((b) => b >= 0x20 && b < 0x7F ? b : 0x2E),
        );
        _log('  [$tag ${_tagLabel(tag)}] = $val', level: LogLevel.info);
      }
    }

    buf.clear();
  }

  List<List<int>> _splitOn(List<int> data, int sep) {
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

  String _hex(List<int> data) =>
      data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

  String _statusLabel(String s) =>
      const {
        '00': 'Approved',
        '01': 'Partial Approved',
        '10': 'Declined',
        '11': 'Comm Error',
        '12': 'Cancelled',
        '13': 'Timed Out',
        '14': 'Not Completed',
        '15': 'Batch Empty',
        '16': 'Declined by Merchant',
        '17': 'Record Not Found',
        '18': 'Already Voided',
        '30': 'Invalid ECR Param',
        '31': 'Battery Low',
        '95': 'Terminal Not Available',
        '99': 'Receipt Data',
      }[s] ??
      '?';

  String _tagLabel(String tag) =>
      const {
        '100': 'TransType',
        '101': 'TransStatus',
        '102': 'Date',
        '103': 'Time',
        '104': 'Amount',
        '105': 'Tip',
        '106': 'Cashback',
        '107': 'Surcharge',
        '108': 'Tax',
        '109': 'Total',
        '110': 'Invoice',
        '112': 'RefNum',
        '118': 'ClerkID',
        '300': 'CardType',
        '301': 'CardDesc',
        '302': 'PAN',
        '306': 'EntryMode',
        '312': 'CVM',
        '400': 'AuthCode',
        '401': 'HostCode',
        '402': 'HostText',
        '404': 'RetrievalRef',
        '405': 'AmountDue',
        '409': 'Balance',
        '412': 'HostTransRef',
        '500': 'Batch#',
        '600': 'DEMO',
        '601': 'TermID',
        '602': 'MerchID',
      }[tag] ??
      '';

  @override
  void dispose() {
    _socket?.destroy();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (same UI as before, no changes needed)
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  const Icon(Icons.point_of_sale, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Terminal Test',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.host}:${widget.port}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isProcessing
                        ? null
                        : () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isProcessing ? null : _processPurchase,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        _isProcessing ? 'Processing...' : 'Process Purchase',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: _logs.isEmpty || _isProcessing
                        ? null
                        : _clearLogs,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Clear logs',
                  ),
                  IconButton.outlined(
                    onPressed: _logs.isEmpty ? null : _copyLogs,
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy logs',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? Center(
                        child: Text(
                          'Logs will appear here',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        itemCount: _logs.length,
                        itemBuilder: (_, i) => _buildLogLine(_logs[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogLine(_LogEntry entry) {
    final ts = entry.time;
    final timeStr =
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}.${ts.millisecond.toString().padLeft(3, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: '$timeStr ',
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextSpan(
              text: entry.message,
              style: TextStyle(color: entry.level.color),
            ),
          ],
        ),
      ),
    );
  }

  void _copyLogs() {
    final text = _logs
        .map((e) {
          final ts = e.time;
          final t =
              '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}';
          return '$t  ${e.message}';
        })
        .join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copied'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}



class _LogEntry {
  final DateTime time;
  final String message;
  final LogLevel level;
  _LogEntry({required this.time, required this.message, required this.level});
}

enum LogLevel {
  info(Color(0xFFD4D4D4)),
  success(Color(0xFF4EC9B0)),
  error(Color(0xFFF48771)),
  tx(Color(0xFF9CDCFE)),
  rx(Color(0xFFDCDCAA)),
  heartbeat(Color(0xFF808080));

  final Color color;
  const LogLevel(this.color);
}
