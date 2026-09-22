// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';
// import 'package:yogo_pos/app/modules/product/dialogs/add_product_dialog.dart';
// import 'package:yogo_pos/app/modules/product/models/product_model.dart';
// import 'package:yogo_pos/app/widgets/appbar.dart';
// import 'package:yogo_pos/app/widgets/custom_btn.dart';
// import 'package:yogo_pos/app/widgets/custom_textfield.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

// import 'package:get/get.dart';

// import '../controllers/product_controller.dart';

// class ProductView extends GetView<ProductController> {
//   const ProductView({super.key});
//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     return Scaffold(
//         appBar: const CustomAppBar(
//           isPrimary: false,
//           title: Text("Restaurants Products"),
//         ),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 22, right: 22, top: 16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: PrimaryBtn(
//                       onPressed: () {
//                         PopupDialog.customDialog(
//                           width: Get.width - 300,
//                           child: const AddProductDialog(),
//                         );
//                       },
//                       text: "Add Product",
//                       textColor: Colors.white,
//                     ),
//                   ),
//                   const Expanded(flex: 2, child: SizedBox()),
//                   const Expanded(
//                     child: CustomTextField(
//                       // controller: controller.searchTEController,
//                       hintText: 'search ',
//                       maxLines: 1,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // table
//             SizedBox(
//               // SingleChildScrollView
//               // scrollDirection: Axis.horizontal,
//               child: SizedBox(
//                   // width: 1000,
//                   child: ClipRRect(
//                       borderRadius: BorderRadius.circular(0),
//                       child: Obx(() {
//                         return Table(
//                           columnWidths: const <int, TableColumnWidth>{
//                             0: FixedColumnWidth(100),
//                             // : const IntrinsicColumnWidth(),
//                             // 1: FlexColumnWidth(),
//                             1: FixedColumnWidth(300),
//                             // 2: FlexColumnWidth(),
//                             // 3: FlexColumnWidth(),
//                             // 4: FlexColumnWidth(),
//                             6: FixedColumnWidth(150),
//                           },
//                           defaultVerticalAlignment:
//                               TableCellVerticalAlignment.middle,
//                           children: <TableRow>[
//                             TableRow(
//                               // table decoration
//                               decoration:
//                                   BoxDecoration(color: theme.dividerColor),
//                               children: <Widget>[
//                                 Text(
//                                   'SL',
//                                   style: theme.textTheme.bodyLarge,
//                                 ).marginSymmetric(vertical: 23, horizontal: 13),
//                                 Text(
//                                   'Product Name',
//                                   style: theme.textTheme.bodyLarge,
//                                 ).marginAll(10),
//                                 Text(
//                                   'Selling Price',
//                                   style: theme.textTheme.bodyLarge,
//                                 ).marginAll(10),
//                                 Text(
//                                   'Total Sales',
//                                   style: theme.textTheme.bodyLarge,
//                                 ).marginAll(10),
//                                 Text(
//                                   'Stack',
//                                   style: theme.textTheme.bodyLarge,
//                                 ).marginAll(10),
//                                 Text(
//                                   'Status',
//                                   style: theme.textTheme.bodyLarge,
//                                 ).marginAll(10),
//                                 Text(
//                                   'Action',
//                                   style: theme.textTheme.bodyLarge,
//                                 ).marginAll(10),
//                               ],
//                             ),
//                             ...List.generate(controller.productList.length,
//                                 (index) {
//                               var product = controller.productList[index];
//                               return TableRow(
//                                 // table decoration
//                                 decoration: const BoxDecoration(
//                                     color: Colors.transparent),
//                                 children: <Widget>[
//                                   //sl
//                                   Text(
//                                     '${index + 1}',
//                                     style: theme.textTheme.bodyLarge,
//                                   ).marginSymmetric(
//                                       vertical: 23, horizontal: 13),
//                                   // price
//                                   Text(
//                                     product.name,
//                                     style: theme.textTheme.bodyLarge,
//                                   ).marginAll(10),
//                                   Text(
//                                     product.price.toStringAsFixed(2),
//                                     style: theme.textTheme.bodyLarge,
//                                   ).marginAll(10),
//                                   Text(
//                                     "",
//                                     style: theme.textTheme.bodyLarge,
//                                   ).marginAll(10),
//                                   Text(
//                                     'Longtitude',
//                                     style: theme.textTheme.bodyLarge,
//                                   ).marginAll(10),
//                                   // Dropdown Button
//                                   Align(
//                                     alignment: Alignment.bottomLeft,
//                                     child: Switch(
//                                             value: true, onChanged: (value) {})
//                                         .marginAll(10),
//                                   ),

//                                   Row(
//                                     children: [
//                                       IconButton(
//                                           onPressed: () {},
//                                           icon: const Icon(
//                                             Icons.edit,
//                                             color: Colors.blueAccent,
//                                           )),
//                                       const SizedBox(width: 10),
//                                       IconButton(
//                                           onPressed: () {},
//                                           icon: const Icon(
//                                             Icons.delete,
//                                             color: Colors.redAccent,
//                                           )),
//                                     ],
//                                   ).marginAll(10),
//                                 ],
//                               );
//                             })
//                           ],
//                         );
//                       })).marginOnly(left: 20, top: 30, right: 20, bottom: 50)),
//             )
//           ],
//         ));
//   }

//   // table row
//   List<TableRow> _tableRows(ThemeData theme, List<ProductModel> data) {
//     return List.generate(data.length, (index) {
//       var product = data[index];
//       return TableRow(
//         // table decoration
//         decoration: const BoxDecoration(color: Colors.transparent),
//         children: <Widget>[
//           Text(
//             '${index + 1}',
//             style: theme.textTheme.bodyLarge,
//           ).marginSymmetric(vertical: 23, horizontal: 13),
//           Text(
//             product.name,
//             style: theme.textTheme.bodyLarge,
//           ).marginAll(10),
//           Text(
//             product.description,
//             style: theme.textTheme.bodyLarge,
//           ).marginAll(10),
//           Text(
//             product.price.toStringAsFixed(2),
//             style: theme.textTheme.bodyLarge,
//           ).marginAll(10),
//           Text(
//             'Longtitude',
//             style: theme.textTheme.bodyLarge,
//           ).marginAll(10),
//           // Dropdown Button
//           Align(
//             alignment: Alignment.bottomLeft,
//             child: Switch(value: true, onChanged: (value) {}).marginAll(10),
//           ),

//           Row(
//             children: [
//               IconButton(
//                   onPressed: () {},
//                   icon: const Icon(
//                     Icons.edit,
//                     color: Colors.blueAccent,
//                   )),
//               IconButton(
//                   onPressed: () {},
//                   icon: const Icon(
//                     Icons.delete,
//                     color: Colors.redAccent,
//                   )),
//             ],
//           ).marginAll(10),
//         ],
//       );
//     });
//   }
// }
