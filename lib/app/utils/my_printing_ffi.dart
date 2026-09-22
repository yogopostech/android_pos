// import 'package:flutter/foundation.dart';
// import 'package:printing_ffi/printing_ffi.dart';

// class MyPrintingFfi {
//   static final MyPrintingFfi _instance = MyPrintingFfi._internal();
//   factory MyPrintingFfi() => _instance;
//   MyPrintingFfi._internal();

//   final PrintingFfi _printingFfi = PrintingFfi.instance;

//   Future<bool> rawDataToPrinter({
//     required Uint8List data,
//     required String printerName,
//     String? docName,
//   }) async {
//     try {
//       final printers = _printingFfi.listPrinters();
//       final printer = printers.firstWhere(
//         (p) => p.name == printerName && p.isAvailable,
//         orElse: () => throw Exception('Printer not found: $printerName'),
//       );

//       if (!printer.isAvailable) {
//         throw Exception('Printer is not available: $printerName');
//       }

//       return await _printingFfi.rawDataToPrinter(
//         printerName,
//         data,
//         docName:docName?? "Print Receipt",
//       );
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
