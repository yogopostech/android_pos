// import 'package:yogo_pos/app/utils/logger.dart';
// import '../../../services/base/base_model.dart';
// import '../../../services/controller/base_controller.dart';
// import '../../../utils/urls.dart';
// import '../models/add_product_model.dart';

// class ProductRepo {
//   ProductRepo._();

//   static Future<bool> addProduct(AddProductModel product) async {
//     try {
//       final BaseModel res = await BaseController.to.apiService.makePostRequest(
//         URLS.products,
//         addProductModelToJson(product),
//       );

//       if (res.statusCode == 200 || res.statusCode == 201) {
//         return true;
//       } else {
//         // showCustomSnackbar(message: res.data['message']);
//         kLogger.e('ERROR adding product: ${res.data['message']}');
//         return false;
//       }
//     } catch (e) {
//       // showCustomSnackbar(message: e.toString());
//       kLogger.e('ERROR adding product: $e');
//       return false;
//     }
//   }
// }
