
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yogo_pos/app/modules/clockIn/model/clock_record_model.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/models/meta_model.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/urls.dart';

part 'time_sheet_provider.g.dart'; // <- file name onujayi change koro

/// Holds one page of data, its pagination meta, and the active filter range.
class TimeSheetState {
  const TimeSheetState({
    this.records = const [],
    this.meta,
    required this.range,
  });

  final List<ClockRecordModel> records;
  final MetaModel? meta;
  final DateTimeRange range;
}

@riverpod
class TimeSheet extends _$TimeSheet {
  // Default = 1st of this month (opening time) → today (closing time).
  late DateTimeRange _range = _defaultRange();

  /// Current range — the picker opens with this as its initial value.
  DateTimeRange get range => _range;

  /// First day of the current month at the restaurant's opening time,
  /// through today at its closing time.
  DateTimeRange _defaultRange() {
    final now = DateTime.now();
    final restaurant = BaseController.to.restaurantDetails?.restaurant;

    final openingParts = restaurant?.openingTime.split(':') ?? ['06', '00'];
    final closingParts = restaurant?.closingTime.split(':') ?? ['23', '59'];

    final openHour = int.parse(openingParts[0]);
    final openMin = int.parse(openingParts[1]);
    final closeHour = int.parse(closingParts[0]);
    final closeMin = int.parse(closingParts[1]);

    // Start: 1st of the current month, at opening time.
    final start = DateTime(now.year, now.month, 1, openHour, openMin);

    // Overnight check: closing time falls on the next calendar day.
    final bool isOvernight =
        closeHour < openHour || (closeHour == openHour && closeMin <= openMin);

    // End: today at closing time (next day if the business day is overnight).
    final end = isOvernight
        ? DateTime(now.year, now.month, now.day + 1, closeHour, closeMin)
        : DateTime(now.year, now.month, now.day, closeHour, closeMin);

    if (kDebugMode) {
      debugPrint(
        '📅 TimeSheet _defaultRange:'
        '\n   openingTime : ${restaurant?.openingTime} → $start'
        '\n   closingTime : ${restaurant?.closingTime} → $end'
        '\n   isOvernight : $isOvernight'
        '\n   now         : $now'
        '\n   valid       : ${!start.isAfter(end)}',
      );
    }

    // Safety: should not happen, but never build an invalid range.
    if (start.isAfter(end)) {
      if (kDebugMode) {
        debugPrint(
          '⛔ TimeSheet _defaultRange: start is after end — fallback to full month',
        );
      }
      return DateTimeRange(
        start: DateTime(now.year, now.month, 1, 0, 0),
        end: DateTime(now.year, now.month, now.day, 23, 59),
      );
    }

    return DateTimeRange(start: start, end: end);
  }

  @override
  Future<TimeSheetState> build() => _fetch(page: 1);

  Future<TimeSheetState> _fetch({required int page, int limit = 20}) async {
    final params = {
      "startDate": DateFormat('yyyy-MM-dd').format(_range.start),
      "endDate": DateFormat('yyyy-MM-dd').format(_range.end),
      "startTime": DateFormat('HH:mm').format(_range.start),
      "endTime": DateFormat('HH:mm').format(_range.end),
      "page": "$page",
      "limit": "$limit",
    };

    final res = await BaseController.to.apiService.makeGetRequest(
      URLS.employeeTimeSheet, // <- tomar actual URL constant
      queryParameters: params,
    );

    if (res.statusCode != 200) {
      throw Exception(res.data?["message"] ?? "Failed to load time sheet.");
    }

    final body = res.data as Map<String, dynamic>;

    final list = (body["data"] as List?) ?? const [];
    final records = list
        .map((e) => ClockRecordModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final meta = body["meta"] == null
        ? null
        : MetaModel.fromJson(body["meta"] as Map<String, dynamic>);

    return TimeSheetState(records: records, meta: meta, range: _range);
  }

  /// Apply a newly picked range and reload from page 1.
  Future<void> applyRange(DateTimeRange range) async {
    _range = range;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(page: 1));
  }

  /// Pagination — keeps the current grid on screen while the page loads.
  Future<void> loadPage(int page) async {
    state = await AsyncValue.guard(() => _fetch(page: page));
  }

  /// Refresh the current range from page 1.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(page: 1));
  }
}
