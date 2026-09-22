import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:yogo_pos/app/formatter/decimal_formatter.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
import 'package:yogo_pos/app/utils/extension/num_extensions.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class PaymentDialog extends StatefulWidget {
  final num minPay;
  final String paymentMethod;

  final Function(PaymentModel? paymentData) onPay;
  final Function(PaymentModel? paymentData) onPayAndPrint;
  const PaymentDialog({
    super.key,
    required this.minPay,
    required this.onPay,
    required this.onPayAndPrint,
    required this.paymentMethod,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  num extraAmount = 0;
  num totalAmount = 0;
  PaymentModel? paymentData;
  final List<String> _paymentList = [
    "VISA",
    "MASTERCARD",
    "AMEX",
    "DEBIT_CARD",
    "OTHERS"
  ];
  final _formKey = GlobalKey<FormState>();
  // for cash
  final _cashAmount = TextEditingController();
  final _cashTip = TextEditingController();
  final _change = TextEditingController();
  // for card
  final _cardAmount = TextEditingController();
  final _cardTip = TextEditingController();

  late final String _selecedMethod = widget.paymentMethod;
  String? _selecedCard;

  //todo:need to finish
  PaymentModel? _collectPaymentData() {
    if (_selecedMethod.isEmpty) {
      PopupDialog.showErrorMessage(
        "Please select a payment method",
      );
    }
    if (_formKey.currentState!.validate() && _selecedMethod.isNotEmpty) {
      // kLogger.i(_selecedMethod);
      if (_selecedMethod != "CASH_AND_CARD" && _selecedMethod != "CASH") {
        // for single payment(card)
        var data = PaymentModel(
          extraAmount: extraAmount,
          methods: [_selecedMethod],
          cardPaidAmount: totalAmount,
          cardTipAmount:
              ((num.tryParse(_cardAmount.text) ?? 0) - totalAmount).toFixed2(),
        );
        kLogger.i("paymnetdata : ${data.toJson()}");
        return data;
      } else if (_selecedMethod == "CASH") {
        // for CASH payment
        var data = PaymentModel(
          methods: [_selecedMethod],
          cashPaidAmount: totalAmount,
          cashTipAmount: num.tryParse(_cashTip.text) ?? 0,
          change: num.tryParse(_change.text) ?? 0,
          extraAmount: extraAmount,
        );
        kLogger.i("paymnetdata : ${data.toJson()}");
        return data;
      } else {
        //for cash and card mayment
        var data = PaymentModel(
          methods: [_selecedMethod],
          cardType: _selecedCard?.replaceAll(" ", "_") ?? "",
          cashPaidAmount: num.tryParse(_cashAmount.text) ?? 0,
          cashTipAmount: num.tryParse(_cashTip.text) ?? 0,
          cardPaidAmount: num.tryParse(_cardAmount.text) ?? 0,
          cardTipAmount: num.tryParse(_cardTip.text) ?? 0,
          extraAmount: extraAmount,
        );
        kLogger.i("paymnetdata : ${data.toJson()}");

        return data;
      }
    }
    return null;
  }

  //Cash Total Calculation
  _cashTotalCalculation() {
    num cashAmount = num.tryParse(_cashAmount.text) ?? 0;
    num cashTip = num.tryParse(_cashTip.text) ?? 0;
    num change = cashAmount - cashTip - totalAmount;
    _change.text = change.toStringAsFixed(2);
    setState(() {});
  }

  //Cash and card Total Calculation
  _cashAndCardTotalCalculation(bool isCash) {
    num cashAmount = num.tryParse(_cashAmount.text) ?? 0;
    num cardAmount = num.tryParse(_cardAmount.text) ?? 0;
    if (isCash) {
      _cardAmount.text = (totalAmount - cashAmount).toStringAsFixed(2);
    } else {
      _cashAmount.text = (totalAmount - cardAmount).toStringAsFixed(2);
    }
  }

  @override
  void initState() {
    if (_selecedMethod == "CASH") {
      num roundedTotal = MyFunc.yogoRound(widget.minPay);
      totalAmount = roundedTotal;
      extraAmount = (roundedTotal - widget.minPay).toFixed2();
    } else {
      totalAmount = widget.minPay.toFixed2();
    }
    super.initState();
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
              if (_selecedMethod == "CASH_AND_CARD" ||
                  _selecedMethod == "CASH") {
                _cashAmount.text = totalAmount.toStringAsFixed(2);
              } else {
                _cardAmount.text = totalAmount.toStringAsFixed(2);
              }

              FocusScope.of(Get.context!)
                  .requestFocus(PosController.to.totalAmountFocusNode);
              _cashTotalCalculation();
              if (_selecedMethod == "CASH_AND_CARD") {
                _cashAndCardTotalCalculation(true);
              }
            },
            text: 'Total: \$${totalAmount.toStringAsFixed(2)}',
            color: Colors.transparent,
            isOutline: true,
            textMaxSize: 100,
            textMinSize: 32,
            height: 100,
          ).marginOnly(bottom: 24),
          // for CASH
          if (_selecedMethod == "CASH")
            Row(
              children: [
                Expanded(
                    child: _textField(
                  theme,
                  controller: _cashAmount,
                  readOnly: false,
                  focusNode: PosController.to.totalAmountFocusNode,
                  extraLabel: "Cash Amount:",
                  onChange: (value) {
                    _cashTotalCalculation();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Card amount required!';
                    }
                    return null;
                  },
                )),
                const SizedBox(width: 16),
                Expanded(
                    child: _textField(
                  theme,
                  controller: _cashTip,
                  readOnly: false,
                  extraLabel: "Cash Tip:",
                  onChange: (value) {
                    _cashTotalCalculation();
                  },
                )),
                const SizedBox(width: 16),
                Expanded(
                    child: _textField(theme,
                        controller: _change,
                        readOnly: true,
                        extraLabel: "Change:", validator: (value) {
                  // Check for empty or null input
                  if (value == null || value.isEmpty) {
                    return 'Card amount required!';
                  }
                  // Parse the input as a number
                  final change = num.tryParse(_change.text) ?? 0;
                  // Check for negative values
                  if (change < 0) {
                    return 'Amount cannot be negative!';
                  }

                  // Validation passed
                  return null;
                }, onTap: () {
                  // int initValue =
                  //     ((num.tryParse(_change.text) ?? 0) * 100).toInt();
                  // CustomKeyboard.open(
                  //   keyboardType: KeyboardType.number,
                  //   regExp: RegExp(r'^\d{0,7}$'),
                  //   initialValue: "$initValue",
                  //   onChange: (value) {
                  //     _change.text = value.toDecimalFormat();
                  //     _cashTotalCalculation();
                  //   },
                  // );
                })),
              ],
            ).marginOnly(bottom: 24),
          // for CASH AND CARD
          if (_selecedMethod == "CASH_AND_CARD") ...{
            Row(
              children: [
                Expanded(
                    child: _textField(
                  theme,
                  controller: _cashAmount,
                  readOnly: false,
                  focusNode: PosController.to.totalAmountFocusNode,
                  extraLabel: "Cash Amount:",
                  onChange: (value) {
                    _cashAndCardTotalCalculation(true);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Cash amount required!';
                    }
                    final cashAmount = num.tryParse(_cashAmount.text) ?? 0;
                    // Check for negative values
                    if (cashAmount < 0) {
                      return 'Cash Amount cannot be negative!';
                    }
                    return null;
                  },
                )),
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
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card Name',
                      style: theme.textTheme.bodyLarge,
                    ).marginOnly(bottom: 5),
                    CustomSearchTextField(
                        hintText: _selecedCard ?? "Select card type",
                        dropDownList:
                            List.generate(_paymentList.length, (index) {
                          return DropDownValueModel(
                              name: _paymentList[index].replaceAll("_", " "),
                              value: _paymentList[index]);
                        }),
                        onChanged: (value) {
                          if (value is DropDownValueModel) {
                            _selecedCard = value.name;
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Card Name required!';
                          }
                          return null;
                        }),
                  ],
                )),
                const SizedBox(width: 16),
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
                  if (cardAmount < 0) {
                    return 'Card Amount cannot be negative!';
                  }
                  return null;
                })),
                const SizedBox(width: 16),
                Expanded(
                  child: _textField(
                    theme,
                    readOnly: false,
                    controller: _cardTip,
                    extraLabel: "Card Tip:",
                  ),
                ),
              ],
            ).marginOnly(bottom: 24),
          },

          // for single card payment
          if (_selecedMethod != "CASH_AND_CARD" && _selecedMethod != "CASH")
            _textField(theme,
                controller: _cardAmount,
                initOpenKeyboard: true,
                readOnly: false,
                focusNode: PosController.to.totalAmountFocusNode,
                extraLabel: "Card Amount:", validator: (value) {
              // for single payment

              if (value == null || value.isEmpty) {
                return 'Card amount required!';
              }

              final cardAmount = num.tryParse(_cardAmount.text) ?? 0;
              if (cardAmount < totalAmount) {
                return 'Amount cannot be less than \$$totalAmount';
              }
              return null;
            }).marginOnly(bottom: 24),

          //payment btns
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Print Check
              PrimaryBtnWithChild(
                onPressed: () => widget.onPayAndPrint(_collectPaymentData()),
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
                onPressed: () => widget.onPay(_collectPaymentData()),
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
