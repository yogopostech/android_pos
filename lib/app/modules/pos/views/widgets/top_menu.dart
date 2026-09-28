import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yogo_pos/config/screen_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yogo_pos/app/helper/data_update_helper.dart';
import 'package:yogo_pos/app/modules/auth/controllers/auth_controller.dart';
import 'package:yogo_pos/app/modules/clockIn/providers/clock_in_out.dart';
import 'package:yogo_pos/app/modules/clockIn/widgets/clock_in_dialog.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/delivery/controllers/delivery_controller.dart';
import 'package:yogo_pos/app/modules/pos/onlineOrder/controllers/online_order_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/controllers/order_controller.dart';
import 'package:yogo_pos/app/modules/pos/order/widgets/dialogs/cash_out_dialog.dart';
import 'package:yogo_pos/app/modules/pos/repo/pos_repo.dart';
import 'package:yogo_pos/app/routes/app_pages.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/int_extensions.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:yogo_pos/app/widgets/date_time_picker_dialog.dart';
import 'package:yogo_pos/app/widgets/popup_dialogs.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/widgets/search_check_dialog.dart';
import 'package:yogo_pos/main.dart';

class TopMenu extends GetView<PosController> {
  final double paddingLeft;
  const TopMenu({this.paddingLeft = 0, super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final double width = 110.r;
    final double height = 90.r;
    final double txtMaxSize = 33.sp.roundToDouble();
    final double txtMinSize = 20.sp.roundToDouble();
    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          //row 1
          SizedBox(height: 12.r),
          Container(
            padding: EdgeInsets.only(right: 16.r, left: 16.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // GetBuilder<PosController>(
                //   builder: (c) {
                //     return Visibility(
                //       visible: c.pageController.page == 0,
                //       replacement: SizedBox.shrink(),
                //       child: PrimaryBtnWithChild(
                //         color: StaticColors.blueColor,
                //         padding: const EdgeInsets.symmetric(
                //           horizontal: 14,
                //           vertical: 20,
                //         ),
                //         child: Text(
                //           'Customer Search',
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 16,
                //             fontWeight: FontWeight.w600,
                //           ),
                //         ),
                //         onPressed: () {
                //           showOrderSearchDialog(
                //             context,
                //             isCallerMode: false,
                //             search: c.guestPhoneController.text,
                //           );
                //         },
                //       ),
                //     );
                //   },
                // ),
                GetBuilder<PosController>(
                  builder: (c) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PrimaryBtnWithChild(
                          width: 48.rMin(kMinTouch),
                          height: 48.rMin(kMinTouch),
                          padding: EdgeInsets.zero,
                          color: StaticColors.blueColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 23.r,
                              ),
                            ],
                          ),
                          onPressed: () async {
                            await DataUpdateHelper.allGetApiCall();
                            PosController.to.update();
                            PosController.to.orderTypeList =
                                PosRepo.getOrderType();
                            PosController.to.clearCartList();
                          },
                        ),
                        SizedBox(width: 18.r),
                        //setting button
                        PrimaryBtnWithChild(
                          width: 48.rMin(kMinTouch),
                          height: 48.rMin(kMinTouch),
                          padding: EdgeInsets.zero,
                          textColor: Colors.white,
                          color: StaticColors.blueColor,
                          child: Icon(
                            Icons.settings,
                            size: 25.r,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            PopupDialog.permissionDialogWithAccessPin(
                              title: "Settings?",
                              onSubmit: () {
                                Get.back();
                                Get.toNamed(Routes.SETTING);
                              },
                            );
                          },
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final clockedIn = ref.watch(isClockedInProvider);
                            return Visibility(
                              visible:
                                  (BaseController
                                          .to
                                          .restaurantDetails
                                          ?.employeeClockInOut ??
                                      false) &&
                                  (BaseController
                                          .to
                                          .employeeData
                                          ?.allowClockInOut ??
                                      false),
                              child: Row(
                                children: [
                                  SizedBox(width: 18.r),
                                  PrimaryBtn(
                                    width: 100.rMin(80),
                                    onPressed: () async {
                                      PopupDialog.customDialog2(
                                        barrierDismissible: false,
                                        width: 550,
                                        child: const ClockInDialog(),
                                      );
                                    },
                                    text: clockedIn
                                        ? 'Clock Out'
                                        : 'Clock In'.toUpperCase(),
                                    textColor: Colors.white,
                                    color: clockedIn
                                        ? StaticColors.orangeColor
                                        : StaticColors.greenColor,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        //clock in/out button
                        SizedBox(width: 18.r),
                        PrimaryBtn(
                          width: 100.rMin(80),
                          onPressed: () async {
                            AuthController.to.isShowSplashScreen.value = false;
                            Get.offAndToNamed(Routes.AUTH);

                            await providerContainer
                                .read(clockInOutProvider.notifier)
                                .clockOut();
                            Preferences.removeItem(Preferences.ACCESS_TOKEN);
                            Preferences.removeItem(Preferences.USER_INFO);
                            Get.delete<PosController>(force: true);
                            BaseController.to.employeeData = null;
                          },
                          text: 'Logout'.toUpperCase(),
                          textColor: Colors.white,
                          color: StaticColors.blueColor,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 12.r),
          //row 2
          GetBuilder<PosController>(
            builder: (c) {
              return Padding(
                padding: EdgeInsets.only(left: paddingLeft),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        c.onchangePage(0);
                        c.scrollHomePage();
                        c.searchController.clear();
                        c.categoryTypeActiveIndex = 0;
                        c.filterCategoriesByMainCategory();
                        PosController.to.isItemsShow = false;
                        if (c.orderType == "DINE_IN") {
                          c.onRemovePackagingCost();
                        } else {
                          c.onAddPackagingCost();
                        }
                      },
                      onDoubleTap: () {
                        c.onchangePage(0);
                        c.scrollHomePage();
                        c.searchController.clear();
                        c.categoryTypeActiveIndex = 0;
                        c.filterCategoriesByMainCategory();
                        c.isItemsShow = false;
                        if (c.orderType == "DINE_IN") {
                          c.onRemovePackagingCost();
                        } else {
                          c.onAddPackagingCost();
                        }
                        if (c.isUpdateView == true) {
                          c.isUpdateView = false;
                          c.selectedItemList.clear();
                          if (c.orderTypeList.isNotEmpty) {
                            c.onChangeOrderType(c.orderTypeList.first);
                          }
                          // PosController.to
                          //     .setOrderTypeIndex(controller.orderTypeList.first);
                          c.setTakeOutTypeIndexAndValue(
                            c.takeOutTypeList.first,
                          );
                          c.onEditableAllCartTextField();
                          c.clearCartList();
                          c.update();
                        }
                      },
                      child: Container(
                        width: height,
                        height: height,
                        decoration: BoxDecoration(
                          color: StaticColors.greenColor,
                          border: Border.all(
                            color: controller.pageController.page == 0
                                ? StaticColors.blueColor
                                : StaticColors.greenColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.home,
                          size: 28.r,
                          color: Colors.white,
                        ),
                      ),
                    ).marginOnly(right: 16.r),
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: ScrollBehavior().copyWith(overscroll: false),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Visibility(
                                visible:
                                    BaseController
                                        .to
                                        .restaurantDetails
                                        ?.restaurant
                                        .takeout ??
                                    false,
                                child: PrimaryBtn(
                                  width: width,
                                  height: height,
                                  onPressed: () {
                                    PosController.to.onchangePage(3);
                                    if (PosController.to.isUpdateView == true) {
                                      PosController.to.isUpdateView = false;
                                      PosController.to.selectedItemList.clear();
                                      if (controller.orderTypeList.isNotEmpty) {
                                        controller.onChangeOrderType(
                                          controller.orderTypeList.first,
                                        );
                                      }
                                      PosController.to
                                          .setTakeOutTypeIndexAndValue(
                                            controller.takeOutTypeList.first,
                                          );
                                      PosController.to
                                          .onEditableAllCartTextField();
                                      PosController.to.clearCartList();
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  color: StaticColors.greenColor,
                                  textColor: Colors.white,
                                  isOutline: true,
                                  borderColor:
                                      controller.pageController.page == 3
                                      ? StaticColors.blueColor
                                      : StaticColors.greenColor,
                                  borderWidth: 2,
                                  text: 'TAKEOUT',
                                  textMaxSize: txtMaxSize,
                                  textMinSize: txtMinSize,
                                ).marginOnly(right: 10.r),
                              ),
                              Visibility(
                                visible:
                                    BaseController
                                        .to
                                        .restaurantDetails
                                        ?.restaurant
                                        .dineIn ??
                                    false,
                                child: PrimaryBtn(
                                  width: width,
                                  height: height,
                                  onPressed: () {
                                    PosController.to.onchangePage(2);
                                    if (PosController.to.isUpdateView == true) {
                                      PosController.to.isUpdateView = false;
                                      PosController.to.selectedItemList.clear();
                                      if (controller.orderTypeList.isNotEmpty) {
                                        controller.onChangeOrderType(
                                          controller.orderTypeList.first,
                                        );
                                      }
                                      PosController.to
                                          .setTakeOutTypeIndexAndValue(
                                            controller.takeOutTypeList.first,
                                          );
                                      PosController.to
                                          .onEditableAllCartTextField();
                                      PosController.to.clearCartList();
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  color: StaticColors.greenColor,
                                  textColor: Colors.white,
                                  isOutline: true,
                                  borderColor:
                                      controller.pageController.page == 2
                                      ? StaticColors.blueColor
                                      : StaticColors.greenColor,
                                  borderWidth: 2,
                                  text: 'DINE-IN',
                                  textMaxSize: txtMaxSize,
                                  textMinSize: txtMinSize,
                                ).marginOnly(right: 10.r),
                              ),

                              // Visibility(
                              //   visible:
                              //       BaseController
                              //           .to
                              //           .restaurantDetails
                              //           ?.restaurant
                              //           .pickup ??
                              //       false,
                              //   child: GetBuilder<OnlineOrderController>(
                              //     builder: (c) {
                              //       return Badge(
                              //         isLabelVisible: c.unseenOrders == 0
                              //             ? false
                              //             : true,
                              //         label: Text(c.unseenOrders.toString()),
                              //         child: PrimaryBtn(
                              //           width: width,
                              //           height: height,
                              //           onPressed: () {
                              //             PosController.to.onchangePage(4);
                              //             if (PosController.to.isUpdateView ==
                              //                 true) {
                              //               PosController.to.isUpdateView =
                              //                   false;
                              //               PosController.to.selectedItemList
                              //                   .clear();
                              //               if (controller
                              //                   .orderTypeList
                              //                   .isNotEmpty) {
                              //                 controller.onChangeOrderType(
                              //                   controller.orderTypeList.first,
                              //                 );
                              //               }
                              //               PosController.to
                              //                   .setTakeOutTypeIndexAndValue(
                              //                     controller
                              //                         .takeOutTypeList
                              //                         .first,
                              //                   );
                              //               PosController.to
                              //                   .onEditableAllCartTextField();
                              //               PosController.to.clearCartList();
                              //             }
                              //             // Get.toNamed(Routes.ONLINE_ORDER);
                              //           },
                              //           color: StaticColors.greenColor,
                              //           textColor: Colors.white,
                              //           isOutline: true,
                              //           borderColor:
                              //               controller.pageController.page == 4
                              //               ? StaticColors.blueColor
                              //               : StaticColors.greenColor,
                              //           borderWidth: 2,
                              //           text: 'OLO',
                              //           textMaxSize: txtMaxSize,
                              //           textMinSize: txtMinSize,
                              //         ).marginOnly(right: 10),
                              //       );
                              //     },
                              //   ),
                              // ),
                              // Visibility(
                              //   visible:
                              //       BaseController
                              //           .to
                              //           .restaurantDetails
                              //           ?.restaurant
                              //           .posDelivery ??
                              //       false,
                              //   child: GetBuilder<DeliveryController>(
                              //     builder: (c) {
                              //       return Badge(
                              //         isLabelVisible: c.unseenOrders == 0
                              //             ? false
                              //             : true,
                              //         label: Text(c.unseenOrders.toString()),
                              //         child: PrimaryBtn(
                              //           width: width,
                              //           height: height,
                              //           onPressed: () {
                              //             PosController.to.onchangePage(5);
                              //             if (PosController.to.isUpdateView ==
                              //                 true) {
                              //               PosController.to.isUpdateView =
                              //                   false;
                              //               PosController.to.selectedItemList
                              //                   .clear();
                              //               if (controller
                              //                   .orderTypeList
                              //                   .isNotEmpty) {
                              //                 controller.onChangeOrderType(
                              //                   controller.orderTypeList.first,
                              //                 );
                              //               }
                              //               PosController.to
                              //                   .setTakeOutTypeIndexAndValue(
                              //                     controller
                              //                         .takeOutTypeList
                              //                         .first,
                              //                   );
                              //               PosController.to
                              //                   .onEditableAllCartTextField();
                              //               PosController.to.clearCartList();
                              //             }
                              //           },
                              //           padding: EdgeInsets.zero,
                              //           color: StaticColors.greenColor,
                              //           textColor: Colors.white,
                              //           isOutline: true,
                              //           borderColor:
                              //               controller.pageController.page == 5
                              //               ? StaticColors.blueColor
                              //               : StaticColors.greenColor,
                              //           borderWidth: 2,
                              //           text: 'DELIVERY',
                              //           textMaxSize: txtMaxSize,
                              //           textMinSize: txtMinSize,
                              //         ).marginOnly(right: 10),
                              //       );
                              //     },
                              //   ),
                              // ),
                              // Visibility(
                              //   visible:
                              //       BaseController
                              //           .to
                              //           .restaurantDetails
                              //           ?.restaurant
                              //           .posReservation ??
                              //       false,
                              //   child: GetBuilder<OnlineOrderController>(
                              //     builder: (c) {
                              //       return PrimaryBtn(
                              //         width: width,
                              //         height: height,
                              //         onPressed: () {
                              //           Get.toNamed(Routes.TABLE_RESERVATIONS);
                              //         },
                              //         color: StaticColors.greenColor,
                              //         textColor: Colors.white,
                              //         text: 'RESV.',
                              //         textMaxSize: txtMaxSize,
                              //         textMinSize: txtMinSize,
                              //       ).marginOnly(right: 10);
                              //     },
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
