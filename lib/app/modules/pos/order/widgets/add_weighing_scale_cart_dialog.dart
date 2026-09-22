import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogo_pos/app/formatter/decimal_formatter.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/discount_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/product_model.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class AddWingScaleCartDialog extends StatefulWidget {
  final ProductModel item;

  const AddWingScaleCartDialog({super.key, required this.item});

  @override
  State<AddWingScaleCartDialog> createState() => _AddWingScaleCartDialogState();
}



class _AddWingScaleCartDialogState extends State<AddWingScaleCartDialog> {
  String selectWingScale = Preferences.wingScale;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _wingController = TextEditingController();

  final TextEditingController _totalPriceController = TextEditingController();


  String extractWeight(String input) {
    final RegExp regex =
        RegExp(r'\d+\.\d+'); // Matches a number with decimal places

    final match = regex.firstMatch(input);

    if (match != null) {
      String weight = match.group(0) ?? '';

      return double.parse(weight).toStringAsFixed(2); // Removes leading zeros
    } else {
      return '';
    }
  }

  void _calculateTotalPrice() {
    if (_wingController.text.isNotEmpty) {
      num? wingValue = num.tryParse(_wingController.text);

      if (wingValue != null) {
        _totalPriceController.text =
            (wingValue * widget.item.price).toStringAsFixed(2);
      } else {
        _totalPriceController.clear();
      }
    } else {
      _totalPriceController.clear();
    }
  }

  // Future<void> initSerialPort() async {
  //   // testfunctiontolistentousbserialposts();
  //   try {
  //     port = SerialPort(selectWingScale);
  //     if (port != null && port!.isOpen == false) {
  //       port?.openReadWrite();
  //       port?.config = SerialPortConfig()
  //         ..baudRate = 9600
  //         ..bits = 7
  //         ..stopBits = 1
  //         ..parity = SerialPortParity.even
  //         ..rts = SerialPortRts.off
  //         ..cts = SerialPortCts.ignore
  //         ..dsr = SerialPortDsr.ignore
  //         ..dtr = SerialPortDtr.off
  //         ..setFlowControl(SerialPortFlowControl.none);
  //       kLogger.e("Serial port opened successfully.");
  //       // Read data from the serial port
  //       SerialPortReader reader = SerialPortReader(port!, timeout: 2000);
  //       Stream upcomingData = reader.stream;
  //       upcomingData.listen(
  //         (data) {
  //           try {
  //             kLogger.e('Data received: $data');
  //             final val = utf8.decode(data);
  //             _wingController.text = extractWeight(val);
  //             _calculateTotalPrice();

  //             // Process data here
  //           } catch (e) {
  //             kLogger.e('Error processing data: $e');
  //           }
  //         },
  //         onError: (error) {
  //           kLogger.e('Error in stream: $error');
  //         },
  //       );
  //       // Send the <W><CR> command
  //       sendWingScaleCommand();

  //       for (int i = 0; i < 2; i++) {
  //         await Future.delayed(const Duration(seconds: 2));
  //         sendWingScaleCommand();
  //       }
  //     }
  //   } catch (e) {
  //     kLogger.e('Error initializing serial port: $e');
  //     // PopupDialog.animatedDialog(title: "Error initializing serial port: $e");
  //   }
  // }

  // Future<void> sendWingScaleCommand() async {
  //   try {
  //     debugPrint('isOpen Port: ${port?.isOpen}');
  //     if (port?.isOpen == true) {
  //       List<int> command = utf8.encode('W\r');

  //       port?.write(Uint8List.fromList(command));

  //       kLogger.e('Command <W><CR> sent to the wing scale.');

  //       await Future.delayed(
  //           const Duration(milliseconds: 500)); // Add a small delay

  //       port?.flush();
  //     } else {
  //       kLogger.e('Serial port is not open.');
  //       PopupDialog.showErrorMessage("Serial port is not open.");
  //     }
  //   } catch (e) {
  //     kLogger.e('Error sending command to wing scale: $e');
  //   }
  // }

  @override
  void initState() {
    super.initState();
   
    _wingController.addListener(() => _calculateTotalPrice());
  }

  @override
  void dispose() {
    _wingController.dispose();
    _totalPriceController.dispose();
   
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),

        //! item name & price

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyCustomText(
              widget.item.name.toUpperCase(),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            MyCustomText(
              '\$${widget.item.price.toStringAsFixed(2)}',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),

        const SizedBox(height: 14),

        // !description

        MyCustomText(
          'Description',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),

        const SizedBox(height: 4),

        MyCustomText(
          widget.item.description == ''
              ? 'N/A'
              : MyFunc.capitalizeEachWord(s: widget.item.description),
          fontSize: 14,
          maxLines: 4,
        ),

        const SizedBox(height: 24),

        // form

        Form(
            key: _formKey,
            child: SizedBox(
              height: 87,
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _wingController,
                      keyboardType: KeyboardType.decimalFormatted,
                      prefixIcon: Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: 90,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12),
                        decoration: const BoxDecoration(
                            color: StaticColors.greenColor,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Weighing value is required';
                        }

                        return null;
                      },
                      inputFormatters: [
                       DecimalFormatter()
                      ],
                      
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _totalPriceController,
                      readOnly: true,
                      prefixIcon: Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12),
                        decoration: const BoxDecoration(
                            color: StaticColors.greenColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(4),
                              topLeft: Radius.circular(4),
                            )),
                        child: const Text(
                          'TOTAL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )),

        const SizedBox(height: 8),

        Center(
          child: PrimaryBtn(
              width: 200,
              height: 66,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // todo : add item

                  var uuid = const Uuid();

                  PosController.to.resetModifierSelections();

                  CartModel order = CartModel(
                      id: uuid.v1(),
                      itemId: widget.item.id,
                      name: widget.item.name,
                      description: widget.item.description,
                      price: num.tryParse(_totalPriceController.text) ?? 0,
                      quantity: 1,
                      weight: num.tryParse(_wingController.text) ?? 0,
                      itemType: widget.item.itemType,
                      discountAmount: 0,
                      printers: widget.item.printers,
                      discount: Discount());

                  //** Add item **

                  if (order.price == 0) {
                    PopupDialog.showErrorMessage("Weigh is required");
                  } else {
                    PosController.to.onAddCartItem(order);

                    Get.back();
                  }
                }
              },
              text: "Add"),
        )
      ],
    );
  }
}
