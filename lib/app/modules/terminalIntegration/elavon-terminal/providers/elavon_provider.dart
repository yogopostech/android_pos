/// Ingenico Tetra TSI — Riverpod Provider
///
/// autoDispose: socket closes when dialog closes.
/// Raw TCP: only kFs + kHb, no STX/ETX framing.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/elavon_constants.dart';
import '../models/elavon_model.dart';
import '../services/elavon_utils.dart';

part 'elavon_provider.g.dart';

// ============================================================================
// State
// ============================================================================

enum ElavonPhase {
  idle,
  connecting,
  sending,
  waitingForCard,
  processing,
  approved,
  declined,
  error,
}

class ElavonState {
  final ElavonPhase phase;
  final String message;
  final ElavonPaymentResult? result;
  final List<String> logs;

  const ElavonState({
    this.phase = ElavonPhase.idle,
    this.message = '',
    this.result,
    this.logs = const [],
  });

  bool get isBusy =>
      phase == ElavonPhase.connecting ||
      phase == ElavonPhase.sending ||
      phase == ElavonPhase.waitingForCard ||
      phase == ElavonPhase.processing;

  ElavonState copyWith({
    ElavonPhase? phase,
    String? message,
    ElavonPaymentResult? result,
    List<String>? logs,
    bool clearResult = false,
  }) =>
      ElavonState(
        phase: phase ?? this.phase,
        message: message ?? this.message,
        result: clearResult ? null : (result ?? this.result),
        logs: logs ?? this.logs,
      );
}

// ============================================================================
// Provider
// ============================================================================

@riverpod
class ElavonPayment extends _$ElavonPayment {
  Socket? _socket;

  @override
  ElavonState build() => const ElavonState();

  // ── Logging ──

  void _log(String msg) {
    debugPrint('[Elavon] $msg');
    final ts = DateTime.now();
    final t = '${ts.hour.toString().padLeft(2, '0')}:'
        '${ts.minute.toString().padLeft(2, '0')}:'
        '${ts.second.toString().padLeft(2, '0')}.'
        '${ts.millisecond.toString().padLeft(3, '0')}';
    final logs = [...state.logs, '$t $msg'];
    if (logs.length > 100) logs.removeRange(0, logs.length - 100);
    state = state.copyWith(logs: logs);
  }

  // =========================================================================
  // Purchase  (type 00)
  // =========================================================================

  Future<ElavonPaymentResult?> purchase({
    required String host,
    required int port,
    required int amountCents,
    String? invoiceNum,
    String? tenderType,
  }) async {
    final payload = StringBuffer()
      ..write(ElavonTranType.purchase)
      ..writeCharCode(kFs)
      ..write('${ElavonTag.amount}$amountCents');

    if (tenderType != null) {
      payload..writeCharCode(kFs)..write('${ElavonTag.tenderType}$tenderType');
    }
    if (invoiceNum != null && invoiceNum.isNotEmpty) {
      payload..writeCharCode(kFs)..write('${ElavonTag.invoice}$invoiceNum');
    }

    return _execute(host: host, port: port, payload: payload.toString());
  }

  // =========================================================================
  // Void  (type 05)
  // =========================================================================

  /// Void a previous transaction.
  ///
  /// All search criteria are optional. If none provided, the terminal
  /// shows its own interactive search menu.
  ///
  /// [isPreAuthVoid] set true to void a pre-auth (tran type class = '02').
  Future<ElavonPaymentResult?> voidTransaction({
    required String host,
    required int port,
    String? invoiceNum,
    String? authCode,
    String? referenceNum,
    String? panLast4,
    int? amountCents,
    bool isPreAuthVoid = false,
  }) async {
    final payload = StringBuffer()..write(ElavonTranType.voidTran);

    if (invoiceNum != null && invoiceNum.isNotEmpty) {
      payload..writeCharCode(kFs)..write('${ElavonTag.invoice}$invoiceNum');
    }
    if (authCode != null && authCode.isNotEmpty) {
      payload..writeCharCode(kFs)..write('${ElavonTag.authCode}$authCode');
    }
    if (referenceNum != null && referenceNum.isNotEmpty) {
      payload..writeCharCode(kFs)..write('${ElavonTag.reference}$referenceNum');
    }
    if (panLast4 != null && panLast4.isNotEmpty) {
      payload..writeCharCode(kFs)..write('${ElavonTag.panLast4}$panLast4');
    }
    if (amountCents != null) {
      payload..writeCharCode(kFs)..write('${ElavonTag.amount}$amountCents');
    }
    if (isPreAuthVoid) {
      payload..writeCharCode(kFs)..write('${ElavonTag.tranTypeClass}02');
    }

    return _execute(host: host, port: port, payload: payload.toString());
  }

  // =========================================================================
  // Refund  (type 03)
  // =========================================================================

  Future<ElavonPaymentResult?> refund({
    required String host,
    required int port,
    required int amountCents,
    String? invoiceNum,
    String? tenderType,
    String? clerkId,
    String? customerRef,
  }) async {
    final payload = StringBuffer()
      ..write(ElavonTranType.refund)
      ..writeCharCode(kFs)
      ..write('${ElavonTag.amount}$amountCents');

    if (tenderType != null) {
      payload..writeCharCode(kFs)..write('${ElavonTag.tenderType}$tenderType');
    }
    if (invoiceNum != null && invoiceNum.isNotEmpty) {
      payload..writeCharCode(kFs)..write('${ElavonTag.invoice}$invoiceNum');
    }
    if (clerkId != null && clerkId.isNotEmpty) {
      payload..writeCharCode(kFs)..write('${ElavonTag.clerkId}$clerkId');
    }
    if (customerRef != null && customerRef.isNotEmpty) {
      payload..writeCharCode(kFs)..write('${ElavonTag.customerRef}$customerRef');
    }

    return _execute(host: host, port: port, payload: payload.toString());
  }

  // =========================================================================
  // Core execute — connect, send, listen, parse
  // =========================================================================

  Future<ElavonPaymentResult?> _execute({
    required String host,
    required int port,
    required String payload,
  }) async {
    if (state.isBusy) return null;

  final completer = Completer<ElavonPaymentResult?>();
    Timer? idleTimer;
    final fields = <String, String>{};

    void resetIdle() {
      idleTimer?.cancel();
      idleTimer = Timer(const Duration(seconds: 60), () {
        if (!completer.isCompleted) {
          _log('✗ Idle timeout (60s)');
          completer.complete(null);
        }
      });
    }

    try {
      // ── Connect ──
      state = state.copyWith(
        phase: ElavonPhase.connecting,
        message: 'Connecting to terminal',
        clearResult: true,
      );
      _log('Connecting to $host:$port...');

      _socket = await Socket.connect(host, port,
          timeout: const Duration(seconds: 10));
      _log('✓ Connected');

      // ── Send ──
      final bytes = utf8.encode(payload);
      state = state.copyWith(
        phase: ElavonPhase.sending,
        message: 'Processing',
      );
      _log('→ TX (${bytes.length}B): ${elavonPrettyBytes(bytes)}');

      _socket!.add(bytes);
      await _socket!.flush();
      _log('✓ Sent');

      resetIdle();

      // ── Listen ──
      final rxBuf = <int>[];

      _socket!.listen(
        (chunk) {
          resetIdle();

          for (final b in chunk) {
            if (b == kHb) {
              _log('♥ Heartbeat');
              state = state.copyWith(
                phase: ElavonPhase.waitingForCard,
                message: 'Processing',
              );
              continue;
            }
            rxBuf.add(b);
          }

          if (rxBuf.length < 3) return;

          final status = String.fromCharCodes(rxBuf.sublist(0, 2));
          _log('← RX (${rxBuf.length}B): ${elavonPrettyBytes(rxBuf)}');
          _log('  Status: $status (${elavonStatusLabel(status)})');

          // Parse tags
          if (rxBuf.length > 3) {
            final parsed = elavonParseTags(rxBuf.sublist(3));
            fields.addAll(parsed);
            for (final e in parsed.entries) {
              final label = elavonTagLabel(e.key);
              _log('  [${e.key}${label.isEmpty ? '' : ' $label'}] = ${e.value}');
            }
          }

          rxBuf.clear();

          // Receipt → reply 990
          if (status == '99') {
            _log('  Receipt → sending 990');
            _socket?.add(utf8.encode('990'));
            state = state.copyWith(
              phase: ElavonPhase.processing,
              message: 'Processing',
            );
            return;
          }

          // Final
          final result = ElavonPaymentResult.fromFields(
            statusCode: status,
            fields: fields,
          );

          _log('── ${result.statusText.toUpperCase()} ──');
          if (result.isApproved) {
            _log('  Auth   : ${result.authCode ?? '-'}');
            _log('  Card   : ${result.cardName ?? '-'}');
            _log('  PAN    : ${result.maskedPan ?? '-'}');
            _log('  Total  : ${result.totalAmount ?? '-'}');
            _log('  Tip    : ${result.tipAmount ?? '-'}');
            _log('  Ref    : ${result.referenceNumber ?? '-'}');
          }

          if (!completer.isCompleted) completer.complete(result);
        },
        onError: (e) {
          _log('✗ Socket error: $e');
          if (!completer.isCompleted) completer.complete(null);
        },
        onDone: () {
          _log('Socket closed');
          if (!completer.isCompleted) completer.complete(null);
        },
      );

      // ── Wait ──
      final result = await completer.future;

      if (result == null) {
        state = state.copyWith(
          phase: ElavonPhase.error,
          message: 'No response from terminal',
        );
        return null;
      }

      state = state.copyWith(
        phase: result.isApproved ? ElavonPhase.approved : ElavonPhase.declined,
        message: result.isApproved
            ? 'Approved'
            : (result.hostResponseText ?? result.statusText),
        result: result,
      );
      return result;
    } on SocketException catch (e) {
      _log('✗ Cannot connect: $e');
      state = state.copyWith(
        phase: ElavonPhase.error,
        message: 'Cannot connect to terminal',
      );
      return null;
    } on TimeoutException {
      _log('✗ Timeout');
      state = state.copyWith(
        phase: ElavonPhase.error,
        message: 'Connection timeout',
      );
      return null;
    } catch (e) {
      _log('✗ Error: $e');
      state = state.copyWith(
        phase: ElavonPhase.error,
        message: 'Failed',
      );
      return null;
    } finally {
      idleTimer?.cancel();
      _socket?.destroy();
      _socket = null;
    }
  }
}
