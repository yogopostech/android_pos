import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/controller/gift_card_controller.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/models/bulk_activate_model.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/gift_card_result_dialog.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/loader.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/swipe_scan_detector.dart';
import 'package:yogo_pos/app/utils/extension/string_extensions.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

/// Redeem dialog. Card number + amount, scan-supported (card field auto-focus).
/// Returns true if a redeem succeeded (so the screen can refresh), else null.
Future<bool?> showRedeemCardDialog(
  BuildContext context, {
  String? initialCardNumber,
  String? initialAmount,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => RedeemCardDialog(
      initialCardNumber: initialCardNumber,
      initialAmount: initialAmount,
    ),
  );
}

class RedeemCardDialog extends StatefulWidget {
  const RedeemCardDialog({
    super.key,
    this.initialCardNumber,
    this.initialAmount,
  });

  final String? initialCardNumber;
  final String? initialAmount;

  @override
  State<RedeemCardDialog> createState() => _RedeemCardDialogState();
}

class _RedeemCardDialogState extends State<RedeemCardDialog> {
  late final TextEditingController _cardCtrl;
  late final TextEditingController _amountCtrl;
  final FocusNode _cardFocus = FocusNode();

  final RewardsGiftCardController _ctrl = Get.isRegistered<RewardsGiftCardController>()
      ? Get.find<RewardsGiftCardController>()
      : Get.put(RewardsGiftCardController());

  bool _submitting = false;

  static const Color _dialogBg = StaticColors.blackLightColor;
  static const Color _fieldBg = StaticColors.cartColor;
  static const Color _borderColor = Color(0xff4A4A4A);
  static const Color _hintColor = Color(0xff8A8A8A);

  @override
  void initState() {
    super.initState();
    _cardCtrl = TextEditingController(text: widget.initialCardNumber);
    _amountCtrl = TextEditingController(text: widget.initialAmount);

    // Dialog khulei card field e focus -> scan shorasori ei field e jabe.
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
    _cardFocus.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    if (_submitting) return;

    final card = _cardCtrl.text.trim();
    final cardDigits = card.replaceAll(RegExp(r'\D'), '');
    final rawAmount = _amountCtrl.text.trim();
    final amount = double.tryParse(rawAmount);

    // ---- Card Number ----
    if (card.isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Card Number',
      );
      return;
    }
    // if (cardDigits.length < 4) {
    //   await showGiftCardResultDialog(
    //     context,
    //     success: false,
    //     message: 'Please Enter A Valid Card Number',
    //   );
    //   return;
    // }
    // final cardDigits = _cardCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (cardDigits.length < 19 || cardDigits.length > 21) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Card Number Must Be 19 To 21 Digits',
      );
      return;
    }

    // ---- Amount ----
    if (rawAmount.isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter An Amount',
      );
      return;
    }
    if (amount == null || amount <= 0) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Valid Amount',
      );
      return;
    }

    setState(() => _submitting = true);
    showAppLoader();

    // orderId dialog-e nai -> controller ekta default banabe.
    final res = await _ctrl.redeem(cardNumber: card, amountText: rawAmount);

    hideAppLoader();
    if (!mounted) return;
    setState(() => _submitting = false);

    if (res != null) {
      await showGiftCardResultDialog(
        context,
        success: true,
        message: res.message.isNotEmpty
            ? res.message.titleCase
            : 'Redeemed Successfully',
      );
      if (mounted) Navigator.of(context).pop(true); // close + refresh signal
    } else {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: _ctrl.errorMessage.value ?? 'Redeem Failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  icon: const Icon(Icons.close, color: Colors.white, size: 55),
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
                    ),
                  ),
                  SizedBox(width: 28),
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
                        // BlockFastInputFormatter(),
                        DecimalTextInputFormatter(decimalRange: 2),
                        LengthLimitingTextInputFormatter(9),
                      ],
                      fieldBg: _fieldBg,
                      borderColor: _borderColor,
                      hintColor: _hintColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Center(
                child: SizedBox(
                  width: 220,
                  height: 92,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _redeem,
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
                    child: _submitting
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
                            'Redeem',
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
    );
  }
}

/// Amount formatter — numbers + one dot, max [decimalRange] digits after dot.
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

/// Label + dark bordered field (scan-focus supported).
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.fieldBg,
    required this.borderColor,
    required this.hintColor,
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
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
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
              color: Colors.white,
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            letterSpacing: 1.5,
          ),
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
