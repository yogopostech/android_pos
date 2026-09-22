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
                  const MyCustomText(
                    'Product Name',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 4),
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
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MyCustomText(
                    'Price',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 4),
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
        const SizedBox(height: 14),
        //description
        const MyCustomText(
          'Notes',
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(height: 4),
        CustomTextField(
          controller: _kitchenNoteController,
          maxLines: 6,
          isFilled: true,
          allowRegex: CommonRegexPatterns.alphanumericWithSpaceAndLength(200),
        ),
        const SizedBox(height: 26),
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
                  .marginOnly(right: 8)),
        ),
        //quantity row
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // for Quantity
            if (foodType[foodTypeIndex] == "food" ||
                foodType[foodTypeIndex] == "drinks" ||
                foodType[foodTypeIndex] == "liquor") ...{
              const Expanded(
                child: MyCustomText(
                  'Quantity',
                  fontSize: 24,
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
                    width: 150,
                    height: 100,
                    // padding: const EdgeInsets.symmetric(horizontal: 200, vertical: 100),
                    text: 'Add',
                    color: StaticColors.blueColor,

                    textColor: Colors.white,
                    textMaxSize: 40,
                    textMinSize: 30,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: SizedBox(
                    height: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PrimaryBtnWithChild(
                          onPressed: () {
                            updateOrderQuantity(
                              false,
                            );
                          },
                          width: 50,
                          height: 50,
                          color: StaticColors.blueColor,
                          child: const Icon(
                            Icons.remove,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 65,
                          child: Center(
                            child: MyCustomText(
                              quantity.toString(),
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        PrimaryBtnWithChild(
                          onPressed: () {
                            updateOrderQuantity(true);
                          },
                          width: 50,
                          height: 50,
                          color: StaticColors.blueColor,
                          child: const Icon(
                            Icons.add,
                            size: 24,
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
              const Expanded(
                child: SizedBox(
                  child: MyCustomText(
                    'Weight',
                    fontSize: 24,
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
                    width: 150,
                    height: 100,
                    // padding: const EdgeInsets.symmetric(horizontal: 200, vertical: 100),
                    text: 'Add',
                    color: StaticColors.blueColor,

                    textColor: Colors.white,
                    textMaxSize: 40,
                    textMinSize: 30,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  // color: Colors.amber,
                  margin: const EdgeInsets.only(left: 50),
                  // height: 70,
                  child: CustomTextField(
                    controller: _wingController,
                    marginBottom: 0,
                    // keyboardType:
                    //     const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: 90,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                      decoration: const BoxDecoration(
                          color: StaticColors.blueColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(4),
                            topLeft: Radius.circular(4),
                          )),
                      child: const Text(
                        'LB',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
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
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}
