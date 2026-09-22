import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/utils/extension/string_extensions.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/controller/gift_card_controller.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/models/gift_card_transaction.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/activate_all_payment_flow.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/cancel_transaction_dialog.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/check_balance_dialog.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/gift_card_result_dialog.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/loader.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/multiple_card_activate_dialog.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/redeem_card_dialog.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/reload_card_dialog.dart';

class GiftCardMasterScreen2 extends StatefulWidget {
  const GiftCardMasterScreen2({super.key});

  @override
  State<GiftCardMasterScreen2> createState() => _GiftCardMasterScreen2State();
}

class _GiftCardMasterScreen2State extends State<GiftCardMasterScreen2> {
  final TextEditingController _searchCtrl = TextEditingController();

  final RewardsGiftCardController _controller = Get.isRegistered<RewardsGiftCardController>()
      ? Get.find<RewardsGiftCardController>()
      : Get.put(RewardsGiftCardController());

  // ---- Theme-driven palette (build() e set) ----
  late Color _scaffoldBg;
  late Color _panelBg;
  late Color _borderColor;
  late Color _hintColor;
  late Color _fieldColor;
  late Color _textColor;

  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();

  final ScrollController _vScrollCtrl = ScrollController();
  final ScrollController _headerHCtrl = ScrollController();
  final ScrollController _bodyHCtrl = ScrollController();
  bool _syncingH = false;

  static const List<String> _columns = [
    'Date',
    'Time',
    'Name',
    'Phone No.',
    'Server',
    'Card No.',
    'Transaction Type',
    'TXN No.',
    'Invoice No.',
  ];

  static const List<int> _colFlex = [
    155,
    95,
    160,
    190,
    115,
    270,
    175,
    155,
    135,
  ];

  @override
  void initState() {
    super.initState();
    _headerHCtrl.addListener(_syncFromHeader);
    _bodyHCtrl.addListener(_syncFromBody);
  }

  void _syncFromHeader() {
    if (_syncingH || !_bodyHCtrl.hasClients) return;
    _syncingH = true;
    _bodyHCtrl.jumpTo(_headerHCtrl.offset);
    _syncingH = false;
  }

  void _syncFromBody() {
    if (_syncingH || !_headerHCtrl.hasClients) return;
    _syncingH = true;
    _headerHCtrl.jumpTo(_bodyHCtrl.offset);
    _syncingH = false;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _amountController.dispose();
    _amountFocus.dispose();
    _vScrollCtrl.dispose();
    _headerHCtrl.dispose();
    _bodyHCtrl.dispose();
    super.dispose();
  }

  String _cellValue(GiftCardTransaction t, int col) {
    switch (col) {
      case 0:
        return t.date;
      case 1:
        return t.time;
      case 2:
        return t.name;
      case 3:
        return t.phone;
      case 4:
        return t.server;
      case 5:
        return t.cardNo;
      case 6:
        return t.transactionType;
      case 7:
        return t.tcnNo;
      default:
        return t.invoiceNo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _scaffoldBg = theme.scaffoldBackgroundColor;
    _panelBg = theme.cardColor;
    _borderColor = theme.hintColor;
    _hintColor = theme.hintColor;
    _fieldColor = theme.cardColor;
    _textColor = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: _scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 28),
              _buildSearchField(),
              SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(
                    label: 'Activate',
                    color: StaticColors.greenColor,
                    onTap: () async {
                      await showMultipleActivateCardDialog(context);
                      _controller.refreshTable();
                    },
                  ),
                  _actionButton(
                    label: 'Reload',
                    color: StaticColors.greenColor,
                    onTap: () async {
                      final input = await showReloadCardDialog(context);
                      if (input == null) return;
                      if (!context.mounted) return;

                      final payment = await showActivateAllPaymentFlow(
                        context,
                        total: input.amount,
                      );
                      if (payment == null) return;
                      if (!context.mounted) return;

                      showAppLoader();
                      final result = await _controller.reload(
                        cardNumber: input.cardNumber,
                        amountText: input.amount.toStringAsFixed(2),
                        paymentSelection: payment,
                      );
                      hideAppLoader();
                      if (!context.mounted) return;

                      if (result != null) {
                        await showGiftCardResultDialog(
                          context,
                          success: true,
                          message: result.message.isNotEmpty
                              ? result.message.titleCase
                              : 'Reload Successful',
                        );
                        _controller.refreshTable();
                      } else {
                        await showGiftCardResultDialog(
                          context,
                          success: false,
                          message:
                              _controller.errorMessage.value ?? 'Reload Failed',
                        );
                      }
                    },
                  ),
                  _actionButton(
                    label: 'Cancell',
                    color: StaticColors.orangeColor,
                    onTap: () async {
                      await showCancelTransactionDialog(context);
                      _controller.refreshTable();
                    },
                  ),
                  _actionButton(
                    label: 'Check Balance',
                    color: StaticColors.greenColor,
                    onTap: () => showCheckBalanceDialog(context),
                  ),
                  _actionButton(
                    label: 'Redeem',
                    color: StaticColors.greenColor,
                    onTap: () async {
                      final ok = await showRedeemCardDialog(context);
                      if (ok == true) _controller.refreshTable();
                    },
                  ),
                ],
              ),
              SizedBox(height: 28),
              const SizedBox(height: 32),
              Expanded(child: _buildTablePanel()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1020),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => _controller.searchQuery.value = v,
          cursorColor: StaticColors.orangeColor,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textColor,
            fontSize: 34,
            letterSpacing: 2,
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(50)],
          decoration: InputDecoration(
            hintText: 'Search by Card / TCN / Invoice / Name / Phone',
            hintStyle: TextStyle(color: _hintColor, fontSize: 28),
            filled: true,
            fillColor: _panelBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: StaticColors.orangeColor,
                width: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: SizedBox(
        height: 120,
        width: 280,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onTap,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTablePanel() {
    return Container(
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(
              'Gift Card Transaction Details',
              style: TextStyle(
                color: _textColor,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Divider(height: 1, color: _borderColor),

          _buildHeaderRow(),
          Divider(height: 1, color: _borderColor),

          Expanded(
            child: Obx(() {
              final loading = _controller.isLoadingTxns.value;
              final err = _controller.txnError.value;
              final list = _controller.transactions;

              if (loading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: StaticColors.orangeColor,
                  ),
                );
              }
              if (err != null && err.isNotEmpty) {
                return Center(
                  child: Text(
                    err,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'Search by Card / TCN / Invoice / Name / Phone',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _hintColor, fontSize: 28),
                  ),
                );
              }

              return RawScrollbar(
                controller: _vScrollCtrl,
                thumbVisibility: true,
                thumbColor: _hintColor,
                trackColor: _hintColor.withOpacity(0.15),
                trackVisibility: true,
                thickness: 10,
                radius: const Radius.circular(10),
                child: SingleChildScrollView(
                  controller: _vScrollCtrl,
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [for (final txn in list) _buildDataRow(txn)],
                  ),
                ),
              );
            }),
          ),

          Divider(height: 1, color: _borderColor),
          _buildPaginationBar(),
        ],
      ),
    );
  }

  Widget _buildPaginationBar() {
    return Obx(() {
      final c = _controller;
      final hasQuery = c.searchQuery.value.trim().isNotEmpty;
      final busy = c.isLoadingTxns.value;

      if (!hasQuery || c.transactions.isEmpty) {
        return SizedBox(height: 90);
      }

      final page = c.currentPage.value;
      final size = c.pageSize.value;
      final total = c.totalItems.value;
      final shown = c.transactions.length;

      final start = ((page - 1) * size) + 1;
      final end = start + shown - 1;

      final rangeText = total > 0
          ? 'Showing $start–$end of $total'
          : 'Showing $start–$end';

      return Container(
        height: 90,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Text(
              rangeText,
              style: TextStyle(color: _hintColor, fontSize: 20),
            ),
            const Spacer(),
            _pageIconBtn(
              icon: Icons.first_page,
              enabled: c.hasPrev && !busy,
              onTap: () => c.goToPage(1),
            ),
            SizedBox(width: 12),
            _pageIconBtn(
              icon: Icons.chevron_left,
              enabled: c.hasPrev && !busy,
              onTap: c.prevPage,
            ),
            SizedBox(width: 20),
            Text(
              c.totalPages.value > 0
                  ? 'Page $page of ${c.totalPages.value}'
                  : 'Page $page',
              style: TextStyle(
                color: _textColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 20),
            _pageIconBtn(
              icon: Icons.chevron_right,
              enabled: c.hasNext && !busy,
              onTap: c.nextPage,
            ),
            SizedBox(width: 12),
            _pageIconBtn(
              icon: Icons.last_page,
              enabled: c.hasNext && !busy,
              onTap: () => c.goToPage(c.totalPages.value),
            ),
          ],
        ),
      );
    });
  }

  Widget _pageIconBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: enabled ? _fieldColor : _fieldColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled ? _borderColor : _borderColor.withOpacity(0.4),
            ),
          ),
          child: Icon(
            icon,
            size: 30,
            color: enabled ? _textColor : _hintColor.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(
          _columns.length,
          (i) => Expanded(
            flex: _colFlex[i],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                _columns[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(GiftCardTransaction txn) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor, width: 1)),
      ),
      child: Row(
        children: List.generate(
          _columns.length,
          (col) => Expanded(
            flex: _colFlex[col],
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 18),
              alignment: Alignment.center,
              child: Text(
                _cellValue(txn, col),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _textColor, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
