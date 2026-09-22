// import 'package:flutter/material.dart';
// import 'package:yogo_pos/app/services/controller/config_controller.dart';
// import 'package:yogo_pos/app/services/models/printer_model.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';

// class PrinterCard extends StatelessWidget {
//   final PrinterModel printer;
//   final VoidCallback? onTap;

//   const PrinterCard({
//     super.key,
//     required this.printer,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Card(
//       elevation: 2,
//       color: ConfigController.to.isLightTheme
//           ? theme.cardColor
//           : StaticColors.cartColor,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Printer Icon
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: StaticColors.blueColor,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   Icons.print_outlined,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),

//               const SizedBox(width: 16),

//               // Printer Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Printer Name
//                     Text(
//                       "${printer.name} ${printer.printerType == "POS" ? "" : "(${printer.printerType})"}",
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),

//                     const SizedBox(height: 6),

//                     // Connection Info
//                     Row(
//                       children: [
//                         Icon(
//                           _getConnectionIcon(),
//                           size: 16,
//                           color: StaticColors.blueColor,
//                         ),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Text(
//                             printer.printerConnection,
//                             style: theme.textTheme.bodyMedium?.copyWith(
//                               color: colorScheme.onSurfaceVariant,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Default Badge
//               if (printer.isCounterPrinter)
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: StaticColors.blueColor,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.star,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   IconData _getConnectionIcon() {
//     switch (printer.printerConnection.toLowerCase()) {
//       case 'network':
//         return Icons.wifi_outlined;
//       case 'usb':
//         return Icons.usb_outlined;
//       case 'bluetooth':
//         return Icons.bluetooth_outlined;
//       default:
//         return Icons.cable_outlined;
//     }
//   }

// }
