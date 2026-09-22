/// Ingenico Tetra TSI — Payment Result Model
///
/// Parsed terminal response, ready for backend saving.
library;

import '../services/elavon_constants.dart';
import '../services/elavon_utils.dart';

class ElavonPaymentResult {
  final bool isApproved;
  final String statusCode;
  final String statusText;

  // Transaction
  final String? transactionType;
  final String? transactionDate;
  final String? transactionTime;
  final String? amount;
  final String? tipAmount;
  final String? cashbackAmount;
  final String? surchargeAmount;
  final String? totalAmount;
  final String? invoiceNumber;
  final String? referenceNumber;

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
  final String? hostTransRefNumber;
  final String? cardBalance;

  // Terminal
  final String? terminalId;
  final String? merchantId;
  final String? batchNumber;
  final bool isDemoMode;

  // Raw
  final Map<String, String> rawFields;

  const ElavonPaymentResult({
    required this.isApproved,
    required this.statusCode,
    required this.statusText,
    this.transactionType,
    this.transactionDate,
    this.transactionTime,
    this.amount,
    this.tipAmount,
    this.cashbackAmount,
    this.surchargeAmount,
    this.totalAmount,
    this.invoiceNumber,
    this.referenceNumber,
    this.cardType,
    this.cardName,
    this.maskedPan,
    this.entryMode,
    this.cvmResult,
    this.authCode,
    this.hostResponseCode,
    this.hostResponseText,
    this.traceNumber,
    this.hostTransRefNumber,
    this.cardBalance,
    this.terminalId,
    this.merchantId,
    this.batchNumber,
    this.isDemoMode = false,
    this.rawFields = const {},
  });

  factory ElavonPaymentResult.fromFields({
    required String statusCode,
    required Map<String, String> fields,
  }) {
    return ElavonPaymentResult(
      isApproved: statusCode == '00' || statusCode == '01',
      statusCode: statusCode,
      statusText: elavonStatusLabel(statusCode),
      transactionType: fields[ElavonTag.transType],
      transactionDate: fields[ElavonTag.transDate],
      transactionTime: fields[ElavonTag.transTime],
      amount: fields[ElavonTag.transAmount],
      tipAmount: fields[ElavonTag.tipAmount],
      cashbackAmount: fields[ElavonTag.cashbackAmount],
      surchargeAmount: fields[ElavonTag.surchargeAmount],
      totalAmount: fields[ElavonTag.totalAmount],
      invoiceNumber: fields[ElavonTag.invoiceNum],
      referenceNumber: fields[ElavonTag.referenceNum],
      cardType: fields[ElavonTag.cardType],
      cardName:
          fields[ElavonTag.cardDesc] ??
          elavonCardTypeName(fields[ElavonTag.cardType]),
      maskedPan: fields[ElavonTag.accountNum],
      entryMode: elavonEntryModeLabel(fields[ElavonTag.entryMode]),
      cvmResult: fields[ElavonTag.cvmResult],
      authCode: fields[ElavonTag.authorizationNum],
      hostResponseCode: fields[ElavonTag.hostResponseCode],
      hostResponseText: fields[ElavonTag.hostResponseText],
      traceNumber: fields[ElavonTag.traceNum],
      hostTransRefNumber: fields[ElavonTag.hostTransRefNum],
      cardBalance: fields[ElavonTag.cardBalance],
      terminalId: fields[ElavonTag.terminalId],
      merchantId: fields[ElavonTag.merchantId],
      batchNumber: fields[ElavonTag.batchNum],
      isDemoMode: fields[ElavonTag.demoIndicator] == '1',
      rawFields: Map.unmodifiable(fields),
    );
  }

  double get amountDollars => // NEW — tag 104 (base amount)
      (int.tryParse(amount ?? '0') ?? 0) / 100;

  double get totalAmountDollars => // FIXED — tag 109 only, no fallback
      (int.tryParse(totalAmount ?? '0') ?? 0) / 100;

  double get tipAmountDollars => // same
      (int.tryParse(tipAmount ?? '0') ?? 0) / 100;

  double get cashbackAmountDollars => // NEW — tag 106
      (int.tryParse(cashbackAmount ?? '0') ?? 0) / 100;

  double get surchargeAmountDollars => // NEW — tag 107
      (int.tryParse(surchargeAmount ?? '0') ?? 0) / 100;

  String get transactionId => referenceNumber ?? authCode ?? traceNumber ?? '';

  Map<String, dynamic> toJson() => {
    'status': statusCode,
    'statusText': statusText,
    'approved': isApproved,
    'transactionType': transactionType,
    'transactionDate': transactionDate,
    'transactionTime': transactionTime,
    'amount': amount,
    'tipAmount': tipAmount,
    'totalAmount': totalAmount,
    'invoiceNumber': invoiceNumber,
    'referenceNumber': referenceNumber,
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
  };

  @override
  String toString() =>
      'ElavonPaymentResult($statusText, card=$cardName, '
      'pan=$maskedPan, auth=$authCode, total=$totalAmount)';
}
