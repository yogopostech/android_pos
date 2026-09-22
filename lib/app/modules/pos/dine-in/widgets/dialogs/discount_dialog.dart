import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/controllers/dine_in_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/dine_in_controller.dart';
import 'package:yogo_pos/app/modules/pos/takeout/controllers/takeout_controller.dart';
import 'package:yogo_pos/app/utils/my_reg_exp.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../../../../services/controller/base_controller.dart';

class DiscountDialog extends StatefulWidget {
  final bool isUpdateView;
  const DiscountDialog({super.key, this.isUpdateView = true});

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  TextEditingController percentageDiscoun = TextEditingController();
  TextEditingController amountDiscoun = TextEditingController();
  TextEditingController discounPin = TextEditingController();
  TextEditingController discounReason = TextEditingController();

  final FocusNode _focusNode = FocusNode();
  final FocusNode _discounReasonFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  String myDiscoun = "";
  String myDiscounPin = "";

  bool isDiscountPin = false;
  bool isPercentage = true;
  bool amountDiscounErr = false;
  onChangePercentage(bool value) {
    setState(() {
      isPercentage = value;
      _scrollToBottom();
      if (value) {
        myDiscoun = "";
        percentageDiscoun.clear();
        amountDiscoun.clear();
        isDiscountPin = false;
      } else {
        myDiscoun = "";
        percentageDiscoun.clear();
        amountDiscoun.clear();
        isDiscountPin = false;
      }
    });
  }

  onDiscountPin() {
    setState(() {
      isDiscountPin = true;
      _scrollToBottom();
    });
  }

  cleareDiscount() {
    setState(() {
      myDiscoun = "";
      percentageDiscoun.clear();
      amountDiscoun.clear();
      discounPin.clear();
    });
  }

  removeDiscount() {
    if (!isDiscountPin && myDiscoun.isNotEmpty) {
      setState(() {
        myDiscoun = myDiscoun.substring(0, myDiscoun.length - 1);
        if (isPercentage) {
          percentageDiscoun.text = myDiscoun;
        } else {
          amountDiscoun.text = myDiscoun;
        }
      });
    } else if (isDiscountPin && myDiscounPin.isNotEmpty) {
      setState(() {
        myDiscounPin = myDiscounPin.substring(0, myDiscounPin.length - 1);
        discounPin.text = myDiscounPin;
      });
    }
  }

  addValueWithKeybord(String value, {bool isKeybord = false}) {
    setState(() {
      //
      if (isPercentage && !isDiscountPin && isKeybord && myDiscoun.length < 3) {
        percentageDiscoun.clear();
        myDiscoun += value;
        percentageDiscoun.text = myDiscoun;
        if (myDiscoun.isNotEmpty) {
          if (int.parse(myDiscoun) > 101) {
            myDiscoun = "100";
            percentageDiscoun.text = myDiscoun;
          }
        }
      } else if (!isPercentage &&
          !isDiscountPin &&
          isKeybord &&
          myDiscoun.length < 4) {
        amountDiscoun.clear();
        myDiscoun += value;
        amountDiscoun.text = myDiscoun;
      } else if (isDiscountPin) {
        myDiscounPin += value;
        discounPin.text = myDiscounPin;
      } else {
        if (isPercentage) {
          amountDiscoun.clear();

          myDiscoun = value;
          // percentageDiscoun.text = myDiscoun;
          if (int.parse(myDiscoun) > 101) {
            myDiscoun = "100";
            percentageDiscoun.text = myDiscoun;
          }
        } else {
          percentageDiscoun.clear();
          myDiscoun = value;
        }
      }
    });
  }

  final ScrollController _scrollController = ScrollController();
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    percentageDiscoun.dispose();
    amountDiscoun.dispose();
    _focusNode.dispose();
    _discounReasonFocus.dispose();
    discounReason.dispose();
    discounPin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GetBuilder<PosController>(builder: (context) {
              return Text(
                context.selectedItemList.length == 1
                    ? 'Discount Item'
                    : context.selectedItemList.length ==
                            context.myOrder.carts.length
                        ? 'Discount Check '
                        : 'Discount Items',
                style: theme.textTheme.displaySmall
                    ?.copyWith(fontSize: 35, fontWeight: FontWeight.bold),
              );
            }),
          ).marginOnly(bottom: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // %%% DISCOUNT
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Transform.scale(
                          scale: 2,
                          child: Checkbox(
                            onChanged: (value) {
                              onChangePercentage(true);
                            },
                            value: isPercentage,
                          ),
                        ).marginOnly(right: 30),
                        Text(
                          'Percentage',
                          style: theme.textTheme.headlineMedium,
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    GetBuilder<PosController>(builder: (controller) {
                      return StaggeredGrid.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        children: [
                          ...List.generate(
                              controller.percentageDiscountList.length,
                              (index) {
                            var item = controller.percentageDiscountList[index];
                            return PrimaryBtn(
                              onPressed: () {
                                percentageDiscoun.clear();
                                onChangePercentage(true);
                                addValueWithKeybord(item.toString());
                                FocusScope.of(context).requestFocus(_focusNode);
                                onDiscountPin();
                              },
                              text: "$item%",
                              width: 100,
                              height: 85,
                              textColor: Colors.white,
                              color: StaticColors.greenColor,
                              fontWeight: FontWeight.bold,
                              maxLines: 1,
                              textMaxSize: 26,
                              textMinSize: 25,
                            );
                          }),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1,
                            child: CustomTextField(
                              readOnly: true,
                              controller: percentageDiscoun,
                              onChange: addValueWithKeybord,
                              onTap: () {
                                onChangePercentage(true);
                              },
                              hintText: "CUSTOM %",
                              borderRadius: 0,
                              marginBottom: 0,
                              hintStyle: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: theme.hintColor,
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 23, horizontal: 22),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(3),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}$'))
                              ],
                            ),
                          )
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              // $$$ DISOUNT
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Transform.scale(
                          scale: 2,
                          child: Checkbox(
                            onChanged: (value) {
                              onChangePercentage(false);
                            },
                            value: !isPercentage,
                          ),
                        ).marginOnly(right: 30),
                        Text(
                          'Amount',
                          style: theme.textTheme.headlineMedium,
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    GetBuilder<PosController>(builder: (controller) {
                      return StaggeredGrid.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        children: [
                          ...List.generate(controller.amountDiscountList.length,
                              (index) {
                            var item = controller.amountDiscountList[index];
                            return PrimaryBtn(
                              onPressed: () {
                                amountDiscoun.clear();
                                onChangePercentage(false);
                                addValueWithKeybord(item.toString());
                                FocusScope.of(context).requestFocus(_focusNode);
                                onDiscountPin();
                              },
                              text: "\$$item",
                              width: 100,
                              height: 85,
                              // isdisabled: isPercentage,
                              textColor: Colors.white,
                              color: StaticColors.greenColor,

                              fontWeight: FontWeight.bold,
                              maxLines: 1,
                              textMaxSize: 26,
                              textMinSize: 25,
                            );
                          }),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1,
                            child: CustomTextField(
                              readOnly: true,
                              controller: amountDiscoun,
                              onChange: addValueWithKeybord,
                              onTap: () {
                                onChangePercentage(false);
                              },
                              hintText: "CUSTOM \$",
                              marginBottom: 0,
                              borderRadius: 0,
                              hintStyle: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: theme.hintColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 23, horizontal: 22),
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(4),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}$'))
                              ],
                            ),
                          )
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          // ! DISCOUNT reason
          const SizedBox(height: 12),
          SizedBox(
            child: CustomTextField(
              controller: discounReason,
              focusNode: _discounReasonFocus,
              maxLines: 1,
              allowRegex:
                  CommonRegexPatterns.alphanumericWithSpaceAndLength(40),
              hintText: "DISCOUNT reason (character limit 40)".toUpperCase(),
              hintStyle: theme.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: theme.hintColor,
              ),
              onTap: _scrollToBottom,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontSize: 25, fontWeight: FontWeight.bold),
              borderRadius: 0,
              padding: const EdgeInsets.symmetric(vertical: 23, horizontal: 22),
            ),
          ),
          // ! Keybord area
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 22),
                    decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        border: Border.all(width: .5, color: Colors.white)),
                    child: MyCustomText(
                      isPercentage ? "$myDiscoun%" : "\$$myDiscoun",
                      fontWeight: FontWeight.w900,
                      maxLines: 1,
                      fontSize: 40,
                    ),
                  ),
                  Visibility(
                      visible: amountDiscounErr,
                      child: const Text(
                        "The discount amount should be less than the item price.",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      )),
                  const SizedBox(height: 16),
                  SizedBox(
                    child: Form(
                      key: _formKey,
                      child: CustomTextField(
                        focusNode: _focusNode,
                        controller: discounPin,
                        readOnly: true,
                        obscureText: true,
                        onTap: () {
                          onDiscountPin();
                        },
                        hintText: "DISCOUNT PIN",
                        hintStyle: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.hintColor,
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 25, fontWeight: FontWeight.bold),
                        borderRadius: 0,
                        padding: const EdgeInsets.symmetric(
                            vertical: 23, horizontal: 22),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(6),
                          // FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))
                        ],
                        validator: (value) {
                          String? pin = BaseController
                              .to.employeeData?.accessPin
                              .toString();
                          if (value == null || value.isEmpty) {
                            return 'Access pin required';
                          } else if (value != pin) {
                            return 'The pin does not match.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 62),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryBtn(
                          color: StaticColors.blueColor,
                          height: 90,
                          textColor: Colors.white,
                          width: 250,
                          textMinSize: 24,
                          textMaxSize: 38,
                          fontWeight: FontWeight.w700,
                          onPressed: () {
                            PosController.to.myOrder.discountReason = "";
                            cleareDiscount();
                          },
                          text: "Clear\nDiscount",
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: PrimaryBtn(
                          onPressed: () async {
                            // if (myDiscoun == '') {
                            //   setState(() {
                            //     amountDiscounErr = true;
                            //   });
                            // }
                            if (_formKey.currentState!.validate()) {
                              if (!isPercentage) {
                                bool isPosible =
                                    PosController.to.checkDiscountPossibilities(
                                  num.parse(myDiscoun),
                                  PosController.to.selectedItemList,
                                );
                                if (isPosible) {
                                  PosController.to.myOrder.discountReason =
                                      discounReason.text;
                                  PosController.to.applyDiscount(
                                    num.parse(myDiscoun),
                                    PosController.to.selectedItemList,
                                    isPercentage: isPercentage,
                                  );
                                  PosController.to.selectedItemList.clear();
                                  if (widget.isUpdateView) {
                                    PopupDialog.showLoadingDialog();
                                    var isUpdated = await PosController.to
                                        .onUpdateOrder(
                                            PosController.to.myOrder.id,
                                            isClearList: false);
                                    PopupDialog.closeLoadingDialog();
                                    if (isUpdated) {
                                      Get.back();
                                      // DineInOrderController
                                      await DineInOrderController.to
                                          .getOrderStatus();
                                      await DineInOrderController.to
                                          .getAllOrders();
                                      await DineInOrderController.to
                                          .clearOrderField();
                                      // Table
                                      await DineInController.to
                                          .getTableCategories();
                                      // takeout
                                      await TakeOutController.to
                                          .getAllTakeOutPaidOrders();
                                      await TakeOutController.to
                                          .getAllTakeOutUnPaidOrders();
                                    }
                                  } else {
                                    Get.back();
                                  }
                                } else {
                                  setState(() {
                                    amountDiscounErr = true;
                                  });
                                }
                              } else {
                                PosController.to.myOrder.discountReason =
                                    discounReason.text;
                                PosController.to.applyDiscount(
                                  num.parse(myDiscoun),
                                  PosController.to.selectedItemList,
                                  isPercentage: isPercentage,
                                );
                                PosController.to.selectedItemList.clear();
                                if (widget.isUpdateView) {
                                  PopupDialog.showLoadingDialog();
                                  var isUpdated = await PosController.to
                                      .onUpdateOrder(
                                          PosController.to.myOrder.id,
                                          isClearList: false);
                                  PopupDialog.closeLoadingDialog();
                                  if (isUpdated) {
                                    Get.back();
                                    // DineInOrderController
                                    await DineInOrderController.to
                                        .getOrderStatus();
                                    await DineInOrderController.to
                                        .getAllOrders();
                                    await DineInOrderController.to
                                        .clearOrderField();
                                    // Table
                                    await DineInController.to
                                        .getTableCategories();
                                    // takeout
                                    await TakeOutController.to
                                        .getAllTakeOutPaidOrders();
                                    await TakeOutController.to
                                        .getAllTakeOutUnPaidOrders();
                                  }
                                } else {
                                  Get.back();
                                }
                              }
                              // PopupDialog.closeLoadingDialog();
                            }
                          },
                          text: "OK",
                          height: 90,
                          width: 250,
                          textMinSize: 24,
                          textMaxSize: 38,
                          fontWeight: FontWeight.w700,
                          color: StaticColors.greenColor,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              )),
              const SizedBox(width: 20),
              Expanded(child: _customKeybord(theme)),
            ],
          ),
          // btn row
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _customKeybord(ThemeData theme) {
    return StaggeredGrid.count(
      crossAxisCount: 3,
      mainAxisSpacing: 3,
      crossAxisSpacing: 3,
      children: List.generate(
          PosController.to.numberList.length,
          (index) => StaggeredGridTile.count(
                crossAxisCellCount: 1,
                mainAxisCellCount: .8,
                child: SizedBox(
                  width: 100,
                  height: 85,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!isDiscountPin) {
                        if (!isPercentage && myDiscoun.length <= 3) {
                          if (isPercentage &&
                              PosController.to.numberList[index] == ".") {
                            // Todo : add a message
                          } else if (PosController.to.numberList[index] ==
                                  "." &&
                              myDiscoun.contains(".")) {
                            // Todo : add a message
                          } else if (PosController.to.numberList[index] ==
                              "X") {
                            removeDiscount();
                          } else {
                            addValueWithKeybord(
                                isKeybord: true,
                                PosController.to.numberList[index]);
                          }
                        } else if (isPercentage && myDiscoun.length <= 2) {
                          if (isPercentage &&
                              PosController.to.numberList[index] == ".") {
                            // Todo : add a message
                          } else if (PosController.to.numberList[index] ==
                                  "." &&
                              myDiscoun.contains(".")) {
                            // Todo : add a message
                          } else if (PosController.to.numberList[index] ==
                              "X") {
                            removeDiscount();
                          } else {
                            addValueWithKeybord(
                                isKeybord: true,
                                PosController.to.numberList[index]);
                          }
                        }
                      } else if (isDiscountPin) {
                        if (PosController.to.numberList[index] == "X") {
                          removeDiscount();
                        } else {
                          addValueWithKeybord(
                            isKeybord: true,
                            PosController.to.numberList[index],
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      // ****** style ******
                      textStyle: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                          fontSize: 36),
                      backgroundColor: theme.canvasColor,
                      foregroundColor: theme.dividerColor,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      // ****** Border color *******
                      side: const BorderSide(
                        color: Color(0xffEBEBEB),
                        width: .5,
                      ),
                    ),
                    child: PosController.to.numberList[index] == "X"
                        ? const Icon(
                            Icons.arrow_back_outlined,
                            color: Colors.red,
                            size: 50,
                          )
                        : MyCustomText(
                            PosController.to.numberList[index],
                            fontWeight: FontWeight.bold,
                            maxLines: 1,
                            fontSize: 33,
                          ),
                  ),
                ),
              )),
    );
  }
}
