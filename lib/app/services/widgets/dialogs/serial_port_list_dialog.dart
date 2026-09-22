import 'package:flutter/material.dart';
import 'package:yogo_pos/app/services/base/preferences.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:get/get.dart';

class SerialPortListDialog extends StatefulWidget {
  const SerialPortListDialog({super.key});

  @override
  State<SerialPortListDialog> createState() => _SerialPortListDialogState();
}

class _SerialPortListDialogState extends State<SerialPortListDialog> {
  String selectWingScale = Preferences.wingScale;
  List<String> availablePorts = [];

  void initPorts() {
    // setState(() => availablePorts = SerialPort.availablePorts);
  }

  @override
  void initState() {
    initPorts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border.all(
        color: Theme.of(Get.context!).hintColor,
        width: 0.5,
      )),
      child: Column(
        children: [
          Text(
            'Select Weighing Scale',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ).marginOnly(bottom: 16),
          ...List.generate(availablePorts.length, (index) {
            String availablePort = availablePorts[index];
            return PrimaryBtn(
                maxLines: 1,
                width: 300,
                textColor: Colors.white,
                isOutline: true,
                borderColor: availablePort == selectWingScale
                    ? StaticColors.blueColor
                    : StaticColors.orangeColor,
                borderWidth: 2,
                onPressed: () {
                  Preferences.wingScale = availablePort;
                  selectWingScale = availablePort;
                  setState(() {});
                  Get.back();
                },
                text: availablePort);
          }),
          if (availablePorts.isEmpty) const Text("No Port Found")
        ],
      ),
    );
  }
}
