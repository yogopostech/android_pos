import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/esc_order_print_receipt.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/widgets/print/kitchen_print.dart';
import 'package:yogo_pos/app/modules/pos/order/models/order_model.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/print_utils.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';

// monerisDialog({
//   PurchaseDialogStatus? status,
//   String? message,
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
//             child: MonerisDialog(
//               status: status ?? PurchaseDialogStatus.processing,
//               message: message ?? "",
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// enum PurchaseDialogStatus {
//   processing,
//   success,
//   error,
// }

// class MonerisDialog extends StatefulWidget {
//   final PurchaseDialogStatus status;
//   final String message;
//   const MonerisDialog({
//     super.key,
//     required this.status,
//     required this.message,
//   });

//   @override
//   State<MonerisDialog> createState() => _MonerisDialogState();
// }

// class _MonerisDialogState extends State<MonerisDialog> {
//   @override
//   initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {});
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
//             child: IconButton(
//                 onPressed: () {
//                   Get.back();
//                 },
//                 icon: const Icon(Icons.close)),
//           ),
//         ),
//         //icon area

//         if (widget.status == PurchaseDialogStatus.processing)
//           SizedBox(
//             width: size,
//             height: size,
//             child: SpinKitFadingCircle(
//               color:
//                   ConfigController.to.isLightTheme ? Colors.grey : Colors.white,
//               size: size - 40,
//             ),
//           ),
//         if (widget.status == PurchaseDialogStatus.error)
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
//         if (widget.status == PurchaseDialogStatus.success)
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
//             (widget.message).toUpperCase(),
//             style: theme.textTheme.headlineMedium,
//             textAlign: TextAlign.center,
//             maxLines: 1,
//           ),
//         ),
//         SizedBox(
//           height: 16,
//         ),
//       ],
//     );
//   }
// }

monerisDialog({
  PurchaseDialogStatus? status,
  String? message,
  OrderModel? order,
}) {
  return showDialog<void>(
    context: Get.context!,
    barrierDismissible: false,
    builder: (BuildContext context) {
      ThemeData theme = Theme.of(context);

      return Center(
        child: SizedBox(
          // height: height,
          width: status == PurchaseDialogStatus.success && order != null
              ? 550
              : 450,
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
            child: MonerisDialog(
              status: status ?? PurchaseDialogStatus.processing,
              message: message ?? "",
              order: order,
            ),
          ),
        ),
      );
    },
  );
}

enum PurchaseDialogStatus { processing, success, error }

class MonerisDialog extends StatefulWidget {
  final PurchaseDialogStatus status;
  final OrderModel? order;
  final String message;
  const MonerisDialog({
    super.key,
    required this.status,
    required this.message,
    this.order,
  });

  @override
  State<MonerisDialog> createState() => _MonerisDialogState();
}

class _MonerisDialogState extends State<MonerisDialog> {
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double size = 250;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //title area
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, right: 10),
            child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.close, size: 25),
            ),
          ),
        ),

        //icon area
        if (widget.status == PurchaseDialogStatus.processing)
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
        if (widget.status == PurchaseDialogStatus.error)
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
        if (widget.status == PurchaseDialogStatus.success)
          SizedBox(
            width: size,
            height: size - 100,
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
            (widget.message).toUpperCase(),
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ),
        Visibility(
          visible:
              widget.status == PurchaseDialogStatus.success &&
              widget.order != null,
          child: SizedBox(
            height: 110,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryBtn(
                  onPressed: () {
                    if (widget.order == null) return;
                    kitchenPrint(widget.order!);
                    Get.back();
                  },
                  text: "Print Kitchen",
                  color: StaticColors.blueColor,
                  width: 120,
                  height: 80,
                  textMinSize: 18,
                  textMaxSize: 20,
                ).marginOnly(right: 10),
                PrimaryBtn(
                  onPressed: () {
                    if (widget.order == null) return;
                    _counterPrint(widget.order!);
                    Get.back();
                  },
                  text: "Customer Print",
                  color: StaticColors.blueColor,
                  width: 120,
                  height: 80,
                  textMinSize: 18,
                  textMaxSize: 20,
                ).marginOnly(right: 10),
                PrimaryBtn(
                  onPressed: () {
                    if (widget.order == null) return;
                    kitchenPrint(widget.order!);
                    _counterPrint(widget.order!);
                    Get.back();
                  },
                  text: "Print Both",
                  color: StaticColors.blueColor,
                  width: 120,
                  height: 80,
                  textMinSize: 18,
                  textMaxSize: 20,
                ).marginOnly(right: 10),
                PrimaryBtn(
                  onPressed: () {
                    Get.back();
                  },
                  text: "Skip Print",
                  color: StaticColors.blueColor,
                  width: 120,
                  height: 80,
                  textMinSize: 18,
                  textMaxSize: 20,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

_counterPrint(OrderModel order) async {
  String printerName = Preferences.counterPrinter;
  if (printerName.isNotEmpty) {
    PopupDialog.showSuccessDialog("Check Sent");
    await PrintUtils().directPrint(
      data: escOrderPrintReceipt(order: order),
      printer: printerName,
    );
  } else {
    PopupDialog.showErrorMessage("You need to select printer first");
  }
}
