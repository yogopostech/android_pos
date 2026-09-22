// ignore_for_file: depend_on_referenced_packages

library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/elavon-cws/services/cws_gratuity.dart';

import '../models/cws_credentials.dart';
import '../models/cws_model.dart';
import '../services/cws_constants.dart';
import '../services/cws_gateway.dart';
import '../services/cws_utils.dart';
import 'cws_credentials_provider.dart';

part 'cws_provider.g.dart';

/// Answers a terminal prompt. Given the raised `requiredInformation` keys and
/// the current command object, returns the parameters to merge into
/// continuePaymentTransaction.
typedef CwsPromptHandler =
    Future<Map<String, dynamic>> Function(
      List<String> requiredInformation,
      Map<String, dynamic> command,
    );

// ============================================================================
// State  (phases identical to the TSI provider so the base dialog is shared)
// ============================================================================

enum CwsPhase {
  idle,
  connecting,
  sending,
  waitingForCard,
  processing,
  approved,
  declined,
  error,
}

class CwsState {
  final CwsPhase phase;
  final String message;
  final CwsPaymentResult? result;
  final List<String> logs;

  const CwsState({
    this.phase = CwsPhase.idle,
    this.message = '',
    this.result,
    this.logs = const [],
  });

  bool get isBusy =>
      phase == CwsPhase.connecting ||
      phase == CwsPhase.sending ||
      phase == CwsPhase.waitingForCard ||
      phase == CwsPhase.processing;

  CwsState copyWith({
    CwsPhase? phase,
    String? message,
    CwsPaymentResult? result,
    List<String>? logs,
    bool clearResult = false,
  }) => CwsState(
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
class CwsPayment extends _$CwsPayment {
  final http.Client _http = _buildClient();

  /// Whether a card reader has already been located/connected this session.
  bool _readerReady = false;

  @override
  CwsState build() {
    ref.onDispose(() => _http.close());
    return const CwsState();
  }

  /// CWS serves HTTPS with a local (self-signed) certificate. Accept it only
  /// for the configured CWS host, or a loopback address. Any other host must
  /// present a valid certificate.
  static http.Client _buildClient() {
    const loopback = {'127.0.0.1', 'localhost', '::1'};
    final io = HttpClient()
      ..badCertificateCallback = (cert, host, port) =>
          host == CwsConfig.host || loopback.contains(host);
    return IOClient(io);
  }

  Uri get _uri =>
      Uri.parse('$kCwsScheme://${CwsConfig.host}:${CwsConfig.port}$kCwsPath');

  // ── Logging ──

  void _log(String msg) {
    debugPrint('[CWS] $msg');
    final ts = DateTime.now();
    final t =
        '${ts.hour.toString().padLeft(2, '0')}:'
        '${ts.minute.toString().padLeft(2, '0')}:'
        '${ts.second.toString().padLeft(2, '0')}.'
        '${ts.millisecond.toString().padLeft(3, '0')}';
    final logs = [...state.logs, '$t $msg'];
    if (logs.length > 100) logs.removeRange(0, logs.length - 100);
    state = state.copyWith(logs: logs);
  }

  // ── Current tenant credentials (single source of truth) ──

  CwsCredentials? _creds() =>
      ref.read(cwsCredentialsConfigProvider).asData?.value;

  String get _currency => _creds()?.currencyCode ?? 'CAD';

  /// One-shot health check (getEnvironmentInfo) — used by the settings card's
  /// "Test connection" button. Returns true if CWS answered.
  Future<bool> checkHealth() => _ping();

  /// Optional: open the gateway ahead of time (called by the credentials
  /// provider once creds are loaded, so the first real payment isn't slowed).
  /// Safe to call repeatedly — it no-ops if already open.
  Future<void> warmUp(CwsCredentials creds) async {
    await CwsGatewaySession.instance.ensureOpen(() => _openGateway(creds));
  }

  // =========================================================================
  // Purchase (SALE)
  // =========================================================================

  // Future<CwsPaymentResult?> purchase({
  //   required int amountCents,
  //   String? invoiceNum,
  //   bool requestTip = false, // terminal prompts the customer for a tip
  //   int? tipCents, // or add a fixed tip from the POS
  //   CwsPromptHandler? onPrompt,
  // }) {
  //   return _execute(
  //     txnType: CwsTxnType.sale,
  //     requestedCents: amountCents,
  //     params: {
  //       // key is baseTransactionAmount (NOT amount) — integer cents shape
  //       'baseTransactionAmount': cwsAmount(amountCents, _currency),
  //       if (requestTip) 'isGratuityRequested': true,
  //       if (tipCents != null)
  //         'gratuityAmount': cwsAmount(tipCents, _currency),
  //       // certification: unique reference on every sale
  //       'merchantTransactionReference':
  //           (invoiceNum == null || invoiceNum.isEmpty)
  //           ? cwsInvoiceNumber()
  //           : invoiceNum,
  //       // certification: card-present retail/restaurant must pass this
  //       'partialApprovalAllowed': CwsConfig.partialApprovalAllowed,
  //     },
  //     onPrompt: onPrompt,
  //   );
  // }

  
  Future<CwsPaymentResult?> purchase({
    required int amountCents,
    String? invoiceNum,
    CwsGratuity gratuity = CwsGratuity.none, // tip config (default: no tip)
    CwsPromptHandler? onPrompt,
  }) {
    return _execute(
      txnType: CwsTxnType.sale,
      requestedCents: amountCents,
      params: {
        'baseTransactionAmount': cwsAmount(amountCents, _currency),
 
        // gratuity (terminal prompt or pre-entered) — from CWS docs
        ...gratuity.toParams(_currency, cwsAmount),
 
        // certification: unique reference on every sale
        'merchantTransactionReference':
            (invoiceNum == null || invoiceNum.isEmpty)
            ? cwsInvoiceNumber()
            : invoiceNum,
        // certification: card-present retail/restaurant must pass this
        'partialApprovalAllowed': CwsConfig.partialApprovalAllowed,
      },
      onPrompt: onPrompt,
    );
  }

  // =========================================================================
  // Refund
  // =========================================================================

  Future<CwsPaymentResult?> refund({
    required int amountCents,
    String? invoiceNum,
    String? customerRef,
    CwsPromptHandler? onPrompt,
  }) {
    return _execute(
      txnType: CwsTxnType.refund,
      params: {
        'baseTransactionAmount': cwsAmount(amountCents, _currency),
        'merchantTransactionReference':
            (customerRef == null || customerRef.isEmpty)
            ? ((invoiceNum == null || invoiceNum.isEmpty)
                  ? cwsInvoiceNumber()
                  : invoiceNum)
            : customerRef,
      },
      onPrompt: onPrompt,
    );
  }

  // =========================================================================
  // Void  (references the original transaction)
  // =========================================================================

  Future<CwsPaymentResult?> voidTransaction({
    String? transId,
    String? invoiceNum,
    int? amountCents,
    CwsPromptHandler? onPrompt,
  }) {
    return _execute(
      txnType: CwsTxnType.voidTxn,
      params: {
        if (transId != null && transId.isNotEmpty) 'originalTransId': transId,
        if (invoiceNum != null && invoiceNum.isNotEmpty)
          'merchantTransactionReference': invoiceNum,
        if (amountCents != null)
          'baseTransactionAmount': cwsAmount(amountCents, _currency),
      },
      onPrompt: onPrompt,
    );
  }

  // =========================================================================
  // Core execute — ping, open gateway, ensure reader, start, poll, parse
  // =========================================================================

  Future<CwsPaymentResult?> _execute({
    required String txnType,
    required Map<String, dynamic> params,
    int? requestedCents,
    CwsPromptHandler? onPrompt,
  }) async {
    if (state.isBusy) return null;

    state = state.copyWith(
      phase: CwsPhase.connecting,
      message: 'Connecting to terminal',
      clearResult: true,
    );

    try {
      // 0) tenant credentials must be loaded and complete
      final creds = _creds();
      if (creds == null || !creds.isConfigured) {
        _log('✗ CWS credentials not configured for this tenant');
        state = state.copyWith(
          phase: CwsPhase.error,
          message: 'CWS not configured',
        );
        return null;
      }

      // 1) reachability — clear error if CWS isn't up
      _log('Checking CWS on ${CwsConfig.host}:${CwsConfig.port}…');
      final alive = await _ping();
      if (!alive) {
        _log('✗ CWS not reachable');
        state = state.copyWith(
          phase: CwsPhase.error,
          message: 'CWS not running (run as administrator)',
        );
        return null;
      }
      _log('✓ CWS alive');

      // 2) open gateway ONCE per app session (cached), reused across dialogs
      final gwId = await CwsGatewaySession.instance.ensureOpen(
        () => _openGateway(creds),
      );
      if (gwId == null) {
        state = state.copyWith(
          phase: CwsPhase.error,
          message: 'Gateway init failed',
        );
        return null;
      }

      // 2.5) ensure a card reader is connected before the sale
      final readerOk = await _ensureCardReader();
      if (!readerOk) {
        state = state.copyWith(
          phase: CwsPhase.error,
          message: 'No card reader connected',
        );
        return null;
      }

      // 3) start transaction
      state = state.copyWith(phase: CwsPhase.sending, message: 'Processing');
      final startRes = await _post(
        method: CwsMethod.startPaymentTransaction,
        target: CwsTarget.paymentGateway,
        params: {
          'paymentGatewayId': gwId,
          'transactionType': txnType,
          'tenderType': CwsTender.card,
          ...params,
        },
      );
      final startCmd = cwsCommandOf(startRes);
      final chanId = startCmd[CwsKey.chanId]?.toString();
      if (chanId == null) {
        _log('✗ No chanId returned');
        // gateway may be stale/expired — drop it so next attempt reopens
        CwsGatewaySession.instance.reset();
        state = state.copyWith(
          phase: CwsPhase.error,
          message: 'Could not start transaction',
        );
        return null;
      }
      _log('✓ Started (chanId=$chanId)');

      // 4) poll to completion
      state = state.copyWith(
        phase: CwsPhase.waitingForCard,
        message: 'Processing',
      );
      final result = await _pollToCompletion(
        gatewayId: gwId,
        chanId: chanId,
        onPrompt: onPrompt ?? _defaultPrompt,
      );

      if (result == null) {
        state = state.copyWith(
          phase: CwsPhase.error,
          message: 'No response from terminal',
        );
        return null;
      }

      _log('── ${result.statusText.toUpperCase()} ──');
      if (result.isApproved) {
        _log('  Auth  : ${result.authCode ?? '-'}');
        _log('  Card  : ${result.cardName ?? '-'}');
        _log('  PAN   : ${result.maskedPan ?? '-'}');
        _log('  Tip   : ${result.tipAmountCents ?? '-'}');
        _log(
          '  Total : ${result.totalAmountCents ?? result.amountCents ?? '-'}',
        );
        _log('  Ref   : ${result.referenceNumber ?? result.transId ?? '-'}');
      }

      // Partial approval: approved for less than requested. Caller must charge
      // the remainder to another tender, or void this transaction.
      final approved = result.amountCents ?? result.totalAmountCents;
      final isPartial =
          result.isApproved &&
          requestedCents != null &&
          approved != null &&
          approved < requestedCents;
      if (isPartial) {
        _log(
          '⚠ PARTIAL approval: $approved of $requestedCents '
          '— collect remainder or void',
        );
      }

      state = state.copyWith(
        phase: result.isApproved ? CwsPhase.approved : CwsPhase.declined,
        message: result.isApproved
            ? (isPartial ? 'Partial approval' : 'Approved')
            : (result.hostResponseText ?? result.statusText),
        result: result,
      );
      return result;
    } on TimeoutException {
      _log('✗ Timeout');
      state = state.copyWith(
        phase: CwsPhase.error,
        message: 'Connection timeout',
      );
      return null;
    } catch (e) {
      _log('✗ Error: $e');
      state = state.copyWith(phase: CwsPhase.error, message: 'Failed');
      return null;
    }
  }

  // ── Card reader: configure + search + connect (once per session) ──

  Future<bool> _ensureCardReader() async {
    if (_readerReady) return true;

    state = state.copyWith(
      phase: CwsPhase.connecting,
      message: 'Connecting terminal',
    );

    // configure which devices to look for
    await _post(
      method: CwsMethod.setDeviceConnectionConfiguration,
      target: CwsTarget.api,
      params: {
        'connectionCriteria': {
          'providerTypes': CwsConfig.readerProviderTypes,
          'connectionTypes': CwsConfig.readerConnectionTypes,
          'deviceTypes': ['CARD_READER'],
        },
      },
    );

    // start the search (connect to the first device found)
    await _post(
      method: CwsMethod.startCardReadersSearch,
      target: CwsTarget.cardReader,
      params: {'timeout': 9000, 'updateIfNecessary': true, 'connect': true},
    );

    // poll the search until it completes
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (DateTime.now().isBefore(deadline)) {
      final res = await _post(
        method: CwsMethod.getCardReadersSearchStatus,
        target: CwsTarget.cardReader,
        params: const {},
        quiet: true,
      );
      final search = cwsReadPath(res, [CwsKey.data, 'cardReadersSearch']);
      if (search is Map && search['completed'] == true) {
        final readers = search['cardReaders'];
        _readerReady = readers is List && readers.isNotEmpty;
        _log(
          _readerReady ? '✓ Card reader connected' : '✗ No card reader found',
        );
        return _readerReady;
      }
      await Future.delayed(kCwsPollInterval);
    }
    _log('✗ Card reader search timed out');
    return false;
  }

  // ── Poll loop ──

  Future<CwsPaymentResult?> _pollToCompletion({
    required String gatewayId,
    required String chanId,
    required CwsPromptHandler onPrompt,
  }) async {
    final deadline = DateTime.now().add(kCwsOverallTimeout);

    while (true) {
      if (DateTime.now().isAfter(deadline)) {
        _log('✗ Idle/overall timeout');
        return null;
      }

      final res = await _post(
        method: CwsMethod.getPaymentTransactionStatus,
        target: CwsTarget.paymentGateway,
        params: {'paymentGatewayId': gatewayId, 'chanId': chanId},
        quiet: true,
      );
      final cmd = cwsCommandOf(res);

      // surface event queue in logs
      final events = cmd[CwsKey.eventQueue];
      if (events is List && events.isNotEmpty) {
        _log('⋯ ${cwsCompact(events, max: 200)}');
      }

      final required =
          (cmd[CwsKey.requiredInformation] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[];

      if (required.isNotEmpty) {
        state = state.copyWith(
          phase: CwsPhase.processing,
          message: 'Processing',
        );
        _log('? Required: $required');
        final answers = await onPrompt(required, cmd);
        await _post(
          method: CwsMethod.continuePaymentTransaction,
          target: CwsTarget.paymentGateway,
          params: {'paymentGatewayId': gatewayId, 'chanId': chanId, ...answers},
        );
        continue; // re-poll immediately
      }

      if (cmd[CwsKey.completed] == true) {
        return CwsPaymentResult.fromCommand(cmd);
      }

      await Future.delayed(kCwsPollInterval);
    }
  }

  /// Default, non-interactive prompt handling. Logs the prompt and applies
  /// safe defaults. Pass an `onPrompt` to override with an interactive UI.
  Future<Map<String, dynamic>> _defaultPrompt(
    List<String> required,
    Map<String, dynamic> cmd,
  ) async {
    final answers = <String, dynamic>{};

    // Terminal asks whether a card is present (manual/keyed flows).
    if (required.contains('CardPresent')) {
      answers['CardPresent'] = 'true';
    }

    if (required.contains(CwsRequiredInfo.emvAppSelection)) {
      // pick the first offered application by default // CONFIRM shape
      final list = cmd[CwsKey.emvAppList];
      String? aid;
      if (list is List && list.isNotEmpty) {
        final first = list.first;
        aid = first is Map
            ? (first['aid'] ?? first['id'])?.toString()
            : first.toString();
      }
      if (aid != null) answers['EmvApplicationIdSelected'] = aid;
    }

    if (required.contains(CwsRequiredInfo.dccConfirmation)) {
      // default: charge in local/merchant currency
      answers[CwsRequiredInfo.dccConfirmation] = CwsDcc.reject;
    }

    return answers;
  }

  // ── HTTP ──

  Future<bool> _ping() async {
    try {
      // Any HTTP 200 with a JSON body means CWS answered.
      await _post(
        method: CwsMethod.getEnvironmentInfo,
        target: CwsTarget.api,
        params: const {},
      );
      return true;
    } catch (e) {
      _log('✗ Ping failed: $e');
      return false;
    }
  }

  Future<String?> _openGateway(CwsCredentials creds) async {
    // Value-integrity diagnostics (no secrets leaked — lengths only).
    _log(
      '  cred len: merchantId=${creds.merchantId.length}, '
      'userId=${creds.userId.length}, pin=${creds.pin.length}, '
      'vendorId=${creds.vendorId.length}',
    );
    if (creds.pin.length != 64) {
      _log(
        '  ⚠ pin length ${creds.pin.length}, expected 64 '
        '(check for a line-break/space when pasting)',
      );
    }
    for (final e in {
      'merchantId': creds.merchantId,
      'userId': creds.userId,
      'pin': creds.pin,
      'vendorId': creds.vendorId,
    }.entries) {
      if (e.value != e.value.trim() || e.value.contains(RegExp(r'\s'))) {
        _log('  ⚠ ${e.key} contains whitespace/newline — strip it');
      }
    }

    final res = await _post(
      method: CwsMethod.openPaymentGateway,
      target: CwsTarget.paymentGateway,
      params: {
        'merchantId': creds.merchantId, // 6-digit Converge account
        'userId': creds.userId,
        'pin': creds.pin, // country-specific 64-char
        'vendorId': creds.vendorId,
        'vendorAppName': CwsConfig.vendorAppName,
        'vendorAppVersion': CwsConfig.vendorAppVersion,
        if (creds.bmsUsername.isNotEmpty) 'bmsUsername': creds.bmsUsername,
        if (creds.bmsPassword.isNotEmpty) 'bmsPassword': creds.bmsPassword,
        'paymentGatewayEnvironment': creds.environment, // DEMO / PROD
        'logLevel': CwsConfig.logLevel,
        ...CwsConfig.extraCredentials,
      },
    );

    final cmd = cwsCommandOf(res);
    final gwData =
        (cwsReadPath(cmd, ['openPaymentGatewayData']) as Map?)
            ?.cast<String, dynamic>() ??
        const {};

    // surface the gateway result text (e.g. ECLTransactionInvalidCredentials)
    final result = gwData['result']?.toString();
    if (result != null) _log('  openGateway result: $result');

    final id =
        (gwData['paymentGatewayId'] ??
                cmd[CwsKey.paymentGatewayId] ??
                cwsReadPath(res, [CwsKey.data, CwsKey.paymentGatewayId]))
            ?.toString();

    if (id == null) {
      _log('✗ openPaymentGateway returned no id (${result ?? 'unknown'})');
    } else {
      _log('✓ Gateway opened');
    }
    return id;
  }

  Future<Map<String, dynamic>> _post({
    required String method,
    required String target,
    required Map<String, dynamic> params,
    bool quiet = false,
  }) async {
    final envelope = cwsBuildRequest(
      method: method,
      targetType: target,
      parameters: params,
    );
    final body = jsonEncode(envelope);
    if (!quiet) {
      _log('→ TX POST $method');
      final shown = CwsConfig.unmaskLogs ? envelope : cwsMaskRequest(envelope);
      _log('  body: ${cwsCompact(shown, max: 900)}');
    }

    final res = await _http
        .post(_uri, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(kCwsHttpTimeout);

    if (res.statusCode != 200) {
      _log('✗ HTTP ${res.statusCode}: ${cwsCompact(res.body, max: 500)}');
      throw http.ClientException('HTTP ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    final map = decoded is Map
        ? decoded.cast<String, dynamic>()
        : <String, dynamic>{};
    if (!quiet) _log('← RX ${cwsCompact(map, max: 900)}');
    return map;
  }
}