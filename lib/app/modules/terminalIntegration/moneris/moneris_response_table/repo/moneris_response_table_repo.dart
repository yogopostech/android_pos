import 'package:yogo_pos/app/modules/terminalIntegration/moneris/moneris_response_table/models/moneris_response_model.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/urls.dart';

// import '../models/table_reservations_model.dart';

class MonerisResponseTableRepo {
  static Future<MonerisResponseModel?> getTableBooks({
    String? startDate,
    String? endDate,
    String? page,
    String? limit,
    String? search,
  }) async {
    Map<String, dynamic> queryParameters = {
      if (startDate != null) "startDate": startDate,
      if (endDate != null) "endDate": endDate,
      if (page != null) "page": page,
      if (limit != null) "limit": limit,
      if (search != null) "search": search,
    };

    try {
      var res = await BaseController.to.apiService
          .makeGetRequest(
            URLS.monerisPostBackURL,
            queryParameters: queryParameters,
          );

      if (res.statusCode == 200 && res.data != null) {
        // Directly parse the entire response into MonerisResponseModel
        return MonerisResponseModel.fromJson(res.data);
      } else {
        kLogger.e("Error: ${res.statusCode}, ${res.data}");
        return null;
      }
    } catch (e) {
      kLogger.e("Exception in getTableBooks: $e");
      return null;
    }
  }
}
