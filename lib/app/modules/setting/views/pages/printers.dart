import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/setting/controllers/printers_controller.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';

class Printers extends GetView<PrintersController> {
  const Printers({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    controller.getPrinters();

    return GetBuilder<ConfigController>(
      builder: (c) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Printer Settings', style: theme.textTheme.displayMedium),
              const SizedBox(height: 35),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Counter Printer',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        return SizedBox(
                          width: 320,
                          child: CustomTextField(
                            controller: controller.counterPrinterController,
                            hintText: controller.counterPrinter.value.isEmpty
                                ? "Select Counter Printer"
                                : controller.counterPrinter.value,
                            //allow 123.232.323.23 max 10 characters ip address only numbers and dots not letters
                            allowRegex: RegExp(r'^[0-9\.]{0,18}$'),
                          ),
                        );
                        // return CustomSearchTextField(
                        //   hintText: controller.counterPrinter.value.isEmpty
                        //       ? "Select Counter Printer"
                        //       : controller.counterPrinter.value,
                        //   dropDownList: List.generate(
                        //       controller.availablePrinters.length, (index) {
                        //     return DropDownValueModel(
                        //       value: controller.availablePrinters[index].name,
                        //       name: controller.availablePrinters[index].name,
                        //     );
                        //   }),
                        //   onChanged: (value) {
                        //     controller.onChangeCounterPrinter(value);
                        //   },
                        // );
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kitchen Printer',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        return SizedBox(
                          width: 320,
                          child: CustomTextField(
                            controller: controller.kitchenPrinterController,
                            //allow 123.232.323.23 max 10 characters ip address
                            allowRegex: RegExp(r'^[0-9\.]{0,18}$'),
                            hintText: controller.kitchenPrinter.value.isEmpty
                                ? "Select Kitchen Printer"
                                : controller.kitchenPrinter.value,
                            onChange: (value) {
                              controller.onChangeKitchenPrinter(value);
                            },
                          ),
                        );
                        // return CustomSearchTextField(
                        //   hintText: controller.kitchenPrinter.value.isEmpty
                        //       ? "Select Kitchen Printer"
                        //       : controller.kitchenPrinter.value,
                        //   dropDownList: List.generate(
                        //       controller.availablePrinters.length, (index) {
                        //     return DropDownValueModel(
                        //       value: controller.availablePrinters[index].name,
                        //       name: controller.availablePrinters[index].name,
                        //     );
                        //   }),
                        //   onChanged: (value) {
                        //     controller.onChangeKitchenPrinter(value);
                        //   },
                        // );
                      }),
                    ],
                  ),
                ],
              ),
              // Row(
              //     children: [
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               'Counter Printer',
              //               style: theme.textTheme.titleLarge,
              //             ),
              //             const SizedBox(height: 8),
              //             Obx(() {
              //               return CustomSearchTextField(
              //                 hintText: controller.counterPrinter.value.isEmpty
              //                     ? "Select Counter Printer"
              //                     : controller.counterPrinter.value,
              //                 dropDownList: List.generate(
              //                   controller.availablePrinters.length,
              //                   (index) {
              //                     return DropDownValueModel(
              //                       value: controller
              //                           .availablePrinters[index]
              //                           .name,
              //                       name: controller
              //                           .availablePrinters[index]
              //                           .name,
              //                     );
              //                   },
              //                 ),
              //                 onChanged: (value) {
              //                   controller.onChangeCounterPrinter(value);
              //                 },
              //               );
              //             }),
              //           ],
              //         ),
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               'Kitchen Printer',
              //               style: theme.textTheme.titleLarge,
              //             ),
              //             const SizedBox(height: 8),
              //             Obx(() {
              //               return CustomSearchTextField(
              //                 hintText: controller.kitchenPrinter.value.isEmpty
              //                     ? "Select Kitchen Printer"
              //                     : controller.kitchenPrinter.value,
              //                 dropDownList: List.generate(
              //                   controller.availablePrinters.length,
              //                   (index) {
              //                     return DropDownValueModel(
              //                       value: controller
              //                           .availablePrinters[index]
              //                           .name,
              //                       name: controller
              //                           .availablePrinters[index]
              //                           .name,
              //                     );
              //                   },
              //                 ),
              //                 onChanged: (value) {
              //                   controller.onChangeKitchenPrinter(value);
              //                 },
              //               );
              //             }),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),

              const SizedBox(height: 22),
              SizedBox(
                width: 650,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   'Paper Width',
                          //   style: theme.textTheme.titleLarge,
                          // ),
                          // const SizedBox(height: 8),
                          // CustomTextField(
                          //   hintText: Preferences.paperWidth,
                          //   keyboardType: KeyboardType.alphaNumeric,
                          //   // allowRegex: CommonRegexPatterns.decimalWithLength(2),
                          // )
                          // DropdownSearch<PrinterType>(
                          //   onBeforePopupOpening: (_) async {
                          //     // do something first
                          //     return false; // return false to prevent opening
                          //   },
                          //   items: (f, cs) => PrinterType.values,
                          //   selectedItem: Preferences.printerType,
                          //   itemAsString: (item) => item.label,
                          //   compareFn: (a, b) => a == b,
                          //   popupProps: PopupProps.menu(
                          //     fit: FlexFit.loose,
                          //   ),
                          //   decoratorProps: const DropDownDecoratorProps(
                          //     decoration: InputDecoration(
                          //       labelText: 'Printer Type',
                          //       prefixIcon: Icon(Icons.print),
                          //       border: OutlineInputBorder(),
                          //     ),
                          //   ),
                          //   onSelected: (value) {
                          //     if (value != null) {
                          //       Preferences.printerType = value;
                          //     }
                          //   },
                          // ),
                          // SizedBox(
                          //   height: 16,
                          // ),
                          // DropdownSearch<DrawerPin>(
                          //   items: (f, cs) => DrawerPin.values,
                          //   selectedItem: Preferences.drawerPin,
                          //   itemAsString: (item) => item.label,
                          //   compareFn: (a, b) => a == b,
                          //   popupProps: PopupProps.menu(fit: FlexFit.loose),
                          //   decoratorProps: const DropDownDecoratorProps(
                          //     decoration: InputDecoration(
                          //       labelText: 'Drawer Pin',
                          //       prefixIcon: Icon(Icons.point_of_sale),
                          //       border: OutlineInputBorder(),
                          //     ),
                          //   ),
                          //   onSelected: (value) {
                          //     if (value != null) {
                          //       Preferences.drawerPin = value;
                          //     }
                          //   },
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
              // olo print
              const SizedBox(height: 20),
              //** kitchen print **
              // Obx(() {
              //   return _switch(
              //     theme: theme,
              //     value: controller.oloPrint.value,
              //     onChanged: controller.onOloPrint,
              //     title: "OLO Kitchen Print",
              //   );
              // }),
              // Obx(() {
              //   return _switch(
              //     theme: theme,
              //     value: controller.deliveryOrderPrint.value,
              //     onChanged: controller.onDeliveryOrderPrint,
              //     title: "Delivery Kitchen Print",
              //   );
              // }),
              // SizedBox(height: 25),
              // Obx(() {
              //   return _switch(
              //     theme: theme,
              //     value: controller.oloCustomerPrint.value,
              //     onChanged: controller.onOloCustomerPrint,
              //     title: "Auto-print Receipt for OLO Takeout",
              //   );
              // }),
              Obx(() {
                return _switch(
                  theme: theme,
                  value: controller.takeOutCustomerReceipt.value,
                  onChanged: controller.onTakeOutCustomerReceipt,
                  title: "Auto-print Receipt for POS Takeout",
                );
              }),
              // const SizedBox(height: 25),
              // Obx(() {
              //   return _switch(
              //     theme: theme,
              //     value: controller.deliveryCustomerReceipt.value,
              //     onChanged: controller.onDeliveryCustomerOrderPrint,
              //     title: "Auto-print receipt for OLO Delivery",
              //   );
              // }),

              // Obx(() {
              //   return _switch(
              //     theme: theme,
              //     value: controller.deliveryPOSCustomerReceipt.value,
              //     onChanged: controller.onDeliveryPOSCustomerReceipt,
              //     title: "Auto-print Receipt for POS Delivery",
              //   );
              // }),
              // SizedBox(height: 20),
              Visibility(
                visible:
                    BaseController.to.restaurantDetails?.printerSelectionMode !=
                    "MULTIPLE",
                child: Obx(() {
                  return _switch(
                    theme: theme,
                    value: controller.skipPrint.value,
                    onChanged: controller.onSkipPrint,
                    title: "Skip Print",
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _switch({
  required ThemeData theme,
  required bool value,
  required Function(bool) onChanged,
  required String title,
}) {
  return SizedBox(
    width: 400,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    ),
  );
}

// import 'package:dropdown_textfield/dropdown_textfield.dart';
// import 'package:flutter/material.dart';
// import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
// import 'package:yogo_pos/app/modules/setting/controllers/printers_controller.dart';
// import 'package:yogo_pos/app/widgets/custom_textfield.dart';
// import 'package:get/get.dart';

// class Printers extends GetView<PrintersController> {
//   const Printers({super.key});

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     controller.getPrinters();
//     return GetBuilder<PosController>(builder: (c) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Printer Settings',
//             style: theme.textTheme.displayMedium,
//           ),
//           const SizedBox(height: 20),
//           Row(
//           children: [
//             Expanded(
//                 child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Counter Printer',
//                   style: theme.textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 8),
//                 Obx(() {
//                   return CustomSearchTextField(
//                     hintText: controller.counterPrinter.value.isEmpty
//                         ? "Select Counter Printer"
//                         : controller.counterPrinter.value,
//                     dropDownList: List.generate(
//                         controller.availablePrinters.length, (index) {
//                       return DropDownValueModel(
//                         value: controller.availablePrinters[index].name,
//                         name: controller.availablePrinters[index].name,
//                       );
//                     }),
//                     onChanged: (value) {
//                       controller.onChangeCounterPrinter(value);
//                     },
//                   );
//                 }),
//               ],
//             )),
//             const SizedBox(width: 12),
//             Expanded(
//                 child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Kitchen Printer',
//                   style: theme.textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 8),
//                 Obx(() {
//                   return CustomSearchTextField(
//                     hintText: controller.kitchenPrinter.value.isEmpty
//                         ? "Select Kitchen Printer"
//                         : controller.kitchenPrinter.value,
//                     dropDownList: List.generate(
//                         controller.availablePrinters.length, (index) {
//                       return DropDownValueModel(
//                         value: controller.availablePrinters[index].name,
//                         name: controller.availablePrinters[index].name,
//                       );
//                     }),
//                     onChanged: (value) {
//                       controller.onChangeKitchenPrinter(value);
//                     },
//                   );
//                 }),
//               ],
//             ))
//           ],
//         ),

//           //
//           const SizedBox(height: 22),
//           // Text(
//           //   'Print Settings',
//           //   style: theme.textTheme.displayMedium,
//           // ),
//           Row(
//             children: [
//               Expanded(
//                   child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Paper Width',
//                     style: theme.textTheme.titleLarge,
//                   ),
//                   const SizedBox(height: 8),
//                   Obx(() {
//                     return CustomSearchTextField(
//                       hintText: controller.selectedPaperWidth.value,
//                       dropDownList:
//                           List.generate(controller.paperWidth.length, (index) {
//                         return DropDownValueModel(
//                           value: controller.paperWidth[index],
//                           name: controller.paperWidth[index],
//                         );
//                       }),
//                       onChanged: (value) {
//                         controller.onChangePaperWidth(value);
//                       },
//                     );
//                   }),
//                 ],
//               )),
//               const SizedBox(width: 12),
//               const Expanded(child: SizedBox())
//             ],
//           ),
//           // olo print
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           'OLO Print',
//                           style: theme.textTheme.titleSmall,
//                         ),
//                       ),
//                       Obx(() {
//                         return Switch(
//                             value: controller.oloPrint.value,
//                             onChanged: controller.onOloPrint);
//                       })
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Expanded(child: SizedBox())
//             ],
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           'Delivery Order Print',
//                           style: theme.textTheme.titleSmall,
//                         ),
//                       ),
//                       Obx(() {
//                         return Switch(
//                             value: controller.deliveryOrderPrint.value,
//                             onChanged: controller.onDeliveryOrderPrint);
//                       })
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Expanded(child: SizedBox())
//             ],
//           ),
//         ],
//       );
//     });
//   }
// }
