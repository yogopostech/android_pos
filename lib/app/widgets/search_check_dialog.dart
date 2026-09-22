import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/modules/setting/providers/caller_id_notifier.dart';
import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';

Future<void> showOrderSearchDialog(
  BuildContext context, {
  String? search,
  List<CallerIdData>? callerDataList,
  bool? isCallerMode,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => OrderSearchDialog(
      search: search,
      isCallerMode: isCallerMode ?? true,
      callerDataList: callerDataList ?? [],
    ),
  );
}

class OrderSearchDialog extends ConsumerStatefulWidget {
  final String? search;
  final List<CallerIdData> callerDataList;
  final bool isCallerMode;

  const OrderSearchDialog({
    super.key,
    this.search,
    required this.isCallerMode,
    this.callerDataList = const [],
  });

  @override
  ConsumerState<OrderSearchDialog> createState() => _OrderSearchDialogState();
}

class _OrderSearchDialogState extends ConsumerState<OrderSearchDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<OrderModel> _orders = [];
  bool _loading = false;
  bool _hasSearched = false;

  // tracks which caller is currently processing delivery (shows spinner)
  String? _deliveryLoadingId;

  // selected caller — 1st caller auto-selected on open, user can tap to change
  String? _selectedCallerId;

  bool get _isCallerMode => widget.isCallerMode;

  @override
  void initState() {
    super.initState();
    if (widget.search?.trim().isNotEmpty ?? false) {
      _controller.text = widget.search!;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _search(widget.search!),
      );
    }
    //auto close
    if (widget.isCallerMode) {
      Future.delayed(Duration(seconds: 30), () {
        Get.back();
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Order search (used only when activeCalls is empty) ────────────────────

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _orders = [];
        _hasSearched = false;
        _loading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 800), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    try {
      final res = await BaseController.to.apiService.makeGetRequest(
        URLS.orders,
        queryParameters: {'limit': 20, 'search': query.trim()},
      );
      if (res.statusCode == 200) {
        _orders = (res.data['data'] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      kLogger.e('Order search error => $e');
    }
    if (mounted){
      setState(() {
        _loading = false;
        _hasSearched = true;
      });
    }
  }

  // ── Takeout ───────────────────────────────────────────────────────────────

  void _onTakeout(CallerIdData data) {
    final pos = PosController.to;
    //routing
    final currentRoute = Get.currentRoute;
    if (currentRoute != '/pos') {
      Get.until((route) => route.settings.name == '/pos');
    }
    pos.clearCartList();
    // check page
    if (pos.pageController.page != 0) {
      pos.pageController.jumpToPage(0);
    }
    pos.onChangeOrderType("TAKEOUT");
    pos.guestController.text = '1';
    pos.tableController.text = "";
    pos.guestNameController.text = data.callerName ?? '';
    pos.guestPhoneController.text = data.phoneNumber ?? '';
    Get.back();
  }

  Future<void> _onDelivery(CallerIdData data) async {
    setState(() => _deliveryLoadingId = data.id);
    try {
      final res = await BaseController.to.apiService.makeGetRequest(
        URLS.orders,
        queryParameters: {
          'limit': 5,
          'search': (data.phoneNumber ?? '').trim(),
          'orderType': 'DELIVERY',
        },
      );
      if (res.statusCode == 200) {
        final orders = (res.data['data'] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList();
        final pos = PosController.to;
        pos.clearCartList();
        if (orders.isNotEmpty) {
          pos.repeatOrder(orders.first, isCleanItem: true);
        } else {
          //routing
          final currentRoute = Get.currentRoute;
          if (currentRoute != '/pos') {
            Get.until((route) => route.settings.name == '/pos');
          }
          pos.clearCartList();
          // check page
          if (pos.pageController.page != 0) {
            pos.pageController.jumpToPage(0);
          }
          pos.onChangeOrderType("DELIVERY");
          pos.guestController.text = '1';
          pos.tableController.text = "";
          pos.guestNameController.text = data.callerName ?? '';
          pos.guestPhoneController.text = data.phoneNumber ?? '';
        }
      }
    } catch (e) {
      kLogger.e('Delivery order search error => $e');
    }

    if (mounted) {
      setState(() => _deliveryLoadingId = null);
      Get.back();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
  

    final screenH = MediaQuery.of(context).size.height;
    final isLight = ConfigController.to.isLightTheme;
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: isLight ? theme.canvasColor : StaticColors.cartColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 850,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 0,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Search + order list: only when no active calls ─────────
              if (!_isCallerMode) ...[
                CustomTextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: !_isCallerMode,
                  style: TextStyle(
                    color: isLight ? Colors.black : Colors.white,
                  ),
                  hintText:
                      'Search by Phone Number, Customer First Name / Last Name',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF3BB2F6),
                  ),
                  onChange: _onSearchChanged,
                  onKeyboardChang: _onSearchChanged,
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildBody(isLight)),
              ],

              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isLight) {
    if (_loading) {
      return const Center(
        child: SpinKitRing(color: StaticColors.orangeColor, size: 53),
      );
    }
    if (!_hasSearched) {
      return const Center(child: Text('Type to search orders'));
    }
    if (_orders.isEmpty) {
      return const Center(child: Text('No orders found'));
    }
    return ListView.separated(
      itemCount: _orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _OrderCard(
        order: _orders[i],
        onAdd: () {
          PosController.to.repeatOrder(_orders[i]);
          Get.back();
        },
        onNewOrder: () {
          PosController.to.repeatOrder(_orders[i], isCleanItem: true);
          Get.back();
        },
      ),
    );
  }
}

// ── Caller Info Header ────────────────────────────────────────────────────────

class _CallerInfoHeader extends StatelessWidget {
  final CallerIdData data;
  final bool isSelected;
  final bool isDeliveryLoading;
  final int index;
  final VoidCallback onSelect;
  final VoidCallback? onTakeout; // null = disabled (not selected)
  final VoidCallback? onDelivery; // null = disabled (not selected)

  const _CallerInfoHeader({
    required this.data,
    required this.isSelected,
    required this.isDeliveryLoading,
    required this.onSelect,
    required this.onTakeout,
    required this.onDelivery,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = ConfigController.to.isLightTheme;
    final textColor = isLight ? Colors.black : Colors.white;
    final subColor = isLight
        ? Colors.black.withAlpha(150)
        : Colors.white.withAlpha(170);

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        height: 100,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? StaticColors.greenColor.withAlpha(15)
              : (isLight
                    ? Colors.black.withAlpha(8)
                    : Colors.white.withAlpha(10)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: isSelected
                ? StaticColors.greenColor.withAlpha(200)
                : (isLight
                      ? Colors.black.withAlpha(15)
                      : Colors.white.withAlpha(20)),
          ),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // index badge
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Text(
                "$index.",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Line badge
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withAlpha(80)),
              ),
              child: Text(
                'Line ${data.lineNumber}',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Icon
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: StaticColors.blueColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.phone_in_talk_outlined,
                color: StaticColors.blueColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),

            // Name + phone
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.displayName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.displayPhone,
                    style: TextStyle(
                      color: subColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 2),
                  Text(
                    DateFormat(
                      'MMM dd, hh:mm a',
                    ).format(data.receivedAt.toLocal()),
                    style: TextStyle(
                      color: subColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Takeout button — disabled when not selected
            Visibility(
              visible: isSelected,
              child: Row(
                children: [
                  Opacity(
                    opacity: isSelected ? 1.0 : 1.0,
                    child: PrimaryBtn(
                      text: 'Takeout',
                      color: StaticColors.blueColor,
                      textColor: Colors.white,
                      width: 160,
                      height: 80,
                      textMinSize: 30,
                      textMaxSize: 30,
                      onPressed: onTakeout ?? () {},
                    ),
                  ),
                  const SizedBox(width: 22),

                  // Delivery button — spinner while loading, disabled when not selected
                  isDeliveryLoading
                      ? SizedBox(
                          width: 140,
                          height: 80,
                          child: Center(
                            child: SpinKitRing(
                              color: StaticColors.orangeColor,
                              size: 32,
                            ),
                          ),
                        )
                      : Opacity(
                          opacity: isSelected ? 1.0 : 1.0,
                          child: PrimaryBtn(
                            text: 'Delivery',
                            color: StaticColors.greenColor,
                            textColor: Colors.white,
                            width: 160,
                            height: 80,
                            textMinSize: 30,
                            textMaxSize: 30,
                            onPressed: onDelivery ?? () {},
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
}

// ── Order Card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onAdd;
  final void Function() onNewOrder;

  const _OrderCard({
    required this.order,
    required this.onAdd,
    required this.onNewOrder,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = ConfigController.to.isLightTheme;
    final theme = Theme.of(context);
    final textColor = isLight ? Colors.black : Colors.white;
    final subTextColor = isLight
        ? Colors.black.withAlpha(160)
        : Colors.white.withAlpha(180);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isLight
            ? theme.dividerColor.withAlpha(80)
            : Colors.white.withAlpha(14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLight
              ? Colors.black.withAlpha(20)
              : Colors.white.withAlpha(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _badge(order.orderId),
                          if (order.orderType == 'DINE_IN') ...[
                            _dot(subTextColor),
                            Text(
                              order.tableName.toUpperCase(),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (order.guestName.isNotEmpty) ...[
                            _dot(subTextColor),
                            Text(
                              order.guestName.toUpperCase(),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (order.guestPhoneNumber.isNotEmpty) ...[
                            _dot(subTextColor),
                            Text(
                              '#${order.guestPhoneNumber.replaceAll("+", "")}',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          _dot(subTextColor),
                          Text(
                            DateFormat(
                              'MMM dd, hh:mm a',
                            ).format(order.createdAt!.toTimeZone()),
                            style: TextStyle(color: subTextColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '\$${order.totalOrderAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (order.carts.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: order.carts
                                .map(
                                  (cart) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: StaticColors.blueColor.withAlpha(
                                        isLight ? 20 : 30,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${cart.quantity}x',
                                          style: const TextStyle(
                                            color: Color(0xFF3BB2F6),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          cart.name,
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          //Right area
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              //Reapet order
              _addButton(),
              //New Order
              const SizedBox(height: 10),
              PrimaryBtn(
                width: 165,
                height: 60,
                color: StaticColors.greenColor,
                onPressed: onNewOrder,
                textMaxSize: 20,
                textMinSize: 20,
                textColor: Colors.white,
                borderRadius: 10,
                text: "New Order",
              ),
              // Order Status
              const SizedBox(height: 10),
              Row(
                children: [
                  _badge(
                    color: Colors.white,
                    bgColor: StaticColors.blueColor,
                    MyFunc.orderType(order),
                  ),
                  const SizedBox(width: 6),
                  _badge(MyFunc.modifyOrderStatus(order.orderStatus)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, {Color? color, bgColor}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor ?? StaticColors.blueColor.withAlpha(38),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color ?? StaticColors.blueColor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _dot(Color color) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: CircleAvatar(radius: 2.5, backgroundColor: color),
  );

  Widget _addButton() => Material(
    color: Colors.transparent,
    child: SizedBox(
      height: 60,
      width: 165,
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [StaticColors.blueColor, Color(0xFF6366F1)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.replay_rounded, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'Repeat Order',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
// import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
// import 'package:yogo_pos/app/modules/setting/providers/caller_id_notifier.dart';
// import 'package:yogo_pos/app/modules/setting/repo/caller_id_data.dart';
// import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/services/controller/config_controller.dart';
// import 'package:yogo_pos/app/utils/extension/my_extension.dart';
// import 'package:yogo_pos/app/utils/logger.dart';
// import 'package:yogo_pos/app/utils/my_func.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';
// import 'package:yogo_pos/app/utils/urls.dart';
// import 'package:yogo_pos/app/widgets/custom_btn.dart';
// import 'package:yogo_pos/app/widgets/custom_textfield.dart';

// Future<void> showOrderSearchDialog(
//   BuildContext context, {
//   String? search,
//   List<CallerIdData>? callerDataList,
//   bool? isCallerMode,
// }) {
//   return showDialog<void>(
//     context: context,
//     barrierDismissible: true,
//     builder: (_) => OrderSearchDialog(
//       search: search,
//       isCallerMode: isCallerMode ?? true,
//       callerDataList: callerDataList ?? [],
//     ),
//   );
// }

// class OrderSearchDialog extends ConsumerStatefulWidget {
//   final String? search;
//   final List<CallerIdData> callerDataList;
//   final bool isCallerMode;

//   const OrderSearchDialog({
//     super.key,
//     this.search,
//     required this.isCallerMode,
//     this.callerDataList = const [],
//   });

//   @override
//   ConsumerState<OrderSearchDialog> createState() => _OrderSearchDialogState();
// }

// class _OrderSearchDialogState extends ConsumerState<OrderSearchDialog> {
//   final _controller = TextEditingController();
//   final _focusNode = FocusNode();
//   Timer? _debounce;
//   List<OrderModel> _orders = [];
//   bool _loading = false;
//   bool _hasSearched = false;

//   String? _deliveryLoadingId;
//   String? _selectedCallerId;

//   // ── Search-order mode (triggered from caller list) ─────────────────────────
//   bool _searchMode = false;

//   bool get _isCallerMode => widget.isCallerMode;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.search?.trim().isNotEmpty ?? false) {
//       _controller.text = widget.search!;
//       WidgetsBinding.instance.addPostFrameCallback(
//         (_) => _search(widget.search!),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _controller.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   // ── Order search ──────────────────────────────────────────────────────────

//   void _onSearchChanged(String query) {
//     _debounce?.cancel();
//     if (query.trim().isEmpty) {
//       setState(() {
//         _orders = [];
//         _hasSearched = false;
//         _loading = false;
//       });
//       return;
//     }
//     _debounce = Timer(const Duration(milliseconds: 800), () => _search(query));
//   }

//   Future<void> _search(String query) async {
//     setState(() => _loading = true);
//     try {
//       final res = await BaseController.to.apiService.makeGetRequest(
//         URLS.orders,
//         queryParameters: {'limit': 20, 'search': query.trim()},
//       );
//       if (res.statusCode == 200) {
//         _orders = (res.data['data'] as List)
//             .map((e) => OrderModel.fromJson(e))
//             .toList();
//       }
//     } catch (e) {
//       kLogger.e('Order search error => $e');
//     }
//     if (mounted) {
//       setState(() {
//         _loading = false;
//         _hasSearched = true;
//       });
//     }
//   }

//   // ── Search Order btn handler ──────────────────────────────────────────────

//   void _onSearchOrder(CallerIdData data) {
//     final phone = (data.phoneNumber ?? '').trim();
//     _controller.text = phone;
//     setState(() {
//       _searchMode = true;
//       _orders = [];
//       _hasSearched = false;
//       _loading = false;
//     });
//     // auto-trigger search if phone non-empty
//     if (phone.isNotEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) => _search(phone));
//     }
//     // focus the field after frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusNode.requestFocus();
//     });
//   }

//   void _exitSearchMode() {
//     _debounce?.cancel();
//     _controller.clear();
//     setState(() {
//       _searchMode = false;
//       _orders = [];
//       _hasSearched = false;
//       _loading = false;
//     });
//   }

//   // ── Takeout ───────────────────────────────────────────────────────────────

//   void _onTakeout(CallerIdData data) {
//     final pos = PosController.to;
//     final currentRoute = Get.currentRoute;
//     if (currentRoute != '/pos') {
//       Get.until((route) => route.settings.name == '/pos');
//     }
//     pos.clearCartList();
//     if (pos.pageController.page != 0) {
//       pos.pageController.jumpToPage(0);
//     }
//     pos.onChangeOrderType("TAKEOUT");
//     pos.guestController.text = '1';
//     pos.tableController.text = "";
//     pos.guestNameController.text = data.callerName ?? '';
//     pos.guestPhoneController.text = data.phoneNumber ?? '';
//     Get.back();
//   }

//   Future<void> _onDelivery(CallerIdData data) async {
//     setState(() => _deliveryLoadingId = data.id);
//     try {
//       final res = await BaseController.to.apiService.makeGetRequest(
//         URLS.orders,
//         queryParameters: {
//           'limit': 5,
//           'search': (data.phoneNumber ?? '').trim(),
//           'orderType': 'DELIVERY',
//         },
//       );
//       if (res.statusCode == 200) {
//         final orders = (res.data['data'] as List)
//             .map((e) => OrderModel.fromJson(e))
//             .toList();
//         final pos = PosController.to;
//         pos.clearCartList();
//         if (orders.isNotEmpty) {
//           pos.repeatOrder(orders.first, isCleanItem: true);
//         } else {
//           final currentRoute = Get.currentRoute;
//           if (currentRoute != '/pos') {
//             Get.until((route) => route.settings.name == '/pos');
//           }
//           pos.clearCartList();
//           if (pos.pageController.page != 0) {
//             pos.pageController.jumpToPage(0);
//           }
//           pos.onChangeOrderType("DELIVERY");
//           pos.guestController.text = '1';
//           pos.tableController.text = "";
//           pos.guestNameController.text = data.callerName ?? '';
//           pos.guestPhoneController.text = data.phoneNumber ?? '';
//         }
//       }
//     } catch (e) {
//       kLogger.e('Delivery order search error => $e');
//     }

//     if (mounted) {
//       setState(() => _deliveryLoadingId = null);
//       Get.back();
//     }
//   }

//   // ── Build ─────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final List<CallerIdData> activeCalls = ref
//         .watch(callerIdProvider)
//         .activeCalls;

//     final screenH = MediaQuery.of(context).size.height;
//     final isLight = ConfigController.to.isLightTheme;
//     final theme = Theme.of(context);

//     return Dialog(
//       backgroundColor: isLight ? theme.canvasColor : StaticColors.cartColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: SizedBox(
//         width: 1050,
//         child: Padding(
//           padding: const EdgeInsets.only(
//             top: 20,
//             bottom: 0,
//             left: 20,
//             right: 20,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // ── Pure search mode (no active calls) ────────────────────
//               if (!_isCallerMode) ...[
//                 CustomTextField(
//                   controller: _controller,
//                   focusNode: _focusNode,
//                   autofocus: true,
//                   style: TextStyle(
//                     color: isLight ? Colors.black : Colors.white,
//                   ),
//                   hintText:
//                       'Search by Phone Number, Customer First Name / Last Name',
//                   prefixIcon: const Icon(
//                     Icons.search,
//                     color: Color(0xFF3BB2F6),
//                   ),
//                   onChange: _onSearchChanged,
//                   onKeyboardChang: _onSearchChanged,
//                 ),
//                 const SizedBox(height: 16),
//                 Expanded(child: _buildBody(isLight)),
//               ],

//               // ── Caller mode ───────────────────────────────────────────
//               if (_isCallerMode) ...[
//                 // Search order panel (slides in when _searchMode == true)
//                 if (_searchMode) ...[
//                   _buildSearchPanel(isLight),
//                   const SizedBox(height: 12),
//                 ],

//                 // Caller list
//                 ConstrainedBox(
//                   constraints: BoxConstraints(
//                     maxHeight: _searchMode
//                         ? screenH *
//                               0.30 // shrink list when search panel open
//                         : screenH * 0.75,
//                   ),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: List.generate(activeCalls.length, (i) {
//                         final call = activeCalls[i];
//                         if (_selectedCallerId == null) {
//                           WidgetsBinding.instance.addPostFrameCallback(
//                             (_) => setState(
//                               () => _selectedCallerId = activeCalls.first.id,
//                             ),
//                           );
//                         }
//                         final isSelected = _selectedCallerId == call.id;
//                         return _CallerInfoHeader(
//                           data: call,
//                           isSelected: isSelected,
//                           index: i + 1,
//                           isDeliveryLoading: _deliveryLoadingId == call.id,
//                           onSelect: () =>
//                               setState(() => _selectedCallerId = call.id),
//                           onTakeout: () {
//                             if (_selectedCallerId != call.id) {
//                               setState(() => _selectedCallerId = call.id);
//                             } else {
//                               _onTakeout(call);
//                             }
//                           },
//                           onDelivery: () {
//                             if (_selectedCallerId != call.id) {
//                               setState(() => _selectedCallerId = call.id);
//                             } else {
//                               _onDelivery(call);
//                             }
//                           },
//                           onSearchOrder: () {
//                             if (_selectedCallerId != call.id) {
//                               setState(() => _selectedCallerId = call.id);
//                             }
//                             _onSearchOrder(call);
//                           },
//                         ).marginOnly(bottom: 12);
//                       }),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Search panel (shown inside caller mode) ───────────────────────────────

//   Widget _buildSearchPanel(bool isLight) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Row(
//           children: [
//             // Back button
//             GestureDetector(
//               onTap: _exitSearchMode,
//               child: Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: isLight
//                       ? Colors.black.withAlpha(12)
//                       : Colors.white.withAlpha(20),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   Icons.arrow_back_ios_new_rounded,
//                   size: 18,
//                   color: isLight ? Colors.black87 : Colors.white,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: CustomTextField(
//                 controller: _controller,
//                 focusNode: _focusNode,
//                 autofocus: false,
//                 style: TextStyle(color: isLight ? Colors.black : Colors.white),
//                 hintText:
//                     'Search by Phone Number, Customer First Name / Last Name',
//                 prefixIcon: const Icon(Icons.search, color: Color(0xFF3BB2F6)),
//                 onChange: _onSearchChanged,
//                 onKeyboardChang: _onSearchChanged,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         ConstrainedBox(
//           constraints: const BoxConstraints(maxHeight: 320),
//           child: _buildBody(isLight),
//         ),
//       ],
//     );
//   }

//   Widget _buildBody(bool isLight) {
//     if (_loading) {
//       return const Center(
//         child: SpinKitRing(color: StaticColors.orangeColor, size: 53),
//       );
//     }
//     if (!_hasSearched) {
//       return const Center(child: Text('Type to search orders'));
//     }
//     if (_orders.isEmpty) {
//       return const Center(child: Text('No orders found'));
//     }
//     return ListView.separated(
//       shrinkWrap: true,
//       itemCount: _orders.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 10),
//       itemBuilder: (_, i) => _OrderCard(
//         order: _orders[i],
//         onAdd: () {
//           PosController.to.repeatOrder(_orders[i]);
//           Get.back();
//         },
//       ),
//     );
//   }
// }

// // ── Caller Info Header ────────────────────────────────────────────────────────

// class _CallerInfoHeader extends StatelessWidget {
//   final CallerIdData data;
//   final bool isSelected;
//   final bool isDeliveryLoading;
//   final int index;
//   final VoidCallback onSelect;
//   final VoidCallback? onTakeout;
//   final VoidCallback? onDelivery;
//   final VoidCallback? onSearchOrder;

//   const _CallerInfoHeader({
//     required this.data,
//     required this.isSelected,
//     required this.isDeliveryLoading,
//     required this.onSelect,
//     required this.onTakeout,
//     required this.onDelivery,
//     required this.onSearchOrder,
//     required this.index,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isLight = ConfigController.to.isLightTheme;
//     final textColor = isLight ? Colors.black : Colors.white;
//     final subColor = isLight
//         ? Colors.black.withAlpha(150)
//         : Colors.white.withAlpha(170);

//     return GestureDetector(
//       onTap: onSelect,
//       child: AnimatedContainer(
//         height: 100,
//         duration: const Duration(milliseconds: 160),
//         curve: Curves.easeOut,
//         decoration: BoxDecoration(
//           color: isSelected
//               ? StaticColors.greenColor.withAlpha(15)
//               : (isLight
//                     ? Colors.black.withAlpha(8)
//                     : Colors.white.withAlpha(10)),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             width: 2,
//             color: isSelected
//                 ? StaticColors.greenColor.withAlpha(200)
//                 : (isLight
//                       ? Colors.black.withAlpha(15)
//                       : Colors.white.withAlpha(20)),
//           ),
//         ),
//         margin: const EdgeInsets.only(bottom: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         child: Row(
//           children: [
//             // index badge
//             Container(
//               width: 40,
//               height: 40,
//               alignment: Alignment.center,
//               child: Text(
//                 "$index.",
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             // Line badge
//             Container(
//               height: 40,
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                 color: Colors.green.withAlpha(30),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.green.withAlpha(80)),
//               ),
//               child: Text(
//                 'Line ${data.lineNumber}',
//                 style: const TextStyle(
//                   color: Colors.green,
//                   fontSize: 22,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),

//             // Icon
//             Container(
//               width: 54,
//               height: 54,
//               decoration: BoxDecoration(
//                 color: StaticColors.blueColor.withAlpha(30),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Icons.phone_in_talk_outlined,
//                 color: StaticColors.blueColor,
//                 size: 26,
//               ),
//             ),
//             const SizedBox(width: 12),

//             // Name + phone
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     data.displayName,
//                     style: TextStyle(
//                       color: textColor,
//                       fontSize: 20,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     data.displayPhone,
//                     style: TextStyle(
//                       color: subColor,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     DateFormat(
//                       'MMM dd, hh:mm a',
//                     ).format(data.receivedAt.toLocal()),
//                     style: TextStyle(
//                       color: subColor,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Action buttons — only visible when selected
//             Visibility(
//               visible: isSelected,
//               child: Row(
//                 children: [
//                   // Takeout
//                   PrimaryBtn(
//                     text: 'Takeout',
//                     color: StaticColors.blueColor,
//                     textColor: Colors.white,
//                     width: 160,
//                     height: 80,
//                     textMinSize: 30,
//                     textMaxSize: 30,
//                     onPressed: onTakeout ?? () {},
//                   ),
//                   const SizedBox(width: 12),

//                   // Delivery
//                   isDeliveryLoading
//                       ? SizedBox(
//                           width: 140,
//                           height: 80,
//                           child: Center(
//                             child: SpinKitRing(
//                               color: StaticColors.orangeColor,
//                               size: 32,
//                             ),
//                           ),
//                         )
//                       : PrimaryBtn(
//                           text: 'Delivery',
//                           color: StaticColors.greenColor,
//                           textColor: Colors.white,
//                           width: 160,
//                           height: 80,
//                           textMinSize: 30,
//                           textMaxSize: 30,
//                           onPressed: onDelivery ?? () {},
//                         ),
//                   const SizedBox(width: 12),

//                   // Search Order
//                   PrimaryBtn(
//                     text: 'Customer Search',
//                     color: StaticColors.orangeColor,
//                     textColor: Colors.white,
//                     width: 160,
//                     height: 80,
//                     textMinSize: 22,
//                     textMaxSize: 22,
//                     onPressed: onSearchOrder ?? () {},
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Order Card ────────────────────────────────────────────────────────────────

// class _OrderCard extends StatelessWidget {
//   final OrderModel order;
//   final VoidCallback onAdd;

//   const _OrderCard({required this.order, required this.onAdd});

//   @override
//   Widget build(BuildContext context) {
//     final isLight = ConfigController.to.isLightTheme;
//     final theme = Theme.of(context);
//     final textColor = isLight ? Colors.black : Colors.white;
//     final subTextColor = isLight
//         ? Colors.black.withAlpha(160)
//         : Colors.white.withAlpha(180);

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: isLight
//             ? theme.dividerColor.withAlpha(80)
//             : Colors.white.withAlpha(14),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: isLight
//               ? Colors.black.withAlpha(20)
//               : Colors.white.withAlpha(20),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Wrap(
//                   spacing: 8,
//                   runSpacing: 6,
//                   crossAxisAlignment: WrapCrossAlignment.center,
//                   children: [
//                     _badge(order.orderId),
//                     if (order.orderType == 'DINE_IN') ...[
//                       _dot(subTextColor),
//                       Text(
//                         order.tableName.toUpperCase(),
//                         style: TextStyle(
//                           color: textColor,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                     if (order.guestName.isNotEmpty) ...[
//                       _dot(subTextColor),
//                       Text(
//                         order.guestName.toUpperCase(),
//                         style: TextStyle(
//                           color: textColor,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                     if (order.guestPhoneNumber.isNotEmpty) ...[
//                       _dot(subTextColor),
//                       Text(
//                         '#${order.guestPhoneNumber.replaceAll("+", "")}',
//                         style: TextStyle(color: subTextColor, fontSize: 14),
//                       ),
//                     ],
//                     _dot(subTextColor),
//                     Text(
//                       DateFormat(
//                         'MMM dd, hh:mm a',
//                       ).format(order.createdAt!.toTimeZone()),
//                       style: TextStyle(color: subTextColor, fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Text(
//                 '\$${order.totalOrderAmount.toStringAsFixed(2)}',
//                 style: TextStyle(
//                   color: textColor,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(width: 14),
//               _addButton(),
//             ],
//           ),
//           if (order.carts.isNotEmpty)
//             Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 10),
//                     child: Wrap(
//                       spacing: 6,
//                       runSpacing: 6,
//                       children: order.carts
//                           .map(
//                             (cart) => Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: StaticColors.blueColor.withAlpha(
//                                   isLight ? 20 : 30,
//                                 ),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(
//                                     '${cart.quantity}x',
//                                     style: const TextStyle(
//                                       color: Color(0xFF3BB2F6),
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 5),
//                                   Text(
//                                     cart.name,
//                                     style: TextStyle(
//                                       color: textColor,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )
//                           .toList(),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   child: Row(
//                     children: [
//                       _badge(
//                         color: Colors.white,
//                         bgColor: StaticColors.blueColor,
//                         MyFunc.orderType(order),
//                       ),
//                       const SizedBox(width: 6),
//                       _badge(MyFunc.modifyOrderStatus(order.orderStatus)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _badge(String label, {Color? color, bgColor}) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//     decoration: BoxDecoration(
//       color: bgColor ?? StaticColors.blueColor.withAlpha(38),
//       borderRadius: BorderRadius.circular(8),
//     ),
//     child: Text(
//       label,
//       style: TextStyle(
//         color: color ?? StaticColors.blueColor,
//         fontSize: 14,
//         fontWeight: FontWeight.w700,
//       ),
//     ),
//   );

//   Widget _dot(Color color) => Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 2),
//     child: CircleAvatar(radius: 2.5, backgroundColor: color),
//   );

//   Widget _addButton() => Material(
//     color: Colors.transparent,
//     child: InkWell(
//       onTap: onAdd,
//       borderRadius: BorderRadius.circular(10),
//       child: Ink(
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [StaticColors.blueColor, Color(0xFF6366F1)],
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.replay_rounded, color: Colors.white, size: 18),
//               SizedBox(width: 6),
//               Text(
//                 'Repeat Order',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
