import 'package:flutter/material.dart';
import 'package:yogo_pos/app/formatter/card_number_formatter.dart';
import 'package:yogo_pos/app/formatter/decimal_formatter.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/repo/datacandy_payment_repo.dart';
import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:get/get.dart';

class CashAndGiftCardDialog extends StatefulWidget {
  final num minPay;

  const CashAndGiftCardDialog({
    super.key,
    required this.minPay,
  });

  @override
  State<CashAndGiftCardDialog> createState() => _CashAndGiftCardDialogState();
}

class _CashAndGiftCardDialogState extends State<CashAndGiftCardDialog> {
  PaymentModel? paymentData;

  final _formKey = GlobalKey<FormState>();
  // for cash
  final _cashAmount = TextEditingController();
  final _cashTip = TextEditingController();
  final _giftNumber = TextEditingController();
  // for card
  final _cardAmount = TextEditingController();
  final _cardTip = TextEditingController();

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
    _giftNumber.dispose();
    _cardAmount.dispose();
    _cardTip.dispose();
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
                  flex: 4,
                  child: CustomTextField(
                    // focusNode: cardFocusNode,
                    keyboardType: KeyboardType.decimalFormatted,
                    padding: const EdgeInsets.symmetric(
                        vertical: 22, horizontal: 12),
                    inputFormatters: [DecimalFormatter()],
                    controller: _cashAmount,
                    style: theme.textTheme.headlineSmall,
                    labelStyle: theme.textTheme.headlineSmall,
                    hintStyle: theme.textTheme.headlineSmall,
                    hintText: "0.00",
                    extraLabel: "Cash Amount:",
                    onKeyboardChang: (value) {
                      _cashAndCardTotalCalculation(true);
                    },
                    onChange: (value) {
                      _cashAndCardTotalCalculation(true);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Cash amount required!';
                      }
                      final cashAmount = num.tryParse(_cashAmount.text) ?? 0;
                      // Check for negative values
                      if (cashAmount < 1) {
                        return 'Cash Amount must be at least 1!';
                      }
                      return null;
                    },
                  )),
              const SizedBox(width: 16),
              Expanded(
                  flex: 3,
                  child: CustomTextField(
                    // focusNode: cardFocusNode,
                    keyboardType: KeyboardType.decimalFormatted,
                    padding: const EdgeInsets.symmetric(
                        vertical: 22, horizontal: 12),
                    inputFormatters: [DecimalFormatter()],
                    controller: _cashTip,
                    style: theme.textTheme.headlineSmall,
                    labelStyle: theme.textTheme.headlineSmall,
                    hintStyle: theme.textTheme.headlineSmall,
                    hintText: "0.00",
                    extraLabel: "Cash Tip:",
                  )),
            ],
          ).marginOnly(bottom: 12),
          Row(
            children: [
              Expanded(
                  flex: 4,
                  child: CustomTextField(
                    // focusNode: cardFocusNode,
                    keyboardType: KeyboardType.cardNumberFormatted,
                    padding: const EdgeInsets.symmetric(
                        vertical: 22, horizontal: 12),
                    inputFormatters: [CardNumberFormatter()],
                    controller: _giftNumber,
                    style: theme.textTheme.headlineSmall,
                    labelStyle: theme.textTheme.headlineSmall,
                    hintStyle: theme.textTheme.headlineSmall,
                    hintText: "xxxx xxxx xxxx xxxx",
                    extraLabel: "Gift Card Number",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Card number is required";
                      }
                      if (value.replaceAll("-", "").length < 12 ||
                          value.replaceAll("-", "").length > 19) {
                        return "Card number must be 12-19 digits";
                      }
                      return null;
                    },
                  )),
              const SizedBox(width: 16),
              Expanded(
                  flex: 3,
                  child: CustomTextField(
                    // focusNode: cardFocusNode,
                    keyboardType: KeyboardType.decimalFormatted,
                    padding: const EdgeInsets.symmetric(
                        vertical: 22, horizontal: 12),
                    inputFormatters: [DecimalFormatter()],
                    controller: _cardAmount,
                    style: theme.textTheme.headlineSmall,
                    labelStyle: theme.textTheme.headlineSmall,
                    hintStyle: theme.textTheme.headlineSmall,
                    hintText: "0.00",
                    extraLabel: "Card Amount:",
                    onKeyboardChang: (value) {
                      _cashAndCardTotalCalculation(false);
                    },
                    onChange: (value) {
                      _cashAndCardTotalCalculation(false);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Card amount required!';
                      }
                      final cardAmount = num.tryParse(_cardAmount.text) ?? 0;
                      // Check for negative values
                      if (cardAmount < 1) {
                        return 'Card Amount must be at least 1!';
                      }
                      return null;
                    },
                  )),
            ],
          ).marginOnly(bottom: 24),

          //payment btns
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Print Check
              PrimaryBtnWithChild(
                onPressed: () async {
                  //_collectPaymentData()
                  if (_formKey.currentState!.validate()) {
                    final isPaid = await DataCandyPaymentRepo.pay(
                        orderId: PosController.to.myOrder.orderId,
                        CID: _giftNumber.text.replaceAll("-", "").trim(),
                        isPrint: true,
                        payment: PaymentModel(
                          methods: ["CASH_AND_CARD"],
                          cardType: "DATACANDY",
                          cashPaidAmount: num.tryParse(_cashAmount.text) ?? 0,
                          cashTipAmount: num.tryParse(_cashTip.text) ?? 0,
                          cardPaidAmount: num.tryParse(_cardAmount.text) ?? 0,
                        ));
                    if (isPaid) {
                      // cardController.clear();
                      // totalAmountController.clear();
                    }
                  } else {
                    debugPrint("Enter Valid Nums");
                  }
                },
                height: 70,
                width: 200,
                color: StaticColors.blueColor,
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.print,
                      color: Colors.white,
                      size: 25,
                    ).marginOnly(right: 12),
                    const FittedBox(
                      child: MyCustomText(
                        'Print Check',
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
              ).marginOnly(right: 50),
              // No Print
              PrimaryBtnWithChild(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final isPaid = await DataCandyPaymentRepo.pay(
                        orderId: PosController.to.myOrder.orderId,
                        CID: _giftNumber.text.replaceAll("-", "").trim(),
                        isPrint: false,
                        payment: PaymentModel(
                          methods: ["CASH_AND_CARD"],
                          cardType: "DATACANDY",
                          cashPaidAmount: num.tryParse(_cashAmount.text) ?? 0,
                          cashTipAmount: num.tryParse(_cashTip.text) ?? 0,
                          cardPaidAmount: num.tryParse(_cardAmount.text) ?? 0,
                        ));
                    if (isPaid) {
                      // cardController.clear();
                      // totalAmountController.clear();
                    }
                  } else {
                    debugPrint("Enter Valid Nums");
                  }
                },
                height: 70,
                width: 200,
                textColor: Colors.white,
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.do_disturb_alt,
                      size: 25,
                      color: Colors.white,
                    ).marginOnly(right: 12),
                    const FittedBox(
                      child: MyCustomText(
                        color: Colors.white,
                        'No Print',
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
