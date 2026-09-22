

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/controller/gift_card_controller.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/models/bulk_activate_model.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/activate_all_payment_flow.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/card_activate_dialog.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/gift_card_result_dialog.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/loader.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/swipe_scan_detector.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';


/// Multiple activate dialog open kore.
Future<void> showMultipleActivateCardDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => const MultipleActivateCardDialog(),
  );
}

/// Ekta staged card — list e boshe thake, tarpor ek shathe activate hoy.
class _StagedCard {
  _StagedCard({
    required this.cardNumber,
    required this.amount,
    required this.name,
    required this.phone,
    this.status = 'staged',
    this.error,
  });

  final String cardNumber;
  final double amount;
  final String name;
  final String phone;
  String status;
  String? error;
}

class MultipleActivateCardDialog extends StatefulWidget {
  const MultipleActivateCardDialog({super.key});

  @override
  State<MultipleActivateCardDialog> createState() =>
      _MultipleActivateCardDialogState();
}

class _MultipleActivateCardDialogState
    extends State<MultipleActivateCardDialog> {
  final _cardCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cardFocus = FocusNode();
  final _amountFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  final GlobalKey<SwipeScanDetectorState> _detectorKey =
      GlobalKey<SwipeScanDetectorState>();

  final List<_StagedCard> _cards = [];
  bool _activating = false;

  final RewardsGiftCardController _ctrl = Get.isRegistered<RewardsGiftCardController>()
      ? Get.find<RewardsGiftCardController>()
      : Get.put(RewardsGiftCardController());

  // ---- Theme-driven palette (build() e set hoy) ----
  late Color _dialogBg;
  late Color _fieldBg;
  late Color _panelBg;
  late Color _borderColor;
  late Color _hintColor;
  late Color _textColor;

  double get _total => _cards
      .where((c) => c.status != 'failed')
      .fold(0.0, (sum, c) => sum + c.amount);

  int get _activatableCount => _cards.where((c) => c.status != 'failed').length;

  int get _activatedCount =>
      _cards.where((c) => c.status == 'activated').length;

  void _onManualFocusChange() {
    final anyFocused = _cardFocus.hasFocus || _amountFocus.hasFocus;
    if (anyFocused) {
      _detectorKey.currentState?.pause();
    } else {
      _detectorKey.currentState?.resume();
    }
  }

  @override
  void initState() {
    super.initState();
    _cardFocus.addListener(_onManualFocusChange);
    _amountFocus.addListener(_onManualFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _cardFocus.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cardFocus.dispose();
    _amountFocus.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  // ---- Draft ke list e add ----
  Future<void> _addToList() async {
    if (_activating) return;

    final card = _cardCtrl.text.trim();
    final cardDigits = card.replaceAll(RegExp(r'\D'), '');
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (card.isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Card Number',
      );
      if (mounted) _cardFocus.requestFocus();
      return;
    }
    if (cardDigits.length < 19 || cardDigits.length > 21) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Card Number Must Be 19 To 21 Digits',
      );
      if (mounted) _cardFocus.requestFocus();
      return;
    }

    if (_amountCtrl.text.trim().isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter An Amount',
      );
      if (mounted) _amountFocus.requestFocus();
      return;
    }
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Valid Amount',
      );
      if (mounted) _amountFocus.requestFocus();
      return;
    }
    if (amount < 5) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Amount Must Be At Least \$5',
      );
      if (mounted) _amountFocus.requestFocus();
      return;
    }
    if (amount > 500) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Amount Cannot Be More Than 500',
      );
      if (mounted) _amountFocus.requestFocus();
      return;
    }

    if (name.isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Name',
      );
      if (mounted) _nameFocus.requestFocus();
      return;
    }
    if (name.length < 2) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Name Must Be At Least 2 Characters',
      );
      if (mounted) _nameFocus.requestFocus();
      return;
    }
    if (name.length > 50) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: "Please enter a valid name",
      );
      if (mounted) _nameFocus.requestFocus();
      return;
    }

    if (phone.isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Phone Number',
      );
      if (mounted) _phoneFocus.requestFocus();
      return;
    }
    if (!isValidCanadaPhone(phone)) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Valid Phone Number',
      );
      if (mounted) _phoneFocus.requestFocus();
      return;
    }

    final dup = _cards.any(
      (c) => c.cardNumber.replaceAll(RegExp(r'\D'), '') == cardDigits,
    );
    if (dup) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'This Card Is Already Added',
      );
      if (mounted) _cardFocus.requestFocus();
      return;
    }

    showAppLoader();
    final check = await _ctrl.checkActivation(card);
    hideAppLoader();
    if (!mounted) return;

    if (check == null) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: _ctrl.errorMessage.value ?? 'Could Not Verify Card',
      );
      return;
    }

    if (!check.status) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: check.message.isNotEmpty ? check.message : 'Card Not Eligible',
      );
      return;
    }

    setState(() {
      _cards.add(
        _StagedCard(cardNumber: card, amount: amount, name: name, phone: phone),
      );
      _cardCtrl.clear();
      _amountCtrl.clear();
      _nameCtrl.clear();
      _phoneCtrl.clear();
    });

    _detectorKey.currentState?.resume();
  }

  void _repeatLast() {
    if (_activating || _cards.isEmpty) return;
    final last = _cards.last;

    setState(() {
      _amountCtrl.text = last.amount.toStringAsFixed(2);
      _nameCtrl.text = last.name;
      _phoneCtrl.text = last.phone;
    });

    if (_cardCtrl.text.trim().isEmpty) {
      _cardFocus.requestFocus();
    } else {
      _amountFocus.requestFocus();
    }
  }

  void _removeCard(int i) {
    if (_activating) return;
    setState(() => _cards.removeAt(i));
  }

  Future<void> _activateOne(_StagedCard c) async {
    setState(() {
      c.status = 'processing';
      c.error = null;
    });

    final res = await _ctrl.activate(
      cardNumber: c.cardNumber,
      amountText: c.amount.toStringAsFixed(2),
      name: c.name,
      phone: c.phone,
    );

    if (!mounted) return;
    setState(() {
      if (res != null) {
        c.status = 'activated';
      } else {
        c.status = 'failed';
        c.error = _ctrl.errorMessage.value ?? 'Activation Failed';
      }
    });
  }

  Future<void> _activateAll() async {
    if (_activating || _cards.isEmpty) return;

    final pending = _cards.where((c) => c.status != 'activated').toList();
    if (pending.isEmpty) return;

    final selection = await showActivateAllPaymentFlow(context, total: _total);
    if (selection == null) return;
    if (!mounted) return;

    final cardsInput = pending.map((c) {
      final amt = c.amount;
      return BulkCardInput(
        cardNumber: c.cardNumber.replaceAll(RegExp(r'\D'), ''),
        initialAmount: amt % 1 == 0 ? amt.toInt() : amt,
        name: c.name,
        phone: c.phone.replaceAll(RegExp(r'\D'), ''),
        source: _sourceFor(selection),
        currency: 'CAD',
      );
    }).toList();

    setState(() {
      _activating = true;
      for (final c in pending) {
        c.status = 'processing';
        c.error = null;
      }
    });

    showAppLoader();
    final res = await _ctrl.activateBulk(
      cards: cardsInput,
      payments: selection.payments,
    );
    hideAppLoader();
    if (!mounted) return;

    setState(() {
      if (res != null && res.success) {
        final okDigits =
            res.data?.cards
                .map((e) => (e.cardNumber ?? '').replaceAll(RegExp(r'\D'), ''))
                .where((e) => e.isNotEmpty)
                .toSet() ??
            <String>{};
        for (final c in pending) {
          final d = c.cardNumber.replaceAll(RegExp(r'\D'), '');
          c.status = (okDigits.isEmpty || okDigits.contains(d))
              ? 'activated'
              : 'failed';
          if (c.status == 'failed') c.error = 'Not Activated';
        }
      } else {
        for (final c in pending) {
          c.status = 'failed';
          c.error = _ctrl.errorMessage.value ?? 'Activation Failed';
        }
      }
      _activating = false;
    });

    final success = res != null && res.success;
    await showGiftCardResultDialog(
      context,
      success: success,
      message: success
          ? (res!.message.isNotEmpty
                ? res.message
                : 'Cards Activated Successfully')
          : (_ctrl.errorMessage.value ?? 'Activation Failed'),
    );
  }

  Future<void> _confirmClose() async {
    if (_activating) return;

    if (_cards.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final leave = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
            decoration: BoxDecoration(
              color: _dialogBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderColor, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Exit this page?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to leave this page?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _hintColor, fontSize: 22),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 80,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: StaticColors.blueColor,
                            side: BorderSide(color: _borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'No',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 80,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StaticColors.blueColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (leave == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  String _sourceFor(PaymentSelection s) {
    final first = s.payments.isNotEmpty
        ? s.payments.first.methods.toUpperCase()
        : 'CASH';
    return _methodToSource(first);
  }

  String _methodToSource(String m) {
    switch (m.toUpperCase()) {
      case 'CASH':
        return 'Cash';
      case 'VISA':
        return 'Visa';
      case 'MASTERCARD':
        return 'MasterCard';
      case 'AMEX':
        return 'Amex';
      case 'DEBIT CARD':
      case 'DEBIT_CARD':
        return 'Interac';
      case 'OTHERS':
        return 'Cash';
      default:
        return 'Cash';
    }
  }

  Future<void> _retryOne(int i) async {
    if (_activating) return;
    setState(() => _activating = true);
    await _activateOne(_cards[i]);
    if (!mounted) return;
    setState(() => _activating = false);
  }

  @override
  Widget build(BuildContext context) {
    // ---- Theme colors ----
    final theme = Theme.of(context);
    _dialogBg = theme.canvasColor;
    _fieldBg = theme.cardColor;
    _panelBg = theme.cardColor;
    _borderColor = theme.hintColor;
    _hintColor = theme.hintColor;
    _textColor = theme.colorScheme.surface;

    void fillCard(String rawDigits) {
      final digits = rawDigits.replaceAll(RegExp(r'\D'), '');
      final formatted = CardNumberInputFormatter(maxDigits: 21)
          .formatEditUpdate(
            const TextEditingValue(text: ''),
            TextEditingValue(
              text: digits,
              selection: TextSelection.collapsed(offset: digits.length),
            ),
          );
      _cardCtrl.value = formatted;
    }

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: _dialogBg,
        child: SwipeScanDetector(
          key: _detectorKey,
          onDetected: (result) {
            fillCard(result.cardNumber);
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(36, 20, 36, 28),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Row(
                      children: [
                        Text(
                          'Activate Gift Cards',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _activating ? null : _confirmClose,
                          splashRadius: 22,
                          icon: Icon(Icons.close, color: _textColor, size: 48),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _panelBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _borderColor, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: _MField(
                                label: 'Card Number *',
                                controller: _cardCtrl,
                                focusNode: _cardFocus,
                                hint: 'Type / Scan / Swipe',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  CardNumberInputFormatter(maxDigits: 21),
                                ],
                                fieldBg: _fieldBg,
                                borderColor: _borderColor,
                                hintColor: _hintColor,
                                textColor: _textColor,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: _MField(
                                label: 'Amount *',
                                controller: _amountCtrl,
                                hint: 'Amount',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  ScanRedirectFormatter(
                                    threshold: 15,
                                    onScanned: (digits) {
                                      fillCard(digits);
                                      _cardFocus.requestFocus();
                                    },
                                  ),
                                  DecimalTextInputFormatter(decimalRange: 2),
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                focusNode: _amountFocus,
                                fieldBg: _fieldBg,
                                borderColor: _borderColor,
                                hintColor: _hintColor,
                                textColor: _textColor,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 3,
                              child: _MField(
                                label: 'Full Name *',
                                controller: _nameCtrl,
                                focusNode: _nameFocus,
                                hint: 'Full Name',
                                inputFormatters: [
                                  ScanRedirectFormatter(
                                    threshold: 15,
                                    onScanned: (digits) {
                                      fillCard(digits);
                                      _cardFocus.requestFocus();
                                    },
                                  ),
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                fieldBg: _fieldBg,
                                borderColor: _borderColor,
                                hintColor: _hintColor,
                                textColor: _textColor,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 3,
                              child: _MField(
                                label: 'Phone Number *',
                                controller: _phoneCtrl,
                                focusNode: _phoneFocus,
                                hint: 'Phone Number',
                                inputFormatters: [
                                  ScanRedirectFormatter(
                                    threshold: 15,
                                    onScanned: (digits) {
                                      fillCard(digits);
                                      _cardFocus.requestFocus();
                                    },
                                  ),
                                  CanadaPhoneInputFormatter(),
                                ],
                                onSubmitted: (_) => _addToList(),
                                fieldBg: _fieldBg,
                                borderColor: _borderColor,
                                hintColor: _hintColor,
                                textColor: _textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _activating ? null : _addToList,
                              icon: const Icon(
                                Icons.add,
                                size: 28,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Add to list',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: StaticColors.blueColor,
                                side: BorderSide(color: _borderColor, width: 1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              onPressed: (_activating || _cards.isEmpty)
                                  ? null
                                  : _repeatLast,
                              icon: Icon(
                                Icons.repeat,
                                size: 28,
                                color: _cards.isEmpty ? _hintColor : _textColor,
                              ),
                              label: Text(
                                'Duplicate',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: _cards.isEmpty
                                      ? _hintColor
                                      : _textColor,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _fieldBg,
                                side: BorderSide(color: _borderColor, width: 1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _borderColor, width: 1),
                      ),
                      child: _cards.isEmpty
                          ? Center(
                              child: Text(
                                'No cards added yet',
                                style: TextStyle(
                                  color: _hintColor,
                                  fontSize: 24,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: _cards.length,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 1, color: _borderColor),
                              itemBuilder: (_, i) => _cardRow(_cards[i], i),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _panelBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$_activatableCount Gift cards',
                          style: TextStyle(color: _hintColor, fontSize: 24),
                        ),
                        const Spacer(),
                        Text(
                          '\$${_total.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 92,
                    child: ElevatedButton(
                      onPressed: (_activating || _cards.isEmpty)
                          ? null
                          : _activateAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StaticColors.greenColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: StaticColors.greenColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _activating
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              _activatedCount > 0 &&
                                      _activatedCount == _cards.length
                                  ? 'All Activated ($_activatedCount)'
                                  : 'Activate All Cards',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardRow(_StagedCard c, int i) {
    final digits = c.cardNumber.replaceAll(RegExp(r'\D'), '');
    final masked = digits.length > 4
        ? '•••• ${digits.substring(digits.length - 4)}'
        : digits;

    Widget trailing;
    switch (c.status) {
      case 'activated':
        trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'activated',
              style: TextStyle(color: StaticColors.greenColor, fontSize: 22),
            ),
            const SizedBox(width: 8),
            Icon(Icons.check_circle, color: StaticColors.greenColor, size: 30),
          ],
        );
        break;
      case 'processing':
        trailing = SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(StaticColors.orangeColor),
          ),
        );
        break;
      case 'failed':
        trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'failed',
              style: TextStyle(color: const Color(0xffFF6B6B), fontSize: 22),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: _activating ? null : () => _retryOne(i),
              style: TextButton.styleFrom(
                foregroundColor: StaticColors.orangeColor,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 22)),
            ),
          ],
        );
        break;
      default:
        trailing = IconButton(
          onPressed: _activating ? null : () => _removeCard(i),
          splashRadius: 20,
          icon: Icon(Icons.close, color: _hintColor, size: 30),
        );
    }

    final rowContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$masked   ·   \$${c.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 24,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${c.name} · ${c.phone}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _hintColor, fontSize: 20),
                ),
                if (c.status == 'failed' && c.error != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    c.error!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xffFF6B6B),
                      fontSize: 18,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );

    if (c.status == 'failed' && !_activating) {
      return Slidable(
        key: ValueKey('failed_${c.cardNumber}_$i'),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.22,
          children: [
            CustomSlidableAction(
              onPressed: (_) => _removeCard(i),
              backgroundColor: const Color(0xffB3261E),
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.delete, size: 40),
                  SizedBox(height: 6),
                  Text(
                    'Delete',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        child: rowContent,
      );
    }

    return rowContent;
  }
}

/// Compact labeled field — theme-driven.
class _MField extends StatelessWidget {
  const _MField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.fieldBg,
    required this.borderColor,
    required this.hintColor,
    required this.textColor,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final Color fieldBg;
  final Color borderColor;
  final Color hintColor;
  final Color textColor;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 25,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onSubmitted: onSubmitted,
          textInputAction: onSubmitted != null
              ? TextInputAction.done
              : TextInputAction.next,
          cursorColor: StaticColors.orangeColor,
          style: TextStyle(color: textColor, fontSize: 28, letterSpacing: 1.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: hintColor,
              fontSize: 25,
              letterSpacing: 1.5,
            ),
            filled: true,
            fillColor: fieldBg,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 25,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: StaticColors.orangeColor,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
