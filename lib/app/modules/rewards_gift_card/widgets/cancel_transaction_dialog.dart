import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/controller/gift_card_controller.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/card_activate_dialog.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/gift_card_result_dialog.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/swipe_scan_detector.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

class CancelTransactionResult {
  final String cardNumber;
  final String amount;
  final String tcnNo;
  final String invoiceNo;

  const CancelTransactionResult({
    required this.cardNumber,
    required this.amount,
    required this.tcnNo,
    required this.invoiceNo,
  });
}

Future<CancelTransactionResult?> showCancelTransactionDialog(
  BuildContext context, {
  String? initialCardNumber,
  String? initialAmount,
  String? initialTcnNo,
  String? initialInvoiceNo,
}) {
  return showDialog<CancelTransactionResult>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => CancelTransactionDialog(
      initialCardNumber: initialCardNumber,
      initialAmount: initialAmount,
      initialTcnNo: initialTcnNo,
      initialInvoiceNo: initialInvoiceNo,
    ),
  );
}

class CancelTransactionDialog extends StatefulWidget {
  const CancelTransactionDialog({
    super.key,
    this.initialCardNumber,
    this.initialAmount,
    this.initialTcnNo,
    this.initialInvoiceNo,
  });

  final String? initialCardNumber;
  final String? initialAmount;
  final String? initialTcnNo;
  final String? initialInvoiceNo;

  @override
  State<CancelTransactionDialog> createState() =>
      _CancelTransactionDialogState();
}

class _CancelTransactionDialogState extends State<CancelTransactionDialog> {
  late final TextEditingController _cardCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _tcnCtrl;
  late final TextEditingController _invoiceCtrl;
  Timer? _amountScanTimer;

  final RewardsGiftCardController _gc = Get.isRegistered<RewardsGiftCardController>()
      ? Get.find<RewardsGiftCardController>()
      : Get.put(RewardsGiftCardController());

  bool _submitting = false;

  // ---- Theme-driven palette (build() e set) ----
  late Color _dialogBg;
  late Color _fieldBg;
  late Color _borderColor;
  late Color _hintColor;
  late Color _textColor;
  static const Color _accent = StaticColors.orangeColor;

  final GlobalKey<SwipeScanDetectorState> _detectorKey =
      GlobalKey<SwipeScanDetectorState>();
  final FocusNode _cardFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();
  final FocusNode _txnFocus = FocusNode();
  final FocusNode _invFocus = FocusNode();

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
    _cardCtrl = TextEditingController(text: widget.initialCardNumber);
    _amountCtrl = TextEditingController(text: widget.initialAmount);
    _tcnCtrl = TextEditingController(text: widget.initialTcnNo);
    _invoiceCtrl = TextEditingController(text: widget.initialInvoiceNo);

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
    _tcnCtrl.dispose();
    _invoiceCtrl.dispose();
    _cardFocus.dispose();
    _amountFocus.dispose();
    _amountScanTimer?.cancel();
    _txnFocus.dispose();
    _invFocus.dispose();
    super.dispose();
  }

  void _fillCard(String rawDigits) {
    final digits = rawDigits.replaceAll(RegExp(r'\D'), '');
    final formatted = CardNumberInputFormatter(maxDigits: 21).formatEditUpdate(
      const TextEditingValue(text: ''),
      TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      ),
    );
    _cardCtrl.value = formatted;
  }

  String _titleCase(String input) => input
      .trim()
      .split(RegExp(r'\s+'))
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  Future<void> _submit() async {
    if (_submitting) return;

    final cardNumber = _cardCtrl.text.replaceAll(RegExp(r'\D'), '');
    final amount = _amountCtrl.text.trim();
    final tcn = _tcnCtrl.text.trim();
    final invoice = _invoiceCtrl.text.trim();

    if (cardNumber.isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Card Number',
      );
      if (mounted) _cardFocus.requestFocus();
      return;
    }
    if (cardNumber.length < 19 || cardNumber.length > 21) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Card Number Must Be 19 To 21 Digits',
      );
      if (mounted) _cardFocus.requestFocus();
      return;
    }

    if (amount.isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter An Amount',
      );
      if (mounted) _amountFocus.requestFocus();
      return;
    }
    final amountVal = double.tryParse(amount);
    if (amountVal == null || amountVal <= 0) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Valid Amount',
      );
      if (mounted) _amountFocus.requestFocus();
      return;
    }
    if (amountVal > 500) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Amount Cannot Be More Than 500',
      );
      if (mounted) _amountFocus.requestFocus();
      return;
    }

    if (tcn.isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A TCN No.',
      );
      if (mounted) _txnFocus.requestFocus();
      return;
    }

    if (invoice.isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter An Invoice No.',
      );
      if (mounted) _invFocus.requestFocus();
      return;
    }

    setState(() => _submitting = true);

    try {
      final res = await _gc.reverse(
        cardNumber: cardNumber,
        tcn: tcn,
        invoiceNumber: invoice,
        amountText: amount,
      );

      if (!mounted) return;
      setState(() => _submitting = false);

      if (res != null && res.success) {
        await showGiftCardResultDialog(
          context,
          success: true,
          message: _titleCase(res.message),
        );
        if (!mounted) return;
        Navigator.of(context).pop(
          CancelTransactionResult(
            cardNumber: cardNumber,
            amount: amount,
            tcnNo: tcn,
            invoiceNo: invoice,
          ),
        );
      } else {
        await showGiftCardResultDialog(
          context,
          success: false,
          message: _titleCase(_gc.errorMessage.value ?? 'Reversal Failed'),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _dialogBg = theme.canvasColor;
    _fieldBg = theme.cardColor;
    _borderColor = theme.hintColor;
    _hintColor = theme.hintColor;
    _textColor = theme.colorScheme.surface;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050),
        child: Container(
          padding: const EdgeInsets.fromLTRB(36, 24, 36, 36),
          decoration: BoxDecoration(
            color: _dialogBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: SwipeScanDetector(
            key: _detectorKey,
            onDetected: (result) {
              _fillCard(result.cardNumber);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    splashRadius: 22,
                    icon: Icon(Icons.close, color: _textColor, size: 55),
                  ),
                ),
                const SizedBox(height: 4),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _LabeledField(
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
                    const SizedBox(width: 28),
                    Expanded(
                      flex: 2,
                      child: _LabeledField(
                        label: 'Amount *',
                        controller: _amountCtrl,
                        hint: 'Amount',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          ScanRedirectFormatter(
                            threshold: 15,
                            onScanned: (digits) {
                              _fillCard(digits);
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
                  ],
                ),
                const SizedBox(height: 28),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _LabeledField(
                        label: 'TXN Number *',
                        controller: _tcnCtrl,
                        focusNode: _txnFocus,
                        hint: 'TXN Number',
                        inputFormatters: [
                          ScanRedirectFormatter(
                            threshold: 15,
                            onScanned: (digits) {
                              _fillCard(digits);
                              _cardFocus.requestFocus();
                            },
                          ),
                          LengthLimitingTextInputFormatter(15),
                        ],
                        fieldBg: _fieldBg,
                        borderColor: _borderColor,
                        hintColor: _hintColor,
                        textColor: _textColor,
                      ),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: _LabeledField(
                        label: 'Invoice Number *',
                        focusNode: _invFocus,
                        inputFormatters: [
                          ScanRedirectFormatter(
                            threshold: 15,
                            onScanned: (digits) {
                              _fillCard(digits);
                              _cardFocus.requestFocus();
                            },
                          ),
                          LengthLimitingTextInputFormatter(15),
                        ],
                        controller: _invoiceCtrl,
                        hint: 'Invoice Number',
                        fieldBg: _fieldBg,
                        borderColor: _borderColor,
                        hintColor: _hintColor,
                        textColor: _textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                Center(
                  child: SizedBox(
                    width: 200,
                    height: 92,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 34,
                              height: 34,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Cancell',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 29,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({this.decimalRange = 2})
    : assert(decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final pattern = RegExp('^\\d+(\\.\\d{0,$decimalRange})?\$');
    if (pattern.hasMatch(text)) return newValue;
    return oldValue;
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 35,
              fontWeight: FontWeight.w500,
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
          cursorColor: StaticColors.orangeColor,
          style: TextStyle(color: textColor, fontSize: 28, letterSpacing: 1.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: hintColor,
              fontSize: 28,
              letterSpacing: 1.5,
            ),
            filled: true,
            fillColor: fieldBg,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 28,
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
