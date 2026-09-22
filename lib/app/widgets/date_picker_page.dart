import 'package:flutter/material.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:timezone/standalone.dart' as tz;

class DatePickerPage extends StatefulWidget {
  const DatePickerPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DatePickerPageState createState() => _DatePickerPageState();
}

class _DatePickerPageState extends State<DatePickerPage> {
  final DateRangePickerController _controller = DateRangePickerController();
  var myZone = Preferences.myTimeZone;
  tz.Location? belizeLocation;

  DateTime get todayInMyZone {
    final myZone =
        tz.getLocation(Preferences.myTimeZone); // Load the preferred time zone
    final now = tz.TZDateTime.now(myZone);
    return now;
  }

  @override
  void initState() {
    super.initState();
    belizeLocation = tz.getLocation(myZone);
    kLogger.e(myZone);
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    // The value can be a single date, a range, or a list depending on the selection mode
    if (args.value is PickerDateRange) {
      // This is the range of dates
      final DateTime startDate = args.value.startDate;
      final DateTime? endDate =
          args.value.endDate; // Could be null if only one date is selected

      // Convert startDate and endDate to 'America/Belize' time zone
      final tz.TZDateTime belizeStartTime =
          tz.TZDateTime.from(startDate, belizeLocation!);
      tz.TZDateTime? belizeEndTime;
      if (endDate != null) {
        belizeEndTime = tz.TZDateTime.from(endDate, belizeLocation!);
      }

      kLogger.e(
          'Selected range in $myZone time zone: $belizeStartTime - $belizeEndTime');
    } else if (args.value is DateTime) {
      // This is a single date
      final DateTime selectedDate = args.value;

      // Convert to 'America/Belize' time zone
      final tz.TZDateTime belizeTime =
          tz.TZDateTime.from(selectedDate, belizeLocation!);

      kLogger.e('Selected date in $myZone time zone: $belizeTime');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfDateRangePicker(
      selectionMode: DateRangePickerSelectionMode.range,
      controller: _controller,
      // initialSelectedDate: todayInMyZone,
      // initialSelectedDates: [todayInMyZone,todayInMyZone],
      initialSelectedRange:
          PickerDateRange(todayInMyZone, DateTime.now().toTimeZone()),
      onSelectionChanged: _onSelectionChanged,
      backgroundColor: Colors.transparent,
    );
  }
}
