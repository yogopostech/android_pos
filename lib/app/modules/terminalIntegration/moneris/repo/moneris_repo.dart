import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/terminals_model.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/moneris/models/moneris_purchase_model.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/moneris/repo/moneris_post_back_repo.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

import '../../../pos/controllers/pos_controller.dart';

class MonerisRepo {
  // purchase
  static Future<void> purchase({
    required String orderId,
    required String totalAmount,
    required String terminalId,
    String? username,
    String? modifier,
    String? linkId,
  }) async {
    String url = PosController.to.terminals?.environment == MonerisEnv.prod
        ? URLS.monerisProdUtl
        : URLS.monerisTestUtl;
    String id = Uuid().v4();
    // Prepare the data to be sent
    Map<String, dynamic> data = {
      "apiVersion": "3.0",
      "apiToken": PosController.to.terminals?.apiToken,
      "storeId": PosController.to.terminals?.storeId,
      "istConfigCode": PosController.to.terminals?.istConfigCode,
      "polling": "true",
      "postBackUrl": "${URLS.monerisPostBackURL}/$id",
      "dataId": id,
      "dataTimestamp": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      "data": {
        "request": [
          {
            "orderId": orderId,
            "idempotencyKey": "${orderId}_purchase",
            "terminalId": terminalId,
            if (username != null) "username": username,
            // "modifier": "example modifier",//Optional
            // "linkId": "example_linkId",//Optional
            "action": "purchase",
            "totalAmount": totalAmount,
          },
        ],
      },
    };
    if (kDebugMode) {
      kLogger.d("URL => $url\nbody => $data");
    }
    // Call the API and return the response
    Dio dio = Dio();
    try {
      var res = await dio.post(url, data: data);
      if (kDebugMode) {
        kLogger.i("1st Response => ${res.data}");
      }

      if (res.statusCode == 200) {
        var fastRes = MonerisPurchaseModel.fromJson(res.data);
        if (fastRes.receipt.statusCode == "5201") {
          var res2 = await MonerisPostBackRepo.purchaseWithRetry(id: id);
          if (res2 != null) {
            if (res2.receipt.statusCode == "5207") {
              PopupDialog.showSuccessDialog(
                res2.receipt.data.response.first.status,
              );
              // order updated
              PosController.to.myOrder.payment = PaymentModel(
                cardPaidAmount:
                    (int.tryParse(
                          res2.receipt.data.response.first.totalAmount,
                        ) ??
                        0) /
                    100,
                cardTipAmount:
                    (int.tryParse(res2.receipt.data.response.first.tipAmount) ??
                        0) /
                    100,
                cardType: res2.receipt.data.response.first.cardName,
                transactionId: res2.receipt.data.response.first.transactionId,
                paymentIntent: res2.receipt.dataId,
                providerName: PosController.to.terminals?.deviceType ?? "",
              );
              PosController.to.myOrder.orderStatus = "COMPLETED";
              PosController.to.myOrder.paymentStatus = "PAID";
              PosController.to.calculateTotalPrice();

              bool isUpdated = await PosController.to.onUpdateOrder(
                PosController.to.myOrder.id,
              );

              if (isUpdated) {
                DataUpdateHelper.getDataByCheckType();
              }
            } else {
              PopupDialog.showErrorMessage(
                res2.receipt.data.response.first.status,
              );
            }
          } else {
            PopupDialog.showErrorMessage("Payment Failed");
          }
        } else {
          PopupDialog.showErrorMessage(
            fastRes.receipt.data.response.first.status,
          );
        }
      }

      // return null;
    } on DioException catch (e) {
      PopupDialog.showErrorMessage("Error: $e");
      kLogger.e(e);
      // return null;
    }
  }

  // refund
  static Future<void> refund({
    required String orderId,
    required String totalAmount,
    required String terminalId,
    required String transactionId,
    String? username,
    String? modifier,
    String? linkId,
  }) async {
    String url = PosController.to.terminals?.environment == MonerisEnv.prod
        ? URLS.monerisProdUtl
        : URLS.monerisTestUtl;
    String id = Uuid().v4();
    // Prepare the data to be sent
    Map<String, dynamic> data = {
      "apiVersion": "3.0",
      "apiToken": PosController.to.terminals?.apiToken,
      "storeId": PosController.to.terminals?.storeId,
      "istConfigCode": PosController.to.terminals?.istConfigCode,
      "polling": "true",
      "postBackUrl": "${URLS.monerisPostBackURL}/$id",
      "dataId": id,
      "dataTimestamp": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      "data": {
        "request": [
          {
            "orderId": orderId,
            "idempotencyKey": "${orderId}_refund",
            "terminalId": terminalId, //Optional
            if (username != null) "username": username, //Optional
            if (linkId != null) "linkId": linkId, //Optional
            "transactionId": transactionId, //Optional
            "action": "refund",
            "totalAmount": totalAmount,
          },
        ],
      },
    };
    if (kDebugMode) {
      kLogger.d("URL => $url\nbody => $data");
    }
    // Call the API and return the response
    Dio dio = Dio();
    try {
      var res = await dio.post(url, data: data);
      if (kDebugMode) {
        kLogger.i("1st Response => ${res.data}");
      }

      if (res.statusCode == 200) {
        var fastRes = MonerisPurchaseModel.fromJson(res.data);
        if (fastRes.receipt.statusCode == "5201") {
          var res2 = await MonerisPostBackRepo.purchaseWithRetry(id: id);
          if (res2 != null) {
            if (res2.receipt.statusCode == "5207") {
              PopupDialog.showSuccessDialog(
                res2.receipt.data.response.first.status,
              );
              // order updated
              bool isUpdated = await PosController.to.onUpdateOrderItems(
                PosController.to.myOrder.id,
                refund: true,
              );

              if (isUpdated) {
                DataUpdateHelper.getDataByCheckType();
              }
            } else {
              PopupDialog.showErrorMessage(
                res2.receipt.data.response.first.status,
              );
            }
          } else {
            PopupDialog.showErrorMessage("Payment Failed");
          }
        } else {
          PopupDialog.showErrorMessage(
            fastRes.receipt.data.response.first.status,
          );
        }
      }
    } on DioException catch (e) {
      PopupDialog.showErrorMessage("Error: $e");
      kLogger.e(e);
      // return null;
    }
  }

  // void
  static Future<void> voidRequest({
    required String orderId,
    required String terminalId,
    required String transactionId,
    // String? username,
    // String? modifier,
    // String? linkId,
  }) async {
    String url = PosController.to.terminals?.environment == MonerisEnv.prod
        ? URLS.monerisProdUtl
        : URLS.monerisTestUtl;
    String id = Uuid().v4();

    // Prepare the data to be sent
    Map<String, dynamic> data = {
      "apiVersion": "3.0",
      "apiToken": PosController.to.terminals?.apiToken,
      "storeId": PosController.to.terminals?.storeId,
      "istConfigCode": PosController.to.terminals?.istConfigCode,
      "polling": "true",
      "postBackUrl": "${URLS.monerisPostBackURL}/$id",
      "dataId": id,
      "dataTimestamp": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      "data": {
        "request": [
          {
            "orderId": orderId,
            "idempotencyKey": "${orderId}_void",
            "terminalId": terminalId,
            "transactionId": transactionId,
            "action": "void",
          },
        ],
      },
    };
    if (kDebugMode) {
      kLogger.d("URL => $url\nbody => $data");
    }
    // Call the API and return the response
    Dio dio = Dio();
    try {
      var res = await dio.post(url, data: data);
      if (kDebugMode) {
        kLogger.i("1st Response => ${res.data}");
      }

      if (res.statusCode == 200) {
        var fastRes = MonerisPurchaseModel.fromJson(res.data);
        if (fastRes.receipt.statusCode == "5201") {
          var res2 = await MonerisPostBackRepo.purchaseWithRetry(id: id);
          if (res2 != null) {
            if (res2.receipt.statusCode == "5207") {
              PopupDialog.showSuccessDialog(
                res2.receipt.data.response.first.status,
              );
              // order updated
              bool isUpdated = await PosController.to.onUpdateOrderItems(
                PosController.to.myOrder.id,
                isVoid: true,
              );

              if (isUpdated) {
                DataUpdateHelper.getDataByCheckType();
              }
            } else {
              PopupDialog.showErrorMessage(
                res2.receipt.data.response.first.status,
              );
            }
          } else {
            PopupDialog.showErrorMessage("Payment Failed");
          }
        } else {
          PopupDialog.showErrorMessage(
            fastRes.receipt.data.response.first.status,
          );
        }
      }
    } on DioException catch (e) {
      PopupDialog.showErrorMessage("Error: $e");
      kLogger.e(e);
      // return null;
    }
  }
}
