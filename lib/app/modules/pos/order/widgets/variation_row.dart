import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/pos/order/models/option_model.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_Btn.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';
import 'package:get/get.dart';

import '../models/variation_model.dart';

class VariationRow extends StatefulWidget {
  final VariationModel variation;
  final bool hasIssue;
  final Function(List<OptionModel> options) onChanged; // Always returns a list
  const VariationRow({
    super.key,
    required this.variation,
    required this.onChanged,
    this.hasIssue = false,
  });

  @override
  State<VariationRow> createState() => _VariationRowState();
}

class _VariationRowState extends State<VariationRow> {
  List<OptionModel> selectedOptions = []; // To hold selected options

// Single selection with toggle behavior
  void _singleSelect(OptionModel option, int qty) {
    setState(() {
      if (selectedOptions.contains(option)) {
        selectedOptions = []; // Deselect if already selected
      } else {
        selectedOptions = [option]; // Select the new option
      }
    });
    widget.onChanged(selectedOptions); // Passing the updated selection
  }

  void _multiSelect(OptionModel option, int qty) {
    setState(() {
      if (selectedOptions.contains(option)) {
        selectedOptions.remove(option); // Deselect if already selected
      } else {
        if (selectedOptions.length < widget.variation.max) {
          selectedOptions.add(option); // Select if not selected and below max
        }
      }
    });
    widget.onChanged(selectedOptions); // Passing the list of selected options
  }

  @override
  Widget build(BuildContext context) {
    String subtitleText;
    if (widget.variation.selectionType == "MULTIPLE") {
      subtitleText = widget.variation.min == widget.variation.max
          ? "Choose ${widget.variation.min} item(s)"
          : "Choose ${widget.variation.min} to ${widget.variation.max} items";
    } else {
      subtitleText =
          "Choose 1 item"; // Single selection usually has fixed choice
    }
    return Container(
      padding: widget.hasIssue ? const EdgeInsets.all(8) : EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          border:
              widget.hasIssue ? Border.all(color: StaticColors.redColor) : null,
          borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          MyCustomText(
            "${MyFunc.capitalizeEachWord(s: widget.variation.name)} ${widget.variation.required ? "(Required)" : ""}",
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: widget.hasIssue ? StaticColors.redColor : null,
          ),
          // Subtitle
          MyCustomText(
            subtitleText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).hintColor,
          ).marginOnly(top: 8),
          const SizedBox(height: 10),
          SizedBox(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                widget.variation.options.length,
                (index) {
                  final option = widget.variation.options[index];
                  final isSelected = selectedOptions.contains(option);
                  kLogger.e(widget.variation.options[index].name);
                  return _Btn(
                    option: option,
                    isSelected: isSelected,
                    onChanged: (qty) {
                      kLogger.i("dsd");
                      if (widget.variation.selectionType == "MULTIPLE") {
                        _multiSelect(option, qty); // MULTIPLE
                      } else {
                        _singleSelect(option, qty); // SINGLE
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final OptionModel option;
  final bool isSelected;

  const _Btn({
    required this.onChanged,
    required this.option,
    required this.isSelected,
  });

  @override
  State<_Btn> createState() => __BtnState();
}

class __BtnState extends State<_Btn> {
  int _quantity = 0;

  void _incrementQuantity() {
    setState(() {
      if (_quantity < widget.option.maxQuantity) {
        _quantity++;
        widget.onChanged(_quantity); // ✅ send updated quantity
      }
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 0) {
        _quantity--;
        widget.onChanged(_quantity); // ✅ send updated quantity
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final option = widget.option;

    return PrimaryBtnWithChild(
      onPressed: () => widget.onChanged(_quantity), // send current qty
      height: widget.option.isQuantityOn ? 150 : 90,
      width: 250,
      isOutline: true,
      color: widget.isSelected
          ? StaticColors.greenColor
          : Theme.of(Get.context!).scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              option.price.toStringAsFixed(2),
              style: theme.textTheme.titleMedium,
              maxLines: 1,
            ),
          ),
          Text(
            option.name.toUpperCase(),
            style: theme.textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Visibility(
            visible: option.isQuantityOn,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrimaryBtnWithChild(
                    onPressed: _decrementQuantity,
                    width: 40,
                    height: 40,
                    color: StaticColors.blueColor,
                    child:
                        const Icon(Icons.remove, size: 18, color: Colors.white),
                  ),
                  SizedBox(
                    width: 65,
                    child: Center(
                      child: MyCustomText(
                        "$_quantity",
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  PrimaryBtnWithChild(
                    onPressed: _incrementQuantity,
                    width: 40,
                    height: 40,
                    color: StaticColors.blueColor,
                    child: const Icon(Icons.add, size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
