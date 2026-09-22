import 'package:yogo_pos/app/modules/terminalIntegration/moneris/models/moneris_purchase_model.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:retry/retry.dart';

// class MonerisPostBackRepo {
//   static Future<MonerisPurchaseModel?> purchaseWithRetry({
//     required String id,
//     int maxRetries = 200,
//     Duration delay = const Duration(seconds: 2),
//   }) async {
//     final String url = "${URLS.monerisPostBackURL}/$id";

//     int attempt = 0;

//     while (attempt < maxRetries) {
//       try {
//         final response = await BaseController.to.apiService.makeGetRequest(url);
//         kLogger.e(
//             'Attempt $attempt: Status: ${response.statusCode}, Data: ${response.data}');
//         if (response.statusCode == 200 && response.data['data'] != null) {
//           final receiptJson = response.data["data"];
//           return MonerisPurchaseModel.fromJson(receiptJson);
//         }
//       } catch (e) {
//         kLogger.e('Attempt $attempt failed with error: $e');
//       }

//       attempt++;
//       if (attempt < maxRetries) {
//         await Future.delayed(delay); // now actually uses the parameter
//       }
//     }
//     kLogger.e("Max retries reached. No valid data received.");
//     return null;
//   }
// }

class MonerisPostBackRepo {
  static Future<MonerisPurchaseModel?> purchaseWithRetry({
    required String id,
    int maxAttempts = 300,
    Duration delay = const Duration(seconds: 2),
  }) async {
    final String url = "${URLS.monerisPostBackURL}/$id";

    final r = RetryOptions(
      maxAttempts: maxAttempts,
      delayFactor: delay,
      maxDelay: delay, // keeps delay constant (no exponential growth)
      randomizationFactor: 0, // no jitter
    );

    try {
      return await r.retry(
        () async {
          final response =
              await BaseController.to.apiService.makeGetRequest(url);
          kLogger.e('Status: ${response.statusCode}, Data: ${response.data}');

          if (response.statusCode == 200 && response.data['data'] != null) {
            return MonerisPurchaseModel.fromJson(response.data["data"]);
          }

          // Throw to trigger retry when data isn't ready yet
          throw Exception('Postback not received yet');
        },
        retryIf: (e) =>
            e is! FormatException, // retry everything except parse errors
      );
    } catch (e) {
      kLogger.e("Max retries reached. No valid data received.");
      return null;
    }
  }
}
