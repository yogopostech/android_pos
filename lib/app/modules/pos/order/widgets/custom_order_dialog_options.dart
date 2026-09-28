import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yogo_pos/config/screen_config.dart';
import 'package:flutter/material.dart';
import 'package:yogo_pos/app/formatter/decimal_formatter.dart';
// import 'package:yogo_pos/app/modules/custom_keyboard/custom_keyboard.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/discount_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/utils/extension/num_extensions.dart';
import 'package:yogo_pos/app/utils/my_reg_exp.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class CustomOrderDialogOptions extends StatefulWidget {
  // final bool? isLiquor;
  const CustomOrderDialogOptions({super.key});

  @override
  State<CustomOrderDialogOptions> createState() =>
      _CustomOrderDialogOptionsState();
}

class _CustomOrderDialogOptionsState extends State<CustomOrderDialogOptions> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _kitchenNoteController = TextEditingController();
  final TextEditingController _wingController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();

  // int variationsActiveIndex = -1;
  // int orderTypeActiveIndex = 0;
  // int orderType2ActiveIndex = 0;
  int quantity = 1;
  num orderTotalPrice = 0;
  // food type
  List<String> foodType = ["food", "drinks", "liquor", "No Tax"];
  int foodTypeIndex = 0;
  onchangeFoodTypeIndex(int index) {
    foodTypeIndex = index;
    quantity = 1;
    _wingController.clear();
    onCalculatTotalPrice();

    setState(() {});
  }

  //** Calculate Price **
  void onCalculatTotalPrice() {
    if (foodType[foodTypeIndex] == "No Tax") {
      num? weightValue = num.tryParse(_wingController.text);
      num? priceValue = num.tryParse(_priceController.text);
      if (weightValue != null && priceValue != null) {
        orderTotalPrice = (weightValue * priceValue);
      } else {
        orderTotalPrice = 0;
      }
    } else {
      num? priceValue = num.tryParse(_priceController.text);
      if (priceValue != null) {
        orderTotalPrice = (priceValue * quantity);
      } else {
        orderTotalPrice = 0;
      }
      // orderTotalPrice = num.parse(value) * quantity;
    }
    setState(() {});
  }

  //** Update quantity **
  void updateOrderQuantity(bool isIncrease) {
    if (_priceController.text.isNotEmpty) {
      if (isIncrease && quantity < 10) {
        quantity++;
        orderTotalPrice = num.parse(_priceController.text) * quantity;
      } else if (!isIncrease && quantity > 1) {
        quantity--;
        orderTotalPrice = num.parse(_priceController.text) * quantity;
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _kitchenNoteController.dispose();
    _wingController.dispose();
    _nameFocus.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _priceController.addListener(() => onCalculatTotalPrice());
    _wingController.addListener(() => onCalculatTotalPrice());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyCustomText(
                    'Product Name',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 4.r),
                  CustomTextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    maxLines: 1,
                    isFilled: true,
                    keyboardType: KeyboardType.alphaNumeric,
                    allowRegex:
                        CommonRegexPatterns.alphanumericWithSpaceAndLength(100),
                    // maxLines: 1,
                    // isFilled: true,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyCustomText(
                    'Price',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 4.r),
                  CustomTextField(
                    controller: _priceController,
                    maxLines: 1,
                    isFilled: true,
                    // readOnly: true,
                    keyboardType: KeyboardType.decimalFormatted,
                    inputFormatters: [DecimalFormatter()],
         
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 14.r),
        //description
        MyCustomText(
          'Notes',
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
        ),
        SizedBox(height: 4.r),
        CustomTextField(
          controller: _kitchenNoteController,
          maxLines: 6,
          isFilled: true,
          allowRegex: CommonRegexPatterns.alphanumericWithSpaceAndLength(200),
        ),
        SizedBox(height: 26.r),
        // ! food type
        Row(
          children: List.generate(
              foodType.length,
              (index) => PrimaryBtn(
                      isOutline: true,
                      textColor: Colors.white,
                      borderColor: foodTypeIndex == index
                          ? StaticColors.orangeColor
                          : Colors.transparent,
                      color: StaticColors.blueColor,
                      onPressed: () {
                        onchangeFoodTypeIndex(index);
                      },
                      text: foodType[index].toUpperCase())
                  .marginOnly(right: 8.r)),
        ),
        //quantity row
        SizedBox(height: 30.r),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // for Quantity
            if (foodType[foodTypeIndex] == "food" ||
                foodType[foodTypeIndex] == "drinks" ||
                foodType[foodTypeIndex] == "liquor") ...{
              Expanded(
                child: MyCustomText(
                  'Quantity',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: PrimaryBtn(
                    onPressed: () {
                      var uuid = const Uuid();
                      CartModel item = CartModel(
                        id: uuid.v1(),
                        itemId: uuid.v1(),
                        isCustomProduct: true,
                        weight: num.tryParse(_wingController.text) ?? 0,
                        name: _nameController.text,
                        kitchenNote: _kitchenNoteController.text,
                        itemType: foodType[foodTypeIndex] == "No Tax"
                            ? "weighing scale"
                            : foodType[foodTypeIndex],
                        price: foodType[foodTypeIndex] != "No Tax"
                            ? num.parse(_priceController.text)
                            : (num.parse(_priceController.text) *
                                    (num.tryParse(_wingController.text) ?? 0))
                                .toFixed2(),
                        quantity: quantity,
                        discount: Discount(),
                      );
                      // print(item.toJson());
                      if (_nameController.text.isEmpty) {
                        PopupDialog.showErrorMessage("Name Field Is Required ");
                      } else if (_priceController.text.isEmpty) {
                        PopupDialog.showErrorMessage("Price Field Is Required");
                      } else if (orderTotalPrice == 0) {
                        PopupDialog.showErrorMessage(
                            "The total price will be more than zero.");
                      } else {
                        PosController.to.onAddCartItem(item);
                        Get.back();
                        // PopupDialog.showSuccessDialog("Cart Items Added Successfully");
                      }
                    },
                    width: 150.r,
                    height: 100.r,
                    // padding: const EdgeInsets.symmetric(horizontal: 200, vertical: 100),
                    text: 'Add',
                    color: StaticColors.blueColor,

                    textColor: Colors.white,
                    textMaxSize: 40.sp.roundToDouble(),
                    textMinSize: 30.sp.roundToDouble(),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 50.r),
                  child: SizedBox(
                    height: 70.r,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PrimaryBtnWithChild(
                          onPressed: () {
                            updateOrderQuantity(
                              false,
                            );
                          },
                          width: 50.rMin(kMinTouch),
                          padding: EdgeInsets.zero,
                          height: 50.rMin(kMinTouch),
                          color: StaticColors.blueColor,
                          child: Icon(
                            Icons.remove,
                            size: 24.r,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 65.r,
                          child: Center(
                            child: MyCustomText(
                              quantity.toString(),
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        PrimaryBtnWithChild(
                          onPressed: () {
                            updateOrderQuantity(true);
                          },
                          width: 50.rMin(kMinTouch),
                          padding: EdgeInsets.zero,
                          height: 50.rMin(kMinTouch),
                          color: StaticColors.blueColor,
                          child: Icon(
                            Icons.add,
                            size: 24.r,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            },

            if (foodType[foodTypeIndex] == "No Tax") ...{
              Expanded(
                child: SizedBox(
                  child: MyCustomText(
                    'Weight',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: PrimaryBtn(
                    onPressed: () {
                      var uuid = const Uuid();
                      CartModel item = CartModel(
                          id: uuid.v1(),
                          itemId: uuid.v1(),
                          isCustomProduct: true,
                          weight: num.tryParse(_wingController.text) ?? 0,
                          name: _nameController.text,
                          kitchenNote: _kitchenNoteController.text,
                          itemType:
                              foodType[foodTypeIndex] == "No Tax"
                                  ? "weighing scale"
                                  : foodType[foodTypeIndex],
                          price: foodType[foodTypeIndex] != "No Tax"
                              ? num.parse(_priceController.text)
                              : (num.parse(_priceController.text) *
                                      (num.tryParse(_wingController.text) ?? 0))
                                  .toFixed2(),
                          quantity: quantity,
                          discount: Discount());
                      // print(item.toJson());
                      if (_nameController.text.isEmpty) {
                        PopupDialog.showErrorMessage("Name Field Is Required ");
                      } else if (_priceController.text.isEmpty) {
                        PopupDialog.showErrorMessage("Price Field Is Required");
                      } else if (orderTotalPrice == 0) {
                        PopupDialog.showErrorMessage(
                            "The total price will be more than zero.");
                      } else {
                        PosController.to.onAddCartItem(item);
                        Get.back();
                        // PopupDialog.showSuccessDialog("Cart Items Added Successfully");
                      }
                    },
                    width: 150.r,
                    height: 100.r,
                    // padding: const EdgeInsets.symmetric(horizontal: 200, vertical: 100),
                    text: 'Add',
                    color: StaticColors.blueColor,

                    textColor: Colors.white,
                    textMaxSize: 40.sp.roundToDouble(),
                    textMinSize: 30.sp.roundToDouble(),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  // color: Colors.amber,
                  margin: EdgeInsets.only(left: 50.r),
                  // height: 70,
                  child: CustomTextField(
                    controller: _wingController,
                    marginBottom: 0,
                    // keyboardType:
                    //     const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: Container(
                      margin: EdgeInsets.only(right: 6.r),
                      width: 90.r,
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.r, vertical: 12.r),
                      decoration: BoxDecoration(
                          color: StaticColors.blueColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(4.r),
                            topLeft: Radius.circular(4.r),
                          )),
                      child: Text(
                        'LB',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    style: TextStyle(
                        fontSize: 22.sp, fontWeight: FontWeight.bold),
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Weighing value is required';
                    //   }
                    //   return null;
                    // },
                    keyboardType: KeyboardType.decimalFormatted,
                    inputFormatters: [
                      DecimalFormatter(),
                    ],
                  ),
                ),
              )
            },
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: MyCustomText(
                  '\$${orderTotalPrice.toStringAsFixed(2)}',
                  fontSize: 35.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 28.r),
      ],
    );
  }
}
