import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/models/Acrivate_card_model.dart';
import 'package:yogo_pos/app/utils/extension/string_extensions.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/controller/gift_card_controller.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/models/Acrivate_card_model.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/gift_card_result_dialog.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/loader.dart';
// ✅ NOTUN: multiple activate dialog
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/multiple_card_activate_dialog.dart';
  

/// Activate dialog. Activate button click korle API call hoy.
/// Success hole [ActivateCardResponse] return kore close hoy, fail hole null.
Future<ActivateCardResponse?> showActivateCardDialog(
  BuildContext context, {
  String? initialCardNumber,
  String? initialAmount,
  String? initialName,
  String? initialPhone,
}) {
  return showDialog<ActivateCardResponse>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => ActivateCardDialog(
      initialCardNumber: initialCardNumber,
      initialAmount: initialAmount,
      initialName: initialName,
      initialPhone: initialPhone,
    ),
  );
}

class ActivateCardDialog extends StatefulWidget {
  const ActivateCardDialog({
    super.key,
    this.initialCardNumber,
    this.initialAmount,
    this.initialName,
    this.initialPhone,
  });

  final String? initialCardNumber;
  final String? initialAmount;
  final String? initialName;
  final String? initialPhone;

  @override
  State<ActivateCardDialog> createState() => _ActivateCardDialogState();
}

class _ActivateCardDialogState extends State<ActivateCardDialog> {
  late final TextEditingController _cardCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  // controller — registered thakle find, na hole put
  final RewardsGiftCardController _ctrl = Get.isRegistered<RewardsGiftCardController>()
      ? Get.find<RewardsGiftCardController>()
      : Get.put(RewardsGiftCardController());

  bool _submitting = false;

  // Palette
  static const Color _dialogBg = StaticColors.blackLightColor;
  static const Color _fieldBg = StaticColors.cartColor;
  static const Color _borderColor = Color(0xff4A4A4A);
  static const Color _hintColor = Color(0xff8A8A8A);

  @override
  void initState() {
    super.initState();
    _cardCtrl = TextEditingController(text: widget.initialCardNumber);
    _amountCtrl = TextEditingController(text: widget.initialAmount);
    _nameCtrl = TextEditingController(text: widget.initialName);
    _phoneCtrl = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    // ---- Card Number: empty check ----
    if (_cardCtrl.text.trim().isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Card Number',
      );
      return;
    }

    // ---- Amount: empty + valid number + max 500 ----
    if (_amountCtrl.text.trim().isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter An Amount',
      );
      return;
    }
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Valid Amount',
      );
      return;
    }
    if (amount > 500) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Amount Cannot Be More Than 500',
      );
      return;
    }

    // ---- Name: empty check ----
    if (_nameCtrl.text.trim().isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Name',
      );
      return;
    }

    if (_nameCtrl.text.trim().length < 2) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Name Must Be At Least 2 Characters',
      );
      return;
    }
    if (_nameCtrl.text.trim().length > 50) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: "Please enter a valid name",
      );
      return;
    }

    // ---- Phone: empty + valid Canada number ----
    if (_phoneCtrl.text.trim().isEmpty) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Phone Number',
      );
      return;
    }
    if (!isValidCanadaPhone(_phoneCtrl.text)) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Valid Phone Number',
      );
      return;
    }

    setState(() => _submitting = true);
    showAppLoader();

    final res = await _ctrl.activate(
      cardNumber: _cardCtrl.text,
      amountText: _amountCtrl.text,
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
    );

    hideAppLoader();
    if (!mounted) return;
    setState(() => _submitting = false);

    if (res != null) {
      // ✅ success — server message dialog e
      await showGiftCardResultDialog(
        context,
        success: true,
        message: res.message.isNotEmpty
            ? res.message.titleCase
            : 'Card Activated Successfully',
      );
      if (mounted) Navigator.of(context).pop(res); // activate dialog close
    } else {
      // ❌ fail — same dialog e error, activate dialog khola thakbe (retry)
      await showGiftCardResultDialog(
        context,
        success: false,
        message: _ctrl.errorMessage.value ?? 'Activation Failed',
      );
    }
  }

  // ✅ NOTUN: multiple activate dialog open
  Future<void> _openMultiple() async {
    if (_submitting) return;
    await showMultipleActivateCardDialog(context);
    // Multiple dialog nijei nijer activation handle kore.
    // Ekhane fire ashle kono kichu refresh korte chaile ekhane koro.
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
              // ---- Close (X) ----
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

              // ---- Row 1: Card Number | Amount ----
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _LabeledField(
                      label: 'Card Number *',
                      controller: _cardCtrl,
                      hint: 'XXXX XXXX XXXX XXXX XXXX',
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
                        // ✅ sudhu number + ekta dot, point-er pore MAX 2 ghor.
                        // 0.22 / 1.22 / 333.45 allowed — 34.555 block hobe.
                        DecimalTextInputFormatter(decimalRange: 2),
                        LengthLimitingTextInputFormatter(6), // 500.00 = 6 char
                      ],
                      fieldBg: _fieldBg,
                      borderColor: _borderColor,
                      hintColor: _hintColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ---- Row 2: Name | Phone ----
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _LabeledField(
                      label: 'Name *',
                      controller: _nameCtrl,
                      hint: 'Name',
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                          50,
                        ), // ✅ 50 char er beshi input na
                      ],
                      fieldBg: _fieldBg,
                      borderColor: _borderColor,
                      hintColor: _hintColor,
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: _LabeledField(
                      label: 'Phone Number *',
                      controller: _phoneCtrl,
                      hint: 'Phone Number',
                      inputFormatters: [
                        CanadaPhoneInputFormatter(), // ✅ auto-format
                      ],
                      fieldBg: _fieldBg,
                      borderColor: _borderColor,
                      hintColor: _hintColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // ---- Activate button (center) + Add button (bottom-right) ----
              Stack(
                alignment: Alignment.center,
                children: [
                  // Activate (center e)
                  SizedBox(
                    width: 200,
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
                              'Activate',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 29,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                    ),
                  ),

                  // ✅ NOTUN: Add button — close (X) er borabor, bottom-right e
                  Positioned(
                    right: 0,
                    child: SizedBox(
                      height: 92,
                      child: OutlinedButton.icon(
                        onPressed: _submitting ? null : _openMultiple,
                        icon: Icon(Icons.add, size: 30, color: Colors.white),
                        label: Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _fieldBg,
                          side: const BorderSide(color: _borderColor, width: 1),
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
    );
  }
}

/// Large label + dark bordered field.
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
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final Color fieldBg;
  final Color borderColor;
  final Color hintColor;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

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

/// Amount formatter — sudhu number + ekta dot, point-er pore max [decimalRange] ghor.
/// Allowed: "0.22", "1.22", "33.33", "333.45", "50", "50." .
/// Blocked: "34.555" (3 decimal), ekadhik dot, ".", non-numeric.
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

    // Field khali korle allow.
    if (text.isEmpty) return newValue;

    // Pattern: integer part (optional) + optional dot + max N decimal digit.
    // Dot diye SHURU kora jabe na (".5" na, user ke "0.5" likhte hobe).
    final pattern = RegExp('^\\d+(\\.\\d{0,$decimalRange})?\$');

    if (pattern.hasMatch(text)) {
      return newValue;
    }

    // Notun input invalid -> ager valid value rakho.
    return oldValue;
  }
}

/// Canada phone formatter -> (XXX) XXX-XXXX
class CanadaPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var d = newValue.text.replaceAll(RegExp(r'\D'), '');
    // leading 1 (country code) thakle baad
    if (d.length > 10 && d.startsWith('1')) d = d.substring(1);
    if (d.length > 10) d = d.substring(0, 10);

    final b = StringBuffer();
    for (int i = 0; i < d.length; i++) {
      if (i == 0) b.write('(');
      if (i == 3) b.write(') ');
      if (i == 6) b.write('-');
      b.write(d[i]);
    }
    final text = b.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// NANP rule: 10 digit, area + exchange er first digit 2-9
bool isValidCanadaPhone(String input) {
  var d = input.replaceAll(RegExp(r'\D'), '');
  if (d.length == 11 && d.startsWith('1')) d = d.substring(1);
  if (d.length != 10) return false;
  if (d[0] == '0' || d[0] == '1') return false; // area code
  if (d[3] == '0' || d[3] == '1') return false; // exchange
  return true;
}

/// Backend e pathanor jonno: +1XXXXXXXXXX
String toE164Canada(String input) {
  var d = input.replaceAll(RegExp(r'\D'), '');
  if (d.length == 11 && d.startsWith('1')) d = d.substring(1);
  return '+1$d';
}
