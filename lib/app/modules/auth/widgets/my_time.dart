import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;

// class MyTime extends StatefulWidget {
//   const MyTime({super.key});

//   @override
//   State<MyTime> createState() => _MyTimeState();
// }

// class _MyTimeState extends State<MyTime> {
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _timer = Timer.periodic(const Duration(seconds: 1), (value) {
//       if (mounted) {
//         setState(() {});
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get the current time in UTC
//     DateTime nowUtc = DateTime.now().toUtc();
//     var myZone = Preferences.myTimeZone;
//     if (myZone.isEmpty) {
//       myZone = "America/Belize";
//     }
//     var detroit = tz.getLocation(myZone);
//     tz.TZDateTime time = tz.TZDateTime.from(nowUtc, detroit);
//     return Text(
//       DateFormat('hh:mm a').format(time),
//       style: const TextStyle(
//         color: Colors.black,
//         fontSize: 16,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }
// }

class MyTime extends StatefulWidget {
  const MyTime({super.key});

  @override
  State<MyTime> createState() => _MyTimeState();
}

class _MyTimeState extends State<MyTime> {
  Timer? _timer;
  final ValueNotifier<String> _formattedTime = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    _updateTime(); // Initial update
    _timer = Timer.periodic(const Duration(seconds: 1), (value) {
      _updateTime();
    });
  }

  void _updateTime() {
    DateTime nowUtc = DateTime.now().toUtc();
    var myZone = Preferences.myTimeZone;
    if (myZone.isEmpty) {
      myZone = "America/Belize";
    }
    var detroit = tz.getLocation(myZone);
    tz.TZDateTime time = tz.TZDateTime.from(nowUtc, detroit);
    _formattedTime.value = DateFormat('hh:mm a').format(time);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _formattedTime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _formattedTime,
      builder: (context, timeString, child) {
        return Text(
          timeString,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
