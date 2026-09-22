// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:yogo_pos/app/modules/pos/onlineOrder/controllers/online_order_controller.dart';
import 'package:yogo_pos/app/utils/extension/my_extension.dart';
import 'package:yogo_pos/app/utils/extension/string_manipulation_extension.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';
import 'package:yogo_pos/app/utils/my_func.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_textfield.dart';

import '../../order/models/order_model.dart';
import 'tabs/details_tab.dart';
import 'tabs/items_tab.dart';
import 'tabs/log_tab.dart';

class OnlineOrderDetails extends GetView<OnlineOrderController> {
  final OrderModel order;
  const OnlineOrderDetails(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header
        Row(
          children: [
            // id
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: StaticColors.orangeColor,
                  borderRadius: BorderRadius.circular(600)),
              child: Text(
                order.orderId,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            //time area
            Expanded(
                child: DefaultTabController(
              length: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(TextSpan(
                      text: "Est. Ready Time - ",
                      style: theme.textTheme.bodyLarge,
                      children: [
                        TextSpan(
                          text:
                              "${order.estimatedDate.toFormattedDate()}, ${order.estimatedTime}",
                          style: theme.textTheme.titleMedium,
                        )
                      ])),
                  Text(
                    'Last Updated ${order.updatedAt.daysDifferenceFromNow()}',
                    style: theme.textTheme.bodyMedium,
                  )
                ],
              ),
            ))
          ],
        ),
        // const Divider(
        //   height: 20,
        //   thickness: 1,
        // ),
        // // selector area
        // Text(
        //   'Change Order Status',
        //   style: theme.textTheme.labelLarge,
        // ),
        // CustomSearchTextField(
        //   hintText: order.orderStatus.toUpperCase(),
        //   onChanged: (value) async {
        //     if (value is DropDownValueModel) {
        //       if (value.value.toUpperCase() ==
        //               order.orderStatus.toUpperCase() ||
        //           order.paymentStatus == "PAID") {
        //         return;
        //       } else {
        //         var isUpdated = await controller.updateOrder(order.id,
        //             orderStatus: value.value);
        //         if (isUpdated) {
        //           if (value.value.toUpperCase() == "canceled".toUpperCase()) {
        //             kitchenPrint(order,
        //                 isCheckCanceled: true, isShowItems: false);
        //           }
        //         }
        //       }
        //     }
        //   },
        //   dropDownList: order.orderStatus == "CANCELED"
        //       ? []
        //       : [
        //           const DropDownValueModel(
        //               name: "COMPLETED", value: "COMPLETED"),
        //           const DropDownValueModel(name: "CANCELED", value: "CANCELED"),
        //         ],
        // ),

        12.height,
        Text(
          'Change Est. Date',
          style: theme.textTheme.labelLarge,
        ),
        CustomTextField(
          hintText: order.estimatedDate.toFormattedDate(),
          controller: controller.estDateController,
          marginBottom: 12,
          readOnly: true,
          onTap: () {
            showDatePicker(
              context: context,
              initialDate: order.estimatedDate,
              firstDate: DateTime(2010, 1),
              lastDate: DateTime(2050, 12),
            ).then((date) {
              if (date != null) {
                String myDate = DateFormat('yyyy-MM-dd').format(date);
                controller.estDateController.text = date.toFormattedDate();
                controller.updateOrder(order.id, estimatedDate: myDate);
              }
            });
          },
        ),
        Text(
          'Change Est. Time',
          style: theme.textTheme.labelLarge,
        ),
        CustomTextField(
          controller: controller.estTimeController,
          hintText: order.estimatedTime,
          // marginBottom: 12,
          readOnly: true,
          onTap: () {
            showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            ).then((time) {
              if (time != null) {
                String myTime = MyFunc().timeOfDayToString(time, context);
                controller.estTimeController.text = myTime;
                controller.updateOrder(order.id, estimatedTime: myTime);
              }

              // controller.startTime.text = time!.format(context);
            });
          },
        ),
        // Text(
        //   'Action',
        //   style: theme.textTheme.labelLarge,
        // ),
        // const CustomSearchTextField(hintText: "Action", dropDownList: [
        //   DropDownValueModel(name: "abc", value: "abc"),
        //   DropDownValueModel(name: "abc1", value: "abc1"),
        // ]),
        //timeline
        Center(
          child: SizedBox(
            height: 80,
            // width: double.infinity,
            child: Timeline.tileBuilder(
              shrinkWrap: true,
              theme: TimelineThemeData(
                direction: Axis.horizontal,
                nodePosition: 20,
                color: StaticColors.orangeColor,
                // indicatorTheme: const IndicatorThemeData(
                //   position: 0,
                //   size: 20,
                // ),
                // connectorTheme: const ConnectorThemeData(
                //   thickness: 2,
                // ),
              ),
              builder: TimelineTileBuilder.connectedFromStyle(
                connectionDirection: ConnectionDirection.before,
                // contentsAlign: ContentsAlign.reverse,
                oppositeContentsBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      controller.orderTypeForTimeLine[index].toCapitalize()),
                ),
                connectorStyleBuilder: (context, index) {
                  switch (order.orderStatus) {
                    case "CONFIRMED":
                      return index == 0
                          ? ConnectorStyle.solidLine
                          : ConnectorStyle.dashedLine;
                    case "COMPLETED":
                      return index == 0 || index == 1
                          ? ConnectorStyle.solidLine
                          : ConnectorStyle.dashedLine;
                    default:
                      return ConnectorStyle.dashedLine;
                  }
                },
                indicatorStyleBuilder: (context, index) {
                  switch (order.orderStatus) {
                    case "CONFIRMED":
                      return index == 0
                          ? IndicatorStyle.dot
                          : IndicatorStyle.outlined;
                    case "COMPLETED":
                      return index == 0 || index == 1
                          ? IndicatorStyle.dot
                          : IndicatorStyle.outlined;
                    default:
                      return IndicatorStyle.outlined;
                  }
                },
                itemCount: controller.orderTypeForTimeLine.length,
              ),
            ),
          ),
        ),
        12.height,
        // table header
        Container(
          decoration: BoxDecoration(
              color: theme.cardColor, borderRadius: BorderRadius.circular(0)),
          child: Row(
            children: List.generate(controller.tabs.length, (index) {
              return Expanded(
                child: GetBuilder<OnlineOrderController>(builder: (controller) {
                  return InkWell(
                    onTap: () {
                      controller.changeTabIndex(index);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: index == controller.selectedTabIndex
                                      ? StaticColors.orangeColor
                                      : Colors.transparent,
                                  width: 1))),
                      child: Text(
                        controller.tabs[index],
                        style: theme.textTheme.labelMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
        GetBuilder<OnlineOrderController>(
            builder: (OnlineOrderController controller) {
          switch (controller.selectedTabIndex) {
            case 0:
              return DetailsTab(order);
            case 1:
              return ItemsTab(order);
            case 2:
              return const LogTab();
            default:
              return DetailsTab(order);
          }
        }),
        12.height,
        // payment area
        // Visibility(
        //   visible: order.paymentStatus == "UNPAID" &&
        //       (order.orderStatus == "CONFIRMED" ||
        //           order.orderStatus == "COMPLETED"), //"confirmed", "completed"
        //   child: PrimaryBtn(
        //     onPressed: () {
        //       PosController.to.myOrder = order;
        //       // PosController.to.isEditableItems = false;
        //       PosController.to.selectedItemList.clear();
        //       Get.back();
        //       Get.to(() => const OrderDetailsView());

        //       // PopupDialog.customDialog(
        //       //     width: 600,
        //       //     child: PaymentMethodDialog(
        //       //       onSelectedPayment: (value) {
        //       //         Get.back();
        //       //         PopupDialog.customDialog(
        //       //             width: 700,
        //       //             child: PaymentDialog(
        //       //                 paymentMethod: value,
        //       //                 minPay: 13,
        //       //                 onPay: (value) async {},
        //       //                 onPayAndPrint: (value) async {}));
        //       //       },
        //       //     ));
        //     },
        //     text: "Update And Pay",
        //     textColor: Colors.white,
        //     color: StaticColors.greenColor,
        //     width: double.infinity,
        //   ),
        // ),
      ],
    );
  }
}
