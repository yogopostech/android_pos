import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
// import 'package:yogo_pos/app/modules/custom_keyboard/custom_keyboard.dart';
import 'package:yogo_pos/app/modules/pos/controllers/address_controller.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/address_model.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/my_reg_exp.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

SliverWoltModalSheetPage addressDialog(
    BuildContext context, ThemeData theme, String value) {
  return WoltModalSheetPage(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    hasTopBarLayer: false,
    isTopBarLayerAlwaysVisible: false,
    child: _Addrass(value),
  );
}

class _Addrass extends StatefulWidget {
  final String value;
  const _Addrass(this.value);

  @override
  State<_Addrass> createState() => _AddrassState();
}

class _AddrassState extends State<_Addrass> {
  var addressController = TextEditingController();
  var activeIndex = -1;
  AddressModel? deliveryAddress;
  Timer? _debounce;
  void _onTextChanged(String text) {
    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start new timer
    _debounce = Timer(const Duration(milliseconds: 2000), () {
      // Called when user stops typing for 800ms
      if (addressController.text.isNotEmpty) {
        AddressController.to.getAddress(addressController.text);
      }
    });
  }

  @override
  void dispose() {
    addressController.dispose();
    _debounce?.cancel();
    Get.delete<AddressController>();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Get.put(AddressController());
    addressController = TextEditingController(text: widget.value);
    addressController.addListener(() {
      _onTextChanged(addressController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white)),
      child: Column(
        children: [
          Center(
            child: Text(
              'Delivery  Address',
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall,
            ),
          ),
          SizedBox(
            height: 35,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomTextField(
              controller: addressController,
              allowRegex:
                  CommonRegexPatterns.alphanumericWithSpaceAndLength(200),
              initOpenKeyboard: true,
              maxLines: 3,
              onChange: _onTextChanged,
              autofocus: true,
              hintText: "Search Address",
              style: theme.textTheme.displaySmall,
              // hintStyle: theme.textTheme.displaySmall,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: GetBuilder<AddressController>(builder: (c) {
              return ListView.builder(
                  // shrinkWrap: true,
                  itemCount: c.addresses.length,
                  itemBuilder: (_, index) {
                    return InkWell(
                      onTap: () {
                        activeIndex = index;
                        addressController.text = c.addresses[index].description;
                        deliveryAddress = c.addresses[index];
                        PosController.to.selectedLat = c.addresses[index].lat;
                        PosController.to.selectedLon = c.addresses[index].lng;
                      },
                      splashFactory: NoSplash.splashFactory,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(
                            bottom: 16, left: 16, right: 16),
                        decoration: BoxDecoration(
                          color: ConfigController.to.isLightTheme
                              ? Colors.white
                              : Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ConfigController.to.isLightTheme
                                ? const Color.fromARGB(255, 83, 83, 83)
                                : const Color.fromARGB(255, 182, 182, 182),
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
                  });
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryBtn(
                color: StaticColors.greenColor,
                textColor: Colors.white,
                onPressed: () async {
                  if (activeIndex < 0 ||
                      activeIndex >= AddressController.to.addresses.length) {
                    PopupDialog.showErrorMessage(
                        duration: Duration(seconds: 2), "Invalid Address");
                    return;
                  }
                  PopupDialog.showLoadingDialog();
                  double? fee = await PosController.to.getDeliveryFee();
                  PopupDialog.closeLoadingDialog();
                  if (fee != null) {
                    PosController.to.addressController.text =
                        addressController.text;
                    PosController.to.myOrder.delivery?.latitude =
                        PosController.to.selectedLat ?? 0.0;
                    PosController.to.myOrder.delivery?.longitude =
                        PosController.to.selectedLon ?? 0.0;
                    PosController.to.myOrder.delivery?.address =
                        addressController.text;
                    Get.back();
                  } else {
                    PopupDialog.showErrorMessage(
                        duration: Duration(seconds: 2), "Invalid Address");
                  }
                },
                textMaxSize: 27,
                textMinSize: 24,
                width: 150,
                height: 100,
                text: "Add"),
          )
        ],
      ),
    );
  }
}

//+++++++ WoltModalType ++++++++++
// ===============================
class LeftSideSheetType extends WoltModalType {
  final EdgeInsetsDirectional padding;

  const LeftSideSheetType({
    this.padding = const EdgeInsetsDirectional.all(32.0),
  }) : super(
          shapeBorder: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          dismissDirection: WoltModalDismissDirection.up,
          showDragHandle: false,
          closeProgressThreshold: 0.8,
          barrierDismissible: true,
        );

  @override
  String routeLabel(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    return localizations.dialogLabel;
  }

  @override
  BoxConstraints layoutModal(Size availableSize) {
    // Fixed width 400, height depends on content
    return const BoxConstraints(
      minWidth: 895,
      maxWidth: 895,
      minHeight: 0,
      maxHeight: double.infinity,
    );
  }

  @override
  Offset positionModal(
    Size availableSize,
    Size modalContentSize,
    TextDirection textDirection,
  ) {
    // Center horizontally, top at 0
    final xOffset = (availableSize.width - modalContentSize.width) / 2;
    final yOffset = 30.0;
    return Offset(xOffset, yOffset);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final alphaAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 100.0 / 300.0, curve: Curves.linear),
        reverseCurve: const Interval(100.0 / 250.0, 1.0, curve: Curves.linear),
      ),
    );

    return FadeTransition(
      opacity: alphaAnimation,
      child: SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(0.0, -1.0), // Start from top off-screen
            end: Offset.zero, // Slide into position
          ).chain(CurveTween(curve: Curves.easeOutQuad)),
        ),
        child: child,
      ),
    );
  }
}
