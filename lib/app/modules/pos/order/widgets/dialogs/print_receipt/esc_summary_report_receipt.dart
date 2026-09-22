import 'dart:typed_data';
import 'package:yogo_pos/app/modules/pos/order/models/summary_report_model.dart';
import 'package:yogo_pos/app/utils/receipt.dart';

Uint8List escSummaryReportReceipt({
  required SummaryReport report,
  required Map<String, bool> selectedSections,
}) {
  final Receipt receipt = Receipt();

  // ── Header
  final meta = report.meta;
  if (meta != null) {
    receipt
        .header(meta.restaurantName, fontSize: 2)
        .space()
        .text(
          '${meta.filter.from}  to  ${meta.filter.to}',
          align: Align.center,
        )
        .text(
          '${meta.generatedBy.reportId} | ${meta.generatedBy.employeeName} | ${meta.generatedBy.generatedAt}',
          align: Align.center,
        )
        .separator();
  }

  // ── Gross Sales
  if (_isSelected(selectedSections, 'grossSales') &&
      report.grossSales != null) {
    _printSection(receipt, report.grossSales!);
  }

  // ── Refunds
  if (_isSelected(selectedSections, 'refunds') && report.refunds != null) {
    _printSection(receipt, report.refunds!);
  }

  // ── Discounts
  if (_isSelected(selectedSections, 'discounts') && report.discounts != null) {
    _printSection(receipt, report.discounts!);
  }

  // ── Discount Transactions
  if (_isSelected(selectedSections, 'discountTransactions') &&
      report.discountTransactions != null) {
    _printSection(receipt, report.discountTransactions!);
  }

  // ── Sales Summary
  if (_isSelected(selectedSections, 'salesSummary') &&
      report.salesSummary != null) {
    _printSection(receipt, report.salesSummary!);
  }

  // ── Tax Summary
  if (_isSelected(selectedSections, 'taxSummary') &&
      report.taxSummary != null) {
    _printSection(receipt, report.taxSummary!);
  }

  // ── Tips & Gratuity
  if (_isSelected(selectedSections, 'tips') &&
      report.tipsAndGratuitySummary != null) {
    _printSection(receipt, report.tipsAndGratuitySummary!);
  }

  // ── Transactions Summary
  if (_isSelected(selectedSections, 'transactions') &&
      report.transactionsSummary != null) {
    _printSection(receipt, report.transactionsSummary!);
  }

  // ── Category Summary
  if (_isSelected(selectedSections, 'category') &&
      report.categorySummary != null) {
    _printSection(receipt, report.categorySummary!);
  }

  // ── Checks Summary
  if (_isSelected(selectedSections, 'checks') && report.checksSummary != null) {
    _printSection(receipt, report.checksSummary!);
  }

  // ── Detailed Card Type Report
  if (_isSelected(selectedSections, 'cardType') &&
      report.detailedReportByCardType != null) {
    _printCardTypeReport(receipt, report.detailedReportByCardType!);
  }

  // ── Footer
  receipt.text('*** End of Report ***', align: Align.center).space().cut();

  return receipt.bytes;
}

// ──────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────

bool _isSelected(Map<String, bool> selections, String key) {
  return selections[key] == true;
}

void _printSection(Receipt receipt, ReportSection section) {
  receipt.bold(section.title, align: Align.center);
  receipt.dashed();

  for (final item in section.items) {
    receipt.row(left: item.label, right: '${item.value}');
  }

  if (section.total != null) {
    receipt.dashed();
    receipt.row(
      left: 'Total',
      right: '${section.total}',
      fontWeight: FontWeight.bold,
    );
  }

  receipt.divider();
}

void _printCardTypeReport(Receipt receipt, DetailedCardTypeReport report) {
  receipt.bold(report.title, align: Align.center);
  receipt.divider();

  for (final card in report.cardTypes) {
    receipt.bold(card.title, align: Align.left);
    receipt.dashed();

    for (final item in card.items) {
      receipt.row(left: '  ${item.label}', right: '${item.value}');
    }

    receipt.space();
  }

  receipt.divider();
}