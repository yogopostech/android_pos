import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/clockIn/providers/clock_in_out.dart';
import 'package:yogo_pos/app/modules/pos/controllers/pos_controller.dart';
import 'package:yogo_pos/app/modules/pos/repo/pos_repo.dart';
import 'package:yogo_pos/app/routes/app_pages.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/appbar.dart';
import 'package:yogo_pos/app/widgets/title_bar.dart';
import '../../../widgets/custom_btn.dart';

class ClockInView extends ConsumerWidget {
  const ClockInView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          const TitleBar(),
          Expanded(
            child: Scaffold(
              appBar: CustomAppBar(
                preferredHeight: 80,
                hasButtonsRow: false,
                isLeading: false,
                hasHomeButton: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: PrimaryBtn(
                      onPressed: () async {
                        // for new clockin, clockIn(seconds: 0) will be called in the provider
                        ref.read(clockInOutProvider.notifier).clockIn();
                        Get.offAllNamed(Routes.POS);
                        await BaseController.to.getRestaurantsDetailsFromAPI();
                      
                        PosController.to.orderTypeList = PosRepo.getOrderType();
                        PosController.to.clearCartList();
                        PosController.to.isItemsShow = false;
                        if (PosController.to.orderTypeList.isNotEmpty) {
                          PosController.to.orderType =
                              PosController.to.orderTypeList.first;
                        }
                        PosController.to.onFocusGuestName();
                      },
                      height: 180,
                      width: 320,
                      textMaxSize: 32,
                      textMinSize: 24,
                      text: 'CLOCK IN',
                      color: StaticColors.greenColor,
                      style: Theme.of(
                        context,
                      ).textTheme.displayLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: PrimaryBtnWithChild(
                          width: 150,
                          height: 60,
                          color: StaticColors.blueColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "skip".toUpperCase(),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_circle_right,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          onPressed: () async {
                            Get.offAllNamed(Routes.POS);
                            await BaseController.to
                                .getRestaurantsDetailsFromAPI();
                          
                            PosController.to.orderTypeList =
                                PosRepo.getOrderType();
                            PosController.to.clearCartList();
                            PosController.to.isItemsShow = false;
                            if (PosController.to.orderTypeList.isNotEmpty) {
                              PosController.to.orderType =
                                  PosController.to.orderTypeList.first;
                            }
                            PosController.to.onFocusGuestName();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
