import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/pos/controllers/address_controller.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/address_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_delivery_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/my_reg_exp.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class ChangeTakeoutToDelivery extends StatefulWidget {
  const ChangeTakeoutToDelivery({super.key});

  @override
  State<ChangeTakeoutToDelivery> createState() =>
      _ChangeTakeoutToDeliveryState();
}

class _ChangeTakeoutToDeliveryState extends State<ChangeTakeoutToDelivery> {
  PosController posController = Get.find<PosController>();

  final addressController = TextEditingController();
  final guestNameController = TextEditingController();
  final phoneController = TextEditingController();
  final additionalDetailsController = TextEditingController();
  final notesController = TextEditingController();

  // fouse node
  final FocusNode addressFocusNode = FocusNode();
  final FocusNode guestNameFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode additionalDetailsFocusNode = FocusNode();
  final FocusNode notesFocusNode = FocusNode();

  var activeIndex = -1;
  AddressModel? deliveryAddress;
  Timer? _debounce;

  void _onTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 2000), () {
      if (addressController.text.isNotEmpty) {
        AddressController.to.getAddress(addressController.text);
      }
    });
  }

  Future<OrderModel?> _firstOrder(
    String query, {
    bool isDelivery = false,
  }) async {
    try {
      final res = await BaseController.to.apiService.makeGetRequest(
        URLS.orders,
        queryParameters: {
          'limit': 1,
          'search': query.trim(),
          if (isDelivery) 'orderType': 'DELIVERY',
        },
      );
      if (res.statusCode == 200) {
        final data = (res.data['data'] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList();
        return data.isNotEmpty ? data.first : null;
      }
      return null;
    } catch (e) {
      kLogger.e('Order search error => $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    Get.put(AddressController());
    guestNameController.text = posController.myOrder.guestName;
    phoneController.text = posController.myOrder.guestPhoneNumber;
    additionalDetailsController.text =
        posController.myOrder.delivery?.additionalDetails ?? '';
    if (phoneController.text.length == 10) {
      _setDeliveryAddress();
    }
    // notesController.text = posController.myOrder.note ?? ''
    addressController.addListener(() {
      _onTextChanged(addressController.text);
    });
    phoneController.addListener(() {
      if (phoneController.text.length == 10) {
        _setDeliveryAddress();
      }
    });

  }

  Future<void> _setDeliveryAddress() async {
    OrderModel? order = await _firstOrder(
      phoneController.text,
      isDelivery: true,
    );
    if (order != null) {
      addressController.text = order.delivery?.address ?? '';
      additionalDetailsController.text =
          order.delivery?.additionalDetails ?? '';
      guestNameController.text = order.guestName;
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    guestNameController.dispose();
    phoneController.dispose();
    additionalDetailsController.dispose();
    notesController.dispose();
    addressFocusNode.dispose();
    guestNameFocusNode.dispose();
    phoneFocusNode.dispose();
    additionalDetailsFocusNode.dispose();
    notesFocusNode.dispose();
    _debounce?.cancel();

    Get.delete<AddressController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Switch to Delivery',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: 22),

              // Guest name + Phone
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: guestNameController,
                      focusNode: guestNameFocusNode,
                      allowRegex:
                          CommonRegexPatterns.alphanumericWithSpaceAndLength(
                            18,
                          ),
                      hintText: "Guest Name",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: phoneController,
                      focusNode: phoneFocusNode,
                      keyboardType: KeyboardType.numeric,
                      allowRegex: CommonRegexPatterns.digitsOnlyWithLength(10),
                      hintText: "Phone Number",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Address search
              CustomTextField(
                controller: addressController,
                focusNode: addressFocusNode,
                allowRegex: CommonRegexPatterns.alphanumericWithSpaceAndLength(
                  200,
                ),
                // initOpenKeyboard: true,
                maxLines: 2,
                onChange: _onTextChanged,
                autofocus: true,
                hintText: "Search Address",
              ),
              const SizedBox(height: 16),

              // Additional details
              CustomTextField(
                controller: additionalDetailsController,
                focusNode: additionalDetailsFocusNode,
                allowRegex: CommonRegexPatterns.alphanumericWithSpaceAndLength(
                  200,
                ),
                maxLines: 1,
                hintText: "Additional Details (Apt, Floor, etc.)",
              ),
              const SizedBox(height: 16),
              // Address results
              SizedBox(
                height: 200,
                child: GetBuilder<AddressController>(
                  builder: (c) {
                    return ListView.builder(
                      itemCount: c.addresses.length,
                      itemBuilder: (_, index) {
                        final isActive = activeIndex == index;
                        return InkWell(
                          onTap: () {
                            setState(() => activeIndex = index);
                            addressController.text =
                                c.addresses[index].description;
                            deliveryAddress = c.addresses[index];
                            PosController.to.selectedLat =
                                c.addresses[index].lat;
                            PosController.to.selectedLon =
                                c.addresses[index].lng;
                          },
                          splashFactory: NoSplash.splashFactory,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: ConfigController.to.isLightTheme
                                  ? Colors.white
                                  : Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isActive
                                    ? StaticColors.greenColor
                                    : (ConfigController.to.isLightTheme
                                          ? const Color.fromARGB(
                                              255,
                                              83,
                                              83,
                                              83,
                                            )
                                          : const Color.fromARGB(
                                              255,
                                              182,
                                              182,
                                              182,
                                            )),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              c.addresses[index].description,
                              style: theme.textTheme.titleSmall,
                              maxLines: 3,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Notes
              // CustomTextField(
              //   controller: notesController,
              //   allowRegex: CommonRegexPatterns.alphanumericWithSpaceAndLength(
              //     200,
              //   ),
              //   maxLines: 2,
              //   hintText: "Notes",
              //   style: theme.textTheme.displaySmall,
              // ),
              // const SizedBox(height: 8),

              // Convert button
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: PrimaryBtn(
                  color: StaticColors.greenColor,
                  textColor: Colors.white,
                  onPressed: () async {
                    //check guest name
                    if (guestNameController.text.isEmpty) {
                      PopupDialog.showErrorMessage("Guest name is required.");
                      return;
                    }
                    if (phoneController.text.isEmpty) {
                      PopupDialog.showErrorMessage("Guest phone is required.");
                    }
                    //check phone
                    //check address
                    if (activeIndex < 0 ||
                        activeIndex >= AddressController.to.addresses.length) {
                      PopupDialog.showErrorMessage(
                        duration: const Duration(seconds: 2),
                        "Please select a valid address.",
                      );
                      return;
                    }
                    if (deliveryAddress == null) {
                      PopupDialog.showErrorMessage(
                        duration: const Duration(seconds: 2),
                        "Please select a valid address.",
                      );
                      return;
                    }
                    try {
                      PopupDialog.showLoadingDialog();
                      final double? fee = await PosController.to
                          .getDeliveryFee();

                      if (fee != null) {
                        final pos = PosController.to;
                        pos.myOrder.deliveryFee = fee;
                        pos.addressController.text = addressController.text;
                        pos.myOrder.delivery = OrderDeliveryModel(
                          latitude: pos.selectedLat ?? 0.0,
                          longitude: pos.selectedLon ?? 0.0,
                          additionalDetails: additionalDetailsController.text,
                          address: addressController.text,
                        );

                        pos.myOrder.orderType = "DELIVERY";
                        pos.myOrder.guestPhoneNumber = phoneController.text;
                        pos.myOrder.guestName = guestNameController.text;

                        pos.calculateTotalPrice();

                        await pos.onUpdateOrderWithOrderType(pos.myOrder.id);
                      } else {
                        PopupDialog.showErrorMessage(
                          duration: const Duration(seconds: 2),
                          "Invalid Address",
                        );
                      }
                    } catch (e) {
                      debugPrint(e.toString());
                    } finally {
                      PopupDialog.closeLoadingDialog();
                      Get.back();
                    }
                  },
                  textMaxSize: 27,
                  textMinSize: 24,
                  width: 150,
                  height: 100,
                  text: "Convert",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
