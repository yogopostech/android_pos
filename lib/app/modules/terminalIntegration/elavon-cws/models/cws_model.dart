/// Elavon Commerce Web Services (CWS) — Payment Result Model
///
/// Parsed final transaction from `paymentTransactionData`, shaped to match the
/// TSI ElavonPaymentResult so the same order-update code and dialogs work.
library;

import '../services/cws_utils.dart';

class CwsPaymentResult {
  final bool isApproved;
  final String statusCode; // raw result string from CWS
  final String statusText;

  // Transaction
  final String? transactionType;
  final String? tenderType;
  final String? transactionDate;
  final String? transactionTime;
  final int? amountCents; // base/approved amount
  final int? tipAmountCents; // gratuityAmount
  final int? totalAmountCents;
  final int? cashbackAmountCents;
  final int? surchargeAmountCents;
  final int? balanceDueCents; // remaining balance (partial approval)
  final String? invoiceNumber;
  final String? referenceNumber;
  final String? transId;

  // Card
  final String? cardType;
  final String? cardName;
  final String? maskedPan;
  final String? entryMode;
  final String? cvmResult;

  // Host
  final String? authCode;
  final String? hostResponseCode;
  final String? hostResponseText;
  final String? traceNumber;
  final String? cardBalance;

  // Terminal
  final String? terminalId;
  final String? merchantId;
  final String? batchNumber;
  final bool isDemoMode;

  // Signature capture (SIG_BIN_2 base bitmap from the terminal)
  final String? signatureData;
  final String? signatureFormat;

  // Errors returned on a failed/declined transaction
  final List<String> errors;

  // Raw
  final Map<String, dynamic> raw;

  const CwsPaymentResult({
    required this.isApproved,
    required this.statusCode,
    required this.statusText,
    this.transactionType,
    this.tenderType,
    this.transactionDate,
    this.transactionTime,
    this.amountCents,
    this.tipAmountCents,
    this.totalAmountCents,
    this.cashbackAmountCents,
    this.surchargeAmountCents,
    this.balanceDueCents,
    this.invoiceNumber,
    this.referenceNumber,
    this.transId,
    this.cardType,
    this.cardName,
    this.maskedPan,
    this.entryMode,
    this.cvmResult,
    this.authCode,
    this.hostResponseCode,
    this.hostResponseText,
    this.traceNumber,
    this.cardBalance,
    this.terminalId,
    this.merchantId,
    this.batchNumber,
    this.isDemoMode = false,
    this.signatureData,
    this.signatureFormat,
    this.errors = const [],
    this.raw = const {},
  });

  /// Build from the paymentGatewayCommand object of a completed transaction.
  factory CwsPaymentResult.fromCommand(Map<String, dynamic> cmd) {
    final txn =
        (cwsReadPath(cmd, ['paymentTransactionData']) as Map?)
            ?.cast<String, dynamic>() ??
        (cwsReadPath(cmd, ['transaction']) as Map?)?.cast<String, dynamic>() ??
        cmd;

    dynamic pick(List<String> keys) {
      for (final k in keys) {
        final v = txn[k];
        if (v != null) return v;
      }
      return null;
    }

    int? cents(dynamic v) {
      if (v == null) return null;
      if (v is Map && v['value'] != null) return (v['value'] as num).toInt();
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    // result="APPROVED"/"PARTIALLY_APPROVED"/"FAILED", approved="yes"/"no"
    final resultStr = (pick(['result', 'resultMessage', 'status']) ?? '').toString();
    final approvedStr = (pick(['approved']) ?? '').toString();
    final approved =
        cwsIsApproved(resultStr) || approvedStr.toLowerCase() == 'yes';

    // errors: []
    final rawErrors = pick(['errors']);
    final errorList = (rawErrors is List)
        ? rawErrors.map((e) => e.toString()).toList()
        : const <String>[];

    // signatureBitmap: { data, format }
    final sig =
        (cwsReadPath(txn, ['signatureBitmap']) as Map?)?.cast<String, dynamic>();

    return CwsPaymentResult(
      isApproved: approved,
      statusCode: resultStr.isNotEmpty ? resultStr : approvedStr,
      statusText: cwsStatusLabel(resultStr.isNotEmpty ? resultStr : approvedStr),
      transactionType: pick(['transactionType'])?.toString(),
      tenderType: pick(['tenderType'])?.toString(),
      transactionDate: pick(['date', 'transactionDate'])?.toString(),
      transactionTime: pick(['time', 'transactionTime'])?.toString(),
      amountCents: cents(pick(['amount', 'baseTransactionAmount', 'approvedAmount', 'amountAuthorized'])),
      tipAmountCents: cents(pick(['gratuityAmount', 'tipAmount', 'gratuity'])),
      totalAmountCents: cents(pick(['totalAmount', 'total'])),
      cashbackAmountCents: cents(pick(['cashbackAmount'])),
      surchargeAmountCents: cents(pick(['surchargeAmount'])),
      balanceDueCents: cents(pick(['balanceDue'])),
      invoiceNumber: pick(['invoiceNumber'])?.toString(),
      referenceNumber: pick(['merchantTransactionReference', 'referenceNumber'])?.toString(),
      transId: pick(['id', 'transId', 'transactionId'])?.toString(),
      cardType: pick(['cardScheme', 'cardType'])?.toString(),
      cardName: cwsCardName(pick(['cardScheme', 'cardType', 'paymentType'])?.toString()),
      maskedPan: pick(['maskedPan', 'maskedCardNumber', 'accountNumber'])?.toString(),
      entryMode: cwsEntryModeLabel(pick(['cardEntryType', 'entryMode', 'cardEntryMode'])?.toString()),
      cvmResult: pick(['cvmResult', 'cvm'])?.toString(),
      authCode: pick(['authCode', 'approvalCode', 'authorizationCode'])?.toString(),
      hostResponseCode: pick(['responseCode', 'hostResponseCode'])?.toString(),
      hostResponseText: pick(['resultMessage', 'responseMessage', 'hostResponseText', 'message'])?.toString(),
      traceNumber: pick(['traceNumber', 'stan'])?.toString(),
      cardBalance: cents(pick(['cardBalance', 'balance']))?.toString(),
      terminalId: pick(['terminalId'])?.toString(),
      merchantId: pick(['merchantId'])?.toString(),
      batchNumber: pick(['batchNumber', 'batchId'])?.toString(),
      isDemoMode: pick(['demo', 'isDemo']) == true,
      signatureData: sig?['data']?.toString(),
      signatureFormat: sig?['format']?.toString(),
      errors: errorList,
      raw: Map.unmodifiable(cmd),
    );
  }

  double get amountDollars => (amountCents ?? 0) / 100;
  double get totalAmountDollars => (totalAmountCents ?? 0) / 100;
  double get tipAmountDollars => (tipAmountCents ?? 0) / 100;
  double get cashbackAmountDollars => (cashbackAmountCents ?? 0) / 100;
  double get surchargeAmountDollars => (surchargeAmountCents ?? 0) / 100;
  double get balanceDueDollars => (balanceDueCents ?? 0) / 100;

  /// Approved for less than requested (partial approval) → balance remains.
  bool get isPartial => isApproved && (balanceDueCents ?? 0) > 0;

  bool get hasSignature => (signatureData ?? '').isNotEmpty;

  String get transactionId =>
      transId ?? referenceNumber ?? authCode ?? traceNumber ?? '';

  /// Decline/failure reason for display (first error, else host text).
  String? get errorMessage =>
      errors.isNotEmpty ? errors.first : (isApproved ? null : hostResponseText);

  Map<String, dynamic> toJson() => {
    'status': statusCode,
    'statusText': statusText,
    'approved': isApproved,
    'transactionType': transactionType,
    'tenderType': tenderType,
    'transactionDate': transactionDate,
    'transactionTime': transactionTime,
    'amount': amountCents,
    'tipAmount': tipAmountCents,
    'totalAmount': totalAmountCents,
    'balanceDue': balanceDueCents,
    'invoiceNumber': invoiceNumber,
    'referenceNumber': referenceNumber,
    'transId': transId,
    'cardType': cardType,
    'cardName': cardName,
    'maskedPan': maskedPan,
    'entryMode': entryMode,
    'authCode': authCode,
    'hostResponseCode': hostResponseCode,
    'hostResponseText': hostResponseText,
    'terminalId': terminalId,
    'merchantId': merchantId,
    'batchNumber': batchNumber,
    'isDemoMode': isDemoMode,
    'hasSignature': hasSignature,
    'signatureFormat': signatureFormat,
    'errors': errors,
  };

  @override
  String toString() =>
      'CwsPaymentResult($statusText, card=$cardName, pan=$maskedPan, '
      'auth=$authCode, tip=$tipAmountCents, total=$totalAmountCents, '
      'balanceDue=$balanceDueCents)';
}