/// Ingenico Tetra TSI — Protocol Constants
///
/// Raw TCP mode: only FS and HB are used.
/// No STX/ETX/LRC/ACK/NAK framing over Ethernet.
library;

// Protocol bytes
const int kFs = 0x1C; // Field Separator
const int kHb = 0x11; // Heartbeat (DC1)

// Transaction type codes (ECR → Terminal)
abstract final class ElavonTranType {
  static const String purchase = '00';
  static const String preAuth = '01';
  static const String preAuthCompletion = '02';
  static const String refund = '03';
  static const String force = '04';
  static const String voidTran = '05';
  static const String balanceInquiry = '06';
  static const String settlement = '20';
}

// ECR Tag identifiers
abstract final class ElavonTag {
  // Request (001–099)
  static const String amount = '001';
  static const String tenderType = '002';
  static const String clerkId = '003';
  static const String invoice = '004';
  static const String authCode = '005';
  static const String customerRef = '010';
  static const String reference = '011';
  static const String panLast4 = '012';
  static const String tranTypeClass = '013'; // '01'=other, '02'=preAuth

  // Response (100–999)
  static const String transType = '100';
  static const String transDate = '102';
  static const String transTime = '103';
  static const String transAmount = '104';
  static const String tipAmount = '105';
  static const String cashbackAmount = '106';
  static const String surchargeAmount = '107';
  static const String totalAmount = '109';
  static const String invoiceNum = '110';
  static const String referenceNum = '112';
  static const String cardType = '300';
  static const String cardDesc = '301';
  static const String accountNum = '302';
  static const String entryMode = '306';
  static const String cvmResult = '312';
  static const String authorizationNum = '400';
  static const String hostResponseCode = '401';
  static const String hostResponseText = '402';
  static const String traceNum = '406';
  static const String cardBalance = '409';
  static const String hostTransRefNum = '412';
  static const String batchNum = '500';
  static const String demoIndicator = '600';
  static const String terminalId = '601';
  static const String merchantId = '602';
}
