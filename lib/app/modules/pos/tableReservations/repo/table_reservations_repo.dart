import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/urls.dart';

import '../models/table_reservations_model.dart';

class TableReservationsRepo {
  static Future<TableReservationsModel?> getTableBooks({
    String? startDate,
    String? endDate,
    String? page,
    String? limit = "10",
  }) async {
    Map<String, dynamic>? queryParameters = {
      if (startDate != null) "startDate": startDate,
      if (endDate != null) "endDate": endDate,
      if (page != null) "page": page,
      if (limit != null) "limit": limit,
    };

    try {
      var res = await BaseController.to.apiService
          .makeGetRequest(URLS.tableBooks, queryParameters: queryParameters);

      if (res.statusCode == 200 && res.data != null) {
        return TableReservationsModel.fromJson(res.data);
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
