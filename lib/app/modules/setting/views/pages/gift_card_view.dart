import 'package:flutter/material.dart';
import '../../../../services/controller/config_controller.dart';
import '../../../../utils/static_colors.dart';
import '../../widgets/datacandy_screen.dart';

class GiftCardSettings extends StatefulWidget {
  const GiftCardSettings({super.key});

  @override
  State<GiftCardSettings> createState() => _GiftCardSettingsState();
}

class _GiftCardSettingsState extends State<GiftCardSettings> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Transparent TabBar section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              width: 500, // fixed width for both tabs
              child: TabBar(
                indicatorColor: StaticColors.blueColor,
                dividerColor: Colors.transparent,
                indicatorWeight: 1.5,
                isScrollable: false,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                labelColor: ConfigController.to.isLightTheme
                    ? Colors.black
                    : Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "DataCandy Gift Card"),
                  Tab(text: ""),
                ],
              ),
            ),
          ),

          // ✅ TabBarView (takes the rest of the height)
          Expanded(
            child: TabBarView(
              children: [
                UpdateDatCandyGiftCardView1(),
                Center(
                  child: Text(
                    "",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ConfigController.to.isLightTheme
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
