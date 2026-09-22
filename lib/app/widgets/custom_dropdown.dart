import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';

class MyDropdownBtn extends StatelessWidget {
  const MyDropdownBtn({
    super.key,
    this.hintText = 'Select an option',
    required this.data,
    required this.selectedValue,
    this.onChanged,
    this.menuItemPadding,
    this.dropdownStyleWidth,
  });

  final String hintText;
  final List<DropdownMenuItem<dynamic>> data;
  final dynamic selectedValue;
  final void Function(dynamic)? onChanged;
  final EdgeInsetsGeometry? menuItemPadding;
  final double? dropdownStyleWidth;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        hint: MyCustomText(
          hintText,
          fontSize: 24,
          fontWeight: FontWeight.w200,
          color: theme.hintColor,
        ),
        items: data,
        value: selectedValue,
        onChanged: onChanged,
        //button style
        buttonStyleData: ButtonStyleData(
          height: 115,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 14, right: 14),
          decoration: BoxDecoration(
            // color: theme.scaffoldBackgroundColor,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: theme.colorScheme.surface.withAlpha(100),
              width: 1,
            ),
          ),
          elevation: 0,
        ),
        //button suffix icon
        iconStyleData: IconStyleData(
          icon: const Icon(Icons.expand_more),
          iconSize: 24,
          iconEnabledColor: theme.colorScheme.surface,
          iconDisabledColor: Colors.grey,
        ),
        //dropdown items style
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: dropdownStyleWidth ?? 300,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            color: theme.cardColor,
          ),
          offset: const Offset(0, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thumbColor: WidgetStatePropertyAll(theme.colorScheme.surface),
            thickness: WidgetStateProperty.all<double>(6),
            thumbVisibility: WidgetStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: 40,
          padding:
              menuItemPadding ?? const EdgeInsets.only(left: 40, right: 14),
          overlayColor: WidgetStatePropertyAll(
            Theme.of(context).cardColor, //item selector color
          ),
        ),
      ),
    );
  }
}

class CustomDropdownButton extends StatelessWidget {
  final List data;
  final String? value;
  final Function(String?)? onChanged;
  const CustomDropdownButton(
      {super.key, required this.data, this.onChanged, this.value});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return DropdownButton<String>(
      value: value,
      iconSize: 20,
      elevation: 16,
      isDense: true,
      dropdownColor: Colors.red,
      underline: const SizedBox(),
      onChanged: onChanged,
      style: theme.textTheme.bodyMedium,
      items: List.generate(
          data.length,
          (index) => DropdownMenuItem<String>(
                value: data[index],
                child: Text(
                  data[index],
                  style: theme.textTheme.bodySmall,
                ),
              )),
    );
  }
}
