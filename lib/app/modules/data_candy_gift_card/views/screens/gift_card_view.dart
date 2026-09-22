import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/controller/gift_card_controller.dart';
import 'package:yogo_pos/app/modules/data_candy_gift_card/views/widgets/update_data_candy_gift_card_view.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/title_bar.dart';

class GiftCardScreen extends StatefulWidget {
  const GiftCardScreen({super.key});

  @override
  State<GiftCardScreen> createState() => _GiftCardScreenState();
}

class _GiftCardScreenState extends State<GiftCardScreen> {
  @override
  Widget build(BuildContext context) {
    // GiftCardController controller = Get.find<GiftCardController>();
    Get.put(GiftCardController());
    final theme = Theme.of(context);

    return DefaultTabController(

      length: 2,
      child: Scaffold(

        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: const TitleBar(),
          toolbarHeight: 30,
        ),
        body: SafeArea(
          child: Scaffold(
            // backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: ConfigController.to.isLightTheme
                  ? theme.cardColor
                  : StaticColors.cartColor,
              title: SizedBox(
                height: 40,
                width: 400,
                child: TabBar(
                  indicatorColor: StaticColors.blueColor,
                  dividerColor: Colors.transparent,
                  indicatorWeight: 1,
                  labelColor: ConfigController.to.isLightTheme
                      ? Colors.black
                      : Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    SizedBox(
                        width: 200, child: Tab(text: "DataCandy Gift Card"),),
                    SizedBox(
                        width: 200, child: Tab(text: ""),),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              children: [
                UpdateDatCandyGiftCardView(),
                Container(),
                // DataCandyGiftCardView(),
                // YogoPosGiftCardView(),

                //  const Center(
                //         child: Text(
                //           "Yogo POS Gift Card",
                //           style: TextStyle(
                //               fontSize: 28, fontWeight: FontWeight.bold),
                //         ),
                //       ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

