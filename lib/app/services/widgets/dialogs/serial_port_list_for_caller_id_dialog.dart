import 'package:flutter/material.dart';
import 'package:yogo_pos/app/utils/static_colors.dart';
import 'package:yogo_pos/app/widgets/custom_btn.dart';
import 'package:get/get.dart';

class SerialPortListForCallerIdDialog extends StatefulWidget {
  final String selectPort;
  final String title;

  // Update the callback to accept a String parameter
  final void Function(String selectedPort) onPressed;

  const SerialPortListForCallerIdDialog({
    super.key,
    required this.selectPort,
    required this.onPressed,
    required this.title,
  });

  @override
  State<SerialPortListForCallerIdDialog> createState() =>
      _SerialPortListForCallerIdDialogState();
}

class _SerialPortListForCallerIdDialogState
    extends State<SerialPortListForCallerIdDialog> {
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
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.title,
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
              borderColor: availablePort == widget.selectPort
                  ? StaticColors.blueColor
                  : StaticColors.orangeColor,
              borderWidth: 2,
              onPressed: () {
                widget.onPressed(availablePort); // Pass selected port
              },
              text: availablePort,
            ).marginOnly(bottom: 8);
          }),
          if (availablePorts.isEmpty) const Text("No Port Found"),
        ],
      ),
    );
  }
}
