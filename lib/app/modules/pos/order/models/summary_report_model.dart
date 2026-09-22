// ──────────────────────────────────────────────
// Summary Report Models
// ──────────────────────────────────────────────

/// Generic label/value item used across most sections
class ReportItem {
  final String label;
  final dynamic value; // String for dollar amounts, int for counts

  const ReportItem({required this.label, required this.value});

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      label: json['label'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'value': value};
}

/// A section with a title, list of items, and optional total
class ReportSection {
  final String title;
  final List<ReportItem> items;
  final dynamic total; // nullable — only some sections have totals

  const ReportSection({
    required this.title,
    required this.items,
    this.total,
  });

  factory ReportSection.fromJson(Map<String, dynamic> json) {
    return ReportSection(
      title: json['title'] as String,
      items: (json['items'] as List)
          .map((e) => ReportItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'items': items.map((e) => e.toJson()).toList(),
        if (total != null) 'total': total,
      };
}

// ──────────────────────────────────────────────
// Meta
// ──────────────────────────────────────────────

class DateRange {
  final String from;
  final String to;

  const DateRange({
    required this.from,
    required this.to,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      from: json['from'] as String,
      to: json['to'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'from': from, 'to': to};
}

class GeneratedBy {
  final String reportId;
  final String employeeName;
  final String generatedAt;

  const GeneratedBy({
    required this.reportId,
    required this.employeeName,
    required this.generatedAt,
  });

  factory GeneratedBy.fromJson(Map<String, dynamic> json) {
    return GeneratedBy(
      reportId: json['reportId'] as String,
      employeeName: json['employeeName'] as String,
      generatedAt: json['generatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'reportId': reportId,
        'employeeName': employeeName,
        'generatedAt': generatedAt,
      };
}

class ReportMeta {
  final String restaurantName;
  final String restaurantOpen;
  final String restaurantClose;
  final DateRange filter;
  final GeneratedBy generatedBy;

  const ReportMeta({
    required this.restaurantName,
    required this.restaurantOpen,
    required this.restaurantClose,
    required this.filter,
    required this.generatedBy,
  });

  factory ReportMeta.fromJson(Map<String, dynamic> json) {
    return ReportMeta(
      restaurantName: json['restaurantName'] as String,
      restaurantOpen: json['restaurantOpen'] as String,
      restaurantClose: json['restaurantClose'] as String,
      filter: DateRange.fromJson(json['filter'] as Map<String, dynamic>),
      generatedBy:
          GeneratedBy.fromJson(json['generatedBy'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'restaurantName': restaurantName,
        'restaurantOpen': restaurantOpen,
        'restaurantClose': restaurantClose,
        'filter': filter.toJson(),
        'generatedBy': generatedBy.toJson(),
      };
}

// ──────────────────────────────────────────────
// Detailed Report by Card Type
// ──────────────────────────────────────────────

class CardTypeReport {
  final String title;
  final List<ReportItem> items;

  const CardTypeReport({required this.title, required this.items});

  factory CardTypeReport.fromJson(Map<String, dynamic> json) {
    return CardTypeReport(
      title: json['title'] as String,
      items: (json['items'] as List)
          .map((e) => ReportItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class DetailedCardTypeReport {
  final String title;
  final List<CardTypeReport> cardTypes;

  const DetailedCardTypeReport({
    required this.title,
    required this.cardTypes,
  });

  factory DetailedCardTypeReport.fromJson(Map<String, dynamic> json) {
    return DetailedCardTypeReport(
      title: json['title'] as String,
      cardTypes: (json['cardTypes'] as List)
          .map((e) => CardTypeReport.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'cardTypes': cardTypes.map((e) => e.toJson()).toList(),
      };
}

// ──────────────────────────────────────────────
// Root Model
// ──────────────────────────────────────────────

class SummaryReport {
  final ReportMeta? meta;
  final ReportSection? grossSales;
  final ReportSection? refunds;
  final ReportSection? discounts;

  final ReportSection? salesSummary;
  final ReportSection? taxSummary;
  final ReportSection? tipsAndGratuitySummary;
  final ReportSection? transactionsSummary;
  final ReportSection? discountTransactions;
  final ReportSection? categorySummary;
  final ReportSection? checksSummary;
  final DetailedCardTypeReport? detailedReportByCardType;

  const SummaryReport({
    this.meta,
    this.grossSales,
    this.refunds,
    this.discounts,
    this.discountTransactions,
    this.salesSummary,
    this.taxSummary,
    this.tipsAndGratuitySummary,
    this.transactionsSummary,
    this.categorySummary,
    this.checksSummary,
    this.detailedReportByCardType,
  });

  factory SummaryReport.fromJson(Map<String, dynamic> json) {
    return SummaryReport(
      meta: json['meta'] != null
          ? ReportMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      grossSales: json['grossSales'] != null
          ? ReportSection.fromJson(json['grossSales'] as Map<String, dynamic>)
          : null,
      refunds: json['refunds'] != null
          ? ReportSection.fromJson(json['refunds'] as Map<String, dynamic>)
          : null,
      discounts: json['discounts'] != null
          ? ReportSection.fromJson(json['discounts'] as Map<String, dynamic>)
          : null,
      salesSummary: json['salesSummary'] != null
          ? ReportSection.fromJson(json['salesSummary'] as Map<String, dynamic>)
          : null,
      taxSummary: json['taxSummary'] != null
          ? ReportSection.fromJson(json['taxSummary'] as Map<String, dynamic>)
          : null,
      tipsAndGratuitySummary: json['tipsAndGratuitySummary'] != null
          ? ReportSection.fromJson(
              json['tipsAndGratuitySummary'] as Map<String, dynamic>)
          : null,
      transactionsSummary: json['transactionsSummary'] != null
          ? ReportSection.fromJson(
              json['transactionsSummary'] as Map<String, dynamic>)
          : null,
      discountTransactions: json['discountTransactions'] != null
          ? ReportSection.fromJson(
              json['discountTransactions'] as Map<String, dynamic>)
          : null,
      categorySummary: json['categorySummary'] != null
          ? ReportSection.fromJson(
              json['categorySummary'] as Map<String, dynamic>)
          : null,
      checksSummary: json['checksSummary'] != null
          ? ReportSection.fromJson(
              json['checksSummary'] as Map<String, dynamic>)
          : null,
      detailedReportByCardType: json['detailedReportByCardType'] != null
          ? DetailedCardTypeReport.fromJson(
              json['detailedReportByCardType'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (meta != null) 'meta': meta!.toJson(),
        if (grossSales != null) 'grossSales': grossSales!.toJson(),
        if (refunds != null) 'refunds': refunds!.toJson(),
        if (discounts != null) 'discounts': discounts!.toJson(),
        if (discountTransactions != null)
          'discountTransactions': discountTransactions!.toJson(),
        if (salesSummary != null) 'salesSummary': salesSummary!.toJson(),
        if (taxSummary != null) 'taxSummary': taxSummary!.toJson(),
        if (tipsAndGratuitySummary != null)
          'tipsAndGratuitySummary': tipsAndGratuitySummary!.toJson(),
        if (transactionsSummary != null)
          'transactionsSummary': transactionsSummary!.toJson(),
        if (categorySummary != null)
          'categorySummary': categorySummary!.toJson(),
        if (checksSummary != null) 'checksSummary': checksSummary!.toJson(),
        if (detailedReportByCardType != null)
          'detailedReportByCardType': detailedReportByCardType!.toJson(),
      };

  /// Convenience getter — all non-null generic sections for rendering with a single loop
  List<ReportSection> get allSections => [
        grossSales,
        refunds,
        discounts,
        discountTransactions,
        salesSummary,
        taxSummary,
        tipsAndGratuitySummary,
        transactionsSummary,
        categorySummary,
        checksSummary,
      ].whereType<ReportSection>().toList();
}
