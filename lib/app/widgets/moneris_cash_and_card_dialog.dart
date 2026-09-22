import 'package:flutter/material.dart';
import 'package:yogo_pos/app/formatter/decimal_formatter.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:get/get.dart';

class MonerisCashAndCardDialog extends StatefulWidget {
  final num minPay;

  final Function(PaymentModel? paymentData) onPay;
  final Function(PaymentModel? paymentData) onPayAndPrint;
  const MonerisCashAndCardDialog({
    super.key,
    required this.minPay,
    required this.onPay,
    required this.onPayAndPrint,
  });

  @override
  State<MonerisCashAndCardDialog> createState() =>
      _MonerisCashAndCardDialogState();
}

class _MonerisCashAndCardDialogState extends State<MonerisCashAndCardDialog> {
  PaymentModel? paymentData;

  final _formKey = GlobalKey<FormState>();
  // for cash
  final _cashAmount = TextEditingController();
  final _cashTip = TextEditingController();
  final _change = TextEditingController();
  // for card
  final _cardAmount = TextEditingController();
  final _cardTip = TextEditingController();
  String? _selecedCard;


  //todo:need to finish
  PaymentModel? _collectPaymentData() {
    if (_formKey.currentState!.validate()) {
      //for cash and card mayment
      var data = PaymentModel(
        methods: ["CASH_AND_CARD"],
        cardType: _selecedCard ?? "",
        cashPaidAmount: num.tryParse(_cashAmount.text) ?? 0,
        cashTipAmount: num.tryParse(_cashTip.text) ?? 0,
        cardPaidAmount: num.tryParse(_cardAmount.text) ?? 0,
        cardTipAmount: 0,
      );
      kLogger.i("paymnetdata : ${data.toJson()}");

      return data;
    }
    return null;
  }

  //Cash Total Calculation
  _cashTotalCalculation() {
    num cashAmount = num.tryParse(_cashAmount.text) ?? 0;
    num cashTip = num.tryParse(_cashTip.text) ?? 0;
    num change = cashAmount - cashTip - widget.minPay;
    _change.text = change.toStringAsFixed(2);
    setState(() {});
  }

  //Cash and card Total Calculation
  _cashAndCardTotalCalculation(bool isCash) {
    num cashAmount = num.tryParse(_cashAmount.text) ?? 0;
    num cardAmount = num.tryParse(_cardAmount.text) ?? 0;
    if (isCash) {
      _cardAmount.text = (widget.minPay - cashAmount).toStringAsFixed(2);
    } else {
      _cashAmount.text = (widget.minPay - cardAmount).toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _cashAmount.dispose();
    _cashTip.dispose();
    _change.dispose();
    _cardAmount.dispose();
    _cardTip.dispose();

    // _selecedMethod = _methodList.first;
    _selecedCard = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Total amount(minPay)
          PrimaryBtn(
            onPressed: () {
              _cashAmount.text = (widget.minPay - 1).toStringAsFixed(2);
              _cardAmount.text = "1.00";

              FocusScope.of(Get.context!)
                  .requestFocus(PosController.to.totalAmountFocusNode);
              _cashTotalCalculation();
              _cashAndCardTotalCalculation(true);
            },
            text: 'Total: \$${widget.minPay.toStringAsFixed(2)}',
            color: Colors.transparent,
            isOutline: true,
            textMaxSize: 100,
            textMinSize: 32,
            height: 100,
          ).marginOnly(bottom: 24),

          // for CASH AND CARD
          Row(
            children: [
              Expanded(
                  child: _textField(theme,
                      controller: _cashAmount,
                      readOnly: false,
                      focusNode: PosController.to.totalAmountFocusNode,
                      extraLabel: "Cash Amount:", onChange: (value) {
                _cashAndCardTotalCalculation(true);
              }, validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Cash amount required!';
                }
                final cashAmount = num.tryParse(_cashAmount.text) ?? 0;
                // Check for negative values
                if (cashAmount < 0) {
                  return 'Cash Amount cannot be negative!';
                }
                return null;
              })),
              const SizedBox(width: 16),
              Expanded(
                  child: _textField(
                theme,
                readOnly: false,
                controller: _cashTip,
                extraLabel: "Cash Tip:",
              )),
            ],
          ).marginOnly(bottom: 12),
          Row(
            children: [
              Expanded(
                  child: _textField(theme,
                      controller: _cardAmount,
                      readOnly: false,
                      extraLabel: "Card Amount:", onChange: (value) {
                _cashAndCardTotalCalculation(false);
              }, validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Card amount required!';
                }
                final cardAmount = num.tryParse(_cardAmount.text) ?? 0;
                // Check for negative values
                if (cardAmount < 1) {
                  return 'Card Amount must be at least 1!';
                }
                return null;
              })),
            ],
          ).marginOnly(bottom: 24),

          //payment btns
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // No Print
              PrimaryBtnWithChild(
                onPressed: () => widget.onPay(_collectPaymentData()),
                height: 70,
                width: 200,
                color: StaticColors.blueColor,
                textColor: Colors.white,
                padding: const EdgeInsets.all(4.0),
                child: FittedBox(
                  child: MyCustomText(
                    color: Colors.white,
                    'PAY',
                    fontSize: 25,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // for cash payment
  Widget _textField(ThemeData theme,
      {String? extraLabel,
      TextEditingController? controller,
      dynamic Function(String)? onChange,
      dynamic Function()? onTap,
      FocusNode? focusNode,
      bool initOpenKeyboard = false,
      String? Function(String?)? validator,
      bool? readOnly}) {
    return CustomTextField(
      readOnly: readOnly,
      extraLabel: extraLabel,
      initOpenKeyboard: initOpenKeyboard,
      keyboardType: KeyboardType.decimalFormatted,
      controller: controller,
      onChange: onChange,
      onTap: onTap,
      focusNode: focusNode,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
      style: theme.textTheme.headlineSmall,
      validator: validator,
      onKeyboardChang: onChange,
      inputFormatters: [DecimalFormatter()],
    );
  }
}
