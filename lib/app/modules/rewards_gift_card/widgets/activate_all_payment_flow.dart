import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/models/bulk_activate_model.dart';
import 'package:yogo_pos/app/modules/rewards_gift_card/widgets/gift_card_result_dialog.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

Future<PaymentSelection?> showActivateAllPaymentFlow(
  BuildContext context, {
  required double total,
}) async {
  final method = await _showSelectPaymentDialog(context);
  if (method == null) return null; // closed without choosing
  if (!context.mounted) return null;

  if (method == _PaymentMethod.cashAndCard) {
    return _showCashCardDialog(context, total: total);
  }
  return _showPrintDialog(context, method: method, total: total);
}

/// ---------------------------------------------------------------------------
/// SHARED PALETTE (matches the existing activate dialog)
/// ---------------------------------------------------------------------------
const Color _dialogBg = StaticColors.blackLightColor;
const Color _fieldBg = StaticColors.cartColor;
const Color _borderColor = Color(0xff4A4A4A);
const Color _hintColor = Color(0xff8A8A8A);
const Color _blue = Color(0xff1E7DF5); // payment buttons / Print Check
const Color _orange = Color(0xffF0592B); // No Print

/// ---------------------------------------------------------------------------
/// PAYMENT METHOD
/// ---------------------------------------------------------------------------
enum _PaymentMethod {
  visa,
  mastercard,
  amex,
  debitCard,
  cash,
  cashAndCard,
  others,
}

extension _PaymentMethodApi on _PaymentMethod {
  String get apiValue {
    switch (this) {
      case _PaymentMethod.visa:
        return 'VISA';
      case _PaymentMethod.mastercard:
        return 'MASTERCARD';
      case _PaymentMethod.amex:
        return 'AMEX';
      case _PaymentMethod.debitCard:
        return 'DEBIT_CARD'; // ← UI label 'DEBIT CARD', API তে 'DEBIT_CARD'
      case _PaymentMethod.cash:
        return 'CASH';
      case _PaymentMethod.cashAndCard:
        return 'CASH_AND_CARD';
      case _PaymentMethod.others:
        return 'OTHERS';
    }
  }
}

extension _PaymentMethodLabel on _PaymentMethod {
  String get label {
    switch (this) {
      case _PaymentMethod.visa:
        return 'VISA';
      case _PaymentMethod.mastercard:
        return 'MASTERCARD';
      case _PaymentMethod.amex:
        return 'AMEX';
      case _PaymentMethod.debitCard:
        return 'DEBIT CARD';
      case _PaymentMethod.cash:
        return 'CASH';
      case _PaymentMethod.cashAndCard:
        return 'CASH & CARD';
      case _PaymentMethod.others:
        return 'OTHERS';
    }
  }
}

/// Card names shown in the "Card Name" dropdown.
// const List<String> _cardNames = ['VISA', 'MASTERCARD', 'AMEX', 'DEBIT CARD'];
const List<String> _cardNames = ['VISA', 'MASTERCARD', 'AMEX', 'DEBIT_CARD'];

/// Internal results popped by the sub-dialogs.
class _PrintResult {
  final bool printCheck;
  final double amount;
  const _PrintResult(this.printCheck, this.amount);
}

class _CashCardResult {
  final bool printCheck;
  final double cash;
  final double card;
  final String? cardName;
  const _CashCardResult({
    required this.printCheck,
    required this.cash,
    required this.card,
    required this.cardName,
  });
}

/// ===========================================================================
/// 1) SELECT PAYMENT DIALOG
/// ===========================================================================
Future<_PaymentMethod?> _showSelectPaymentDialog(BuildContext context) {
  return showDialog<_PaymentMethod>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => const _SelectPaymentDialog(),
  );
}

class _SelectPaymentDialog extends StatelessWidget {
  const _SelectPaymentDialog();

  static const _options = <_PaymentMethod>[
    _PaymentMethod.visa,
    _PaymentMethod.mastercard,
    _PaymentMethod.amex,
    _PaymentMethod.debitCard,
    _PaymentMethod.cash,
    _PaymentMethod.cashAndCard,
    _PaymentMethod.others,
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          decoration: BoxDecoration(
            color: _dialogBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close (X)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: 22,
                  icon: Icon(Icons.close, color: Colors.white, size: 40),
                ),
              ),
              Text(
                'Select Payment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 24),

              // 2-column grid (last row keeps one button left-aligned)
              LayoutBuilder(
                builder: (context, c) {
                  final itemW = (c.maxWidth - 20) / 2;
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      for (final m in _options)
                        SizedBox(
                          width: itemW,
                          height: 120,
                          child: _PaymentButton(
                            label: m.label,
                            onTap: () => Navigator.of(context).pop(m),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentButton extends StatelessWidget {
  const _PaymentButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// ===========================================================================
/// 2) TOTAL + CARD AMOUNT + PRINT / NO PRINT DIALOG
///    (VISA / MASTERCARD / AMEX / DEBIT CARD / CASH / OTHERS)
/// ===========================================================================
Future<PaymentSelection?> _showPrintDialog(
  BuildContext context, {
  required _PaymentMethod method,
  required double total,
}) async {
  final result = await showDialog<_PrintResult>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => _PrintDialog(total: total),
  );
  if (result == null) return null; // dismissed

  return PaymentSelection(
    payments: [
      // BulkPaymentInput(methods: method.label, paidAmount: result.amount),
      BulkPaymentInput(methods: method.apiValue, paidAmount: result.amount),
    ],
    printCheck: result.printCheck,
  );
}

class _PrintDialog extends StatefulWidget {
  const _PrintDialog({required this.total});

  final double total;

  @override
  State<_PrintDialog> createState() => _PrintDialogState();
}

class _PrintDialogState extends State<_PrintDialog> {
  late final TextEditingController _cardAmountCtrl;

  @override
  void initState() {
    super.initState();
    // Total card amount ta field e pre-fill.
    _cardAmountCtrl = TextEditingController(
      text: widget.total.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _cardAmountCtrl.dispose();
    super.dispose();
  }

  // void _done(bool printCheck) {
  //   final amt = double.tryParse(_cardAmountCtrl.text) ?? widget.total;
  //   Navigator.of(context).pop(_PrintResult(printCheck, amt));
  // }
  void _done(bool printCheck) {
    // Amount fixed — always total (edit kora jay na)
    Navigator.of(context).pop(_PrintResult(printCheck, widget.total));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          padding: const EdgeInsets.fromLTRB(32, 12, 32, 32),
          decoration: BoxDecoration(
            color: _dialogBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Close (X)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: 22,
                  icon: Icon(Icons.close, color: Colors.white, size: 40),
                ),
              ),

              // Total box
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _borderColor, width: 1),
                  ),
                  child: Text(
                    'Total: \$${widget.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Card Amount (pre-filled with total)
              _AmountField(
                label: 'Card Amount:',
                controller: _cardAmountCtrl,
                readOnly: true,
                onChanged: (_) {},
              ),
              SizedBox(height: 34),

              // Print Check | No Print
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _IconTextButton(
                    label: 'Print Check',
                    icon: Icons.print,
                    color: _blue,
                    onTap: () => _done(true),
                  ),
                  SizedBox(width: 24),
                  _IconTextButton(
                    label: 'No Print',
                    icon: Icons.block,
                    color: _orange,
                    onTap: () => _done(false),
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

class _IconTextButton extends StatelessWidget {
  const _IconTextButton({
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
    return SizedBox(
      height: 92,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 28, color: Colors.white),
        label: Text(
          label,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 26),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// 3) CASH & CARD SPLIT DIALOG (no tips)
/// ===========================================================================
Future<PaymentSelection?> _showCashCardDialog(
  BuildContext context, {
  required double total,
}) async {
  final result = await showDialog<_CashCardResult>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => _CashCardDialog(total: total),
  );
  if (result == null) return null;

  final payments = <BulkPaymentInput>[];
  if (result.cash > 0) {
    payments.add(BulkPaymentInput(methods: 'CASH', paidAmount: result.cash));
  }
  if (result.card > 0) {
    payments.add(
      BulkPaymentInput(
        methods: (result.cardName ?? 'CARD').toUpperCase(),
        paidAmount: result.card,
      ),
    );
  }
  // Fallback (shouldn't happen): put the whole total on cash.
  if (payments.isEmpty) {
    payments.add(BulkPaymentInput(methods: 'CASH', paidAmount: total));
  }

  return PaymentSelection(payments: payments, printCheck: result.printCheck);
}

class _CashCardDialog extends StatefulWidget {
  const _CashCardDialog({required this.total});

  final double total;

  @override
  State<_CashCardDialog> createState() => _CashCardDialogState();
}

class _CashCardDialogState extends State<_CashCardDialog> {
  final TextEditingController _cashCtrl = TextEditingController();
  final TextEditingController _cardCtrl = TextEditingController();
  String? _selectedCard;
  final FocusNode _cashFocus = FocusNode();
  final FocusNode _cardTypeFocus = FocusNode();
  bool _cardTypeError = false;
  bool _totalTapped = false;

  double get _total => widget.total;

  // @override
  // void initState() {
  //   super.initState();
  //   _applyDefaultSplit();
  // }

  @override
  void initState() {
    super.initState();
    _setText(_cashCtrl, 0);
    _setText(_cardCtrl, 0);
  }

  @override
  void dispose() {
    _cashCtrl.dispose();
    _cardCtrl.dispose();
    _cashFocus.dispose();
    _cardTypeFocus.dispose();
    super.dispose();
  }

  void _setText(TextEditingController c, double value) {
    final s = value.toStringAsFixed(2);
    c.value = TextEditingValue(
      text: s,
      selection: TextSelection.collapsed(offset: s.length),
    );
  }

  // Default split: card = $2 + total-er cents, cash = baki.
  // total 30.45 -> card 2.45, cash 28.00
  // void _applyDefaultSplit() {
  //   final totalCents = (_total * 100).round();
  //   final centsPart = totalCents % 100; // 30.45 -> 45
  //   var cardCents = 200 + centsPart; // 2.45 -> 245
  //   if (cardCents > totalCents) cardCents = totalCents; // choto total guard
  //   final cashCents = totalCents - cardCents;
  //   _setText(_cashCtrl, cashCents / 100.0);
  //   _setText(_cardCtrl, cardCents / 100.0);
  // }

  //   void _applyDefaultSplit() {
  //   final totalCents = (_total * 100).round();
  //   final centsPart = totalCents % 100;
  //   var cardCents = 200 + centsPart;
  //   if (cardCents > totalCents) cardCents = totalCents;
  //   final cashCents = totalCents - cardCents;
  //   _setText(_cashCtrl, cashCents / 100.0);
  //   _setText(_cardCtrl, cardCents / 100.0);
  //   setState(() => _totalTapped = true); // ← border active
  // }

  // Total box e tap -> cash field e focus (split apnai type korle hobe)
  void _focusCash() {
    _cashFocus.requestFocus();
  }

  // User cash edit korle card = total - cash.
  void _onCashChanged(String v) {
    final cash = double.tryParse(v) ?? 0;
    final card = (_total - cash).clamp(0.0, _total);
    _setText(_cardCtrl, card);
  }

  // User card edit korle cash = total - card.
  void _onCardChanged(String v) {
    final card = double.tryParse(v) ?? 0;
    final cash = (_total - card).clamp(0.0, _total);
    _setText(_cashCtrl, cash);
  }

  Future<void> _submit(bool printCheck) async {
    final cash = double.tryParse(_cashCtrl.text) ?? 0;
    final card = double.tryParse(_cardCtrl.text) ?? 0;

    // CASH & CARD -> card amount obossoi thakte hobe (khali/0 cholbe na)
    if (card <= 0) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Enter A Card Amount',
      );
      return;
    }

    // Card thakle card type lagbe.
    if (_selectedCard == null) {
      setState(() => _cardTypeError = true);
      _cardTypeFocus.requestFocus();
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Please Select A Card Type',
      );
      return;
    }

    // cash + card obossoi total-er soman hote hobe.
    if ((cash + card - _total).abs() > 0.001) {
      await showGiftCardResultDialog(
        context,
        success: false,
        message: 'Cash + Card Must Equal \$${_total.toStringAsFixed(2)}',
      );
      return;
    }

    Navigator.of(context).pop(
      _CashCardResult(
        printCheck: printCheck,
        cash: cash,
        card: card,
        cardName: _selectedCard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          padding: const EdgeInsets.fromLTRB(32, 12, 32, 32),
          decoration: BoxDecoration(
            color: _dialogBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Close (X)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: 22,
                  icon: Icon(Icons.close, color: Colors.white, size: 40),
                ),
              ),

              // ---- Total box (tap -> default split reset) ----
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  // onTap: _applyDefaultSplit,
                  onTap: _focusCash,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: StaticColors.orangeColor,
                        width: 1.6,
                      ),
                    ),
                    child: Text(
                      'Total: \$${_total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // ---- Cash Amount ----
              _AmountField(
                label: 'Cash Amount:',
                controller: _cashCtrl,
                focusNode: _cashFocus,
                onChanged: _onCashChanged,
              ),
              SizedBox(height: 26),

              // ---- Card Name | Card Amount ----
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expanded(
                  //   child: _CardNameDropdown(
                  //     value: _selectedCard,
                  //     onChanged: (v) => setState(() => _selectedCard = v),
                  //   ),
                  // ),
                  Expanded(
                    child: _CardNameDropdown(
                      value: _selectedCard,
                      focusNode: _cardTypeFocus, // ← notun
                      hasError: _cardTypeError, // ← notun
                      onChanged: (v) => setState(() {
                        _selectedCard = v;
                        _cardTypeError = false; // select korle highlight off
                      }),
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: _AmountField(
                      label: 'Card Amount:',
                      controller: _cardCtrl,
                      onChanged: _onCardChanged,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 34),

              // ---- Print Check | No Print ----
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _IconTextButton(
                    label: 'Print Check',
                    icon: Icons.print,
                    color: _blue,
                    onTap: () => _submit(true),
                  ),
                  SizedBox(width: 24),
                  _IconTextButton(
                    label: 'No Print',
                    icon: Icons.block,
                    color: _orange,
                    onTap: () => _submit(false),
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
// class _CashCardDialogState extends State<_CashCardDialog> {
//   final TextEditingController _cashCtrl = TextEditingController();
//   final TextEditingController _cardCtrl = TextEditingController();
//   String? _selectedCard;

//   double get _total => widget.total;

//   @override
//   void dispose() {
//     _cashCtrl.dispose();
//     _cardCtrl.dispose();
//     super.dispose();
//   }

//   // ---- two-way calculation: cash + card = total --------------------------
//   void _setText(TextEditingController c, double value) {
//     final s = value.toStringAsFixed(2);
//     c.value = TextEditingValue(
//       text: s,
//       selection: TextSelection.collapsed(offset: s.length),
//     );
//   }

//   // Tap on the Total box -> put total into cash, card becomes remainder (0).
//   void _fillFromTotal() {
//     _setText(_cashCtrl, _total);
//     _setText(_cardCtrl, 0);
//     setState(() {});
//   }

//   // User edits cash -> card = total - cash.
//   void _onCashChanged(String v) {
//     final cash = double.tryParse(v) ?? 0;
//     final card = (_total - cash).clamp(0.0, _total);
//     _setText(_cardCtrl, card);
//   }

//   // User edits card -> cash = total - card.
//   void _onCardChanged(String v) {
//     final card = double.tryParse(v) ?? 0;
//     final cash = (_total - card).clamp(0.0, _total);
//     _setText(_cashCtrl, cash);
//   }

//   Future<void> _submit(bool printCheck) async {
//     final cash = double.tryParse(_cashCtrl.text) ?? 0;
//     final card = double.tryParse(_cardCtrl.text) ?? 0;

//     // Card amount thakle card type lagbe.
//     if (card > 0 && _selectedCard == null) {
//       await showGiftCardResultDialog(
//         context,
//         success: false,
//         message: 'Please Select A Card Type',
//       );
//       return;
//     }

//         // ---- NOTUN: cash + card obossoi total-er soman hote hobe ----
//     final sum = cash + card;
//     if ((sum - _total).abs() > 0.001) {
//       await showGiftCardResultDialog(
//         context,
//         success: false,
//         message:
//             'Cash + Card Must Equal \$${_total.toStringAsFixed(2)}',
//       );
//       return;
//     }

//     Navigator.of(context).pop(
//       _CashCardResult(
//         printCheck: printCheck,
//         cash: cash,
//         card: card,
//         cardName: _selectedCard,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 760),
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(32, 12, 32, 32),
//           decoration: BoxDecoration(
//             color: _dialogBg,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: _borderColor, width: 1),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Close (X)
//               Align(
//                 alignment: Alignment.topRight,
//                 child: IconButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   splashRadius: 22,
//                   icon: Icon(Icons.close, color: Colors.white, size: 40.sp),
//                 ),
//               ),

//               // ---- Total box (tap to fill cash) ----
//               Center(
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(10),
//                   onTap: _fillFromTotal,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 40.w,
//                       vertical: 24.h,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: _borderColor, width: 1),
//                     ),
//                     child: Text(
//                       'Total: \$${_total.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 34.sp,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 30.h),

//               // ---- Cash Amount ----
//               _AmountField(
//                 label: 'Cash Amount:',
//                 controller: _cashCtrl,
//                 onChanged: _onCashChanged,
//               ),
//               SizedBox(height: 26.h),

//               // ---- Card Name | Card Amount ----
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: _CardNameDropdown(
//                       value: _selectedCard,
//                       onChanged: (v) => setState(() => _selectedCard = v),
//                     ),
//                   ),
//                   SizedBox(width: 24.w),
//                   Expanded(
//                     child: _AmountField(
//                       label: 'Card Amount:',
//                       controller: _cardCtrl,
//                       onChanged: _onCardChanged,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 34.h),

//               // ---- Print Check | No Print ----
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _IconTextButton(
//                     label: 'Print Check',
//                     icon: Icons.print,
//                     color: _blue,
//                     onTap: () => _submit(true),
//                   ),
//                   SizedBox(width: 24.w),
//                   _IconTextButton(
//                     label: 'No Print',
//                     icon: Icons.block,
//                     color: _orange,
//                     onTap: () => _submit(false),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

/// Label + amount input (2 decimals).
class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.readOnly = false,
    this.focusNode,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          readOnly: readOnly,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            _AmountFormatter(decimalRange: 2),
            LengthLimitingTextInputFormatter(9),
          ],
          cursorColor: StaticColors.orangeColor,
          style: const TextStyle(color: Colors.white, fontSize: 26),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: const TextStyle(color: _hintColor, fontSize: 26),
            filled: true,
            fillColor: _fieldBg,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 24,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _borderColor, width: 1),
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

/// Card Name dropdown.
class _CardNameDropdown extends StatelessWidget {
  const _CardNameDropdown({
    required this.value,
    required this.onChanged,
    this.focusNode, // ← notun
    this.hasError = false,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final FocusNode? focusNode; // ← notun
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    // API value -> display label (DEBIT_CARD -> Debit Card)
    String _cardLabel(String v) {
      switch (v.toUpperCase()) {
        case 'DEBIT_CARD':
          return 'Debit Card';
        case 'VISA':
          return 'Visa';
        case 'MASTERCARD':
          return 'Mastercard';
        case 'AMEX':
          return 'Amex';
        default:
          return v;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Name',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _fieldBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasError ? StaticColors.orangeColor : _borderColor,
              width: hasError ? 1.6 : 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              focusNode: focusNode,
              dropdownColor: _fieldBg,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              hint: const Text(
                'Select card type',
                style: TextStyle(color: _hintColor, fontSize: 24),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 24),
              // items: _cardNames
              //     .map(
              //       (e) => DropdownMenuItem<String>(
              //         value: e,
              //         child: Text(e),
              //       ),
              //     )
              //     .toList(),
              items: _cardNames
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(_cardLabel(e)), // ← display sundor
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Amount formatter: numbers + one dot, max [decimalRange] digits after dot.
class _AmountFormatter extends TextInputFormatter {
  final int decimalRange;

  _AmountFormatter({this.decimalRange = 2}) : assert(decimalRange >= 0);

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
