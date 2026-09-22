import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/pos/delivery/views/delivery_view.dart';
import 'package:yogo_pos/app/modules/pos/dine-in/views/dine_in_view.dart';
import 'package:yogo_pos/app/modules/pos/onlineOrder/views/online_order_view.dart';
import 'package:yogo_pos/app/modules/pos/order/views/order_view.dart';
import 'package:yogo_pos/app/modules/pos/dine-in-orders/views/dine_in_order_view.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/widgets/show_caller_order_split_dialog.dart';
import 'package:yogo_pos/app/widgets/title_bar.dart';

import '../controllers/pos_controller.dart';
import '../takeout/views/takeout_view.dart';

class PosView extends StatefulWidget {
  const PosView({super.key});

  @override
  State<PosView> createState() => _PosViewState();
}

class _PosViewState extends State<PosView> {
  @override
  void initState() {
    // _startTimer();
    Future.delayed(Duration(milliseconds: 1500), () {
      if (BaseController.to.hasNewCall) {
        showCallerOrderSplitDialog(Get.context!);
        BaseController.to.hasNewCall = false;
      }
    });
    super.initState();
  }
  //   void _startTimer() {
  //   _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
  //      DataUpdateHelper.allGetApiCall();
  //   });
  // }

  // _openCallerIdDialog() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TitleBar(),
          Expanded(
            child: PageView(
              controller: PosController.to.pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (value) {},
              children: const [
                // TableOrderPage(),
                OrderView(),
                DineInOrderView(),
                DineInView(),
                TakeOutView(),
                OnlineOrderView(),
                DeliveryView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
