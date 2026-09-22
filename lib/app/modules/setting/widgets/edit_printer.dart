// import 'package:dropdown_textfield/dropdown_textfield.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:yogo_pos/app/services/models/printer_model.dart';
// import 'package:yogo_pos/app/utils/int_extensions.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';
// import 'package:yogo_pos/app/widgets/custom_btn.dart';
// import 'package:yogo_pos/app/widgets/custom_textfield.dart';

// import '../controllers/printers_controller.dart';


// class EditPrinter extends StatefulWidget {
//   final PrinterModel printerModel;
//   const EditPrinter({super.key, required this.printerModel});

//   @override
//   State<EditPrinter> createState() => _EditPrinterState();
// }

// class _EditPrinterState extends State<EditPrinter> {
//   final PrintersController controller = Get.find<PrintersController>();
//   late TextEditingController nameController;
//   late TextEditingController ipAddressController;
//   late TextEditingController portController;
//   late TextEditingController receiptsController;
//   late String printerTypeController;
//   late String printerConnectionController;
//   late bool isCounterPrinterController;
//   late bool isDefaultController;

//   @override
//   void initState() {
//     nameController = TextEditingController(text: widget.printerModel.name);
//     ipAddressController = TextEditingController(
//       text: widget.printerModel.ipAddress,
//     );
//     portController = TextEditingController(
//       text: widget.printerModel.port.toString(),
//     );
//     receiptsController = TextEditingController(
//       text: widget.printerModel.receipts.toString(),
//     );
//     printerTypeController = widget.printerModel.printerType;
//     printerConnectionController = widget.printerModel.printerConnection;
//     isCounterPrinterController = widget.printerModel.isCounterPrinter;
//     // printerTypeController = widget.printerModel.printerType;
//     // printerConnectionController = widget.printerModel.printerConnection;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         CustomTextField(
//           readOnly: true,
//           controller: nameController,
//           extraLabel: 'Printer Name',
//           onTap: () {},
//         ),
//         16.height,
//         // CustomTextField(
//         //   controller: ipAddressController,
//         //   extraLabel: 'Printer Connection',
//         //   keyboardType: TextInputType.text,
//         //   readOnly: true,
//         // ),
//         CustomSearchTextField(
//           hintText: printerConnectionController.isEmpty
//               ? "Select Printer"
//               : printerConnectionController,
//           dropDownList: List.generate(controller.availablePrinters.length, (
//             index,
//           ) {
//             return DropDownValueModel(
//               value: controller.availablePrinters[index].name,
//               name: controller.availablePrinters[index].name,
//             );
//           }),
//           onChanged: (value) {
//             if (value != null) {
//               if (value is DropDownValueModel) {
//                 printerConnectionController = value.name;
//               }
//             }
//             // controller.onChangeCounterPrinter(value);
//           },
//         ),
//         // 16.height,
//         // CustomTextField(
//         //   controller: ipAddressController,
//         //   extraLabel: 'IP Address',
//         // ),
//         // 16.height,
//         // CustomTextField(
//         //   controller: portController,
//         //   extraLabel: 'Port',
//         //   keyboardType: TextInputType.number,
//         // ),
//         // 16.height,
//         // CustomTextField(
//         //   controller: receiptsController,
//         //   extraLabel: 'Receipts',
//         //   keyboardType: TextInputType.number,
//         //   onTap: () {
//         //     if (Preferences.customKeyboard) {
//         //       CustomKeyboard.open(
//         //         keyboardType: KeyboardType.number,
//         //         initialValue: receiptsController.text,
//         //         regExp: RegExp(r'^[1-9]$'), // Allow only numbers from 1 to 9
//         //         onChange: (value) {
//         //           receiptsController.text = value;
//         //         },
//         //         onSubmit: () {
//         //           controller.updatePrinter(
//         //             widget.printerModel.id,
//         //             PrinterModel(
//         //               name: nameController.text,
//         //               printerConnection: printerConnectionController,
//         //               printerType: printerTypeController,
//         //               ipAddress: ipAddressController.text,
//         //               receipts: int.parse(receiptsController.text),
//         //               port: int.parse(portController.text),
//         //               isCounterPrinter: isCounterPrinterController,
//         //               isDefault: isDefaultController,
//         //               id: widget.printerModel.id,
//         //             ),
//         //           );
//         //           Get.back();
//         //         },
//         //       );
//         //     }
//         //   },
//         // ),
//         20.height,
//         SizedBox(
//           width: double.infinity,
//           child: PrimaryBtn(
//             color: StaticColors.greenColor,
//             textColor: Colors.white,
//             onPressed: () {
//               controller.updatePrinter(
//                 widget.printerModel.id,
//                 PrinterModel(
//                   name: nameController.text,
//                   printerConnection: printerConnectionController,
//                   printerType: printerTypeController,
//                   ipAddress: ipAddressController.text,
//                   receipts: int.parse(receiptsController.text),
//                   port: int.parse(portController.text),
//                   isCounterPrinter: isCounterPrinterController,
//                   id: widget.printerModel.id,
//                   priority: widget.printerModel.priority,
//                 ),
//               );
//             },
//             text: 'Save',
//           ),
//         ),

//         // Add more fields as needed
//       ],
//     );
//   }
// }
