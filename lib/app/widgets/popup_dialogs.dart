import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/gift_card_controller.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class PopupDialog {
  // SuccessDialog
  static void showSuccessDialog(
    String message, {
    double? width,
    int? maxLines,
    Duration? duration,
  }) {
    toastification.show(
      pauseOnHover: false,
      title: Text(message, maxLines: maxLines ?? 3),
      type: ToastificationType.success,
      autoCloseDuration: duration ?? Duration(milliseconds: 1500),
    );
  }

  // error messase
  static void showErrorMessage(
    String message, {
    double? width,
    int? maxLines,
    Duration? duration,
  }) {
    toastification.show(
      pauseOnHover: false,
      title: Text(message, maxLines: maxLines ?? 3),
      type: ToastificationType.error,
      autoCloseDuration: duration ?? Duration(milliseconds: 1500),
    );
  }

  static showLoadingDialog() {
    ThemeData theme = Theme.of(Get.context!);
    return showDialog<void>(
      // Context
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Column(
          // for horizontal minHeight
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // for ertical minWidth
            Center(
              child: SizedBox(
                // dialog width
                width: 120,
                height: 120,
                child: Material(
                  elevation: 2,
                  // dialog color
                  shadowColor: Colors.transparent,
                  // backgraund color
                  color: Colors.transparent,
                  // border radius
                  borderRadius: BorderRadius.circular(8),
                  // main body
                  /// DoubleBounce
                  /// SpinningLines
                  child: SpinKitRing(
                    color: theme.primaryColor,
                    size: 53, // You can customize the size
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future customDialog({
    required Widget child,
    double? width,
    double? height,
    Color? color,
    Color? iconColor,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    Widget topLavel = const SizedBox(),
    bool hasScroll = false,
    EdgeInsetsGeometry? padding,
  }) {
    return showDialog<void>(
      // Context
      context: Get.context!,
      // barrierDismissible: false,
      anchorPoint: Offset(0, 0),
      builder: (BuildContext context) {
        ThemeData theme = Theme.of(context);
        if (hasScroll) {
          return Center(
            child: SizedBox(
              height: height,
              width: width ?? MediaQuery.sizeOf(context).width * 0.7,
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: Theme.of(context).hintColor, // 👈 border color
                    width: 1.5, // 👈 border thickness
                  ),
                ),
                elevation: 3,
                // dialog color
                shadowColor: ConfigController.to.isLightTheme
                    ? Colors.black12
                    : Colors.white,
                // backgraund color
                color:
                    color ??
                    (ConfigController.to.isLightTheme
                        ? theme.canvasColor
                        : StaticColors.cartColor),

                // border radius

                /// SpinningLines
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 0,
                        top: 0,
                        bottom: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          topLavel,
                          InkWell(
                            onTap: () {
                              Get.back();
                            },
                            splashFactory: NoSplash.splashFactory,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close,
                                color:
                                    iconColor ??
                                    Theme.of(context).colorScheme.surface,
                                size: 38,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding:
                              padding ??
                              const EdgeInsets.only(
                                left: 20,
                                right: 26,
                                bottom: 20,
                              ),
                          child: child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Column(
          mainAxisAlignment: mainAxisAlignment,
          children: [
            50.height,
            Center(
              child: SizedBox(
                height: height,
                width: width ?? MediaQuery.sizeOf(context).width * 0.7,
                child: Material(
                  elevation: 3,
                  // dialog color
                  shadowColor: ConfigController.to.isLightTheme
                      ? Colors.black12
                      : Colors.white,
                  // backgraund color
                  color:
                      color ??
                      (ConfigController.to.isLightTheme
                          ? theme.canvasColor
                          : StaticColors.cartColor),
                  // border radius
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(
                      color: Theme.of(context).hintColor, // 👈 border color
                      width: 1.5, // 👈 border thickness
                    ),
                  ),

                  /// SpinningLines
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 0,
                          top: 0,
                          bottom: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            topLavel,
                            InkWell(
                              onTap: () {
                                Get.back();
                              },
                              splashFactory: NoSplash.splashFactory,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.close,
                                  color:
                                      iconColor ??
                                      Theme.of(context).colorScheme.surface,
                                  size: 38,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding:
                              padding ??
                              const EdgeInsets.only(
                                left: 20,
                                right: 26,
                                bottom: 20,
                              ),
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static searchCheckDialog({
    required Widget child,
    double? width,
    double? height,
    Color? color,
    Color? iconColor,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    Widget topLavel = const SizedBox(),
    bool hasScroll = false,
    EdgeInsetsGeometry? padding,
  }) {
    return showDialog<void>(
      // Context
      context: Get.context!,
      // barrierDismissible: false,
      anchorPoint: Offset(0, 0),
      builder: (BuildContext context) {
        ThemeData theme = Theme.of(context);
        if (hasScroll) {
          return Center(
            child: SizedBox(
              height: height,
              width: width ?? 650,
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: Theme.of(context).hintColor, // 👈 border color
                    width: 1.5, // 👈 border thickness
                  ),
                ),
                elevation: 3,
                // dialog color
                shadowColor: ConfigController.to.isLightTheme
                    ? Colors.black12
                    : Colors.white,
                // backgraund color
                color:
                    color ??
                    (ConfigController.to.isLightTheme
                        ? theme.canvasColor
                        : StaticColors.cartColor),

                // border radius

                /// SpinningLines
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 0,
                        top: 0,
                        bottom: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          topLavel,
                          InkWell(
                            onTap: () {
                              Get.back();
                            },
                            splashFactory: NoSplash.splashFactory,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close,
                                color:
                                    iconColor ??
                                    Theme.of(context).colorScheme.surface,
                                size: 38,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding:
                              padding ??
                              const EdgeInsets.only(
                                left: 20,
                                right: 26,
                                bottom: 20,
                              ),
                          child: child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Column(
          mainAxisAlignment: mainAxisAlignment,
          children: [
            105.height,
            Center(
              child: SizedBox(
                height: height,
                width: width ?? 650,
                child: Material(
                  elevation: 3,
                  // dialog color
                  shadowColor: ConfigController.to.isLightTheme
                      ? Colors.black12
                      : Colors.white,
                  // backgraund color
                  color:
                      color ??
                      (ConfigController.to.isLightTheme
                          ? theme.canvasColor
                          : StaticColors.cartColor),
                  // border radius
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(
                      color: Theme.of(context).hintColor, // 👈 border color
                      width: 1.5, // 👈 border thickness
                    ),
                  ),

                  /// SpinningLines
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 0,
                          top: 0,
                          bottom: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            topLavel,
                            InkWell(
                              onTap: () {
                                Get.back();
                              },
                              splashFactory: NoSplash.splashFactory,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.close,
                                  color:
                                      iconColor ??
                                      Theme.of(context).colorScheme.surface,
                                  size: 38,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding:
                              padding ??
                              const EdgeInsets.only(
                                left: 20,
                                right: 26,
                                bottom: 20,
                              ),
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static permissionDialog(
    ThemeData theme, {
    required void Function() onSubmit,
    void Function()? onCancle,
    TextStyle? titleStyle,
    required String title,
  }) {
    customDialog2(
      width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //title
          Text(
            title,
            style: titleStyle ?? theme.textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PrimaryBtn(
                onPressed: onSubmit,
                width: 120,
                height: 60,
                text: "Yes",
                textMaxSize: 35,
                textMinSize: 30,
                textColor: Colors.white,
                color: StaticColors.greenColor,
              ),
              const SizedBox(width: 26),
              PrimaryBtn(
                width: 120,
                height: 60,
                textMaxSize: 35,
                textMinSize: 30,
                textColor: Colors.white,
                color: StaticColors.redColor,
                onPressed:
                    onCancle ??
                    () {
                      Get.back();
                    },
                text: "No",
              ),
            ],
          ),
        ],
      ),
    );
  }

  static animatedDialog({
    required String title,
    double? width,
    double? height,
    bool isErr = false,
  }) {
    return showDialog<void>(
      // Context
      barrierColor: Colors.transparent,
      context: Get.context!,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        ThemeData theme = Theme.of(context);
        return Center(
          child: SizedBox(
            height: height,
            width: width,
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: Theme.of(context).hintColor, // 👈 border color
                  width: 1.5, // 👈 border thickness
                ),
              ),
              elevation: 3,
              // dialog color
              // shadowColor: ConfigController.to.isLightTheme
              //     ? Colors.black12
              //     : Colors.white,
              // backgraund color
              color: theme.cardColor,
              // border radius

              /// SpinningLines
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: Get.back,
                          splashFactory: NoSplash.splashFactory,
                          child: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.surface,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 30,
                          right: 30,
                          bottom: 60,
                        ),
                        child: Column(
                          children: [
                            Lottie.asset(
                              'assets/animations/success.json',
                              height: 150,
                              repeat: true,
                              reverse: true,
                              fit: BoxFit.cover,
                            ),
                            // const SizedBox(height: 20),
                            AnimatedTextKit(
                              repeatForever: true,
                              animatedTexts: [
                                ColorizeAnimatedText(
                                  title,
                                  textStyle:
                                      Get.textTheme.displaySmall as TextStyle,
                                  textAlign: TextAlign.center,
                                  colors: [
                                    Colors.red,
                                    Colors.blue,
                                    Colors.yellow,
                                    Colors.red,
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static permissionDialogWithAccessPin({
    required String title,
    required void Function() onSubmit,
  }) {
    customDialog(
      width: 500,
      child: PermissionWithAccessPin(title: title, onSubmit: onSubmit),
    );
  }

  // close dialog
  static void closeLoadingDialog() {
    Get.back();
  }

  static customDialog1({
    required Widget child,
    double? width,
    double? height,
    Color? color,
    Color? iconColor,
    Color? borderColor,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    Widget topLavel = const SizedBox(),
    bool hasScroll = false,
    EdgeInsetsGeometry? padding,
  }) {
    return showDialog<void>(
      context: Get.context!,
      anchorPoint: Offset(10, 5),
      builder: (BuildContext context) {
        ThemeData theme = Theme.of(context);
        return Center(
          child: SizedBox(
            height: height,
            width: width ?? MediaQuery.sizeOf(context).width * 0.7,
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: color ?? Colors.transparent, // 👈 border color
                  width: 1, // 👈 border thickness
                ),
              ),
              elevation: 3,
              shadowColor: ConfigController.to.isLightTheme
                  ? Colors.black12
                  : Colors.white,
              color:
                  color ??
                  (ConfigController.to.isLightTheme
                      ? theme.canvasColor
                      : StaticColors.cartColor),
              // borderRadius: BorderRadius.circular(6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 0,
                      top: 0,
                      bottom: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        topLavel,
                        InkWell(
                          onTap: Get.back,
                          splashFactory: NoSplash.splashFactory,
                          child: Icon(
                            Icons.close,
                            color:
                                iconColor ??
                                Theme.of(context).colorScheme.surface,
                            size: 38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: hasScroll
                        ? SingleChildScrollView(
                            child: Padding(
                              padding:
                                  padding ??
                                  const EdgeInsets.only(
                                    left: 20,
                                    right: 26,
                                    bottom: 20,
                                  ),
                              child: child,
                            ),
                          )
                        : Padding(
                            padding:
                                padding ??
                                const EdgeInsets.only(
                                  left: 20,
                                  right: 26,
                                  bottom: 20,
                                ),
                            child: child,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static customDialog2({
    required Widget child,
    double? width,
    double? height,
    Color? color,
    Color? iconColor,
    bool barrierDismissible = true,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    Widget topLavel = const SizedBox(),
    bool hasScroll = false,
    EdgeInsetsGeometry? padding,
  }) {
    GiftCardController controller = Get.put(GiftCardController());
    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: barrierDismissible,
      anchorPoint: Offset(10, 5),
      builder: (BuildContext context) {
        ThemeData theme = Theme.of(context);
        return Center(
          child: SizedBox(
            height: height,
            width: width ?? MediaQuery.sizeOf(context).width * 0.7,
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: Theme.of(context).hintColor, // 👈 border color
                  width: 1.5, // 👈 border thickness
                ),
              ),
              elevation: 3,
              // dialog color
              shadowColor: ConfigController.to.isLightTheme
                  ? Colors.black12
                  : Colors.white,
              // backgraund color
              color:
                  color ??
                  (ConfigController.to.isLightTheme
                      ? theme.canvasColor
                      : StaticColors.cartColor),
              // borderRadius: BorderRadius.circular(6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 0,
                      right: 5,
                      top: 5,
                      bottom: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        topLavel,
                        InkWell(
                          onTap: Get.back,
                          splashFactory: NoSplash.splashFactory,
                          child: Icon(
                            Icons.close,
                            color:
                                iconColor ??
                                Theme.of(context).colorScheme.surface,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: hasScroll
                        ? SingleChildScrollView(
                            child: Padding(
                              padding:
                                  padding ??
                                  const EdgeInsets.only(
                                    left: 20,
                                    right: 26,
                                    bottom: 20,
                                  ),
                              child: child,
                            ),
                          )
                        : Padding(
                            padding:
                                padding ??
                                const EdgeInsets.only(
                                  left: 20,
                                  right: 26,
                                  bottom: 20,
                                ),
                            child: child,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      // ✅ Dialog বন্ধ হলেই clear হবে
      controller.textControllerRemove();
    });
  }

  static customCenterDialog({
    required Widget child,
    double? width,
    double? height,
    Color? color,
    Color? iconColor,
    Widget topLavel = const SizedBox(),
    bool hasScroll = false,
    EdgeInsetsGeometry? padding,
  }) {
    return showDialog<void>(
      context: Get.context!,
      builder: (BuildContext context) {
        ThemeData theme = Theme.of(context);

        final dialogContent = SizedBox(
          height: height,
          width: width ?? MediaQuery.sizeOf(context).width * 0.7,
          child: Material(
            elevation: 3,
            shadowColor: ConfigController.to.isLightTheme
                ? Colors.black12
                : Colors.white,
            color:
                color ??
                (ConfigController.to.isLightTheme
                    ? theme.canvasColor
                    : StaticColors.cartColor),
            borderRadius: BorderRadius.circular(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 0,
                    top: 0,
                    bottom: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      topLavel,
                      InkWell(
                        onTap: Get.back,
                        splashFactory: NoSplash.splashFactory,
                        child: Icon(
                          Icons.close,
                          color:
                              iconColor ??
                              Theme.of(context).colorScheme.surface,
                          size: 38,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: hasScroll
                      ? SingleChildScrollView(
                          child: Padding(
                            padding:
                                padding ??
                                const EdgeInsets.only(
                                  left: 20,
                                  right: 26,
                                  bottom: 20,
                                ),
                            child: child,
                          ),
                        )
                      : Padding(
                          padding:
                              padding ??
                              const EdgeInsets.only(
                                left: 20,
                                right: 26,
                                bottom: 20,
                              ),
                          child: child,
                        ),
                ),
              ],
            ),
          ),
        );

        // Center the dialog
        return Center(child: dialogContent);
      },
    );
  }
}

class PermissionWithAccessPin extends StatefulWidget {
  final String title;
  final void Function() onSubmit;
  const PermissionWithAccessPin({
    super.key,
    required this.title,
    required this.onSubmit,
  });

  @override
  State<PermissionWithAccessPin> createState() =>
      _PermissionWithAccessPinState();
}

class _PermissionWithAccessPinState extends State<PermissionWithAccessPin> {
  String? pin = BaseController.to.employeeData?.accessPin.toString();
  final TextEditingController _pin = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  //focus node
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _pin.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _focusNode.requestFocus();
    _pin.addListener(() {
      if (_pin.text.length >= 4) {
        if (pin != null && pin == _pin.text) {
          if (Get.isDialogOpen!) {
            Get.back();
          }
          Get.back();

          widget.onSubmit();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: theme.textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        Text('Access Pin', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 6),
        Form(
          key: _formKey,
          child: CustomTextField(
            controller: _pin,
            keyboardType: KeyboardType.numeric,
            maxLines: 1,
            isFilled: true,
            obscureText: true,
            focusNode: _focusNode,
            style: theme.textTheme.headlineSmall,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 22),
            validator: (value) {
              kLogger.e(pin);
              if (value == null || value.isEmpty) {
                return 'Please enter your Access Pin';
              } else if (value != pin) {
                return 'Incorrect password.';
              }
              return null;
            },
            inputFormatters: [
              LengthLimitingTextInputFormatter(6),
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrimaryBtn(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSubmit();
                }
              },
              width: 120,
              height: 60,
              text: "Yes",
              textMaxSize: 35,
              textMinSize: 30,
              textColor: Colors.white,
              color: StaticColors.greenColor,
            ),
            const SizedBox(width: 16),
            PrimaryBtn(
              width: 120,
              height: 60,
              textMaxSize: 35,
              textMinSize: 30,
              textColor: Colors.white,
              color: StaticColors.redColor,
              onPressed: () {
                Get.back();
              },
              text: "No",
            ),
          ],
        ),
      ],
    );
  }
}
