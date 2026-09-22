import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/pos/views/widgets/top_menu.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';

import '../controllers/online_order_controller.dart';
import '../widgets/online_order_card.dart';

class OnlineOrderView extends GetView<OnlineOrderController> {
  const OnlineOrderView({super.key});
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 10),
        child: GetBuilder<OnlineOrderController>(builder: (controller) {
          return Column(
            children: [
              const TopMenu(),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //unpaid orders
                        Container(
                          width: 350,
                          margin: EdgeInsets.only(right: 60),
                          color: ConfigController.to.isLightTheme
                              ? theme.cardColor
                              : StaticColors.cartColor,
                          child: Column(
                            children: [
                              // header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                    color: controller.orderTypeColor[0],
                                    borderRadius: BorderRadius.circular(6)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Text(
                                      controller.orderType[0].toUpperCase(),
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(color: Colors.white),
                                    )),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(800)),
                                        child: Text(
                                          '${controller.unPaidOrders.length}',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                        )),
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: ListView.builder(
                                itemCount: controller.unPaidOrders.length,
                                itemBuilder: (_, index) {
                                  return OnlineOrderCard(
                                      controller.unPaidOrders[index]);
                                },
                              )),
                            ],
                          ),
                        )
                        //paid orders
                        ,
                        Container(
                          width: 350,
                          margin: EdgeInsets.only(right: 60),
                          color: ConfigController.to.isLightTheme
                              ? theme.cardColor
                              : StaticColors.cartColor,
                          child: Column(
                            children: [
                              // header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                    color: controller.orderTypeColor[1],
                                    borderRadius: BorderRadius.circular(6)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Text(
                                      controller.orderType[1].toUpperCase(),
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(color: Colors.white),
                                    )),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(800)),
                                        child: Text(
                                          '${controller.paidOrders.length}',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                        )),
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: ListView.builder(
                                itemCount: controller.paidOrders.length,
                                itemBuilder: (_, index) {
                                  return OnlineOrderCard(
                                      controller.paidOrders[index]);
                                },
                              )),
                            ],
                          ),
                        ),
                        // canceled orders
                        Container(
                          width: 350,
                          color: ConfigController.to.isLightTheme
                              ? theme.cardColor
                              : StaticColors.cartColor,
                          child: Column(
                            children: [
                              // header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                    color: controller.orderTypeColor[2],
                                    borderRadius: BorderRadius.circular(6)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Text(
                                      controller.orderType[2].toUpperCase(),
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(color: Colors.white),
                                    )),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(800)),
                                        child: Text(
                                          '${controller.canceledOrders.length}',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                        )),
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: ListView.builder(
                                itemCount: controller.canceledOrders.length,
                                itemBuilder: (_, index) {
                                  return OnlineOrderCard(
                                      controller.canceledOrders[index]);
                                },
                              )),
                            ],
                          ),
                        )
                      ]),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
