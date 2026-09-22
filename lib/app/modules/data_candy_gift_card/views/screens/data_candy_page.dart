import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/formatter/card_number_formatter.dart';
import 'package:yogo_pos/app/formatter/decimal_formatter.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/data_candy_active_reload_controller.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import '../../../../services/controller/config_controller.dart';
import '../../../../utils/static_colors.dart';
import '../../../../widgets/custom_Btn.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/my_custom_text.dart';
import '../../../../widgets/popup_dialogs.dart';
import '../../../../widgets/title_bar.dart';
import '../../../pos/order/widgets/dialogs/order_payment_dialog.dart';

class DataCandyPage extends GetView<DataCandyActiveAndReloadController> {
  const DataCandyPage({super.key});

  // GiftCardController giftCardController = Get.put(GiftCardController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const TitleBar(),
        toolbarHeight: 30,
      ),
      body: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: ConfigController.to.isLightTheme
                ? theme.cardColor
                : StaticColors.cartColor,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/datacandy.png",
                        height: 70, width: 70),
                    const SizedBox(width: 10),
                    MyCustomText(
                      "DataCandy",
                      fontSize: 43,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // Custom button

                // Form(
                //   key: controller.formKey,
                //   child:
                Row(
                  // mainAxisAlignment: MainAxisAlignment.center, // horizontally center
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: SizedBox(
                        height: 200,
                        width: 300,
                        child: Form(
                          key: controller.amountFormKey,
                          child: CustomTextField(
                            keyboardType: KeyboardType.decimalFormatted,
                            extralabeldownpadding: 28,
                            inputFormatters: [DecimalFormatter()],
                            padding: EdgeInsets.all(26),
                            errorStyle: const TextStyle(
                              fontSize: 16,
                              height: 1,
                              overflow: TextOverflow.fade,
                            ),
                            controller: controller.amountController,
                            extraLabelFontSize: 40,
                            hintStyle: TextStyle(
                                fontSize: 30,
                                color: Theme.of(context).hintColor),
                            hintText: "Custom Amount",
                            extraLabel: "Amount",
                            style: TextStyle(
                              fontSize: 30,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Amount is required";
                              }

                              final numberRegExp = RegExp(r'^\d+(\.\d+)?$');
                              if (!numberRegExp.hasMatch(value)) {
                                return "Only numeric values are allowed";
                              }

                              final numValue = num.tryParse(value);
                              if (numValue == null) {
                                return "Invalid number";
                              }

                              if (numValue < 5 || numValue > 500) {
                                return "Amount must be between 5 and 500";
                              }

                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 75),
                      child: PrimaryBtn(
                        onPressed: () {
                          if (controller.amountFormKey.currentState!
                              .validate()) {
                            //Active dialog
                            _showDialog(
                              context,
                              onChanged: (value) {
                                controller.cardController.text = value;
                                debugPrint(controller.cardController.text);
                              },
                              onActive: () {
                                if (controller.cardController.text.isEmpty) {
                                  PopupDialog.showErrorMessage("Card is Empty");
                                  return;
                                }
                                if (controller.cardController.text
                                        .replaceAll("-", "")
                                        .length >
                                    11) {
                                  Get.back();
                                  PopupDialog.customDialog(
                                      child: DataCandyPaymentDialog(
                                        isReload: false,
                                      ),
                                      width: 600);
                                } else {
                                  PopupDialog.showErrorMessage(
                                      "Card Number Invalid");
                                }

                                // print("Activate pressed");
                              },
                              onReload: () {
                                if (controller.cardController.text.isEmpty) {
                                  PopupDialog.showErrorMessage("Card is Empty");
                                  return;
                                }
                                if (controller.cardController.text
                                        .replaceAll("-", "")
                                        .length >
                                    11) {
                                  Get.back();
                                  PopupDialog.customDialog(
                                      child: DataCandyPaymentDialog(
                                        isReload: true,
                                      ),
                                      width: 600);
                                } else {
                                  PopupDialog.showErrorMessage(
                                      "Card Number Invalid");
                                }
                              },
                            );
                          }

                          // controller.textControllerRemove();
                        },
                        text: "Custom",
                        textMinSize: 30,
                        textMaxSize: 30,
                        height: 90,
                        width: 200,
                        color: StaticColors.greenColor,
                      ),
                    ),
                  ],
                  // ),
                ),

                const SizedBox(height: 25),

                // Generated buttons (5,10,...,50)

                SizedBox(
                  child: StaggeredGrid.count(
                    crossAxisCount: 5, // 4 ta column
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,

                    children: List.generate(
                      controller.values.length,
                      (index) {
                        final value = controller.values[index];
                        final formattedValue = value.toStringAsFixed(2);

                        return SizedBox(
                          height: 120,
                          // crossAxisCellCount: 3,
                          // mainAxisCellCount: 2,
                          child: PrimaryBtn(
                            textMinSize: 30,
                            textMaxSize: 30,
                            onPressed: () {
                              controller.amountController.text = formattedValue;
                              _showDialog(
                                context,
                                onChanged: (value) {
                                  controller.cardController.text = value;
                                  debugPrint(controller.cardController.text);
                                },
                                onActive: () {
                                  if (controller.cardController.text.isEmpty) {
                                    PopupDialog.showErrorMessage(
                                        "Card is Empty");
                                    return;
                                  }
                                  if (controller.cardController.text
                                          .replaceAll("-", "")
                                          .length >
                                      11) {
                                    Get.back();
                                    PopupDialog.customDialog(
                                        child: DataCandyPaymentDialog(
                                          isReload: false,
                                        ),
                                        width: 600);
                                  } else {
                                    PopupDialog.showErrorMessage(
                                        "Card Number Invalid");
                                  }

                                  // print("Activate pressed");
                                },
                                onReload: () {
                                  if (controller.cardController.text.isEmpty) {
                                    PopupDialog.showErrorMessage(
                                        "Card is Empty");
                                    return;
                                  }

                                  // print(controller.cardController.text
                                  //     .replaceAll("-", "")
                                  // .length);
                                  if (controller.cardController.text
                                          .replaceAll("-", "")
                                          .length >
                                      11) {
                                    Get.back();
                                    PopupDialog.customDialog(
                                        child: DataCandyPaymentDialog(
                                          isReload: true,
                                        ),
                                        width: 600);
                                  } else {
                                    PopupDialog.showErrorMessage(
                                        "Card Number Invalid");
                                  }
                                },
                              );
                            },
                            text: "\$$formattedValue",
                            height: 100,
                            width: 100,
                            color: StaticColors.blueColor,
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog(
    BuildContext context, {
    required void Function() onActive,
    required void Function() onReload,
    void Function(String)? onChanged,
  }) {
    PopupDialog.customDialog2(

        // height:350,
        // borderColor: Theme.of(context).hintColor,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  // color: Colors.red,
                  height: 180,
                  child: CustomTextField(
                    extralabeldownpadding: 28,
                    keyboardType: KeyboardType.cardNumberFormatted,
                    // 19 digit with hyphen formatter
                    allowRegex: RegExp(r'^.{0,22}$'),
                    padding: EdgeInsets.all(26),
                    errorStyle: TextStyle(
                        height: 1,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis),
                    inputFormatters: [CardNumberFormatter()],
                    controller: controller.cardController,
                    hintText: "xxxx xxxx xxxx xxxx",
                    extraLabel: "Gift Card Number",
                    extraLabelFontSize: 40,
                    textAlign: TextAlign.center,

                    // extraLabelStyle: TextStyle(fontSize: 24,fontWeight: FontWeight.w900),
                    hintStyle: TextStyle(fontSize: 30),
                    style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Card number is required";
                      }
                      if (value.replaceAll("-", "").length < 12 ||
                          value.replaceAll("-", "").length > 19) {
                        return "Card number must be 12–19 digits";
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Print Check
                  Padding(
                    padding: const EdgeInsets.only(right: 35),
                    child: PrimaryBtn(
                      textMaxSize: 30,
                      textMinSize: 30,
                      fontWeight: FontWeight.w600,
                      text: "Activate",
                      color: StaticColors.greenColor,
                      height: 110,
                      width: 230,
                      onPressed: onActive,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 35),
                    child: PrimaryBtn(
                      textMaxSize: 30,
                      textMinSize: 30,
                      fontWeight: FontWeight.w600,
                      text: "Reload",
                      color: StaticColors.greenColor,
                      height: 110,
                      width: 230,
                      onPressed: onReload,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        width: 900,
        // height: 520,
        height: 430);
  }
}
