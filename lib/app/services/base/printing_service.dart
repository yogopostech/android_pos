// import 'dart:typed_data';

// import 'package:pdf/pdf.dart';
// import 'package:printing_ffi/printing_ffi.dart';
// import 'package:yogo_pos/app/modules/setting/controllers/printers_controller.dart';
// import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
// import 'package:pdf/widgets.dart' as pw;

// class PrintingService {
//   final _printer = PrintingFfi.instance;

//   Future<bool> openCashDrawer(String printerName) async {
//     final List<int> openDrawerCommand = [
//       0x1B,
//       0x70,
//       0x00,
//       0x19,
//       0xFA,
//     ];

//     final Uint8List data = Uint8List.fromList(openDrawerCommand);

//     try {
//       bool success = await _printer.rawDataToPrinter(
//         printerName,
//         data,
//         docName: 'open_cash_drawer',
//         options: [
//           OrientationOption(WindowsOrientation.portrait),
//         ],
//       );

//       if (success) {
//         PopupDialog.showSuccessDialog("Cash Drawer Opened");
//         return true;
//       } else {
//         PopupDialog.showErrorMessage("Error Opening Cash Drawer");
//         return false;
//       }
//     } catch (e) {
//       PopupDialog.showErrorMessage('Error Opening Cash Drawer: $e');
//       return false;
//     }
//   }

//   Future<bool> printReceipt(String printerName, pw.Widget child,
//       {String? docName, String? successMSG}) async {
//     // Define the PDF page
//     final pdf = pw.Document();
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat(
//             (PrintersController.to.selectedPaperWidth.value == "80mm"
//                     ? 70
//                     : 50) *
//                 PdfPageFormat.mm,
//             double.infinity),
//         build: (pw.Context context) {
//           return pw.Center(
//             child: child,
//           ); // Center
//         },
//       ),
//     );
//     try {
//       final pdfBytes = await pdf.save();
//       bool success = await _printer.rawDataToPrinter(
//         printerName,
//         pdfBytes,
//         docName: docName ?? 'receipt',
//         options: [
//           OrientationOption(WindowsOrientation.portrait),
//         ],
//       );

//       if (success) {
//         if (successMSG != null) {
//           PopupDialog.showSuccessDialog(successMSG);
//         }

//         return true;
//       } else {
//         PopupDialog.showErrorMessage('Failed to print receipt');
//         return false;
//       }
//     } catch (e) {
//       PopupDialog.showErrorMessage('Error printing receipt: $e');
//       return false;
//     }
//   }

//   Future<bool> testPrint(String printerName, String content) async {
//     final List<int> commands = [
//       0x1B, 0x40, // Initialize
//       0x1B, 0x61, 0x01, // Center
//       ...('TEST_RECEIPT\n').codeUnits,
//       0x1B, 0x61, 0x00, // Left
//       ...content.codeUnits,
//       0x1D, 0x56, 0x00, // Cut paper
//     ];

//     final Uint8List data = Uint8List.fromList(commands);

//     try {
//       bool success = await _printer.rawDataToPrinter(
//         printerName,
//         data,
//         docName: 'test_receipt',
//         options: [
//           OrientationOption(WindowsOrientation.portrait),
//         ],
//       );

//       if (success) {
//         PopupDialog.showSuccessDialog('Receipt printed successfully');
//         return true;
//       } else {
//         PopupDialog.showErrorMessage('Failed to print receipt');
//         return false;
//       }
//     } catch (e) {
//       PopupDialog.showErrorMessage('Error printing receipt: $e');
//       return false;
//     }
//   }

//   void dispose() {
//     _printer.dispose();
//   }
// }
