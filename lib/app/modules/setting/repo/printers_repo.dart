// import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/services/models/printer_model.dart';
// import 'package:yogo_pos/app/utils/urls.dart';

// class PrintersRepo {
//   static Future<PrinterModel?> update(String id, PrinterModel printer) async {
//     try {
//       var res = await BaseController.to.apiService
//           .makePatchRequest("${URLS.printers}/$id", printer.toJson());
//       if (res.statusCode == 200 || res.statusCode == 201) {
//         return PrinterModel.fromJson(res.data["data"]);
//       } else {
//         return null;
//       }
//     } catch (e) {
//     return null;
//     }
//   }
// }
