import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/modules/pos/order/models/summary_report_model.dart';
import 'package:yogo_pos/app/modules/pos/order/widgets/dialogs/print_receipt/esc_summary_report_receipt.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

// ──────────────────────────────────────────────
// Theme Colors (B&W only)
// ──────────────────────────────────────────────

class _C {
  final bool isDark;
  _C(this.isDark);

  Color get bg => isDark ? const Color.fromARGB(255, 22, 22, 22) : Colors.white;
  Color get card =>
      isDark ? const Color.fromARGB(255, 63, 63, 63) : const Color(0xFFF5F5F5);
  Color get surface =>
      isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEEEEEE);
  Color get text1 => isDark ? Colors.white : Colors.black;
  Color get text2 => isDark ? Colors.white : Colors.black;
  Color get divider => isDark
      ? const Color.fromARGB(255, 204, 204, 204)
      : const Color.fromARGB(255, 146, 146, 146);
  Color get border =>
      isDark ? const Color.fromARGB(255, 88, 88, 88) : const Color(0xFFCCCCCC);
  Color get btnBg => isDark ? Colors.white : Colors.black;
  Color get btnFg => isDark ? Colors.black : Colors.white;
}

// ──────────────────────────────────────────────
// Widget
// ──────────────────────────────────────────────

class SummaryReportWidget extends StatefulWidget {
  const SummaryReportWidget({super.key});

  @override
  State<SummaryReportWidget> createState() => _SummaryReportWidgetState();
}

class _SummaryReportWidgetState extends State<SummaryReportWidget>
    with SingleTickerProviderStateMixin {
  bool _selectorOpen = false;
  late final AnimationController _arrowCtrl;
  late final Animation<double> _arrowTurn;

  SummaryReport? _report;
  bool _isLoading = true;
  String? _error;
  final Map<String, bool> _checks = {};

  _C get _c => _C(Get.isDarkMode);

  List<_Sec> get _sections {
    final r = _report;
    if (r == null) return [];
    return [
      if (r.grossSales != null) _Sec('grossSales', r.grossSales!.title),
      if (r.refunds != null) _Sec('refunds', r.refunds!.title),
      if (r.discounts != null) _Sec('discounts', r.discounts!.title),
      if (r.salesSummary != null) _Sec('salesSummary', r.salesSummary!.title),
      if (r.taxSummary != null) _Sec('taxSummary', r.taxSummary!.title),
      if (r.tipsAndGratuitySummary != null)
        _Sec('tips', r.tipsAndGratuitySummary!.title),
      if (r.transactionsSummary != null)
        _Sec('transactions', r.transactionsSummary!.title),
      if (r.discountTransactions != null)
        _Sec('discountTransactions', r.discountTransactions!.title),
      if (r.categorySummary != null) _Sec('category', r.categorySummary!.title),
      if (r.checksSummary != null) _Sec('checks', r.checksSummary!.title),
      if (r.detailedReportByCardType != null)
        _Sec('cardType', r.detailedReportByCardType!.title),
    ];
  }

  @override
  void initState() {
    super.initState();
    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _arrowTurn = Tween(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeOutCubic),
    );
    _fetchReport();
  }

  @override
  void dispose() {
    _arrowCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      Map<String, dynamic> param = {
        "startDate": DateFormat('yyyy-MM-dd')
            .format(BaseController.to.dateRange.start),
        "endDate": DateFormat('yyyy-MM-dd')
            .format(BaseController.to.dateRange.end ),
      };
      final res = await BaseController.to.apiService
          .makeGetRequest(URLS.summaryReport, queryParameters: param);
      if (res.statusCode == 200) {
        final report = SummaryReport.fromJson(res.data['data']);
        _checks.clear();
        setState(() {
          _report = report;
          _isLoading = false;
        });
        for (final s in _sections) {
          _checks[s.key] = false;
        }
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Server error: ${res.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load report:\n$e';
      });
    }
  }

  void _toggleSelector() {
    setState(() => _selectorOpen = !_selectorOpen);
    _selectorOpen ? _arrowCtrl.forward() : _arrowCtrl.reverse();
  }

  void _toggle(String key) {
    setState(() => _checks[key] = !(_checks[key] ?? false));
  }

  // ────────────── Print ──────────────

  Future<void> _handlePrint() async {
    if (_report == null) return;

    final hasSelected = _checks.values.any((v) => v);
    if (!hasSelected) {
      PopupDialog.showErrorMessage("No Section Selected");
      return;
    }

    final receiptBytes = escSummaryReportReceipt(
      report: _report!,
      selectedSections: _checks,
    );

    bool isPrint = await PrintUtils().directPrint(
      data: receiptBytes,
      printer: Preferences.counterPrinter,
    );
    if (isPrint) {
      Get.back();
    }
  }

  // ────────────── Build ──────────────

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return SizedBox(
      child: _isLoading
          ? _loading(c)
          : _error != null
              ? _errorView(c)
              : _reportView(c),
    );
  }

  // ── Loading
  Widget _loading(_C c) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: c.text1),
          ),
          const SizedBox(height: 14),
          Text('Loading Report...',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: c.text1)),
        ],
      );

  // ── Error
  Widget _errorView(_C c) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: c.text2, size: 30),
            const SizedBox(height: 14),
            Text('Failed to Load',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: c.text1)),
            const SizedBox(height: 6),
            Text(_error ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: c.text2)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _fetchReport,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: c.btnBg, borderRadius: BorderRadius.circular(8)),
                child: Text('Retry',
                    style: TextStyle(
                        color: c.btnFg,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
            ),
          ],
        ),
      );

  // ── Report
  Widget _reportView(_C c) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(c),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(children: _allSections(c)),
            ),
          ),
          _printBar(c),
        ],
      );

  // ── Header
  Widget _header(_C c) {
    final meta = _report?.meta;
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(meta?.restaurantName ?? 'Summary Report',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.text1,
              )),
          if (meta?.filter != null) ...[
            const SizedBox(height: 3),
            Text('${meta!.filter.from}  to  ${meta.filter.to}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: c.text2)),
          ],
          if (meta?.generatedBy != null) ...[
            const SizedBox(height: 3),
            Text(
                '${meta!.generatedBy.reportId} | ${meta.generatedBy.employeeName} | ${meta.generatedBy.generatedAt}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: c.text2)),
          ],
        ],
      ),
    );
  }

  // ── All Sections
  List<Widget> _allSections(_C c) {
    final r = _report;
    if (r == null) return [];
    return [
      if (r.grossSales != null) _section(r.grossSales!, c),
      if (r.refunds != null) _section(r.refunds!, c),
      if (r.discounts != null) _section(r.discounts!, c),
      if (r.salesSummary != null) _section(r.salesSummary!, c),
      if (r.taxSummary != null) _section(r.taxSummary!, c),
      if (r.tipsAndGratuitySummary != null)
        _section(r.tipsAndGratuitySummary!, c),
      if (r.transactionsSummary != null) _section(r.transactionsSummary!, c),
      if (r.discountTransactions != null) _section(r.discountTransactions!, c),
      if (r.categorySummary != null) _section(r.categorySummary!, c),
      if (r.checksSummary != null) _section(r.checksSummary!, c),
      if (r.detailedReportByCardType != null)
        _cardReport(r.detailedReportByCardType!, c),
    ];
  }

  Widget _section(ReportSection s, _C c) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.divider, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.title,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: c.text1)),
          Divider(color: c.divider, height: 16, thickness: 0.5),
          ...s.items.map((i) => _row(i.label, '${i.value}', c)),
          if (s.total != null) ...[
            Divider(color: c.divider, height: 12, thickness: 0.5),
            _row('Total', '${s.total}', c, bold: true),
          ],
        ]),
      );

  Widget _cardReport(DetailedCardTypeReport r, _C c) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.divider, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.title,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: c.text1)),
          Divider(color: c.divider, height: 16, thickness: 0.5),
          ...r.cardTypes.map((card) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: c.surface, borderRadius: BorderRadius.circular(6)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.title,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: c.text1)),
                      const SizedBox(height: 4),
                      ...card.items.map((i) => _row(i.label, '${i.value}', c)),
                    ]),
              )),
        ]),
      );

  Widget _row(String label, String value, _C c, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: bold ? c.text1 : c.text2,
                      fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    color: c.text1,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
          ],
        ),
      );

  // ── Print Bar
  Widget _printBar(_C c) {
    final secs = _sections;
    final count = _checks.values.where((v) => v).length;

    return Container(
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        border: Border(top: BorderSide(color: c.divider, width: 0.5)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _selectorOpen ? _selector(secs, c) : const SizedBox.shrink(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: Row(children: [
            GestureDetector(
              onTap: _toggleSelector,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectorOpen ? c.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: c.border, width: 0.5),
                ),
                child: RotationTransition(
                  turns: _arrowTurn,
                  child: Icon(Icons.keyboard_arrow_up_rounded,
                      color: c.text1, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _handlePrint,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                      color: StaticColors.blueColor,
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.print_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(count > 0 ? 'Print ($count)' : 'Print',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                      ]),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _selector(List<_Sec> secs, _C c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('SELECT SECTIONS',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.text2,
                  letterSpacing: 1)),
          GestureDetector(
            onTap: () {
              final all = _checks.values.every((v) => v);
              setState(() {
                for (final k in _checks.keys) {
                  _checks[k] = !all;
                }
              });
            },
            child: Text(
              _checks.values.every((v) => v) ? 'Deselect All' : 'Select All',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: c.text1),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        ...List.generate((secs.length / 2).ceil(), (row) {
          final left = row * 2;
          final right = left + 1;
          return Row(
            children: [
              Expanded(child: _sectionTile(secs[left], left, c)),
              const SizedBox(width: 6),
              if (right < secs.length)
                Expanded(child: _sectionTile(secs[right], right, c))
              else
                const Expanded(child: SizedBox.shrink()),
            ],
          );
        }),
        const SizedBox(height: 6),
        Divider(color: c.divider, height: 1, thickness: 0.5),
      ]),
    );
  }

  Widget _sectionTile(_Sec s, int i, _C c) {
    final on = _checks[s.key] ?? false;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 150 + (i * 40)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child:
            Transform.translate(offset: Offset(0, 8 * (1 - v)), child: child),
      ),
      child: GestureDetector(
        onTap: () => _toggle(s.key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: on ? c.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: on ? c.border : Colors.transparent, width: 0.5),
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: on ? c.text1 : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: on ? c.text1 : c.text2, width: 1.5),
              ),
              child: AnimatedScale(
                scale: on ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Icon(Icons.check_rounded, color: c.btnFg, size: 12),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(s.title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: on ? FontWeight.w700 : FontWeight.w600,
                      color: on ? c.text1 : c.text2)),
            ),
          ]),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────

class _Sec {
  final String key;
  final String title;
  const _Sec(this.key, this.title);
}
