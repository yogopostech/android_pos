// // ignore_for_file: deprecated_member_use

// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:lottie/lottie.dart';
// import 'package:uuid/uuid.dart';
// import 'package:yogo_pos/app/helper/data_update_helper.dart';
// import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
// import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
// import 'package:yogo_pos/app/modules/terminalIntegration/moneris/models/moneris_purchase_model.dart';
// import 'package:yogo_pos/app/modules/terminalIntegration/moneris/repo/moneris_post_back_repo.dart';
// import 'package:yogo_pos/app/services/base/preferences.dart';
// import 'package:yogo_pos/app/services/controller/base_controller.dart';
// import 'package:yogo_pos/app/services/controller/config_controller.dart';
// import 'package:yogo_pos/app/utils/extension/id_formatter.dart';
// import 'package:yogo_pos/app/utils/logger.dart';
// import 'package:yogo_pos/app/utils/my_func.dart';
// import 'package:yogo_pos/app/utils/static_colors.dart';
// import 'package:yogo_pos/app/utils/urls.dart';

// monerisPurchaseDialog({
//   required String orderId,
//   required String totalAmount,
//   required String terminalId,
//   num cash = 0,
//   num cashTip = 0,
//   bool isPlaceOrder = false,
//   bool isCashAndCard = false,
//   bool isKitchenPrint = false,
//   String? username,
//   String? modifier,
//   String? linkId,
// }) {
//   return showDialog<void>(
//     context: Get.context!,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       ThemeData theme = Theme.of(context);

//       return Center(
//         child: SizedBox(
//           // height: height,
//           width: 450,
//           child: Material(
//             elevation: 3,
//             // dialog color
//             shadowColor: ConfigController.to.isLightTheme
//                 ? Colors.black12
//                 : const Color.fromARGB(255, 77, 76, 76),
//             // backgraund color
//             color: (ConfigController.to.isLightTheme
//                 ? theme.canvasColor
//                 : StaticColors.cartColor),
//             // border radius
//             borderRadius: BorderRadius.circular(6),

//             /// SpinningLines
//             child: _PurchaseDialogContent(
//               orderId: orderId,
//               totalAmount: totalAmount,
//               terminalId: terminalId,
//               isPlaceOrder: isPlaceOrder,
//               isKitchenPrint: isKitchenPrint,
//               username: username,
//               modifier: modifier,
//               linkId: linkId,
//               cash: cash,
//               cashTip: cashTip,
//               isCashAndCard: isCashAndCard,
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// class _PurchaseDialogContent extends StatefulWidget {
//   final String orderId;
//   final bool isPlaceOrder;
//   final bool isCashAndCard;
//   final bool isKitchenPrint;
//   final String totalAmount;
//   final String terminalId;
//   final num cash;
//   final num cashTip;
//   final String? username;
//   final String? modifier;
//   final String? linkId;
//   const _PurchaseDialogContent({
//     required this.orderId,
//     required this.totalAmount,
//     required this.terminalId,
//     required this.isPlaceOrder,
//     this.username,
//     this.modifier,
//     this.linkId,
//     required this.cashTip,
//     required this.cash,
//     required this.isCashAndCard,
//     required this.isKitchenPrint,
//   });

//   @override
//   State<_PurchaseDialogContent> createState() => __PurchaseDialogContentState();
// }

// enum PurchaseDialogStatus { processing, success, error }

// class __PurchaseDialogContentState extends State<_PurchaseDialogContent> {
//   PurchaseDialogStatus _status = PurchaseDialogStatus.processing;
//   String? _message;
//   bool _isShowCloseBtn = false;

//   onChangeStatusMsg(PurchaseDialogStatus status, {String? message}) {
//     setState(() {
//       _status = status;
//       _message = message;
//       _isShowCloseBtn = switch (status) {
//         PurchaseDialogStatus.processing => false,
//         PurchaseDialogStatus.success => true,
//         PurchaseDialogStatus.error => true,
//       };
//     });
//   }

//   Future<void> purchase() async {
//     String url = URLS.monerisUtl;
//     String id = Uuid().v4();
//     String resId = BaseController.to.restaurantDetails?.id ?? "id";
//     String monerisOrderId = MyFunc.generateId(IdFor.moneris).toFormattedId();
//     // Prepare the data to be sent
//     // if (PosController.to.terminals?.storeId == "mogo004010") {
//     //   print("ZZZZZ");
//     // } else {
//     //   print("XXXXX =>${PosController.to.terminals?.storeId}andmogo004010");
//     // }

//     Map<String, dynamic> data = {
//       "apiVersion": "3.0",
//       "apiToken": PosController.to.terminals?.apiToken,
//       "storeId": PosController.to.terminals?.storeId.trim(),
//       "istConfigCode": PosController.to.terminals?.istConfigCode,
//       "polling": "true",
//       "postBackUrl":
//           "${URLS.monerisPostBackURL}/${Preferences.stationId}/$resId/$id",
//       "dataId": id,
//       "dataTimestamp": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
//       "data": {
//         "request": [
//           {
//             "orderId": monerisOrderId,
//             "idempotencyKey": "${monerisOrderId}_purchase",
//             "terminalId": widget.terminalId,
//             if (widget.username != null) "username": widget.username,
//             // "modifier": "example modifier",//Optional
//             // "linkId": "example_linkId",//Optional
//             "action": "purchase",
//             "totalAmount": widget.totalAmount,
//           },
//         ],
//       },
//     };

//     debugPrint("URL => $url\nbody => $data");

//     // Call the API and return the response
//     Dio dio = Dio();
//     (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
//         (HttpClient client) {
//           client.badCertificateCallback =
//               (X509Certificate cert, String host, int port) => true;
//           return client;
//         };
//     try {
//       var res = await dio.post(url, data: data);

//       kLogger.i("1st Response => ${res.data}");

//       if (res.statusCode == 200) {
//         var fastRes = MonerisPurchaseModel.fromJson(res.data);
//         if (fastRes.receipt.statusCode == "5201") {
//           setState(() {
//             _message = "Processing Payment";
//           });

//           var res2 = await MonerisPostBackRepo.purchaseWithRetry(id: id);
//           if (res2 != null) {
//             if (res2.receipt.statusCode == "5207") {
//               onChangeStatusMsg(
//                 PurchaseDialogStatus.success,
//                 message: res2.receipt.data.response.first.status,
//               );
//               // PopupDialog.showSuccessDialog(
//               //     res2.receipt.data.response.first.status);
//               // order updated
//               if (widget.isCashAndCard) {
//                 PosController.to.myOrder.payment = PaymentModel(
//                   methods: ["CASH_AND_CARD"],
//                   cardPaidAmount:
//                       (int.tryParse(
//                             res2.receipt.data.response.first.totalAmount,
//                           ) ??
//                           0) /
//                       100,
//                   cardTipAmount:
//                       (int.tryParse(
//                             res2.receipt.data.response.first.tipAmount,
//                           ) ??
//                           0) /
//                       100,
//                   cashPaidAmount: widget.cash,
//                   cashTipAmount: widget.cashTip,
//                   cardType: res2.receipt.data.response.first.cardName,
//                   transactionId: res2.receipt.data.response.first.transactionId,
//                   maskedPan: res2.receipt.data.response.first.maskedPan,
//                   // entryMode: result.entryMode ?? "",
//                   paymentIntent: monerisOrderId,
//                   providerName: PosController.to.terminals?.deviceType ?? "",
//                 );
//               } else {
//                 PosController.to.myOrder.payment = PaymentModel(
//                   methods: [
//                     (res2.receipt.data.response.first.cardName.toUpperCase()),
//                   ],
//                   cardPaidAmount:
//                       (int.tryParse(
//                             res2.receipt.data.response.first.totalAmount,
//                           ) ??
//                           0) /
//                       100,
//                   cardTipAmount:
//                       (int.tryParse(
//                             res2.receipt.data.response.first.tipAmount,
//                           ) ??
//                           0) /
//                       100,
//                   cardType: res2.receipt.data.response.first.cardName,
//                   transactionId: res2.receipt.data.response.first.transactionId,
//                   maskedPan: res2.receipt.data.response.first.maskedPan,
//                   // entryMode: result.entryMode ?? "",
//                   paymentIntent: monerisOrderId,
//                   providerName: PosController.to.terminals?.deviceType ?? "",
//                 );
//               }
//               // PosController.to.myOrder.payment = PaymentModel(
//               //   methods: ["CARD"],
//               //   cardPaidAmount: (int.tryParse(
//               //               res2.receipt.data.response.first.totalAmount) ??
//               //           0) /
//               //       100,
//               //   cardTipAmount:
//               //       (int.tryParse(res2.receipt.data.response.first.tipAmount) ??
//               //               0) /
//               //           100,
//               //   cardType: res2.receipt.data.response.first.cardName,
//               //   transactionId: res2.receipt.data.response.first.transactionId,
//               //   paymentIntent: res2.receipt.dataId,
//               //   providerName: PosController.to.terminals?.deviceType ?? "",
//               // );
//               PosController.to.myOrder.orderStatus = "COMPLETED";
//               PosController.to.myOrder.paymentStatus = "PAID";
//               PosController.to.calculateTotalPrice();

//               if (widget.isPlaceOrder) {
//                 await PosController.to.onPlaseOrder(
//                   orderStatus: "COMPLETED",
//                   paymentStatus: "PAID",
//                   isPrint: widget.isKitchenPrint,
//                 );
//                 DataUpdateHelper.getDataByCheckType();
//               } else {
//                 bool isUpdated = await PosController.to.onUpdateOrder(
//                   PosController.to.myOrder.id,
//                 );

//                 if (isUpdated) {
//                   DataUpdateHelper.getDataByCheckType();
//                 }
//               }
//             } else if (res2.receipt.statusCode == "5202") {
//               // Duplicate request that is still in progress
//               onChangeStatusMsg(
//                 PurchaseDialogStatus.error,
//                 message: "Duplicate request that is still in progress",
//               );
//             } else if (res2.receipt.statusCode == "5903") {
//               // Duplicate request that is completed
//               onChangeStatusMsg(
//                 PurchaseDialogStatus.error,
//                 message: "Duplicate request that is completed",
//               );
//             } else {
//               onChangeStatusMsg(
//                 PurchaseDialogStatus.error,
//                 message: res2.receipt.data.response.first.status,
//               );
//             }
//           } else {
//             onChangeStatusMsg(
//               PurchaseDialogStatus.error,
//               message: "Payment Failed",
//             );
//           }
//         } else if (fastRes.receipt.statusCode == "5903") {
//           // Terminal is disconnected
//           onChangeStatusMsg(
//             PurchaseDialogStatus.error,
//             message: "Payment Terminal Offline",
//           );
//         } else if (fastRes.receipt.statusCode == "5202") {
//           // Duplicate request that is still in progress
//           onChangeStatusMsg(
//             PurchaseDialogStatus.error,
//             message: "Duplicate request that is still in progress",
//           );
//         } else if (fastRes.receipt.statusCode == "5903") {
//           // Duplicate request that is completed
//           onChangeStatusMsg(
//             PurchaseDialogStatus.error,
//             message: "Duplicate request that is completed",
//           );
//         } else {
//           onChangeStatusMsg(
//             PurchaseDialogStatus.error,
//             message: fastRes.receipt.data.response.first.status,
//           );
//         }
//       } else {
//         onChangeStatusMsg(
//           PurchaseDialogStatus.error,
//           message: "Payment Failed",
//         );
//       }

//       // return null;
//     } on DioException catch (e) {
//       // PopupDialog.showErrorMessage("Error: $e");
//       onChangeStatusMsg(PurchaseDialogStatus.error, message: "Payment Failed");
//       kLogger.e("Error from purchase => $e");
//       // return null;
//     }
//   }

//   @override
//   initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       purchase();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     double size = 250;
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         //title area
//         SizedBox(
//           height: 40,
//           child: Align(
//             alignment: Alignment.topRight,
//             child: Visibility(
//               visible: _isShowCloseBtn,
//               child: IconButton(
//                 onPressed: () {
//                   Get.back();
//                 },
//                 icon: const Icon(Icons.close),
//               ),
//             ),
//           ),
//         ),

//         //icon area
//         if (_status == PurchaseDialogStatus.processing)
//           SizedBox(
//             width: size,
//             height: size,
//             child: SpinKitFadingCircle(
//               color: ConfigController.to.isLightTheme
//                   ? Colors.grey
//                   : Colors.white,
//               size: size - 40,
//             ),
//           ),
//         if (_status == PurchaseDialogStatus.error)
//           SizedBox(
//             width: size,
//             height: size,
//             child: Lottie.asset(
//               'assets/animations/error_3.json',
//               repeat: false,
//               delegates: LottieDelegates(
//                 values: [
//                   ValueDelegate.color(
//                     const ['**'], // or use the specific layer name(s)
//                     value: StaticColors.redColor, // your desired color
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         if (_status == PurchaseDialogStatus.success)
//           SizedBox(
//             width: size,
//             height: size,
//             child: Lottie.asset(
//               'assets/animations/success.json',
//               repeat: false, // disables looping
//             ),
//           ),
//         // message area
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             // 'Processing Payment',
//             (_message ?? "Connecting to terminal").toUpperCase(),
//             style: theme.textTheme.headlineMedium,
//             maxLines: 1,
//           ),
//         ),
//         SizedBox(height: 16),
//       ],
//     );
//   }
// }

// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/models/payment_model.dart';
import 'package:yogo_pos/app/modules/pos/order/models/terminals_model.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/moneris/models/moneris_purchase_model.dart';
import 'package:yogo_pos/app/modules/terminalIntegration/moneris/repo/moneris_post_back_repo.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/extension/id_formatter.dart';
import 'package:yogo_pos/app/utils/logger.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

monerisPurchaseDialog({
  required String orderId,
  required String totalAmount,
  required String terminalId,
  num cash = 0,
  num cashTip = 0,
  bool isPlaceOrder = false,
  bool isCashAndCard = false,
  bool isKitchenPrint = false,
  String? username,
  String? modifier,
  String? linkId,
}) {
  return showDialog<void>(
    context: Get.context!,
    barrierDismissible: false,
    builder: (BuildContext context) {
      ThemeData theme = Theme.of(context);

      return Center(
        child: SizedBox(
          // height: height,
          width: 450,
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
            child: _PurchaseDialogContent(
              orderId: orderId,
              totalAmount: totalAmount,
              terminalId: terminalId,
              isPlaceOrder: isPlaceOrder,
              isKitchenPrint: isKitchenPrint,
              username: username,
              modifier: modifier,
              linkId: linkId,
              cash: cash,
              cashTip: cashTip,
              isCashAndCard: isCashAndCard,
            ),
          ),
        ),
      );
    },
  );
}

class _PurchaseDialogContent extends StatefulWidget {
  final String orderId;
  final bool isPlaceOrder;
  final bool isCashAndCard;
  final bool isKitchenPrint;
  final String totalAmount;
  final String terminalId;
  final num cash;
  final num cashTip;
  final String? username;
  final String? modifier;
  final String? linkId;
  const _PurchaseDialogContent({
    required this.orderId,
    required this.totalAmount,
    required this.terminalId,
    required this.isPlaceOrder,
    this.username,
    this.modifier,
    this.linkId,
    required this.cashTip,
    required this.cash,
    required this.isCashAndCard,
    required this.isKitchenPrint,
  });

  @override
  State<_PurchaseDialogContent> createState() => __PurchaseDialogContentState();
}

enum PurchaseDialogStatus { processing, success, error }

class __PurchaseDialogContentState extends State<_PurchaseDialogContent> {
  PurchaseDialogStatus _status = PurchaseDialogStatus.processing;
  String? _message;
  bool _isShowCloseBtn = false;

  onChangeStatusMsg(PurchaseDialogStatus status, {String? message}) {
    if (!mounted) return;
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

  Future<void> purchase() async {
    String url = PosController.to.terminals?.environment == MonerisEnv.prod
        ? URLS.monerisProdUtl
        : URLS.monerisTestUtl;
    String id = Uuid().v4();
    String resId = BaseController.to.restaurantDetails?.id ?? "id";
    String monerisOrderId = MyFunc.generateId(IdFor.moneris).toFormattedId();
    // Prepare the data to be sent
    // if (PosController.to.terminals?.storeId == "mogo004010") {
    //   print("ZZZZZ");
    // } else {
    //   print("XXXXX =>${PosController.to.terminals?.storeId}andmogo004010");
    // }

    Map<String, dynamic> data = {
      "apiVersion": "3.0",
      "apiToken": PosController.to.terminals?.apiToken,
      "storeId": PosController.to.terminals?.storeId.trim(),
      "istConfigCode": PosController.to.terminals?.istConfigCode,
      "polling": "true",
      "postBackUrl":
          "${URLS.monerisPostBackURL}/${Preferences.stationId}/$resId/$id",
      "dataId": id,
      "dataTimestamp": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      "data": {
        "request": [
          {
            "orderId": monerisOrderId,
            "idempotencyKey": "${monerisOrderId}_purchase",
            "terminalId": widget.terminalId,
            if (widget.username != null) "username": widget.username,
            // "modifier": "example modifier",//Optional
            // "linkId": "example_linkId",//Optional
            "action": "purchase",
            "totalAmount": widget.totalAmount,
          },
        ],
      },
    };

    debugPrint("URL => $url\nbody => $data");

    // Call the API and return the response
    Dio dio = Dio();
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };
    try {
      var res = await dio.post(url, data: data);

      kLogger.i("1st Response => ${res.data}");

      if (res.statusCode == 200) {
        var fastRes = MonerisPurchaseModel.fromJson(res.data);
        if (fastRes.receipt.statusCode == "5201") {
          // NOTE: mounted guard — dialog dispose hoye thakle setState skip,
          // kintu niche payment/order logic guard chara cholbe.
          if (mounted) {
            setState(() {
              _message = "Processing Payment";
            });
          }

          var res2 = await MonerisPostBackRepo.purchaseWithRetry(id: id);
          if (res2 != null) {
            if (res2.receipt.statusCode == "5207") {
              onChangeStatusMsg(
                PurchaseDialogStatus.success,
                message: res2.receipt.data.response.first.status,
              );
              // PopupDialog.showSuccessDialog(
              //     res2.receipt.data.response.first.status);
              // order updated
              if (widget.isCashAndCard) {
                PosController.to.myOrder.payment = PaymentModel(
                  methods: ["CASH_AND_CARD"],
                  cardPaidAmount:
                      (int.tryParse(
                            res2.receipt.data.response.first.totalAmount,
                          ) ??
                          0) /
                      100,
                  cardTipAmount:
                      (int.tryParse(
                            res2.receipt.data.response.first.tipAmount,
                          ) ??
                          0) /
                      100,
                  cashPaidAmount: widget.cash,
                  cashTipAmount: widget.cashTip,
                  cardType: res2.receipt.data.response.first.cardName,
                  transactionId: res2.receipt.data.response.first.transactionId,
                  maskedPan: res2.receipt.data.response.first.maskedPan,
                  // entryMode: result.entryMode ?? "",
                  paymentIntent: monerisOrderId,
                  providerName: PosController.to.terminals?.deviceType ?? "",
                );
              } else {
                PosController.to.myOrder.payment = PaymentModel(
                  methods: [
                    (res2.receipt.data.response.first.cardName.toUpperCase()),
                  ],
                  cardPaidAmount:
                      (int.tryParse(
                            res2.receipt.data.response.first.totalAmount,
                          ) ??
                          0) /
                      100,
                  cardTipAmount:
                      (int.tryParse(
                            res2.receipt.data.response.first.tipAmount,
                          ) ??
                          0) /
                      100,
                  cardType: res2.receipt.data.response.first.cardName,
                  transactionId: res2.receipt.data.response.first.transactionId,
                  maskedPan: res2.receipt.data.response.first.maskedPan,
                  // entryMode: result.entryMode ?? "",
                  paymentIntent: monerisOrderId,
                  providerName: PosController.to.terminals?.deviceType ?? "",
                );
              }
              // PosController.to.myOrder.payment = PaymentModel(
              //   methods: ["CARD"],
              //   cardPaidAmount: (int.tryParse(
              //               res2.receipt.data.response.first.totalAmount) ??
              //           0) /
              //       100,
              //   cardTipAmount:
              //       (int.tryParse(res2.receipt.data.response.first.tipAmount) ??
              //               0) /
              //           100,
              //   cardType: res2.receipt.data.response.first.cardName,
              //   transactionId: res2.receipt.data.response.first.transactionId,
              //   paymentIntent: res2.receipt.dataId,
              //   providerName: PosController.to.terminals?.deviceType ?? "",
              // );
              PosController.to.myOrder.orderStatus = "COMPLETED";
              PosController.to.myOrder.paymentStatus = "PAID";
              PosController.to.calculateTotalPrice();

              if (widget.isPlaceOrder) {
                await PosController.to.onPlaseOrder(
                  orderStatus: "COMPLETED",
                  paymentStatus: "PAID",
                  isPrint: widget.isKitchenPrint,
                  isDirectPay: false,
                );
                DataUpdateHelper.getDataByCheckType();
              } else {
                bool isUpdated = await PosController.to.onUpdateOrder(
                  PosController.to.myOrder.id,
                );

                if (isUpdated) {
                  DataUpdateHelper.getDataByCheckType();
                }
              }

              // Payment + order update sesh. Jodi dialog dispose hoye thake,
              // user ke toast diye janai (post-frame guarded helper).
              if (!mounted) {
                PopupDialog.showSuccessDialog("Payment successful");
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
            message: "Payment Terminal Offline",
          );
        } else if (fastRes.receipt.statusCode == "5202") {
          // Duplicate request that is still in progress
          onChangeStatusMsg(
            PurchaseDialogStatus.error,
            message: "Duplicate request that is still in progress",
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
      }

      // return null;
    } on DioException catch (e) {
      // PopupDialog.showErrorMessage("Error: $e");
      onChangeStatusMsg(PurchaseDialogStatus.error, message: "Payment Failed");
      kLogger.e("Error from purchase => $e");
      // return null;
    }
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      purchase();
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
            (_message ?? "Connecting to terminal").toUpperCase(),
            style: theme.textTheme.headlineMedium,
            maxLines: 1,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
