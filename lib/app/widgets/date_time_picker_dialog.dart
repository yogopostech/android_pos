import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';


/// Shows a dialog with 4 tappable fields: Start Date, Start Time, End Date, End Time.
/// Returns [DateTimeRange] or null if cancelled.
Future<DateTimeRange?> showDateTimeRangePickerDialog(
  BuildContext context, {
  DateTime? initialStart,
  DateTime? initialEnd,
  DateTime? minDate,
  DateTime? maxDate,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _DateTimeRangeDialog(
      initialStart: initialStart ?? DateTime.now(),
      initialEnd: initialEnd ?? DateTime.now().add(const Duration(hours: 1)),
      minDate: minDate ?? DateTime(2000),
      maxDate: maxDate ?? DateTime(2100),
    ),
  );
}

class _DateTimeRangeDialog extends StatefulWidget {
  final DateTime initialStart;
  final DateTime initialEnd;
  final DateTime minDate;
  final DateTime maxDate;

  const _DateTimeRangeDialog({
    required this.initialStart,
    required this.initialEnd,
    required this.minDate,
    required this.maxDate,
  });

  @override
  State<_DateTimeRangeDialog> createState() => _DateTimeRangeDialogState();
}

class _DateTimeRangeDialogState extends State<_DateTimeRangeDialog> {
  static const _accent = StaticColors.blueColor;
  static const _accentLight = Color.fromARGB(255, 40, 133, 248);

  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;

  // Which field is active: null = none, 0 = start date, 1 = start time, 2 = end date, 3 = end time
  int? _activeField;

  final DateRangePickerController _pickerController =
      DateRangePickerController();

  // For time spinner
  late int _hour; // 1-12
  late int _minute; // 0-59
  late bool _isAm;

  @override
  void initState() {
    super.initState();
    _startDate = _dateOnly(widget.initialStart);
    _startTime = TimeOfDay.fromDateTime(widget.initialStart);
    _endDate = _dateOnly(widget.initialEnd);
    _endTime = TimeOfDay.fromDateTime(widget.initialEnd);
    _hour = 12;
    _minute = 0;
    _isAm = true;
  }

  @override
  void dispose() {
    _pickerController.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:$m $p';
  }

  // String _formatDateShort(DateTime d) {
  //   const months = [
  //     'Jan',
  //     'Feb',
  //     'Mar',
  //     'Apr',
  //     'May',
  //     'Jun',
  //     'Jul',
  //     'Aug',
  //     'Sep',
  //     'Oct',
  //     'Nov',
  //     'Dec',
  //   ];
  //   return '${months[d.month - 1]} ${d.day}';
  // }

  void _openDateField(int fieldIndex, DateTime current) {
    _applyPendingTime();
    setState(() {
      _activeField = fieldIndex;
      _pickerController.selectedDate = current;
    });
  }

  void _openTimeField(int fieldIndex, TimeOfDay current) {
    _applyPendingTime();
    final h12 = current.hourOfPeriod == 0 ? 12 : current.hourOfPeriod;
    setState(() {
      _activeField = fieldIndex;
      _hour = h12;
      _minute = current.minute;
      _isAm = current.period == DayPeriod.am;
    });
  }

  void _applyPendingTime() {
    if (_activeField != 1 && _activeField != 3) return;
    int h24;
    if (_isAm) {
      h24 = _hour == 12 ? 0 : _hour;
    } else {
      h24 = _hour == 12 ? 12 : _hour + 12;
    }
    final tod = TimeOfDay(hour: h24, minute: _minute);
    if (_activeField == 1) {
      _startTime = tod;
    } else {
      _endTime = tod;
    }
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  void _adjustHour(int dir) => setState(() {
    _hour += dir;
    if (_hour > 12) _hour = 1;
    if (_hour < 1) _hour = 12;
  });

  void _adjustMinute(int dir) => setState(() {
    _minute += dir;
    if (_minute > 59) _minute = 0;
    if (_minute < 0) _minute = 59;
  });

  // ── build ──

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1a1a2e);

    return Dialog(
      backgroundColor: bg,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      // insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SizedBox(
        width: 860,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // _buildHeader(),

            // close button on top right
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 0,
                top: 0,
                bottom: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    splashFactory: NoSplash.splashFactory,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.surface,
                        size: 38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                children: [
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          label: 'Start Date',
                          value: _formatDate(_startDate),
                          icon: Icons.calendar_today_rounded,
                          active: _activeField == 0,
                          onTap: () => _openDateField(0, _startDate),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _field(
                          label: 'End Date',
                          value: _formatDate(_endDate),
                          icon: Icons.calendar_today_rounded,
                          active: _activeField == 2,
                          onTap: () => _openDateField(2, _endDate),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          label: 'Start Time',
                          value: _formatTime(_startTime),
                          icon: Icons.access_time_rounded,
                          active: _activeField == 1,
                          onTap: () => _openTimeField(1, _startTime),
                        ),
                      ),

                      const SizedBox(width: 16),
                      Expanded(
                        child: _field(
                          label: 'End Time',
                          value: _formatTime(_endTime),
                          icon: Icons.access_time_rounded,
                          active: _activeField == 3,
                          onTap: () => _openTimeField(3, _endTime),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_activeField == 0 || _activeField == 2)
              _buildDatePicker(isDark, textColor),
            if (_activeField == 1 || _activeField == 3)
              _buildTimePicker(textColor),

            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── header with full range display ──

  // Widget _buildHeader() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
  //     decoration: const BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [_accent, _accentLight],
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             // Start block
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'FROM',
  //                     style: TextStyle(
  //                       color: Colors.white.withValues(alpha: 0.6),
  //                       fontSize: 10,
  //                       fontWeight: FontWeight.w700,
  //                       letterSpacing: 1.2,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     _formatDateShort(_startDate),
  //                     style: const TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.w700,
  //                     ),
  //                   ),
  //                   Text(
  //                     _formatTime(_startTime),
  //                     style: TextStyle(
  //                       color: Colors.white.withValues(alpha: 0.85),
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             // Arrow
  //             Container(
  //               margin: const EdgeInsets.symmetric(horizontal: 12),
  //               padding: const EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withValues(alpha: 0.2),
  //                 shape: BoxShape.circle,
  //               ),
  //               child: const Icon(
  //                 Icons.arrow_forward_rounded,
  //                 color: Colors.white,
  //                 size: 20,
  //               ),
  //             ),
  //             // End block
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.end,
  //                 children: [
  //                   Text(
  //                     'TO',
  //                     style: TextStyle(
  //                       color: Colors.white.withValues(alpha: 0.6),
  //                       fontSize: 10,
  //                       fontWeight: FontWeight.w700,
  //                       letterSpacing: 1.2,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     _formatDateShort(_endDate),
  //                     style: const TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.w700,
  //                     ),
  //                   ),
  //                   Text(
  //                     _formatTime(_endTime),
  //                     style: TextStyle(
  //                       color: Colors.white.withValues(alpha: 0.85),
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ── tappable field ──

  Widget _field({
    required String label,
    required String value,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? _accent : _accent.withValues(alpha: 0.15),
            width: active ? 2 : 1.5,
          ),
          color: active ? _accent.withValues(alpha: 0.06) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: active ? _accent : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: active ? _accent : Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: active ? _accent : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── date picker (Syncfusion) ──

  Widget _buildDatePicker(bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SfDateRangePicker(
        backgroundColor: Colors.transparent,
        controller: _pickerController,
        selectionMode: DateRangePickerSelectionMode.single,
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        showNavigationArrow: true,
        todayHighlightColor: _accent,
        selectionColor: _accent,
        selectionTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
        headerStyle: DateRangePickerHeaderStyle(
          textAlign: TextAlign.center,
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        headerHeight: 50,
        monthViewSettings: DateRangePickerMonthViewSettings(
          viewHeaderStyle: DateRangePickerViewHeaderStyle(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.45),
            ),
          ),
          dayFormat: 'EE',
          firstDayOfWeek: 7,
        ),
        monthCellStyle: DateRangePickerMonthCellStyle(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          todayTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _accent,
          ),
          todayCellDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _accent, width: 1.5),
          ),
          disabledDatesTextStyle: TextStyle(
            fontSize: 16,
            color: textColor.withValues(alpha: 0.25),
          ),
        ),
        selectionShape: DateRangePickerSelectionShape.circle,
        onSelectionChanged: (args) {
          if (args.value is DateTime) {
            setState(() {
              if (_activeField == 0) {
                _startDate = args.value as DateTime;
              } else {
                _endDate = args.value as DateTime;
              }
            });
          }
        },
      ),
    );
  }

  // ── time picker (horizontal arrows) ──

  Widget _buildTimePicker(Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hour spinner (horizontal)
          _horizontalSpinner(
            value: _hour.toString().padLeft(2, '0'),
            onLeft: () => _adjustHour(-1),
            onRight: () => _adjustHour(1),
            textColor: textColor,
          ),

          // Colon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: _accent,
              ),
            ),
          ),

          // Minute spinner (horizontal)
          _horizontalSpinner(
            value: _minute.toString().padLeft(2, '0'),
            onLeft: () => _adjustMinute(-1),
            onRight: () => _adjustMinute(1),
            textColor: textColor,
          ),

          const SizedBox(width: 24),

          // AM/PM
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _accent.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _periodChip('AM', _isAm),
                Container(
                  height: 1.5,
                  width: 64,
                  color: _accent.withValues(alpha: 0.2),
                ),
                _periodChip('PM', !_isAm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _horizontalSpinner({
    required String value,
    required VoidCallback onLeft,
    required VoidCallback onRight,
    required Color textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Left arrow
        _arrowButton(Icons.chevron_left_rounded, onLeft),
        const SizedBox(width: 8),
        // Value
        Container(
          width: 90,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _accent.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Right arrow
        _arrowButton(Icons.chevron_right_rounded, onRight),
      ],
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 28, color: _accent),
      ),
    );
  }

  Widget _periodChip(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _isAm = label == 'AM'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [_accent, _accentLight])
              : null,
          color: active ? null : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: active ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  // ── footer ──

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 34),
      child: ElevatedButton(
        onPressed: () {
          _applyPendingTime();
          final start = _combine(_startDate, _startTime);
          final end = _combine(_endDate, _endTime);
          if (end.isBefore(start)) {
            PopupDialog.showErrorMessage(
              duration: Duration(seconds: 2),
              'End time must be after Start time.',
            );
            return;
          }
          Navigator.of(
            context,
          ).pop(DateTimeRange(start: start, end: end));
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          backgroundColor: StaticColors.greenColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: StaticColors.greenColor.withValues(alpha: 0.4),
        ),
        child: const Text(
          'Confirm ',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
    );
  }
}
