
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/controller/gift_card_controller.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/card_activate_dialog.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/giftcard_balance_dialog.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/loader.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/swipe_scan_detector.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'gift_card_result_dialog.dart';

Future<String?> showCheckBalanceDialog(
  BuildContext context, {
  String? initialCardNumber,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => CheckBalanceDialog(initialCardNumber: initialCardNumber),
  );
}

class CheckBalanceDialog extends StatefulWidget {
  const CheckBalanceDialog({super.key, this.initialCardNumber});

  final String? initialCardNumber;

  @override
  State<CheckBalanceDialog> createState() => _CheckBalanceDialogState();
}

class _CheckBalanceDialogState extends State<CheckBalanceDialog> {
  late final TextEditingController _cardCtrl;

  final GlobalKey<SwipeScanDetectorState> _detectorKey =
      GlobalKey<SwipeScanDetectorState>();
  final FocusNode _cardFocus = FocusNode();

  final RewardsGiftCardController _ctrl = Get.isRegistered<RewardsGiftCardController>()
      ? Get.find<RewardsGiftCardController>()
      : Get.put(RewardsGiftCardController());

  bool _submitting = false;
  bool _scanned = false;

  // ---- Theme-driven palette (build() e set) ----
  late Color _dialogBg;
  late Color _fieldBg;
  late Color _borderColor;
  late Color _hintColor;
  late Color _textColor;
  static const Color _accent = StaticColors.orangeColor;

  @override
  void initState() {
    super.initState();
    _cardCtrl = TextEditingController(text: widget.initialCardNumber);

    _cardFocus.addListener(() {
      if (_cardFocus.hasFocus) {
        _detectorKey.currentState?.pause();
      } else {
        _detectorKey.currentState?.resume();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _cardFocus.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _cardFocus.dispose();
    super.dispose();
  }

  Future<void> _onDetected(SwipeScanResult result) async {
    final formatted = CardNumberInputFormatter(maxDigits: 21).formatEditUpdate(
      const TextEditingValue(text: ''),
      TextEditingValue(
        text: result.cardNumber,
        selection: TextSelection.collapsed(offset: result.cardNumber.length),
      ),
    );

    setState(() {
      _cardCtrl.value = formatted;
      _scanned = true;
    });
    await _submit();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final card = _cardCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (card.isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Card Number',
      );
      return;
    }

    if (card.length < 19 || card.length > 21) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Card Number Must Be 19 To 21 Digits',
      );
      return;
    }

    setState(() => _submitting = true);
    showAppLoader();

    int? cents;
    try {
      cents = await _ctrl.checkBalance(card);
    } finally {
      hideAppLoader();
      if (mounted) setState(() => _submitting = false);
    }

    if (!mounted) return;

    if (cents != null) {
      await showGiftCardBalanceDialog(context, balanceCents: cents);
      if (mounted) Navigator.of(context).pop(card);
    } else {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: _ctrl.errorMessage.value ?? 'Balance check failed',
      );
      if (mounted) {
        setState(() {
          _cardCtrl.clear();
          _scanned = false;
        });
        _detectorKey.currentState?.resume();
      }
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
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SwipeScanDetector(
        key: _detectorKey,
        onDetected: _onDetected,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
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
                    icon: Icon(Icons.close, color: _textColor, size: 55),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 22),
                  child: Text(
                    'Card Number *',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 35,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _cardCtrl,
                  focusNode: _cardFocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CardNumberInputFormatter(maxDigits: 21)],
                  cursorColor: _accent,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 28,
                    letterSpacing: 1.5,
                  ),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Type / Scan / Swipe',
                    hintStyle: TextStyle(
                      color: _hintColor,
                      fontSize: 28,
                      letterSpacing: 1.5,
                    ),
                    filled: true,
                    fillColor: _fieldBg,
                    isDense: true,
                    suffixIcon: _scanned
                        ? const Icon(
                            Icons.qr_code_scanner,
                            color: StaticColors.greenColor,
                            size: 34,
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 28,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _borderColor, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _accent, width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Center(
                  child: SizedBox(
                    width: 220,
                    height: 92,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
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
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Check\nBalance',
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
