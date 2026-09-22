import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:yogo_pos/app/modules/auth/controllers/signin_controller.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';
import 'package:yogo_pos/app/utils/my_reg_exp.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/app_keyboard.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/widgets/title_bar.dart';

class SigninView extends StatefulWidget {
  const SigninView({super.key});

  @override
  State<SigninView> createState() => _SigninViewState();
}

class _SigninViewState extends State<SigninView> {
  SignInController controller = Get.find<SignInController>();

  @override
  void initState() {
    Preferences.stationId = Uuid().v4();
    Future.delayed(const Duration(milliseconds: 500), () {
      FocusScope.of(Get.context!).requestFocus(controller.emailFocusNode);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const TitleBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // header
                  8.height,
                  SizedBox(
                    child: SvgPicture.asset(
                      width: 150,
                      'assets/images/splash/yogo_logo.svg',
                      colorFilter: ColorFilter.mode(
                        ConfigController.to.isLightTheme
                            ? Colors.black
                            : Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      // color: Colors.amber,
                      width: 450,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Form(
                            key: controller.formKey,
                            child: Obx(() {
                              return Visibility(
                                visible: controller.isEmailPage.value,
                                //  for password
                                replacement: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back',
                                      style: theme.textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 6),
                                    Text.rich(
                                        TextSpan(
                                            text: controller
                                                .emailControlller.text,
                                            children: [
                                              TextSpan(
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    500), () {
                                                          // ignore: use_build_context_synchronously
                                                          FocusScope.of(context)
                                                              .requestFocus(
                                                                  controller
                                                                      .emailFocusNode);
                                                        });

                                                        BaseController.to
                                                            .playTapSound();
                                                        controller.isEmailPage
                                                            .value = true;
                                                      },
                                                text: " Change",
                                                style: theme
                                                    .textTheme.labelLarge
                                                    ?.copyWith(
                                                        color: StaticColors
                                                            .blueColor),
                                              )
                                            ]),
                                        style: theme.textTheme.labelLarge),
                                    const SizedBox(height: 16),
                                    Obx(() {
                                      return CustomTextField(
                                        initOpenKeyboard: true,
                                        keyboardType: KeyboardType.numeric,
                                        controller:
                                            controller.passwordControlller,
                                        label: const Text("Password"),
                                        allowRegex: CommonRegexPatterns
                                            .pinCodeWithLength(15),
                                        obscureText:
                                            controller.isPassHide.value,
                                        focusNode: controller.passFocusNode,
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            BaseController.to.playTapSound();
                                            controller.isPassHide.value =
                                                !controller.isPassHide.value;
                                          },
                                          child: Icon(
                                              controller.isPassHide.value ==
                                                      true
                                                  ? Icons.visibility
                                                  : Icons.visibility_off),
                                        ),
                                        validator: (value) {
                                          if (controller.isEmailPage.value ==
                                              true) {
                                            return null;
                                          } else if (value == null ||
                                              value.isEmpty) {
                                            return 'Enter a password';
                                          } else if (value.length <= 7) {
                                            return 'Password must be at least 8 characters';
                                          }
                                          return null;
                                        },
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 19),
                                        onFieldSubmitted: (value) {
                                          // login process
                                          if (Get.isDialogOpen == true) {
                                            Get.back();
                                          }
                                          controller.signInWithEmail();
                                        },
                                      );
                                    }),
                                  ],
                                ),
                                // for email
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sign in',
                                      style: theme.textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 16),
                                    GetBuilder<SignInController>(
                                        builder: (controller) {
                                      return CustomTextField(
                                        initOpenKeyboard: true,
                                        keyboardType: KeyboardType.alphaNumeric,
                                        controller: controller.emailControlller,
                                        focusNode: controller.emailFocusNode,
                                        allowRegex: CommonRegexPatterns
                                            .emailCharsWithLength(50),
                                        label: const Text("Enter your email"),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Enter an email address ';
                                          } else if (!RegExp(MyRegExp.email)
                                              .hasMatch(value)) {
                                            return "Enter an valid  email address or phone number.";
                                          }
                                          return null;
                                        },
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 19),
                                        onFieldSubmitted: (value) {
                                          //if have dialog then close it
                                          if (Get.isDialogOpen == true) {
                                            Get.back();
                                          }
                                          Future.delayed(
                                              const Duration(milliseconds: 500),
                                              () {
                                            FocusScope.of(Get.context!)
                                                .requestFocus(
                                                    controller.passFocusNode);
                                          });
                                          controller.isEmailPage.value = false;
                                        },
                                        
                                      );
                                    }),
                                  ],
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                          PrimaryBtn(
                            onPressed: () {
                              if (controller.formKey.currentState!.validate()) {
                                if (controller.isEmailPage.value) {
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    // ignore: use_build_context_synchronously
                                    FocusScope.of(context)
                                        .requestFocus(controller.passFocusNode);
                                  });

                                  controller.isEmailPage.value = false;
                                  // controller.update();
                                } else {
                                  // login process
                                  controller.signInWithEmail();
                                }
                              }
                            },
                            text: "Next",
                            textColor: Colors.white,
                            color: StaticColors.blueColor,
                            borderRadius: 4,
                          ),
                          // const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
