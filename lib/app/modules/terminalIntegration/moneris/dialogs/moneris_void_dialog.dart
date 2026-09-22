import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/controllers/split_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/terminals_model.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/moneris/models/moneris_purchase_model.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/moneris/repo/moneris_post_back_repo.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

monerisVoidDialog({
  required String orderId,
  required String terminalId,
  required String transactionId,
  bool? isSplitOrder,
  int? splitIndex,
}) {
  return showDialog<void>(
    context: Get.context!,
    barrierDismissible: false,
    builder: (BuildContext context) {
      ThemeData theme = Theme.of(context);

      return Center(
        child: SizedBox(
          // height: height,
          width: 400,
          child: Material(
            elevation: 3,
            // dialog color
            shadowColor: ConfigController.to.isLightTheme
                ? Colors.black12
                : const Color.fromARGB(255, 77, 76, 76),
            // backgraund color
            color: (ConfigController.to.isLightTheme
                ? theme.canvasColor
                : StaticColors.cartColor),
            // border radius
            borderRadius: BorderRadius.circular(6),

            /// SpinningLines
            child: _VoidDialogContent(
              orderId: orderId,
              terminalId: terminalId,
              transactionId: transactionId,
              isSplitOrder: isSplitOrder,
              splitIndex: splitIndex,
            ),
          ),
        ),
      );
    },
  );
}

class _VoidDialogContent extends StatefulWidget {
  final String orderId;
  final String transactionId;
  final String terminalId;
  final bool? isSplitOrder;
  final int? splitIndex;

  const _VoidDialogContent({
    required this.orderId,
    required this.transactionId,
    required this.terminalId,
    this.isSplitOrder,
    this.splitIndex,
  });

  @override
  State<_VoidDialogContent> createState() => __VoidDialogContentState();
}

enum PurchaseDialogStatus { processing, success, error }

class __VoidDialogContentState extends State<_VoidDialogContent> {
  PurchaseDialogStatus _status = PurchaseDialogStatus.processing;
  String? _message;
  bool _isShowCloseBtn = false;

  onChangeStatusMsg(PurchaseDialogStatus status, {String? message}) {
    setState(() {
      _status = status;
      _message = message;
      _isShowCloseBtn = switch (status) {
        PurchaseDialogStatus.processing => false,
        PurchaseDialogStatus.success => true,
        PurchaseDialogStatus.error => true,
      };
    });
  }

  Future<void> voidRequest() async {
    String url = PosController.to.terminals?.environment == MonerisEnv.prod
        ? URLS.monerisProdUtl
        : URLS.monerisTestUtl;
    String id = Uuid().v4();
    String resId = BaseController.to.restaurantDetails?.id ?? "id";

    // Prepare the data to be sent
    Map<String, dynamic> data = {
      "apiVersion": "3.0",
      "apiToken": PosController.to.terminals?.apiToken,
      "storeId": PosController.to.terminals?.storeId,
      "istConfigCode": PosController.to.terminals?.istConfigCode,
      "polling": "true",
      "postBackUrl":
          "${URLS.monerisPostBackURL}/${Preferences.stationId}/$resId/$id",
      "dataId": id,
      "dataTimestamp": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      "data": {
        "request": [
          {
            "orderId": widget.orderId,
            "idempotencyKey": "${widget.orderId}_void",
            "terminalId": widget.terminalId,
            "transactionId": widget.transactionId,
            // if (username != null) "username": username,
            // "modifier": "example modifier",//Optional
            // "linkId": "example_linkId",//Optional
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
          setState(() {
            _message = "Processing Request";
          });
          var res2 = await MonerisPostBackRepo.purchaseWithRetry(id: id);
          if (res2 != null) {
            if (res2.receipt.statusCode == "5207") {
              onChangeStatusMsg(
                PurchaseDialogStatus.success,
                message: res2.receipt.data.response.first.status,
              );
              // order updated
              // for normal order
              if (widget.isSplitOrder == null) {
                await PosController.to.onUpdateOrderItems(
                  PosController.to.myOrder.id,
                  isVoid: true,
                );
                DataUpdateHelper.getDataByCheckType();
              } else if (widget.isSplitOrder == true) {
                // for SplitOrder
                if (widget.splitIndex == null) {
                  PopupDialog.showErrorMessage('Split Index Is Missing');
                  return;
                }
                SplitOrderController
                        .to
                        .listOfSpitChecksByItems[widget.splitIndex ?? 0]
                        .isVoid =
                    true;
                SplitOrderController.to.update();
              } else {
                //for split amount
                if (widget.splitIndex == null) {
                  PopupDialog.showErrorMessage('Split Index Is Missing');
                  return;
                }
                SplitOrderController
                        .to
                        .splitAmountChecks
                        .splitAmounts[widget.splitIndex ?? 0]
                        .isVoid =
                    true;
                SplitOrderController.to.update();
              }
            } else if (res2.receipt.statusCode == "5202") {
              // Duplicate request that is still in progress
              onChangeStatusMsg(
                PurchaseDialogStatus.error,
                message: "Duplicate request that is still in progress",
              );
            } else if (res2.receipt.statusCode == "5903") {
              // Duplicate request that is completed
              onChangeStatusMsg(
                PurchaseDialogStatus.error,
                message: "Duplicate request that is completed",
              );
            } else {
              onChangeStatusMsg(
                PurchaseDialogStatus.error,
                message: res2.receipt.data.response.first.status,
              );
            }
          } else {
            onChangeStatusMsg(
              PurchaseDialogStatus.error,
              message: "Payment Failed",
            );
          }
        } else if (fastRes.receipt.statusCode == "5903") {
          // Terminal is disconnected
          onChangeStatusMsg(
            PurchaseDialogStatus.error,
            message: "Payment Terminal Disconnected",
          );
        } else if (fastRes.receipt.statusCode == "5202") {
          // Duplicate request that is still in progress
          onChangeStatusMsg(
            PurchaseDialogStatus.error,
            message: "Duplicate request that is still in progress",
          );
        } else if (fastRes.receipt.statusCode == "5903") {
          // Duplicate request that is completed
          onChangeStatusMsg(
            PurchaseDialogStatus.error,
            message: "Duplicate request that is completed",
          );
        } else {
          onChangeStatusMsg(
            PurchaseDialogStatus.error,
            message: fastRes.receipt.data.response.first.status,
          );
        }
      } else {
        onChangeStatusMsg(
          PurchaseDialogStatus.error,
          message: "Payment Failed",
        );
        kLogger.e("Error: ${res.statusMessage}");
      }
    } on DioException catch (e) {
      onChangeStatusMsg(PurchaseDialogStatus.error, message: "Error: $e");
      kLogger.e(e);
      // return null;
    }
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      voidRequest();
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double size = 250;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //title area
        SizedBox(
          height: 40,
          child: Align(
            alignment: Alignment.topRight,
            child: Visibility(
              visible: _isShowCloseBtn,
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ),
        //icon area

        if (_status == PurchaseDialogStatus.processing)
          SizedBox(
            width: size,
            height: size,
            child: SpinKitFadingCircle(
              color: ConfigController.to.isLightTheme
                  ? Colors.grey
                  : Colors.white,
              size: size - 40,
            ),
          ),
        if (_status == PurchaseDialogStatus.error)
          SizedBox(
            width: size,
            height: size,
            child: Lottie.asset(
              'assets/animations/error_3.json',
              repeat: false,
              delegates: LottieDelegates(
                values: [
                  ValueDelegate.color(
                    const ['**'], // or use the specific layer name(s)
                    value: StaticColors.redColor, // your desired color
                  ),
                ],
              ),
            ),
          ),
        if (_status == PurchaseDialogStatus.success)
          SizedBox(
            width: size,
            height: size,
            child: Lottie.asset(
              'assets/animations/success.json',
              repeat: false, // disables looping
            ),
          ),
        // message area
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            // 'Processing Payment',
            _message ?? "Connecting to terminal",
            style: theme.textTheme.headlineMedium,
            maxLines: 1,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
