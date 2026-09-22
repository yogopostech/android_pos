import 'dart:async';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/setting/controllers/general_controller.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/services/models/restaurant_model.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

class General extends StatefulWidget {
  const General({super.key});

  @override
  State<General> createState() => _GeneralState();
}

class _GeneralState extends State<General> {
  List<int> windowIds = [];
  bool isCustomerDisplay = false;
  Timer? _windowTimer;

  // Future<void> getWindowId() async {
  //   final ids = await DesktopMultiWindow.getAllSubWindowIds();
  //   if (!mounted) return;

  //   if (ids.isNotEmpty && !isCustomerDisplay) {
  //     setState(() {
  //       windowIds = ids;
  //       isCustomerDisplay = true;
  //     });
  //   } else if (ids.isEmpty && isCustomerDisplay) {
  //     setState(() {
  //       windowIds = [];
  //       isCustomerDisplay = false;
  //     });
  //   }
  // }

  // onChangeCustomerDisplay(bool value) {
  //   if (isCustomerDisplay) {
  //     PopupDialog.showErrorMessage(
  //       "Customer Display is already open. Close it first from the customer display window.",
  //     );
  //     return;
  //   }
  //   PopupDialog.permissionDialogWithAccessPin(
  //     title: "Customer Display ?",
  //     onSubmit: () {
  //       setState(() {
  //         isCustomerDisplay = value;
  //       });
  //       if (isCustomerDisplay) {
  //         // Open customer display window
  //         CustomerWindowServices.openCustomerWindow();
  //       }
  //     },
  //   );
  // }

  bool fireAndLogout = false;
  // fire and logout
  onchangeFireAndLogout(bool value) {
    setState(() {
      fireAndLogout = value;
      Preferences.fireAndLogout = value;
    });
  }

  @override
  void initState() {
   
    fireAndLogout = Preferences.fireAndLogout;
  
    super.initState();
  }

  @override
  void dispose() {
    // Cancel timer when page closes
    _windowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //app sound
        GetBuilder<GeneralController>(
          builder: (context) {
            return _CustomSwitch(
              title: "App Sound",
              subtitle: "Notification Sound",
              value: context.isNotificationSound,
              onChanged: context.onChangeNotificationSound,
            );
          },
        ),

        // Custom Keyboard
        Text("Keyboard Settings", style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Container(
          width: 500,
          decoration: BoxDecoration(
            border: Border.all(
              color: ConfigController.to.isLightTheme
                  ? theme.cardColor
                  : Colors.white.withAlpha(51),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: ConfigController.to.isLightTheme
                          ? theme.cardColor
                          : Colors.white.withAlpha(51),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Custom Keyboard',
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                    GetBuilder<GeneralController>(
                      builder: (context) {
                        return Switch(
                          value: context.isCustomKeyboard,
                          onChanged: context.onChangeCustomKeyboard,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Keyboard Sound',
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                    GetBuilder<GeneralController>(
                      builder: (context) {
                        return Switch(
                          value: context.isKeyboardSound,
                          onChanged: context.onChangeKeyboardSound,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        GetBuilder<BaseController>(
          builder: (bc) {
            return Visibility(
              visible:
                  bc.restaurantDetails?.restaurant.allowLayoutChange ?? false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("POS Layout Mode", style: theme.textTheme.titleLarge),
                  8.height,
                  SizedBox(
                    width: 500,
                    child: AbsorbPointer(
                      absorbing:
                          bc
                              .restaurantDetails
                              ?.restaurant
                              .posCategoryDisplayMode !=
                          PosDisplayMode.both,
                      child: DropdownSearch<PosDisplayMode>(
                        items: (f, cs) => const [
                          PosDisplayMode.itemsOnly,
                          PosDisplayMode.categoryWithItems,
                        ],
                        selectedItem: bc.posDisplayMode,
                        itemAsString: (item) => item.label,
                        compareFn: (a, b) => a == b,
                        popupProps: PopupProps.menu(
                          fit: FlexFit.loose,
                          itemBuilder: (context, item, isSelected, isDisabled) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Text(
                                item.label,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color:
                                    Colors.grey.shade400, // ja chan seta boshan
                                width: 1,
                              ),
                            ),
                          ),
                          baseStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onSelected: (value) {
                          if (value != null) {
                            bc.posDisplayMode = value;
                            Preferences.posDisplayMode = value;
                            BaseController.to.update();
                            // print(value);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),

        _CustomSwitch(
          title: "Logout",
          subtitle: "Fire and Logout",
          value: fireAndLogout,
          onChanged: onchangeFireAndLogout,
        ),
      ],
    );
  }
}

class _CustomSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _CustomSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: ConfigController.to.isLightTheme
                    ? theme.cardColor
                    : Colors.white.withAlpha(51),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: ConfigController.to.isLightTheme
                            ? theme.cardColor
                            : Colors.white.withAlpha(51),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(subtitle, style: theme.textTheme.titleSmall),
                          ],
                        ),
                      ),
                      Switch(value: value, onChanged: onChanged),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
