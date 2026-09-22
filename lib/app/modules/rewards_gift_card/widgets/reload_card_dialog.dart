import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/controller/gift_card_controller.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/gift_card_result_dialog.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/loader.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/swipe_scan_detector.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

class ReloadInput {
  final String cardNumber;
  final double amount;
  const ReloadInput({required this.cardNumber, required this.amount});
}

Future<ReloadInput?> showReloadCardDialog(
  BuildContext context, {
  String? initialCardNumber,
  String? initialAmount,
}) {
  return showDialog<ReloadInput>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => ReloadCardDialog(
      initialCardNumber: initialCardNumber,
      initialAmount: initialAmount,
    ),
  );
}

class ReloadCardDialog extends StatefulWidget {
  const ReloadCardDialog({
    super.key,
    this.initialCardNumber,
    this.initialAmount,
  });

  final String? initialCardNumber;
  final String? initialAmount;

  @override
  State<ReloadCardDialog> createState() => _ReloadCardDialogState();
}

class _ReloadCardDialogState extends State<ReloadCardDialog> {
  late final TextEditingController _cardCtrl;
  late final TextEditingController _amountCtrl;

  final GlobalKey<SwipeScanDetectorState> _detectorKey =
      GlobalKey<SwipeScanDetectorState>();
  final FocusNode _cardFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();

  final RewardsGiftCardController _ctrl = Get.isRegistered<RewardsGiftCardController>()
      ? Get.find<RewardsGiftCardController>()
      : Get.put(RewardsGiftCardController());

  bool _checking = false;

  // ---- Theme-driven palette (build() e set) ----
  late Color _dialogBg;
  late Color _fieldBg;
  late Color _borderColor;
  late Color _hintColor;
  late Color _textColor;

  @override
  void initState() {
    super.initState();
    _cardCtrl = TextEditingController(text: widget.initialCardNumber);
    _amountCtrl = TextEditingController(text: widget.initialAmount);

    _cardFocus.addListener(_onManualFocusChange);
    _amountFocus.addListener(_onManualFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _cardFocus.requestFocus();
      });
    });
  }

  void _onManualFocusChange() {
    final anyFocused = _cardFocus.hasFocus || _amountFocus.hasFocus;
    if (anyFocused) {
      _detectorKey.currentState?.pause();
    } else {
      _detectorKey.currentState?.resume();
    }
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _amountCtrl.dispose();
    _cardFocus.dispose();
    _amountFocus.dispose();
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

  Future<void> _proceed() async {
    if (_checking) return;

    final rawCard = _cardCtrl.text.trim();
    final rawAmount = _amountCtrl.text.trim();
    final cardNumber = rawCard.replaceAll(RegExp(r'\D'), '');
    final amount = double.tryParse(rawAmount);

    if (rawCard.isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Card Number',
      );
      if (mounted) _cardFocus.requestFocus();
      return;
    }
    final cardDigits = _cardCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (cardDigits.length < 19 || cardDigits.length > 21) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Card Number Must Be 19 To 21 Digits',
      );
      if (mounted) _cardFocus.requestFocus();
      return;
    }

    if (rawAmount.isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter An Amount',
      );
      if (mounted) _amountFocus.requestFocus();
      return;
    }
    if (amount == null || amount <= 0) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Valid Amount',
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

    _checking = true;
    showAppLoader();
    final check = await _ctrl.checkReload(cardNumber);
    hideAppLoader();
    _checking = false;
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

    if (!mounted) return;
    Navigator.of(
      context,
    ).pop(ReloadInput(cardNumber: cardNumber, amount: amount));
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
      insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                    onPressed: _checking
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
                        autofocus: true,
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
                    SizedBox(width: 28),
                    Expanded(
                      flex: 2,
                      child: _LabeledField(
                        label: 'Amount *',
                        controller: _amountCtrl,
                        focusNode: _amountFocus,
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
                      onPressed: _checking ? null : () => _proceed(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StaticColors.greenColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: StaticColors.greenColor
                            .withOpacity(0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _checking
                          ? SizedBox(
                              width: 28,
                              height: 28,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Reload',
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
    return pattern.hasMatch(text) ? newValue : oldValue;
  }
}

/// Label + theme-driven bordered field.
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.fieldBg,
    required this.borderColor,
    required this.hintColor,
    required this.textColor,
    this.keyboardType,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
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
  final bool autofocus;

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
              fontSize: 35,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(height: 14),
        TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
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
            contentPadding: EdgeInsets.symmetric(
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

class CardNumberInputFormatter extends TextInputFormatter {
  final int groupSize;
  final String separator;
  final int? maxDigits;

  CardNumberInputFormatter({
    this.groupSize = 4,
    this.separator = '-',
    this.maxDigits,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (maxDigits != null && digits.length > maxDigits!) {
      digits = digits.substring(0, maxDigits!);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i != 0 && i % groupSize == 0) buffer.write(separator);
      buffer.write(digits[i]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
