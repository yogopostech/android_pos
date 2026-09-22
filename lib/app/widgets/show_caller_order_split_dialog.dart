import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pagination_flutter/pagination.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/models/meta_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/search_check_dialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

Future<void> showCallerOrderSplitDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const CallerOrderSplitDialog(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Main dialog
// ─────────────────────────────────────────────────────────────────────────────

class CallerOrderSplitDialog extends ConsumerStatefulWidget {
  const CallerOrderSplitDialog({super.key});

  @override
  ConsumerState<CallerOrderSplitDialog> createState() =>
      _CallerOrderSplitDialogState();
}

class _CallerOrderSplitDialogState
    extends ConsumerState<CallerOrderSplitDialog> {
  final _searchCtrl = TextEditingController();
  final _focus = FocusNode();
  final _gridCtrl = DataGridController();
  Timer? _debounce;

  List<CallerIdData> _callers = [];
  MetaModel? _meta;
  bool _loading = true;
  int _page = 1;

  CallerIdData? _selectedCaller;
  late _CallerDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = _CallerDataSource(
      callers: const [],
      isLight: ConfigController.to.isLightTheme,
      page: 1,
      perPage: 10,
    );
    _fetchCallers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    _gridCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  Future<void> _fetchCallers({int page = 1}) async {
    setState(() {
      _loading = true;
      _page = page;
    });
    try {
      final params = <String, dynamic>{'page': page};
      final q = _searchCtrl.text.trim();
      if (q.isNotEmpty) params['search'] = q;

      final res = await BaseController.to.apiService.makeGetRequest(
        '${URLS.baseURL}/caller-id',
        queryParameters: params,
      );
      if (res.statusCode == 200) {
        final dataMap = res.data['data'] as Map<String, dynamic>;
        _callers = (dataMap['records'] as List)
            .map((e) => CallerIdData.fromJson(e as Map<String, dynamic>))
            .toList();
        _meta = MetaModel.fromJson(dataMap['meta'] as Map<String, dynamic>);
        _dataSource.updateCallers(
          _callers,
          page: _page,
          perPage: _meta?.limit ?? 10,
        );
        if (_callers.isNotEmpty) {
          _selectedCaller = _callers.first;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _gridCtrl.selectedIndex = 0;
          });
        }
      }
    } catch (e) {
      kLogger.e('Caller fetch error => $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _fetchCallers(page: 1),
    );
  }

  // ── Row interaction ───────────────────────────────────────────────────────

  void _onRowTap(int dataIndex) {
    if (dataIndex < 0 || dataIndex >= _callers.length) return;
    final caller = _callers[dataIndex];

    if (_selectedCaller?.id == caller.id) {
      _showOrderTypeDialog(caller);
    } else {
      setState(() => _selectedCaller = caller);
    }
  }

  void _onRowDoubleTap(int dataIndex) {
    if (dataIndex < 0 || dataIndex >= _callers.length) return;
    final caller = _callers[dataIndex];
    setState(() => _selectedCaller = caller);
    _showOrderTypeDialog(caller);
  }

  // ── Order type dialog ─────────────────────────────────────────────────────

  void _showOrderTypeDialog(CallerIdData caller) {
    showDialog<void>(
      context: context,
      builder: (_) => _OrderTypeDialog(
        caller: caller,
        isLight: ConfigController.to.isLightTheme,
        onTakeout: () => _applyTakeout(caller),
        onDelivery: () => _applyDelivery(caller),
        onSearchOrder: () => _applySearchOrder(caller),
      ),
    );
  }

  void _applySearchOrder(CallerIdData caller) {
    Get.back();
    Get.back();
    showOrderSearchDialog(
      Get.context!,
      search: caller.phoneNumber,
      isCallerMode: false,
    );
  }

  void _applyTakeout(CallerIdData caller) {
    final pos = PosController.to;
    pos.clearCartList();
    pos.onChangeOrderType("TAKEOUT");
    pos.guestController.text = '1';
    pos.tableController.text = "";
    pos.guestNameController.text = caller.callerName ?? '';
    pos.guestPhoneController.text = caller.phoneNumber ?? '';

    Get.back();
    Get.back();
  }

  Future<void> _applyDelivery(CallerIdData caller) async {
    Get.back();

    try {
      final res = await BaseController.to.apiService.makeGetRequest(
        URLS.orders,
        queryParameters: {
          'limit': 5,
          'search': (caller.phoneNumber ?? '').trim(),
          'orderType': 'DELIVERY',
        },
      );
      if (res.statusCode == 200) {
        final orders = (res.data['data'] as List)
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final pos = PosController.to;
        pos.clearCartList();
        if (orders.isNotEmpty) {
          pos.repeatOrder(orders.first, isCleanItem: true);
        } else {
          pos.clearCartList();
          pos.onChangeOrderType("DELIVERY");
          pos.guestController.text = '1';
          pos.tableController.text = "";
          pos.guestNameController.text = caller.callerName ?? '';
          pos.guestPhoneController.text = caller.phoneNumber ?? '';
        }
      }
    } catch (e) {
      kLogger.e('Delivery order search error => $e');
    }

    if (mounted) Get.back();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final isLight = ConfigController.to.isLightTheme;
    final theme = Theme.of(context);
    final textColor = isLight ? Colors.black : Colors.white;
    final subColor = isLight
        ? Colors.black.withAlpha(120)
        : Colors.white.withAlpha(120);

    return Dialog(
      backgroundColor: isLight ? theme.canvasColor : StaticColors.cartColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 1200,
        height: screenH * 0.80,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ───────────────────────────────────────────────
              Row(
                children: [
                  Text(
                    'Call History',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 76),
                  SizedBox(
                    width: 460,
                    child: CustomTextField(
                      focusNode: _focus,
                      controller: _searchCtrl,
                      autofocus: false,
                      style: TextStyle(color: textColor),
                      hintText:
                          'Search by Phone Number, Customer First Name / Last Name',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: StaticColors.blueColor,
                      ),
                      onChange: _onSearchChanged,
                      onKeyboardChang: _onSearchChanged,
                    ),
                  ),
                  const Spacer(),
                  _IconButton(
                    isLight: isLight,
                    icon: Icons.refresh_rounded,
                    color: StaticColors.blueColor,
                    onTap: () => _fetchCallers(page: _page),
                  ),
                  const SizedBox(width: 26),
                  _IconButton(
                    isLight: isLight,
                    icon: Icons.close_rounded,
                    color: isLight
                        ? Colors.black.withAlpha(160)
                        : Colors.white.withAlpha(180),
                    onTap: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Grid ─────────────────────────────────────────────────────
              Expanded(child: _buildGridArea(isLight, subColor)),

              // ── Pagination ───────────────────────────────────────────────
              if (!_loading && (_meta?.totalPages ?? 0) > 1) ...[
                const SizedBox(height: 12),
                _buildPagination(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridArea(bool isLight, Color subColor) {
    if (_loading) {
      return const Center(
        child: SpinKitRing(color: StaticColors.orangeColor, size: 40),
      );
    }
    if (_callers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone_disabled_outlined, size: 52, color: subColor),
            const SizedBox(height: 12),
            Text(
              'No callers found',
              style: TextStyle(color: subColor, fontSize: 16),
            ),
          ],
        ),
      );
    }

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
        source: _dataSource,
        controller: _gridCtrl,
        selectionMode: SelectionMode.single,
        navigationMode: GridNavigationMode.row,
        highlightRowOnHover: true,
        rowHeight: 54,
        headerRowHeight: 46,
        onCellTap: (DataGridCellTapDetails details) {
          final rowIdx = details.rowColumnIndex.rowIndex;
          if (rowIdx < 1) return;
          _onRowTap(rowIdx - 1);
        },
        onCellDoubleTap: (DataGridCellDoubleTapDetails details) {
          final rowIdx = details.rowColumnIndex.rowIndex;
          if (rowIdx < 1) return;
          _onRowDoubleTap(rowIdx - 1);
        },
        columns: [
          GridColumn(
            columnName: 'no',
            width: 80,
            label: _headerCell('No.', isLight),
          ),
          GridColumn(
            columnName: 'line',
            width: 170,
            label: _headerCell('Phone Line', isLight),
          ),
          GridColumn(
            columnName: 'receivedAt',
            width: 260,
            label: _headerCell('Date & Time', isLight),
          ),
          GridColumn(
            columnName: 'name',
            columnWidthMode: ColumnWidthMode.fill,
            label: _headerCell('Customer Name', isLight),
          ),
          GridColumn(
            columnName: 'phone',
            width: 190,
            label: _headerCell('Phone Number', isLight),
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

  Widget _buildPagination(BuildContext context) {
    final theme = Theme.of(context);
    return Pagination(
      numOfPages: _meta!.totalPages,
      selectedPage: _page,
      pagesVisible: 5,
      onPageChanged: (p) => _fetchCallers(page: p),
      nextIcon: const Icon(
        Icons.arrow_forward_ios,
        color: StaticColors.blueColor,
        size: 14,
      ),
      previousIcon: const Icon(
        Icons.arrow_back_ios,
        color: StaticColors.blueColor,
        size: 14,
      ),
      activeTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      activeBtnStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(StaticColors.blueColor),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      inactiveBtnStyle: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
        ),
      ),
      inactiveTextStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: theme.textTheme.labelLarge?.color,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SfDataGrid source
// ─────────────────────────────────────────────────────────────────────────────

class _CallerDataSource extends DataGridSource {
  _CallerDataSource({
    required List<CallerIdData> callers,
    required this.isLight,
    required int page,
    required int perPage,
  }) {
    _buildRows(callers, page: page, perPage: perPage);
  }

  final bool isLight;
  List<DataGridRow> _rows = [];

  void updateCallers(
    List<CallerIdData> callers, {
    required int page,
    required int perPage,
  }) {
    _buildRows(callers, page: page, perPage: perPage);
    notifyListeners();
  }

  void _buildRows(
    List<CallerIdData> callers, {
    required int page,
    required int perPage,
  }) {
    _rows = List.generate(callers.length, (i) {
      final c = callers[i];
      final no = (page - 1) * perPage + i + 1;
      return DataGridRow(
        cells: [
          DataGridCell<int>(columnName: 'no', value: no),
          DataGridCell<String>(
            columnName: 'line',
            value: 'Line ${c.lineNumber}',
          ),
          DataGridCell<String>(
            columnName: 'receivedAt',
            value: DateFormat('MMM dd, hh:mm a').format(c.receivedAt.toLocal()),
          ),
          DataGridCell<String>(columnName: 'name', value: c.displayName),
          DataGridCell<String>(columnName: 'phone', value: c.displayPhone),
        ],
      );
    });
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final textColor = isLight ? Colors.black : Colors.white;

    final cells = row.getCells();
    return DataGridRowAdapter(
      cells: cells.map((cell) {
        final isNo = cell.columnName == 'no';
        final isLine = cell.columnName == 'line';

        return Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: isNo
              ? Text(
                  '${cell.value}',
                  style: TextStyle(
                    color: textColor.withAlpha(160),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : isLine
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(28),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.withAlpha(80)),
                  ),
                  child: Text(
                    cell.value.toString(),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : Text(
                  cell.value.toString(),
                  style: TextStyle(
                    color: textColor.withAlpha(200),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order type dialog  (2nd dialog)
// ─────────────────────────────────────────────────────────────────────────────

class _OrderTypeDialog extends StatelessWidget {
  const _OrderTypeDialog({
    required this.caller,
    required this.isLight,
    required this.onTakeout,
    required this.onDelivery,
    required this.onSearchOrder,
  });

  final CallerIdData caller;
  final bool isLight;
  final VoidCallback onTakeout;
  final VoidCallback onDelivery;
  final VoidCallback onSearchOrder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = isLight ? Colors.black : Colors.white;

    return Dialog(
      backgroundColor: isLight ? theme.canvasColor : StaticColors.cartColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: 620,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Select Order Type',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  _IconButton(
                    isLight: isLight,
                    icon: Icons.close_rounded,
                    color: isLight
                        ? Colors.black.withAlpha(160)
                        : Colors.white.withAlpha(180),
                    onTap: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _OrderTypeBtn(
                      label: 'Takeout',
                      icon: Icons.shopping_bag_outlined,
                      color: StaticColors.blueColor,
                      onTap: onTakeout,
                    ),
                  ),
                  const SizedBox(width: 45),
                  Expanded(
                    child: _OrderTypeBtn(
                      label: 'Delivery',
                      icon: Icons.delivery_dining_outlined,
                      color: StaticColors.greenColor,
                      onTap: onDelivery,
                    ),
                  ),
                  // const SizedBox(width: 45),
                  // Expanded(
                  //   child: _OrderTypeBtn(
                  //     label: 'Customer Search',
                  //     icon: Icons.delivery_dining_outlined,
                  //     color: StaticColors.blueColor,
                  //     onTap: onSearchOrder,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderTypeBtn extends StatelessWidget {
  const _OrderTypeBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.white.withAlpha(40),
        highlightColor: Colors.white.withAlpha(25),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.isLight,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final bool isLight;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: isLight
                ? Colors.black.withAlpha(10)
                : Colors.white.withAlpha(14),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isLight
                  ? Colors.black.withAlpha(18)
                  : Colors.white.withAlpha(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}
