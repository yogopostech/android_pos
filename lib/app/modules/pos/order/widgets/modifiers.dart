import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/modifier_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class Modifiers extends StatefulWidget {
  final ModifierModel modifier;
  final bool hasIssue;

  const Modifiers({super.key, required this.modifier, this.hasIssue = false});

  @override
  State<Modifiers> createState() => _ModifiersState();
}

class _ModifiersState extends State<Modifiers> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PosController>(
      builder: (context) {
        return Container(
          padding: widget.hasIssue ? const EdgeInsets.all(8) : EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: widget.hasIssue
                ? Border.all(color: StaticColors.redColor)
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Column(
                  children: List.generate(widget.modifier.options.length, (
                    index,
                  ) {
                    final option = widget.modifier.options[index];
                    final isSelected = context.selectedModifiers.contains(
                      option.title,
                    );
                    return _popupPrimaryBtn(
                      onChanged: () {
                        // ckeck cart is empty
                        if (PosController.to.myOrder.carts.isEmpty) {
                          PopupDialog.showErrorMessage("No item selected");
                          return;
                        }
                        if (PosController.to.selectedItemList.length > 1) {
                          PopupDialog.showErrorMessage("Select 1 item");
                          return;
                        }
                        CartModel? cart;
                        if (PosController.to.selectedItemList.isEmpty) {
                          cart = PosController.to.myOrder.carts.last;
                        } else {
                          cart = PosController.to.myOrder.carts
                              .firstWhereOrNull(
                                (c) =>
                                    c.id ==
                                    PosController.to.selectedItemList.first,
                              );
                        }
                        if (cart == null) {
                          PopupDialog.showErrorMessage("Item not found");
                          return;
                        }

                        if (cart.isUpdated) {
                          PopupDialog.showErrorMessage("Can't update modifier");
                          return;
                        }
                        if (PosController.to.selectedItemList.isEmpty) {
                          PosController.to.cartListScrollToBottom();
                        }

                        if (PosController.to.selectedItemList.length == 1) {
                          PosController.to.editModifier(
                            option.id,
                            option.title,
                            widget.modifier.id,
                          );
                        }
                        // PosController.to.getModifiers();

                        if (PosController.to.myOrder.carts.isNotEmpty &&
                            PosController.to.selectedItemList.isEmpty) {
                          if (widget.modifier.selectionType == "MULTIPLE") {
                            context.multiSelect(option.title); // MULTIPLE
                          } else {
                            List<String> titlesInGroup = widget.modifier.options
                                .map((option) => option.title)
                                .toList();

                            bool isAlreadySelected = PosController
                                .to
                                .selectedModifiers
                                .contains(option.title);

                            // Remove all existing options from that modifier group
                            PosController.to.selectedModifiers.removeWhere(
                              (item) => titlesInGroup.contains(item),
                            );

                            if (!isAlreadySelected) {
                              // Add if it wasn’t already selected
                              PosController.to.selectedModifiers.add(
                                option.title,
                              );
                              debugPrint(
                                "Selected SINGLE modifier: ${option.title}",
                              );
                            } else {
                              // Don’t add again = user double-clicked to deselect
                              debugPrint(
                                "Deselected SINGLE modifier: ${option.title}",
                              );
                            }
                            PosController.to.myOrder.carts.last.modifiers =
                                List.from(PosController.to.selectedModifiers);
                            PosController.to.update();
                            // context.singleSelect(option.title); // SINGLE
                          }
                        } else {
                          // PopupDialog.showErrorMessage("Put minimum 1 item");
                          debugPrint("Add an item");
                        }
                        if (kDebugMode) {
                          debugPrint(
                            "is cart is to ${PosController.to.cart.toString()}",
                          );
                          debugPrint(
                            "is cart is ${PosController.to.cart?.modifiers.contains(option.title)}",
                          );
                        }
                      },
                      label: option.title.toUpperCase(),
                      isSelected: isSelected,
                    ).marginOnly(bottom: 4);
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _popupPrimaryBtn({
    required VoidCallback onChanged,
    required String label,
    required bool isSelected,
  }) {
    return PrimaryBtnWithChild(
      onPressed: onChanged,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 25),
      isOutline: true,
      color: isSelected
          ? StaticColors.blueColor
          : Theme.of(Get.context!).scaffoldBackgroundColor,
      borderColor: isSelected
          ? StaticColors.blueColor
          : StaticColors.greenColor,
      child: MyCustomText(
        label.toUpperCase(),
        fontSize: 16,
        maxLines: 21,
        color: isSelected
            ? Colors.white
            : ConfigController.to.isLightTheme
            ? Colors.black
            : Colors.grey,
      ),
    ).marginOnly(bottom: 8);
  }
}
