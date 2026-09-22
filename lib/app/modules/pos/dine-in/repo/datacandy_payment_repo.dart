import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/formatter/card_number_formatter.dart';
import 'package:yogo_pos/app/formatter/decimal_formatter.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/print_receipt/esc_redeem_increase_receipt.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_order_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

import '../../../../utils/static_colors.dart';
import '../../../../widgets/custom_Btn.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/my_custom_text.dart';
import '../models/datacandy_payment_model.dart';

Future<void> showAnimatedSuccessDialog(BuildContext context,
    {String? title, bool autoDismiss = true}) async {
  if (!context.mounted) return;
  showDialog(
    context: context,
    builder: (_) => AnimatedMessageDialog(
      height: 350,
      width: 600,
      title: title ?? "Payment Successful!",
      // message:message ?? "Transaction Successful!",
      type: DialogType.success,
    ),
  );
}

Future<void> showAnimatedErrorDialog(BuildContext context,
    {String? title, String? message, bool autoDismiss = true}) async {
  if (!context.mounted) return;
  showDialog(
    context: context,
    builder: (_) => AnimatedMessageDialog(
      height: 350,
      width: 750,
      title: title ?? "Payment Failed!",
      // message: message ?? "Something went wrong while processing your payment.",
      type: DialogType.error,
    ),
  );
}

Future<void> showAnimatedNetworkErrorDialog(BuildContext context,
    {String? title, String? message, bool autoDismiss = true}) async {
  if (!context.mounted) return;
  showDialog(
    context: context,
    builder: (_) => AnimatedMessageDialog(
      height: 350,
      width: 400,
      title: title ?? "Network Issue",
      message: message ?? "Please check your internet connection.",
      type: DialogType.warning,
    ),
  );
}

Map<String, String> parseErrorText(String text) {
  if (text.isEmpty) return {'code': '', 'message': ''};

  // Split at the first colon (:)
  final parts = text.split(':');
  final code = parts.isNotEmpty ? parts.first.trim() : '';
  final message = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

  // Capitalize each word of the message
  String capitalizeEachWord(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      int index = word.indexOf(RegExp(r'[A-Za-z]'));
      if (index == -1) return word;
      return word.substring(0, index) +
          word[index].toUpperCase() +
          word.substring(index + 1).toLowerCase();
    }).join(' ');
  }

  return {
    'code': code,
    'message': capitalizeEachWord(message),
  };
}

class DataCandyPaymentRepo {
  // static GiftCardController controller = Get.put(GiftCardController());
  static Future<bool> pay(
      {bool isPrint = false,
      // ignore: non_constant_identifier_names
      required String CID,
      required PaymentModel payment,
      String? orderId,
      String? successTitle,
      String? successMessage,
      String? errorTitle,
      String? erroMessage}) async {
    try {
      var data = {
        "WSN": "1",
        "CID": CID,
        "INV": orderId,
        "payment": payment.toJson()
      };
      var id = PosController.to.myOrder.id;
      PopupDialog.showLoadingDialog();
      var response = await BaseController.to.apiService
          .makePatchRequest("${URLS.datacandyPayment}/$id", data);
      PopupDialog.closeLoadingDialog();
      if (response.statusCode == 200) {
        Get.back();
        // PopupDialog.showSuccessDialog("Payment Success");

        // show success popup safely
        showAnimatedSuccessDialog(Get.context!, title: "Payment Successful!");

        OrderModel orderData =
            OrderModel.fromJson(response.data["data"]["orderResult"]);
        PosController.to.myOrder = orderData;
        PosController.to.update();
        DataCandyPaymentModel dataCandy =
            DataCandyPaymentModel.fromJson(response.data["data"]["dataCandy"]);
        if (isPrint) {
          // todo:print
          PrintUtils().directPrint(
              data:  escOrderPrintReceipt(order: orderData),
              printer: Preferences.counterPrinter);
          PrintUtils().directPrint(
              data:  escDataCandyRedeemIncreaseReceipt(
                  data: dataCandy, server: orderData.employee?.firstName),
              printer: Preferences.counterPrinter);
        }
        DataUpdateHelper.getDataByCheckType();
        return true;
      } else {
        final result = parseErrorText(response.data["message"]);
        // print(result['code']); // 101
        // print(result['message']);
        showAnimatedErrorDialog(Get.context!,
            title: "Error ${result['code']} : ${result['message']}");
        // showAnimatedErrorDialog(Get.context!,title: errorTitle,message: erroMessage);
        // PopupDialog.showErrorMessage(
        //     MyFunc.capitalizeEachWord(s: response.data["message"]));
        return false;
      }
    } catch (e) {
      showAnimatedErrorDialog(Get.context!, title: e.toString());
      // PopupDialog.showErrorMessage(e.toString());
      return false;
    }
  }

  // static processDialog(num minPay){
  //   showDialogActivate(minPay);
  //
  //
  // }

  // static processDialog1()async{
  //    PopupDialog.showLoadingDialog();
  // await controller.checkBlance();
  // PopupDialog.closeLoadingDialog();
  //
  // }
  //

  static showDialogPay(num minPay) {
    PopupDialog.customDialog(
      // borderColor: Colors.amber,
      width: 900,
      height: 420,

      child: _Child(minPay: minPay),
    );
  }
}

class _Child extends StatefulWidget {
  final num minPay;

  const _Child({required this.minPay});

  @override
  State<_Child> createState() => _ChildState();
}

class _ChildState extends State<_Child> {
  final _formKey = GlobalKey<FormState>();
  num tipAmount = 0.00;
  TextEditingController cardController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();

  // fouses nodes
  FocusNode cardFocusNode = FocusNode();
  FocusNode totalAmountFocusNode = FocusNode();

  @override
  void dispose() {
    cardController.dispose();
    totalAmountController.dispose();
    cardFocusNode.dispose();
    totalAmountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PrimaryBtn(
              onPressed: () {
                totalAmountController.text = widget.minPay.toStringAsFixed(2);
                // after 500ms card focus
                Future.delayed(const Duration(milliseconds: 500), () {
                  cardFocusNode.requestFocus();
                });
              },
              text: 'Total: \$${widget.minPay.toStringAsFixed(2)}',
              color: Colors.transparent,
              isOutline: true,
              textMaxSize: 100,
              textMinSize: 32,
              height: 100,
            ).marginOnly(bottom: 34),
            //crud number and price text field row
            Row(
              children: [
                // ✅ Card
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    keyboardType: KeyboardType.decimalFormatted,
                    focusNode: totalAmountFocusNode,
                    initOpenKeyboard: true,
                    inputFormatters: [DecimalFormatter()],
                    padding: const EdgeInsets.symmetric(
                        vertical: 22, horizontal: 12),
                    controller: totalAmountController,
                    hintText: "Card Amount",
                    extraLabel: "Card Amount",
                    validator: (value) {
                      // Allow empty -> auto treated as 0.00
                      if (value == null || value.trim().isEmpty) {
                        // totalAmountController.text = "0.00";
                        return null;
                      }

                      // ✅ Allow only valid numeric input
                      final numberRegExp = RegExp(r'^\d+(\.\d+)?$');
                      if (!numberRegExp.hasMatch(value)) {
                        return "Only numeric values are allowed";
                      }

                      final numValue = num.tryParse(value);
                      if (numValue == null) {
                        return "Invalid number";
                      }

                      if (numValue < widget.minPay) {
                        return 'Amount cannot be less than \$${widget.minPay.toStringAsFixed(2)}';
                      }
                      return null;
                    },
                  ),
                ),
                20.width,
                Expanded(
                  // flex: 3,
                  child: SizedBox(
                    // color: Colors.red,

                    child: CustomTextField(
                      focusNode: cardFocusNode,
                      keyboardType: KeyboardType.cardNumberFormatted,
                      padding: const EdgeInsets.symmetric(
                          vertical: 22, horizontal: 12),
                      inputFormatters: [CardNumberFormatter()],
                      controller: cardController,
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
                    ),
                  ),
                ),

                // ✅ Amount
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Print Check
                PrimaryBtnWithChild(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final isPaid = await DataCandyPaymentRepo.pay(
                          orderId: PosController.to.myOrder.orderId,
                          CID: cardController.text.replaceAll("-", "").trim(),
                          isPrint: true,
                          payment: PaymentModel(
                            methods: ["DATACANDY_GIFT_CARD"],
                            cardType: "DATACANDY",
                            cardPaidAmount: widget.minPay,
                            cardTipAmount: (num.tryParse(
                                        totalAmountController.text.trim()) ??
                                    0.00) -
                                widget.minPay,
                          ));
                      if (isPaid) {
                        cardController.clear();
                        totalAmountController.clear();
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
                          'Print',
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ).marginOnly(right: 40),
                // No Print
                PrimaryBtnWithChild(
                  onPressed: () async {
                    // print("unvalid");

                    if (_formKey.currentState!.validate()) {
                      final isPaid = await DataCandyPaymentRepo.pay(
                          orderId: PosController.to.myOrder.orderId,
                          CID: cardController.text.replaceAll("-", "").trim(),
                          isPrint: false,
                          payment: PaymentModel(
                            methods: ["DATACANDY_GIFT_CARD"],
                            cardType: "DATACANDY",
                            cardPaidAmount: widget.minPay,
                            cardTipAmount: (num.tryParse(
                                        totalAmountController.text.trim()) ??
                                    0.00) -
                                widget.minPay,
                          ));
                      if (isPaid) {
                        cardController.clear();
                        totalAmountController.clear();
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
            )
          ],
        ),
      ),
    );
  }
}

class AnimatedMessageDialog extends StatefulWidget {
  final String title;
  final String? message;
  final bool autoDismiss;
  final DialogType type; // ✅ Success / Error / Info
  final double height;
  final double width;

  const AnimatedMessageDialog({
    super.key,
    required this.title,
    this.message,
    this.autoDismiss = true,
    this.type = DialogType.success,
    required this.height,
    required this.width,
  });

  @override
  State<AnimatedMessageDialog> createState() => _AnimatedMessageDialogState();
}

class _AnimatedMessageDialogState extends State<AnimatedMessageDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    if (widget.autoDismiss) {
      Future.delayed(const Duration(seconds: 300), () {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _dialogColor {
    switch (widget.type) {
      case DialogType.success:
        return Colors.green;
      case DialogType.error:
        return Colors.red;
      case DialogType.warning:
        return Colors.orange;
      case DialogType.info:
        return Colors.blue;
    }
  }

  IconData get _dialogIcon {
    switch (widget.type) {
      case DialogType.success:
        return Icons.check_circle_rounded;
      case DialogType.error:
        return Icons.error_rounded;
      case DialogType.warning:
        return Icons.warning_amber_rounded;
      case DialogType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 10,
            // backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: const EdgeInsets.all(24),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ✅ Main content (centered)
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        Icon(
                          _dialogIcon,
                          color: _dialogColor,
                          size: 100,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 55,
                            fontWeight: FontWeight.w900,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (widget.message != null &&
                            widget.message!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.message!,
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                        if (!widget.autoDismiss) ...[
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context, rootNavigator: true)
                                    .pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _dialogColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 12),
                            ),
                            child: const Text(
                              "OK",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ✅ Close icon (absolute position)
                  Positioned(
                    top: -10,
                    right: -10,
                    child: InkWell(
                      onTap: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade700,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

// ✅ Enum to specify dialog type
enum DialogType { success, error, warning, info }
