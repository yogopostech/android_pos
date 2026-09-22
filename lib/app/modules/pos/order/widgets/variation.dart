import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/discount_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/option_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/product_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/variation_model.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_Btn.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class Variation extends StatefulWidget {
  final ProductModel item;
  final List<OptionModel>? activeOptions;
  final num? initialQuantity;

  const Variation({
    super.key,
    required this.item,
    this.activeOptions,
    this.initialQuantity,
  });

  @override
  State<Variation> createState() => _VariationState();
}

class _VariationState extends State<Variation> {
  List<VariationModel> variations = [];
  List<OptionModel> options = [];
  num quantity = 1;
  num price = 0;

  num _calculatePrice() {
    num total = 0;

    for (final variation in variations) {
      for (final option in variation.options) {
        if (option.isSelected) {
          total += option.price * option.quantity;
        }
      }
    }

    return total + price;
  }

  bool validateVariation(VariationModel variation) {
    final selectedCount = variation.options.where((o) => o.isSelected).length;

    if (variation.selectionType == 'SINGLE') {
      // SINGLE: at least one option should be selected if required
      if (variation.required && selectedCount == 0) return false;
    } else {
      // MULTIPLE: check min and max if required
      if (variation.required) {
        if (selectedCount < variation.min) return false;
        if (selectedCount > variation.max) return false;
      }
    }

    return true;
  }

  bool validateAllVariations(List<VariationModel> variations) {
    for (final variation in variations) {
      final selectedCount = variation.options.where((o) => o.isSelected).length;

      if (variation.selectionType == 'SINGLE') {
        // SINGLE: at least one option should be selected if required
        if (variation.required && selectedCount == 0) return false;
      } else {
        // MULTIPLE: check min and max if required
        if (variation.required) {
          if (selectedCount < variation.min) return false;
          if (selectedCount > variation.max) return false;
        }
      }
    }

    return true;
  }

  _changeQuantity({bool isIncrement = true}) {
    setState(() {
      if (isIncrement) {
        if (quantity < 99) {
          quantity++;
        }
      } else {
        if (quantity > 1) {
          quantity--;
        }
      }
    });
  }

  List<OptionModel> getSelectedOptions(List<VariationModel> variations) {
    final List<OptionModel> selectedOptions = [];

    for (final variation in variations) {
      for (final option in variation.options) {
        if (option.isSelected) {
          selectedOptions.add(option);
        }
      }
    }

    return selectedOptions;
  }

  void _selectVariation(int variationIndex, int optionIndex) {
    setState(() {
      final variation = variations[variationIndex];
      final options = List.of(variation.options);
      final option = options[optionIndex];

      if (variation.selectionType == 'SINGLE') {
        // SINGLE: deselect all first
        if (option.isSelected) {
          options[optionIndex] = option.copyWith(
            isSelected: false,
            quantity: 0,
          );
        } else {
          // Deselect all other options first
          for (int i = 0; i < options.length; i++) {
            options[i] = options[i].copyWith(isSelected: false, quantity: 0);
          }
          // Select the tapped option
          options[optionIndex] = option.copyWith(isSelected: true, quantity: 1);
        }
      } else {
        // MULTIPLE: check max/min
        final selectedCount = options.where((o) => o.isSelected).length;
        if (!option.isSelected) {
          // Selecting new option
          if (selectedCount >= variation.max) {
            PopupDialog.showErrorMessage(
              "Can't select more than ${variation.max} options",
            );
            return;
          }
          options[optionIndex] = option.copyWith(isSelected: true, quantity: 1);
        } else {
          options[optionIndex] = option.copyWith(
            isSelected: false,
            quantity: 0,
          );
        }
      }

      variations[variationIndex] = variation.copyWith(options: options);
    });
  }

  void _changeChildQuantity(
    int variationIndex,
    int optionIndex, {
    bool? isIncrement, // null = tap/toggle, true = +, false = -
  }) {
    setState(() {
      final variation = variations[variationIndex];

      final options = List<OptionModel>.from(variation.options);
      final option = options[optionIndex];

      if (variation.selectionType == 'SINGLE') {
        // SINGLE selection
        if (isIncrement == null || isIncrement) {
          // Tap or + → select this option only
          for (int i = 0; i < options.length; i++) {
            options[i] = options[i].copyWith(isSelected: false, quantity: 0);
          }

          // Increment quantity up to maxQuantity
          final newQty = option.quantity < option.maxQuantity
              ? option.quantity + 1
              : option.quantity;

          options[optionIndex] = option.copyWith(
            isSelected: true,
            quantity: newQty > 0 ? newQty : 1,
          );
        } else {
          // - button → decrement quantity step by step
          if (option.quantity > 1) {
            options[optionIndex] = option.copyWith(
              quantity: option.quantity - 1,
            );
          } else {
            // quantity is 1 → deselect
            options[optionIndex] = option.copyWith(
              isSelected: false,
              quantity: 0,
            );
          }
        }
      } else {
        // MULTIPLE selection
        final selectedCount = options.where((o) => o.isSelected).length;

        if (isIncrement == null) {
          // Tap = toggle
          if (!option.isSelected) {
            if (selectedCount >= variation.max) {
              PopupDialog.showErrorMessage(
                "Can't select more than ${variation.max} options",
              );
              return;
            }
            options[optionIndex] = option.copyWith(
              isSelected: true,
              quantity: 1,
            );
          }
        } else if (isIncrement) {
          // + button
          if (!option.isSelected) {
            if (selectedCount >= variation.max) {
              PopupDialog.showErrorMessage(
                "Can't select more than ${variation.max} options",
              );
              return;
            }
            options[optionIndex] = option.copyWith(
              isSelected: true,
              quantity: 1,
            );
          } else {
            // Respect option-level maxQuantity if defined
            if (option.quantity >= option.maxQuantity) {
              PopupDialog.showErrorMessage(
                "Can't exceed max quantity (${option.maxQuantity}) for this option",
              );
              return;
            }
            options[optionIndex] = option.copyWith(
              quantity: option.quantity + 1,
            );
          }
        } else {
          // - button
          if (option.quantity > 1) {
            options[optionIndex] = option.copyWith(
              quantity: option.quantity - 1,
            );
          } else {
            options[optionIndex] = option.copyWith(
              isSelected: false,
              quantity: 0,
            );
          }
        }
      }

      // Update the variation
      variations[variationIndex] = variation.copyWith(options: options);

      debugPrint(variations[variationIndex].toJson().toString());
    });
  }

  @override
  void initState() {
    variations = widget.item.variations;
    if (widget.initialQuantity != null) {
      quantity = widget.initialQuantity!;
    }

    price = widget.item.price;
    if (widget.activeOptions != null) {
      for (final variation in variations) {
        final options = List.of(variation.options);
        for (int i = 0; i < options.length; i++) {
          final option = options[i];
          final activeOption = widget.activeOptions!.firstWhereOrNull(
            (activeOption) =>
                activeOption.variationOptionId == option.variationOptionId,
          );

          if (activeOption != null) {
            options[i] = option.copyWith(
              isSelected: true,
              quantity: activeOption.quantity, // Use quantity from activeOption
            );
          }
        }
        final index = variations.indexOf(variation);
        variations[index] = variation.copyWith(options: options);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: double.infinity,
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //item info
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.item.variations.length, (index) {
                  var variation = widget.item.variations[index];
                  return _VariationRow(
                    variation: variation,
                    hasIssue: !validateVariation(variation),
                    onPressed: (int value) {
                      _selectVariation(index, value);
                    },
                    onIncrement: (int value) {
                      _changeChildQuantity(index, value, isIncrement: true);
                    },
                    onDecrement: (int value) {
                      _changeChildQuantity(index, value, isIncrement: false);
                    },
                  );
                }),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _ItemInfo(item: widget.item)),

              Visibility(
                child: Padding(
                  padding: const EdgeInsets.only(right: 50),
                  child: PrimaryBtn(
                    onPressed: () {
                      if (!validateAllVariations(variations)) {
                        PopupDialog.showErrorMessage(
                          "Please select all variations",
                        );
                        return;
                      }
                      Get.back();
                      options = getSelectedOptions(variations);
                      PosController.to.resetModifierSelections();

                      if (widget.activeOptions == null) {
                        var uuid = const Uuid();
                        CartModel order = CartModel(
                          id: uuid.v1(),
                          itemId: widget.item.id,
                          name: widget.item.name,
                          description: widget.item.description,
                          price: _calculatePrice(),
                          quantity: quantity,
                          itemType: widget.item.itemType,
                          kitchenNote: '',
                          discountAmount: 0,
                          variationOptions: options,
                          printers: widget.item.printers,
                          discount: Discount(),
                        );

                        PosController.to.onAddCartItem(order);
                      } else {
                        PosController.to.onUpdateCartItemWithOptions(
                          widget.item.id,
                          options,
                          _calculatePrice(),
                          quantity,
                        );
                      }
                    },
                    text: 'ADD',
                    textMaxSize: 22,
                    textMinSize: 18,
                    width: 150,
                    height: 100,
                    color: StaticColors.blueColor,
                    textColor: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // 100.width,
                        PrimaryBtnWithChild(
                          onPressed: () {
                            _changeQuantity(isIncrement: false);
                          },
                          width: 60,
                          height: 60,
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
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        PrimaryBtnWithChild(
                          onPressed: () {
                            _changeQuantity(isIncrement: true);
                          },
                          width: 60,
                          height: 60,
                          color: StaticColors.blueColor,
                          child: const Icon(
                            Icons.add,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: MyCustomText(
                          '\$${(_calculatePrice() * quantity).toStringAsFixed(2)}',
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                        ),
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
}

class _ItemInfo extends StatelessWidget {
  final ProductModel item;
  const _ItemInfo({required this.item});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        //! item name & price
        MyCustomText(
          item.name.toUpperCase(),
          fontSize: 20,
          fontWeight: FontWeight.w700,
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
          item.description == ''
              ? 'N/A'
              : MyFunc.capitalizeEachWord(s: item.description),
          fontSize: 14,
          maxLines: 4,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _VariationRow extends StatelessWidget {
  final VariationModel variation;
  final bool hasIssue;
  final ValueChanged<int> onPressed;
  final ValueChanged<int> onIncrement;
  final ValueChanged<int> onDecrement;

  const _VariationRow({
    required this.variation,
    required this.hasIssue,
    required this.onPressed,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String subtitleText;
    if (variation.selectionType == "MULTIPLE") {
      if (variation.min == variation.max) {
        subtitleText = "Choose ${variation.min} item(s)";
      } else if (variation.min == 1) {
        subtitleText = "Choose up to ${variation.max} items";
      } else {
        subtitleText = "Choose ${variation.min} to ${variation.max} items";
      }
    } else {
      subtitleText = "Choose 1 item";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Variation Title
          Text(
            MyFunc.capitalizeEachWord(s: variation.name),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: hasIssue
                  ? StaticColors.orangeColor
                  : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            variation.required ? "(Required) • $subtitleText" : subtitleText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),

          const SizedBox(height: 12),

          // Options
          Wrap(
            spacing: 25,
            runSpacing: 25,
            children: List.generate(variation.options.length, (index) {
              final option = variation.options[index];
              return _VariationBTN(
                option: option,
                theme: theme,
                onPressed: () => onPressed(index),
                onIncrement: option.quantity == option.maxQuantity
                    ? null
                    : () => onIncrement(index),
                onDecrement: option.quantity <= 0
                    ? null
                    : () => onDecrement(index),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _VariationBTN extends StatelessWidget {
  const _VariationBTN({
    required this.option,
    required this.theme,
    required this.onPressed,
    required this.onIncrement,
    required this.onDecrement,
  });

  final OptionModel option;
  final ThemeData theme;
  final VoidCallback onPressed;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final isSelected = option.isSelected;

    final bgColor = isSelected
        ? ConfigController.to.isLightTheme
              ? theme.cardColor
              : theme.cardColor
        : ConfigController.to.isLightTheme
        ? theme.cardColor
        : theme.cardColor;
    final borderColor = isSelected
        ? StaticColors.blueColor
        : colorScheme.outlineVariant.withAlpha(100);

    final lightTextColor = Colors.black;
    final dartTextColor = isSelected ? Colors.white : Colors.white;
    final textColor = ConfigController.to.isLightTheme
        ? lightTextColor
        : dartTextColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: 360,
      height: 70,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: isSelected ? 1.6 : .5),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: StaticColors.blueColor.withAlpha(50),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Row(
          children: [
            // Decrement button
            if (option.isQuantityOn && isSelected)
              _QuantityButton(
                icon: Icons.remove,
                onTap: onDecrement,
                color: colorScheme.primary,
              ),

            // Option info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      option.name.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${option.price.toStringAsFixed(2)}",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Increment button + quantity display
            if (option.isQuantityOn && isSelected)
              _QuantityButton(
                label: "${option.quantity}",
                onTap: onIncrement,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback? onTap;
  final Color color;

  const _QuantityButton({
    this.icon,
    this.label,
    this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8);
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        width: 44,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: StaticColors.blueColor,
          borderRadius: radius,
        ),
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 22)
            : Text(
                label ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
