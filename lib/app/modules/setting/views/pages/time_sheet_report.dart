
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:yogo_pos/app/modules/clockIn/model/clock_record_model.dart';
import 'package:yogo_pos/app/modules/setting/providers/time_sheet_provider.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_pagination.dart';
import 'package:yogo_pos/app/widgets/date_time_picker_dialog.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class TimeSheetReport extends ConsumerWidget {
  const TimeSheetReport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(timeSheetProvider);
    final notifier = ref.read(timeSheetProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ---- Top bar: range picker (left) + refresh (right) ----
          Row(
            children: [
              // Date-time range picker
              SizedBox(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    final range = await showDateTimeRangePickerDialog(
                      context,
                      initialStart: notifier.range.start, // provider's range
                      initialEnd: notifier.range.end,
                      minDate: DateTime(2025),
                      maxDate: DateTime.now(),
                    );
                    if (range != null) {
                      await notifier.applyRange(range);
                    }
                  },
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: StaticColors.blueColor,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _rangeLabel(notifier.range),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Refresh button
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  BaseController.to.playTapSound();
                  await notifier.refresh();
                },
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: StaticColors.blueColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ---- Body: loading / error / data ----
          Expanded(
            child: asyncState.when(
              loading: () => const Center(
                child: SpinKitRing(color: StaticColors.orangeColor, size: 53),
              ),
              error: (e, _) => _TimeSheetError(
                message: e.toString(),
                onRetry: () => notifier.refresh(),
              ),
              data: (state) {
                final meta = state.meta;
                // Serial numbers continue across pages: page 2 starts at 11, etc.
                final startIndex =
                    ((meta?.currentPage ?? 1) - 1) * (meta?.limit ?? 10);

                return Column(
                  children: [
                    Expanded(
                      child: state.records.isEmpty
                          ? const _TimeSheetEmptyState()
                          : _TimeSheetGrid(
                              records: state.records,
                              startIndex: startIndex,
                            ),
                    ),
                    if (meta != null && meta.totalPages > 1) ...[
                      const SizedBox(height: 12),
                      CustomPagination(
                        numOfPages: meta.totalPages,
                        selectedPage: meta.currentPage,
                        pagesVisible: 5,
                        onPageChanged: (page) async {
                          BaseController.to.playTapSound();
                          PopupDialog.showLoadingDialog();
                          await notifier.loadPage(page as int);
                          PopupDialog.closeLoadingDialog();
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Label for the picker button.
  String _rangeLabel(DateTimeRange r) {
    final d = DateFormat('MMM d, yyyy');
    final t = DateFormat('h:mm a');
    return "${d.format(r.start)} ${t.format(r.start)}  →  "
        "${d.format(r.end)} ${t.format(r.end)}";
  }
}

class _TimeSheetGrid extends StatelessWidget {
  const _TimeSheetGrid({required this.records, required this.startIndex});

  final List<ClockRecordModel> records;
  final int startIndex;

  @override
  Widget build(BuildContext context) {
    // Reactive: rebuilds automatically when the app theme changes.
    final isLight = Theme.of(context).brightness == Brightness.light;

    final source = TimeSheetDataSource(
      records: records,
      startIndex: startIndex,
      isLight: isLight,
    );

    return SfDataGridTheme(
      data: SfDataGridThemeData(
        headerColor: isLight
            ? Colors.black.withAlpha(14)
            : Colors.white.withAlpha(14),
        selectionColor: StaticColors.blueColor.withAlpha(66),
        currentCellStyle: DataGridCurrentCellStyle(
          borderColor: Colors.transparent,
          borderWidth: 0,
        ),
        gridLineColor: isLight
            ? Colors.black.withAlpha(18)
            : Colors.white.withAlpha(100),
        gridLineStrokeWidth: 0.6,
        rowHoverColor: StaticColors.blueColor.withAlpha(15),
        sortIconColor: StaticColors.blueColor,
      ),
      child: SfDataGrid(
        source: source,
        highlightRowOnHover: true,
        rowHeight: 54,
        headerRowHeight: 46,
        gridLinesVisibility: GridLinesVisibility.horizontal,
        headerGridLinesVisibility: GridLinesVisibility.horizontal,
        columnWidthMode: ColumnWidthMode.fill,
        columns: [
          GridColumn(
            columnName: 'no',
            width: 80,
            label: _headerCell('No.', isLight),
          ),
          GridColumn(
            columnName: 'startDate',
            label: _headerCell('Start Date', isLight),
          ),
          GridColumn(
            columnName: 'endDate',
            label: _headerCell('End Date', isLight),
          ),
          GridColumn(
            columnName: 'totalTimes',
            label: _headerCell('Total Times', isLight),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, bool isLight) => Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Text(
      label,
      style: TextStyle(
        color: (isLight ? Colors.black : Colors.white).withAlpha(200),
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
  );
}

class _TimeSheetEmptyState extends StatelessWidget {
  const _TimeSheetEmptyState();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final subColor = isLight
        ? Colors.black.withAlpha(120)
        : Colors.white.withAlpha(120);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_outlined, size: 52, color: subColor),
          const SizedBox(height: 12),
          Text(
            'No time sheet records found',
            style: TextStyle(color: subColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _TimeSheetError extends StatelessWidget {
  const _TimeSheetError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final subColor = isLight
        ? Colors.black.withAlpha(120)
        : Colors.white.withAlpha(120);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 52, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(
            'Could not load time sheet',
            style: TextStyle(color: subColor, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: StaticColors.blueColor,
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Feeds ClockRecordModel data into the SfDataGrid.
class TimeSheetDataSource extends DataGridSource {
  TimeSheetDataSource({
    required List<ClockRecordModel> records,
    required this.isLight,
    this.startIndex = 0,
  }) : _records = records {
    _rows = records.asMap().entries.map<DataGridRow>((entry) {
      final i = entry.key;
      final r = entry.value;
      final isActive = r.endDate == null; // still clocked in

      return DataGridRow(
        cells: [
          DataGridCell<String>(
            columnName: 'no',
            value: '${startIndex + i + 1}',
          ),
          DataGridCell<String>(
            columnName: 'startDate',
            value: isActive
                ? 'Clocked in at ${_formatDate(r.startDate)}'
                : _formatDate(r.startDate),
          ),
          DataGridCell<String>(
            columnName: 'endDate',
            value: r.endDate == null ? '-' : _formatDate(r.endDate!),
          ),
          DataGridCell<String>(
            columnName: 'totalTimes',
            value: _formatDuration(r.totalTime),
          ),
        ],
      );
    }).toList();
  }

  final bool isLight;
  final int startIndex;
  final List<ClockRecordModel> _records;
  List<DataGridRow> _rows = [];

  /// "Jul 12, 2026 12:26 PM"
  static String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy h:mm a').format(date.toLocal());
  }

  /// Seconds -> "2hr 15m", "45m", or "30s" for very short spans.
  static String _formatDuration(int? seconds) {
    if (seconds == null) return '-';
    if (seconds < 60) return '${seconds}s';

    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;

    if (h == 0) return '${m}m';
    return '${h}hr ${m}m';
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final textColor = isLight ? Colors.black : Colors.white;

    // An "active" row is one where the employee has not clocked out yet.
    final index = _rows.indexOf(row);
    final isActive = index >= 0 && _records[index].endDate == null;

    return DataGridRowAdapter(
      color: isActive ? Colors.green.withAlpha(14) : Colors.transparent,
      cells: row.getCells().map<Widget>((cell) {
        final isNo = cell.columnName == 'no';
        // Only the "Clocked in at ..." text gets the bordered chip.
        final isClockedInCell = isActive && cell.columnName == 'startDate';

        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: isClockedInCell
              ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(28),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withAlpha(80)),
                  ),
                  child: Text(
                    cell.value.toString(),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Text(
                  cell.value.toString(),
                  style: TextStyle(
                    color: isActive
                        ? Colors.green
                        : textColor.withAlpha(isNo ? 160 : 200),
                    fontSize: 14,
                    fontWeight: isNo ? FontWeight.w700 : FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
        );
      }).toList(),
    );
  }
}
