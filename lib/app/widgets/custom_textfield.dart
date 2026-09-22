import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogo_pos/app/formatter/regex_input_formatter.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/my_custom_text.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final bool? obscureText;
  final bool? readOnly;
  final bool? initOpenKeyboard;
  final Widget? suffixIcon;
  final RegExp? allowRegex;
  final bool isCustomKeyboard;
  final Function(String)? onKeyboardChang;

  final Widget? suffixIconColor;
  final Widget? prefixIcon;
  final String? hintText;
  final Widget? label;
  final String? extraLabel;
  final double? extraLabelFontSize;
  final TextStyle? labelStyle;
  final TextStyle? extraLabelStyle;
  final TextStyle? errorStyle;
  final VoidCallback? onTap;
  final AutovalidateMode? autovalidateMode;
  // final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChange;
  final Function(String)? onFieldSubmitted;
  final EdgeInsetsGeometry? padding;
  final FocusNode? focusNode;
  final Color? cursorColor;
  final TextAlign? textAlign;
  final double? fontSize;
  final List<TextInputFormatter>? inputFormatters;
  final bool? autofocus;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final String? errorText;
  final VoidCallback? onEditingComplete;
  final int? maxLines;
  final double? marginBottom;
  final bool isFilled;
  final double? borderRadius;
  final String? prefixText;
  final double? extralabeldownpadding;
  final KeyboardType? keyboardType;

  const CustomTextField({
    super.key,
    this.controller,
    this.obscureText,
    this.allowRegex,
    this.readOnly,
    this.onKeyboardChang,
    this.suffixIcon,
    this.prefixIcon,
    this.hintText,
    this.label,
    this.onTap,
    this.autovalidateMode,
    this.keyboardType,
    this.validator,
    this.onChange,
    this.padding,
    this.cursorColor,
    this.inputFormatters,
    this.autofocus,
    this.textAlign,
    this.fontSize,
    this.style,
    this.errorText,
    this.onEditingComplete,
    this.maxLines,
    this.suffixIconColor,
    this.extraLabel,
    this.extraLabelFontSize,
    this.extraLabelStyle,
    this.labelStyle,
    this.errorStyle,
    this.marginBottom,
    this.hintStyle,
    this.borderRadius,
    this.isFilled = false,
    this.focusNode,
    this.prefixText,
    this.onFieldSubmitted,
    this.extralabeldownpadding,
    this.initOpenKeyboard,
    this.isCustomKeyboard = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  dispose() {
    super.dispose();
    if (Preferences.customKeyboard) {
      AppKeyboard.close();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initOpenKeyboard == true &&
        Preferences.customKeyboard == true &&
        widget.isCustomKeyboard) {
      AppKeyboard.open(
        keyboardType: widget.keyboardType ?? KeyboardType.alphaNumeric,
        context,
        allowRegex: widget.allowRegex,
        focusNode: widget.focusNode,
        controller: widget.controller,
      );
      // Future.delayed(const Duration(seconds: 1), () {
      //   // use 1 second delay to ensure widget is built

      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ********** extraLabel ********
        if (widget.extraLabel != null)
          MyCustomText(
            widget.extraLabel ?? "",
            fontSize: widget.extraLabelFontSize,
          ),
        if (widget.extraLabel != null)
          SizedBox(height: widget.extralabeldownpadding ?? 10),
        TextFormField(
          // enableInteractiveSelection: false,

          // ********** controller ********
          controller: widget.controller,
          // ********** validator ********
          validator: widget.validator,
          // ********** focusNode ********
          focusNode: widget.focusNode,
          // ********** onChanged ********
          onChanged: widget.onChange,
          // ********** obscureText ********
          obscureText: widget.obscureText ?? false,
          // ********** readOnly ********
          readOnly: true,
          // ********** autovalidateMode ********
          autovalidateMode: widget.autovalidateMode,
          // ********** cursorColor ********
          cursorColor: widget.cursorColor ?? theme.primaryColor,
          // ********** maxLines ********
          maxLines: widget.maxLines ?? 1,
          // ********** autofocus ********
          autofocus: widget.autofocus ?? false,
          // ********** textAlign ********
          textAlign: widget.textAlign ?? TextAlign.start,
          // ********** onTap ********
          onTap: () {
            if (Preferences.customKeyboard &&
                widget.readOnly != true &&
                widget.isCustomKeyboard) {
              AppKeyboard.open(
                keyboardType: widget.keyboardType ?? KeyboardType.alphaNumeric,
                context,
                focusNode: widget.focusNode,
                // allowRegex: RegExp(r'^[0-9]*$'),
                allowRegex: widget.allowRegex,
                controller: widget.controller,
                onChange: widget.onKeyboardChang,
              );
            }
            if (widget.onTap != null) {
              widget.onTap!();
            }
          },
          // ********** onFieldSubmitted ********
          onFieldSubmitted: widget.onFieldSubmitted,
          // ********** style ********
          style: widget.style ?? theme.textTheme.bodyLarge,
          // ********** controller ********
          onEditingComplete: widget.onEditingComplete,
          // ********** keyboardType ********
          // keyboardType: widget.keyboardType,
          // selectionControls:
          //     MaterialTextSelectionControls(), // Use default selection controls

          //! ********** decoration ********
          decoration: InputDecoration(
            filled: widget.isFilled,
            fillColor: theme.scaffoldBackgroundColor,
            // ********** errorText ********
            errorText: widget.errorText,
            errorStyle:
                widget.errorStyle ??
                theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
            errorMaxLines: 5,
            // ********** padding ********

            contentPadding:
                widget.padding ??
                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            // ********** prefixIcon ********
            prefixIcon: widget.prefixIcon,
            prefixText: widget.prefixText,
            // ********** suffixIcon ********
            suffixIcon: widget.suffixIcon,
            // ********** border ********
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 6),
              borderSide: BorderSide(color: theme.hintColor),
            ),
            // ********** focusedBorder ********
            focusColor: theme.primaryColor,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 6),
              borderSide: BorderSide(color: theme.primaryColor),
            ),
            // ********** enabledBorder ********
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 6),
              borderSide: BorderSide(color: theme.hintColor),
            ),
            // ********** errorBorder ********
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 6),
              borderSide: const BorderSide(color: Colors.red),
            ),
            // ********** errorBorder ********
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 6),
              borderSide: const BorderSide(color: Colors.red),
            ),
            // ********** hintText ********
            hintText: widget.hintText,
            hintStyle:
                widget.hintStyle ??
                theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            // ********** label ********
            label: widget.label,
            labelStyle: widget.labelStyle ?? theme.textTheme.labelMedium,
          ),

          // ********** inputFormatters ********
          inputFormatters:
              widget.inputFormatters ??
              [
                if (widget.allowRegex != null)
                  RegexInputFormatter(widget.allowRegex!),
              ],
        ),
        // ********** marginBottom ********
        SizedBox(height: widget.marginBottom),
      ],
    );
  }
}

class CustomDropdownTextField extends StatelessWidget {
  const CustomDropdownTextField({
    super.key,
    this.label,
    required this.onChanged,
    this.hint,
    this.icon,
    this.enabledBorderColor,
    this.borderColor,
    this.hintStyle,
    this.value,
    required this.items,
  });

  final String? label;
  final Widget? hint;
  final Widget? icon;
  final Function(String?) onChanged;
  final Color? enabledBorderColor;
  final Color? borderColor;
  final TextStyle? hintStyle;
  final String? value;
  final List<DropdownMenuItem<String>>? items;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) MyCustomText(label ?? ""),
        SizedBox(height: label == null ? 0 : 8),
        DropdownButtonFormField<String>(
          hint:
              hint ??
              Text(
                'Select',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFC0C0C0),
                ),
              ),
          icon: icon,
          initialValue: value,
          dropdownColor: theme.scaffoldBackgroundColor,
          focusColor: theme.scaffoldBackgroundColor,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: theme.hintColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: theme.hintColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: theme.hintColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 14,
            ),
            focusColor: theme.scaffoldBackgroundColor,
            hintStyle:
                hintStyle ??
                theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor,
                ), // Set the background color here
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class CustomSearchTextField extends StatelessWidget {
  final dynamic controller;
  final FocusNode? textFieldFocusNode;
  final FocusNode? searchFocusNode;
  final bool? clearOption;
  final bool? searchShowCursor;
  final int? dropDownItemCount;
  final bool? enableSearch;
  final TextInputType? searchKeyboardType;
  final List<DropDownValueModel> dropDownList;
  final Function(dynamic)? onChanged;
  final String? hintText;
  final bool? searchAutofocus;
  final bool? isFilled;
  final double? radius;
  final EdgeInsets? padding;
  final String? Function(String?)? validator;
  const CustomSearchTextField({
    super.key,
    this.controller,
    this.textFieldFocusNode,
    this.searchFocusNode,
    this.clearOption,
    this.searchShowCursor,
    this.dropDownItemCount,
    this.enableSearch,
    this.searchKeyboardType,
    required this.dropDownList,
    this.onChanged,
    this.hintText,
    this.searchAutofocus,
    this.isFilled,
    this.radius,
    this.validator,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return DropDownTextField(
      padding: padding,
      controller: controller,
      clearOption: clearOption ?? true,
      textFieldFocusNode: textFieldFocusNode,
      searchFocusNode: searchFocusNode,
      searchAutofocus: searchAutofocus ?? false,
      dropDownItemCount: dropDownItemCount ?? 6,
      searchShowCursor: searchShowCursor,
      enableSearch: enableSearch ?? false,
      searchKeyboardType: searchKeyboardType,
      dropDownList: dropDownList,
      onChanged: onChanged,
      validator: validator,
      listTextStyle: theme.textTheme.labelLarge?.copyWith(color: Colors.black),
      textFieldDecoration: InputDecoration(
        filled: isFilled,
        fillColor: theme.scaffoldBackgroundColor,
        // ********** padding ********
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        // // ********** prefixIcon ********
        // prefixIcon: prefixIcon,
        // // ********** suffixIcon ********
        // suffixIcon: suffixIcon,
        // ********** border ********
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 4),
          borderSide: BorderSide(color: theme.hintColor),
        ),
        // ********** focusedBorder ********
        focusColor: theme.primaryColor,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 4),
          borderSide: BorderSide(color: theme.hintColor),
        ),
        // ********** enabledBorder ********
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 4),
          borderSide: BorderSide(color: theme.hintColor),
        ),
        // ********** errorBorder ********
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 4),
          borderSide: const BorderSide(color: Colors.red),
        ),
        // ********** errorBorder ********
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius ?? 4),
          borderSide: const BorderSide(color: Colors.red),
        ),
        // ********** hintText ********
        hintText: hintText,
        // ********** label ********
        labelStyle: theme.textTheme.labelLarge,
      ),
    );
  }
}

class CardNumberField extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  final String? labelText;
  final String? hintText;

  CardNumberField({super.key, this.labelText, this.hintText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      cursorColor: Colors.red,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        // CardNumberFormatter(),
      ],
      decoration: InputDecoration(
        fillColor: theme.scaffoldBackgroundColor,
        focusColor: theme.primaryColor,
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        errorStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: theme.hintColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.red),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.red),
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      ),
      onChanged: (value) {
        // original digits (without dash)
        String pureNumber = value.replaceAll("-", "");
        debugPrint("Digits: $pureNumber");
      },
    );
  }
}
