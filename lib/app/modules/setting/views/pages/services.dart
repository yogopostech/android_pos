import 'package:flutter/material.dart';
import 'package:yogo_pos/app/modules/setting/controllers/servicees_controller.dart';
import 'package:yogo_pos/app/services/controller/config_controller.dart';
import 'package:get/get.dart';

class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  //  ServicesController controller = Get.find<ServicesController>();
  @override
  void initState() {
    super.initState();
    Get.put(ServicesController());
  }

  @override
  void dispose() {
    Get.delete<ServicesController>(); // Dispose from memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Modules", style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: ConfigController.to.isLightTheme
                  ? theme.cardColor
                  : Colors.white.withAlpha(51),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: ConfigController.to.isLightTheme
                          ? theme.cardColor
                          : Colors.white.withAlpha(51),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'OLO Takeout',
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                    GetBuilder<ServicesController>(
                      builder: (sc) {
                        return Switch(
                          value: sc.initOloTakeOut,
                          onChanged: (val) {
                            sc.onUpdateRestrurent(oloTakeOut: val);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'OLO Delivery',
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                    GetBuilder<ServicesController>(
                      builder: (sc) {
                        return Switch(
                          value: sc.initOloDelivery,
                          onChanged: (val) {
                            sc.onUpdateRestrurent(oloDelivery: val);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
